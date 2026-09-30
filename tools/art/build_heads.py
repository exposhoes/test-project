"""Karakter kafalarını görünüm sayfalarından gerçek 3D biçimde üretir (görsel gövde / silüet oyma).

Önden, yandan ve arkadan kafa+saç silüetleri 3B ızgarada kesiştirilir, yumuşatılır ve
marching cubes ile yüzeye çevrilir. Her üçgen yönüne göre (ön/yan/arka) ilgili görselden
kaplanır. Çıktı: assets/textures/actors/<kod>_head.bin (float32: köşe sayısı, sonra her köşe
için konum xyz, normal xyz, uv) ve <kod>_head.png; <kod>_skin.json içindeki "head" parçasına
"mesh" ve "mouth" alanları eklenir. Actor.gd bu dosya varsa kafa kutusu yerine bunu kullanır.
Çalıştır: python3 tools/art/build_heads.py  (build_actor.py'den SONRA), ardından
godot --headless --path . --script res://tools/bake_heads.gd (.bin -> .res; oyun .res kullanır)."""
import json, os, struct
import numpy as np
from PIL import Image, ImageFilter
from scipy.ndimage import gaussian_filter, zoom
from skimage.measure import marching_cubes

SRC = os.path.join(os.path.dirname(__file__), "sources")
OUT = "assets/textures/actors/"
S = 1.8 / 620.0
RES = 50
## Küp kafalı tarzda saçı ayrı 3D parça yap (False: saç küpün yüzlerine çizili kalır — daha temiz).
HAIR_3D = False
CELL, PAD = 512, 24

# kod: (sayfa, önden kutu, yandan kutu, arkadan kutu, burun sağda mı)
HEADS = {
    "emir": ("emir2.png", (238, 298, 622, 686), (1030, 303, 1370, 686), (1779, 298, 2163, 686), True, 1.8 / 1220.0,
             {"front": (290, 399, 577, 686), "side": (1076, 399, 1364, 686)}),
    "ali": ("ali.png", (187, 106, 352, 280), (615, 104, 783, 280), (1037, 106, 1202, 280), False),
    "anne": ("anne.png", (183, 106, 358, 272), (612, 105, 788, 272), (1033, 106, 1208, 272), False),
    "zeynep": ("zeynep.png", (200, 98, 356, 306), (612, 98, 790, 306), (1016, 98, 1172, 306), False),
    "ogretmen": ("ogretmen.png", (200, 121, 356, 306), (614, 121, 790, 306), (1016, 121, 1172, 306), False),
    "doktor": ("doktor.png", (222, 100, 362, 256), (614, 100, 762, 256), (1015, 100, 1155, 256), True),
    "bakkal": ("bakkal.png", (212, 114, 355, 250), (623, 114, 764, 250), (1029, 114, 1172, 250), False),
}


def background(img, dark=28):
    """Kenardan bağlı siyah alan = arka plan (gözbebekleri gibi iç koyuluklar hariç)."""
    a = np.asarray(img.convert("RGB")).max(axis=2) < dark
    h, w = a.shape
    bg = np.zeros_like(a)
    stack = [(x, y) for x in range(w) for y in (0, h - 1)] + [(x, y) for y in range(h) for x in (0, w - 1)]
    while stack:
        x, y = stack.pop()
        if x < 0 or y < 0 or x >= w or y >= h or bg[y, x] or not a[y, x]:
            continue
        bg[y, x] = True
        stack += [(x + 1, y), (x - 1, y), (x, y + 1), (x, y - 1)]
    return bg


def filled(img, bg):
    """Arka plan piksellerini komşu renkle doldurur (kenarda siyah sızmasın)."""
    rgba = img.convert("RGBA")
    alpha = Image.fromarray(((~bg) * 255).astype(np.uint8)).filter(ImageFilter.MinFilter(3))
    rgba.putalpha(alpha)
    fill = None
    for r in (2, 6, 16, 40):
        b = rgba.filter(ImageFilter.GaussianBlur(r))
        fill = b if fill is None else Image.alpha_composite(b, fill)
    base = Image.new("RGBA", img.size, (90, 70, 60, 255))
    return Image.alpha_composite(Image.alpha_composite(base, fill), rgba).convert("RGB")


def mask_to(bg, shape_uv):
    """Silüeti (True = kafa) ızgara çözünürlüğüne indirger."""
    m = (~bg).astype(np.float32)
    return zoom(m, (shape_uv[0] / m.shape[0], shape_uv[1] / m.shape[1]), order=1) > 0.5


def build(code, sheet, fbox, sbox, bbox, nose_right, scale=None, cube=None):
    """cube: kafa küpünün önden/yandan piksel kutusu. Verilirse yalnızca küpün dışında kalan saç
    oyulur ve "hair" parçası olarak eklenir; küpün kendisi build_actor.py'deki keskin "head" kutusudur."""
    global S
    S = scale or 1.8 / 620.0
    im = Image.open(os.path.join(SRC, sheet)).convert("RGB")
    views = {k: im.crop(b) for k, b in (("front", fbox), ("side", sbox), ("back", bbox))}
    bgs = {k: background(v) for k, v in views.items()}
    W = (fbox[2] - fbox[0]) * S
    H = (fbox[3] - fbox[1]) * S
    D = (sbox[2] - sbox[0]) * S
    nx, ny, nz = RES, int(RES * H / W), int(RES * D / W)
    # silüetler: [y satırı, yatay]
    F = mask_to(bgs["front"], (ny, nx))
    Bk = mask_to(bgs["back"], (ny, nx))
    Sd = mask_to(bgs["side"], (ny, nz))
    # model koordinatı: x ön görselde sağdan sola (+X görselin solu), arka görselde soldan sağa;
    # z yan görselde burun solda ise soldan sağa -D/2..+D/2 (ön -Z).
    xi = np.arange(nx)
    occ = np.zeros((nx, ny, nz), np.float32)
    front_x = F[:, ::-1]           # indeks i -> x = -W/2 + (i+.5)/nx*W
    back_x = Bk                     # arka görselde soldan sağa x artar
    side_z = Sd if not nose_right else Sd[:, ::-1]
    occ = (front_x.T[:, :, None] & back_x.T[:, :, None] & side_z[None, :, :]).astype(np.float32)
    if cube:
        # küp bölgesini (1 hücre içeriden) çıkar; saç küpün üstünde ve çevresinde kalır
        fx0, fy0, fx1, fy1 = cube["front"]
        sz0, _, sz1, _ = cube["side"]
        gx = lambda px: (fbox[2] - px) / (fbox[2] - fbox[0]) * nx       # görsel sağı -X: indeks 0 = -X
        gy = lambda py: (py - fbox[1]) / (fbox[3] - fbox[1]) * ny
        gz = (lambda pz: (sbox[2] - pz) / (sbox[2] - sbox[0]) * nz) if nose_right else (lambda pz: (pz - sbox[0]) / (sbox[2] - sbox[0]) * nz)
        i0, i1 = sorted((gx(fx0), gx(fx1)))
        j0, j1 = gy(fy0), gy(fy1)
        k0, k1 = sorted((gz(sz0), gz(sz1)))
        occ[int(i0) + 1:int(np.ceil(i1)) - 1, int(j0) + 1:, int(k0) + 1:int(np.ceil(k1)) - 1] = 0
    occ = np.pad(occ, 2)
    occ = gaussian_filter(occ, 1.2 if cube else 1.6)
    verts, faces, normals, _ = marching_cubes(occ, 0.5)
    verts -= 2
    # ızgara -> dünya (y ekseni ters: satır 0 en üst)
    sx, sy, sz = W / nx, H / ny, D / nz
    P = np.stack([-W / 2 + (verts[:, 0] + 0.5) * sx,
                  H / 2 - (verts[:, 1] + 0.5) * sy,
                  -D / 2 + (verts[:, 2] + 0.5) * sz], axis=1)
    N = np.stack([-normals[:, 0] / sx, normals[:, 1] / sy, -normals[:, 2] / sz], axis=1)
    N = -N  # marching cubes normalleri içeri bakar (yüksek değer içeride)
    N[:, 1] *= -1  # y ekseni ters çevrildi
    N /= np.linalg.norm(N, axis=1, keepdims=True) + 1e-9
    # doku atlası: ön | yan | arka
    w = CELL + 2 * PAD
    atlas = Image.new("RGB", (3 * w, w))
    for i, k in enumerate(("front", "side", "back")):
        c = filled(views[k], bgs[k]).resize((CELL, CELL), Image.LANCZOS)
        atlas.paste(c.resize((w, w)), (i * w, 0))
        atlas.paste(c, (i * w + PAD, PAD))
    atlas.save(OUT + code + "_head.png")

    def uv(region, u, v):
        return ((region * w + PAD + u * CELL) / (3 * w), (PAD + v * CELL) / w)

    out = []
    for tri in faces:
        p = P[tri]
        fn = np.cross(p[1] - p[0], p[2] - p[0])
        c = p.mean(axis=0)
        ax = np.abs(fn)
        if ax[1] > max(ax[0], ax[2]) * 1.2:
            region = 0 if c[2] < 0 else 2  # tepe/alt: öndeki yarı ön, arkadaki yarı arka görselden
        elif ax[0] > ax[2]:
            region = 1
        else:
            region = 0 if fn[2] < 0 else 2
        for k in range(3):
            x, y, z = P[tri[k]]
            v = (H / 2 - y) / H
            if region == 0:
                u = (W / 2 - x) / W
            elif region == 2:
                u = (x + W / 2) / W
            else:
                u = (z + D / 2) / D if not nose_right else (D / 2 - z) / D
            u = min(max(u, 0.0), 1.0)
            v = min(max(v, 0.0), 1.0)
            out.append((*P[tri[k]], *N[tri[k]], *uv(region, u, v)))
    # marching cubes üçgen sırası: Godot'nun ön yüz yönüne çevir
    arr = np.array(out, np.float32).reshape(-1, 3, 8)[:, ::-1, :].reshape(-1, 8)
    with open(OUT + code + "_head.bin", "wb") as fh:
        fh.write(struct.pack("<f", float(len(arr))))
        fh.write(arr.astype("<f4").tobytes())
    # ağız: kafa ortasında, yüksekliğin %36 altında; oradaki en öndeki yüzey
    my = -0.36 * H
    near = P[(np.abs(P[:, 0]) < W * 0.08) & (np.abs(P[:, 1] - my) < H * 0.06)]
    mz = float(near[:, 2].min()) if len(near) else -D / 2
    # gözler: ön görseldeki iki göz akı (parlak, yuvarlakça bölge) — göz kırpma kapakları için
    from scipy.ndimage import label, find_objects
    fa = np.asarray(views["front"]).astype(int)
    hh, ww = fa.shape[:2]
    white = (fa.min(axis=2) > 200) & ~bgs["front"]
    lab, n = label(white)
    cands = []
    for idx, sl in enumerate(find_objects(lab), start=1):
        ys, xs = sl
        bh, bw = ys.stop - ys.start, xs.stop - xs.start
        area = (lab[sl] == idx).sum()
        cy_, cx_ = (ys.start + ys.stop) / 2 / hh, (xs.start + xs.stop) / 2 / ww
        if not (0.25 < cy_ < 0.85 and 0.12 < cx_ < 0.88):
            continue
        if not (ww * 0.02 < bw < ww * 0.3 and hh * 0.03 < bh < hh * 0.3 and 0.4 < bw / bh < 2.5):
            continue
        cands.append((area, cx_, cy_, bw / ww, bh / hh))
    cands.sort(reverse=True)
    pair = sorted(cands[:2], key=lambda c: c[1]) if len(cands) >= 2 else []
    eyes = []
    for _, u, v, bu, bv in pair:
        ex, ey = W / 2 - u * W, H / 2 - v * H
        nearp = P[(np.abs(P[:, 0] - ex) < W * 0.06) & (np.abs(P[:, 1] - ey) < H * 0.06)]
        ez = float(nearp[:, 2].min()) if len(nearp) else -D / 2
        eyes.append([round(ex, 4), round(ey, 4), round(ez - 0.003, 4), round(bu * W * 1.25, 4), round(bv * H * 1.3, 4)])
    cheek = fa[int(hh * 0.62):int(hh * 0.72), int(ww * 0.3):int(ww * 0.7)].reshape(-1, 3)
    cheek = cheek[cheek.mean(axis=1) > 120]
    skin = [int(c) for c in np.median(cheek, axis=0)] if len(cheek) else [240, 200, 160]
    js = OUT + code + "_skin.json"
    info = json.load(open(js))
    if cube:
        head = [p for p in info["parts"] if p["name"] == "head"][0]
        fx0, fy0, fx1, fy1 = cube["front"]
        sz0, _, sz1, _ = cube["side"]
        off_x = -(((fbox[0] + fbox[2]) / 2) - ((fx0 + fx1) / 2)) * S
        off_y = -(((fbox[1] + fbox[3]) / 2) - ((fy0 + fy1) / 2)) * S
        dz = ((sbox[0] + sbox[2]) / 2) - ((sz0 + sz1) / 2)
        off_z = (-dz if nose_right else dz) * S
        info["parts"] = [p for p in info["parts"] if p["name"] != "hair"]
        if HAIR_3D:
            info["parts"].append({"name": "hair", "mesh_res": code + "_head.res", "size": [W, H, D],
                                  "pos": [round(head["pos"][0] + off_x, 4), round(head["pos"][1] + off_y, 4), round(head["pos"][2] + off_z, 4)]})
        hs = head["size"]
        head.pop("mesh", None)
        head["mouth"] = [0.0, round(-0.30 * hs[1], 4), round(-hs[2] / 2 - 0.004, 4)]
        head["eyes"] = [[round(e[0] + off_x, 4), round(e[1] + off_y, 4), round(-hs[2] / 2 - 0.003, 4), e[3], e[4]] for e in eyes]
        head["skin"] = skin
        info["sharp"] = True  # keskin kutulu tarz: köşeler yuvarlatılmaz
        json.dump(info, open(js, "w"), indent=1)
        print(code, len(arr) // 3, "üçgen (saç)")
        return
    for part in info["parts"]:
        if part["name"] == "head":
            part["mesh"] = code + "_head.bin"
            part["mesh_texture"] = code + "_head.png"
            part["mouth"] = [0.0, round(my, 4), round(mz - 0.004, 4)]
            part["eyes"] = []  # eski (yuvarlak kenarlı) görsellerde göz tespiti güvenilir değil
            part["skin"] = skin
    json.dump(info, open(js, "w"), indent=1)
    print(code, len(arr) // 3, "üçgen")


for code, args in HEADS.items():
    build(code, *args)
