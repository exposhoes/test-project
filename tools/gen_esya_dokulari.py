# -*- coding: utf-8 -*-
"""
EmirCRAFT — eşya dokuları ve ön yüz görselleri üreticisi (prosedürel).

Amaç: yapay zeka görsel aracı olmadan da mobilyaların düz renkli görünmemesi.
Bu betik, kodun beklediği dosya adlarıyla PNG üretir; oyun bunları otomatik
yükler. Sonradan gerçek AI görseliyle aynı adla değiştirmek yeterlidir.

Üretilenler:
  assets/textures/esya/dokular/*.png   yüzey dokuları (1024x1024, döşenebilir)
  assets/textures/esya/dokular/kapi_ic.png

Ön yüz görselleri QuadMesh üzerine gerildiği için GERÇEK en-boy oranında
üretilirler (bkz. _face() ve çağrı yerleri: film_props.gd).

Çalıştırma:
  python tools/gen_esya_dokulari.py
"""

from __future__ import annotations

import os

import numpy as np
from PIL import Image, ImageDraw, ImageFilter
from scipy.ndimage import zoom

SIZE = 1024
ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
DOK = os.path.join(ROOT, "assets", "textures", "esya", "dokular")

# ---------------------------------------------------------------- yardimcilar


def _cell(rng, size, cy, cx):
    """(cy, cx) hucreli rastgele alani kareye, kenar ortusmasi (seamless) buyut."""
    g = rng.random((max(2, int(cy)), max(2, int(cx)))).astype(np.float32)
    z = zoom(g, (size / g.shape[0], size / g.shape[1]), order=3, mode="grid-wrap")
    return np.ascontiguousarray(z[:size, :size], dtype=np.float32)


def fbm(size, cy, cx, octaves, seed, gain=0.5):
    """Cok oktavli, kenar ortusmali gurultu. 0..1 araliginda."""
    rng = np.random.default_rng(seed)
    out = np.zeros((size, size), np.float32)
    amp, tot = 1.0, 0.0
    for o in range(octaves):
        f = 2.0**o
        out += amp * _cell(rng, size, cy * f, cx * f)
        tot += amp
        amp *= gain
    out /= tot
    lo, hi = float(out.min()), float(out.max())
    return (out - lo) / max(hi - lo, 1e-6)


def norm(a):
    lo, hi = float(a.min()), float(a.max())
    return (a - lo) / max(hi - lo, 1e-6)


def mix(a, b, t):
    """a/b renk (3,) veya (h,w,3); t 2B maske ya da 3B dizi ile eslenir."""
    a = np.asarray(a, np.float32)
    b = np.asarray(b, np.float32)
    t = np.asarray(t, np.float32)
    if a.ndim == 1:
        a = a.reshape((1, 1, -1))
    if b.ndim == 1:
        b = b.reshape((1, 1, -1))
    if t.ndim == 2:          # (h,w) maske -> (1,h,w)
        t = t[:, :, None]
    return a * (1.0 - t) + b * t


def to_img(rgb):
    return Image.fromarray(np.clip(rgb, 0, 255).astype(np.uint8), "RGB")


def save(img, name, folder=DOK, max_kb=700, palette=True, dither=False):
    """PNG yazar. Gurultulu yuzey dokulari 256 renkli palete indirilir
    (gorunur degismez, dosya 5-10 kat kuculur; Godot palet PNG'yi sorunsuz alir).
    Dither YOK: benekli dokuda bantlasmayi zaten gurultu gizler, dither ise
    dosyayi buyutuyor."""
    path = os.path.join(folder, name + ".png")
    out = img
    if palette and img.mode == "RGB":
        out = img.quantize(colors=256, method=Image.MEDIANCUT,
                           dither=Image.Dither.FLOYDSTEINBERG if dither else Image.Dither.NONE)
    out.save(path, "PNG", optimize=True)
    kb = os.path.getsize(path) / 1024.0
    if kb > max_kb:   # mobil surum/magaza icin gerekirse kucult
        w, h = img.size
        s = (max_kb / kb) ** 0.5 * 0.9
        small = img.filter(ImageFilter.GaussianBlur(0.5)).resize(
            (max(64, int(w * s)), max(64, int(h * s))), Image.LANCZOS)
        if palette:
            small = small.quantize(colors=256, method=Image.MEDIANCUT,
                                   dither=Image.Dither.FLOYDSTEINBERG if dither else Image.Dither.NONE)
        small.save(path, "PNG", optimize=True)
        img = small
        kb = os.path.getsize(path) / 1024.0
    print("  %-24s %-11s %6.0f KB" % (name + ".png", "%dx%d" % img.size, kb))
    return path


def grad_img(w, h, top, bottom):
    """Dikey yumusak gecis."""
    t = np.linspace(0.0, 1.0, h, dtype=np.float32)[:, None, None]
    top = np.asarray(top, np.float32)
    bottom = np.asarray(bottom, np.float32)
    arr = top * (1 - t) + bottom * t
    return to_img(np.repeat(arr, w, axis=1))


# ------------------------------------------------------------ yuzey dokulari


def tex_wood(name, base, dark, light, seed, rings=7.0, vertical=False, warp_amt=2.2):
    """Ahsap: damar cizgileri + ince tel tel dokular.
    vertical=True -> damar Y boyunca (kapi/panelde dogru olan budur),
    warp_amt kucultulunce cizgiler duzleşir."""
    s = SIZE
    warp = fbm(s, 2, 2, 3, seed)          # genis dalga
    yy, xx = np.mgrid[0:s, 0:s].astype(np.float32)
    if vertical:
        phase = (xx / s) * rings + (warp - 0.5) * warp_amt + (yy / s) * 0.35
        streak = fbm(s, 2, 220, 2, seed + 7)   # hizli X, yumusak Y
    else:
        phase = (yy / s) * rings + (warp - 0.5) * warp_amt + (xx / s) * 0.35
        streak = fbm(s, 220, 2, 2, seed + 7)   # ince, X boyunca uzanmis
    g = 0.5 + 0.5 * np.sin(2 * np.pi * phase)
    g = g**1.7                            # cizgi haline getir
    blotch = fbm(s, 3, 3, 3, seed + 19)   # genis renk oynakligi
    t = np.clip(g * 0.62 + streak * 0.20 + blotch * 0.18, 0, 1)
    col = mix(np.asarray(dark, np.float32), np.asarray(light, np.float32), t)
    col = col * (0.86 + 0.28 * norm(blotch))[..., None]
    return to_img(col)


def tex_lacquer(name, seed, tint=(246, 246, 244)):
    """Beyaz lake: neredeyse duz, cok hafif genis lekelilik + mikro doku."""
    s = SIZE
    soft = fbm(s, 2, 2, 2, seed)
    micro = fbm(s, 180, 180, 2, seed + 3)
    v = 1.0 + (soft - 0.5) * 0.030 + (micro - 0.5) * 0.018
    col = np.asarray(tint, np.float32) * v[..., None]
    return to_img(col)


def tex_granite(name, seed):
    """Gri benekli granit: siyah/beyaz kristaller + koyu damarlar."""
    s = SIZE
    base = np.zeros((s, s, 3), np.float32) + np.asarray((138, 138, 136), np.float32)
    vein = fbm(s, 3, 3, 3, seed)
    base *= (0.90 + 0.16 * vein)[..., None]
    img = to_img(base)
    d = ImageDraw.Draw(img, "RGBA")
    rng = np.random.default_rng(seed + 5)
    # kristaller — kenarlara tasacak sekilde cizilir (dokulabilir kalsin)
    for _ in range(5200):
        x, y = int(rng.integers(0, s)), int(rng.integers(0, s))
        r = int(rng.integers(1, 4))
        pick = rng.random()
        c = (34, 34, 36, 210) if pick < 0.42 else (
            (215, 215, 212, 190) if pick < 0.66 else ((92, 92, 90, 170) if pick < 0.85 else (168, 120, 96, 120))
        )
        for ox in (-s, 0, s):
            for oy in (-s, 0, s):
                d.ellipse([x + ox - r, y + oy - r, x + ox + r, y + oy + r], fill=c)
    img = img.filter(ImageFilter.GaussianBlur(0.4))
    return img


def tex_steel(name, seed):
    """Fircalanmis celik: yatay ince cizgiler + yatay yumusak metal bandi."""
    s = SIZE
    brush = fbm(s, 300, 2, 3, seed)        # hizli Y, yumusak X -> yatay cizgiler
    brush2 = fbm(s, 700, 2, 1, seed + 11)
    band = fbm(s, 2, 2, 2, seed + 23)
    v = 0.62 + 0.20 * band
    v = v + (brush - 0.5) * 0.16 + (brush2 - 0.5) * 0.09
    col = np.asarray((176, 181, 186), np.float32) * v[..., None]
    # cok hafif metalik sicaklık
    col[..., 2] *= 1.015
    col[..., 0] *= 0.995
    return to_img(col)


def tex_fabric(name, base, seed, wrinkle=0.10):
    """Kumas: gercek dokuma (birbirinin altina giren iplikler) + elyaf gurultusu."""
    s = SIZE
    n = 128                                # 1024/8 -> 8px iplik
    idx = np.arange(s)
    tx = (idx * n // s).astype(np.int32)
    f = ((idx * n) % s) / float(s)          # iplik ici 0..1
    prof = np.sin(np.pi * f)               # silindirik parlaklik
    warp = prof[None, :]                   # dikey iplikler (X boyunca degisir)
    weft = prof[:, None]                   # yatay iplikler
    over = ((tx[:, None] + tx[None, :]) % 2) == 0
    weave = np.where(over, warp, weft)
    rng = np.random.default_rng(seed)
    # iplik basina ton farki: X ve Y icin AYRI diziler. Tek dizi kullanilirsa
    # her satir ayni renge duser ve yatay bant olusur.
    tx_rng = 0.90 + 0.20 * rng.random(n)
    ty_rng = 0.90 + 0.20 * rng.random(n)
    tone = ty_rng[tx][:, None] * tx_rng[tx][None, :]
    tone = tone * np.where(over, 1.0, 0.97)
    fiber = fbm(s, 150, 150, 2, seed + 4)   # kaba lif; cok ince olursa dosya sisar
    soft = fbm(s, 5, 5, 2, seed + 9)                  # yumusak kivrim
    v = tone * (0.72 + 0.34 * weave) + (fiber - 0.5) * 0.07 + (soft - 0.5) * wrinkle
    col = np.asarray(base, np.float32) * v[..., None]
    return to_img(col).filter(ImageFilter.GaussianBlur(0.3))


def tex_tiles(name, seed, cols=4, grout=7, tile=(252, 252, 250), grout_c=(203, 206, 210)):
    """Beyaz kare fayans: ince acik gri derz, dosenebilir."""
    s = SIZE
    ts = s // cols
    rng = np.random.default_rng(seed)
    img = Image.new("RGB", (s, s), grout_c)
    d = ImageDraw.Draw(img)
    for gy in range(cols):
        for gx in range(cols):
            x0, y0 = gx * ts + grout // 2, gy * ts + grout // 2
            x1, y1 = x0 + ts - grout, y0 + ts - grout
            k = 0.965 + 0.035 * rng.random()   # fayans basina hafif ton farki
            c = tuple(int(v * k) for v in tile)
            d.rectangle([x0, y0, x1, y1], fill=c)
            # fayans ici yumusak parlama (ust kenar)
            gl = Image.new("L", (ts, ts), 0)
            ImageDraw.Draw(gl).ellipse([-ts * 0.3, -ts * 0.9, ts * 1.3, ts * 0.55], fill=26)
            gl = gl.filter(ImageFilter.GaussianBlur(ts * 0.14))
            img.paste(Image.new("RGB", (ts, ts), (255, 255, 255)), (x0, y0), gl)
    fine = fbm(s, 260, 260, 2, seed + 2)
    arr = np.asarray(img, np.float32) * (1.0 + (fine - 0.5) * 0.035)[..., None]
    return to_img(arr)


def tex_concrete(name, seed):
    """Parlatilmis beton: duz gri, hafif lekeler + ince agregat."""
    s = SIZE
    base = np.asarray((150, 150, 148), np.float32)
    stain = fbm(s, 2, 2, 3, seed)           # genis lekeler
    fine = fbm(s, 300, 300, 2, seed + 5)
    agg = fbm(s, 700, 700, 1, seed + 8)
    v = 1.0 + (stain - 0.5) * 0.20 + (fine - 0.5) * 0.10 + (agg - 0.5) * 0.06
    v = np.clip(v, 0.72, 1.24)
    col = base * v[..., None]
    return to_img(col)


# ------------------------------------------------------------- on yuz cizimi


def _steel_bar(d, x0, y0, x1, y1, r, light=(214, 218, 222), dark=(120, 126, 132)):
    """Yuvarlak kesitli celik cubuk (kulpu)."""
    d.rounded_rectangle([x0, y0, x1, y1], radius=r, fill=dark)
    d.rounded_rectangle([x0, y0, x1, y0 + (y1 - y0) * 0.52], radius=r, fill=light)
    d.line([x0 + r, y0 + r, x0 + r, y1 - r], fill=(236, 239, 242))


def _recess(img, box, depth=26, light=True):
    """Iceri gomulmus panel: ust/sol golge, alt/sag isik."""
    x0, y0, x1, y1 = box
    d = ImageDraw.Draw(img, "RGBA")
    if light:
        d.line([x0, y0, x1, y0], fill=(0, 0, 0, depth), width=3)      # ust golge
        d.line([x0, y0, x0, y1], fill=(0, 0, 0, depth), width=3)      # sol golge
        d.line([x0, y1, x1, y1], fill=(255, 255, 255, depth), width=3)  # alt isik
        d.line([x1, y0, x1, y1], fill=(255, 255, 255, depth), width=3)
    else:
        d.line([x0, y0, x1, y0], fill=(255, 255, 255, depth), width=3)
        d.line([x0, y1, x1, y1], fill=(0, 0, 0, depth), width=3)


def face_dolap_kapagi(w=1024, h=1024):
    """Mutfak alt dolap kapagi: beyaz shaker, ustte yatay celik kulp."""
    img = grad_img(w, h, (252, 252, 251), (238, 238, 236))
    m = int(w * 0.055)
    d = ImageDraw.Draw(img)
    # shaker cercevesi: 5 parca -> dis cerceve + ic panel
    d.rectangle([m, m, w - m, h - m], outline=(226, 226, 223), width=3)
    p = int(w * 0.135)
    _recess(img, [p, p, w - p, h - p], depth=58)
    inner = [p + 16, p + 16, w - p - 16, h - p - 16]
    d.rectangle(inner, fill=(240, 240, 238))
    _recess(img, inner, depth=26, light=False)
    # ustte yatay kulp
    bw = int(w * 0.42)
    bx = (w - bw) // 2
    by = int(h * 0.075)
    _steel_bar(d, bx, by, bx + bw, by + int(h * 0.030), int(h * 0.015))
    d.line([bx + 8, by + int(h * 0.038), bx + bw - 8, by + int(h * 0.038)],
           fill=(0, 0, 0, 40), width=3)
    return img


def face_ust_dolap(w=1024, h=592):
    """Mutfak ust dolap kapagi: duz beyaz, altta yatay celik kulp."""
    img = grad_img(w, h, (252, 252, 251), (240, 240, 238))
    d = ImageDraw.Draw(img)
    m = int(h * 0.07)
    d.rectangle([m, m, w - m, h - m], outline=(228, 228, 225), width=3)
    bw = int(w * 0.44)
    bx = (w - bw) // 2
    by = h - m - int(h * 0.20)
    _steel_bar(d, bx, by, bx + bw, by + int(h * 0.075), int(h * 0.036))
    return img


def face_cekmece(w=1024, h=368):
    """Cekmece onu: acik meşe, ortada yuvarlak ahsap kulp."""
    img = tex_wood("_tmp", (203, 166, 116), (168, 130, 84), (226, 196, 152), 4242,
                   rings=7.0, warp_amt=0.6).resize((w, h))
    d = ImageDraw.Draw(img, "RGBA")
    m = int(h * 0.10)
    _recess(img, [m, m, w - m, h - m], depth=30)
    cx, cy, r = w // 2, h // 2, int(h * 0.16)
    d.ellipse([cx - r, cy - r, cx + r, cy + r], fill=(96, 66, 42))
    d.ellipse([cx - r, cy - r, cx + r, cy + r], outline=(58, 38, 22), width=4)
    d.ellipse([cx - r * 0.62, cy - r * 0.72, cx + r * 0.30, cy - r * 0.05], fill=(132, 92, 58))
    return img


def face_gardirop(w=512, h=1024):
    """Gardirop kapagi: acik meşe, girintili panel, sagda yuvarlak kulp."""
    img = tex_wood("_tmp", (205, 168, 118), (170, 132, 86), (228, 198, 154), 777,
                   rings=9.0, vertical=True, warp_amt=0.7).resize((w, h))
    d = ImageDraw.Draw(img, "RGBA")
    m = int(w * 0.09)
    p = int(w * 0.20)
    _recess(img, [m, m, w - m, h - m], depth=30)
    _recess(img, [p, p, w - p, h - p], depth=38)
    d.rectangle([p + 10, p + 10, w - p - 10, h - p - 10], outline=(150, 116, 76), width=2)
    cx, cy, r = w - int(w * 0.13), h // 2, int(w * 0.055)
    d.ellipse([cx - r, cy - r, cx + r, cy + r], fill=(92, 64, 40))
    d.ellipse([cx - r, cy - r, cx + r, cy + r], outline=(56, 38, 22), width=3)
    d.ellipse([cx - r * 0.55, cy - r * 0.70, cx + r * 0.20, cy - r * 0.10], fill=(126, 88, 55))
    return img


def face_buzdolabi(w=512, h=1024):
    """Buzdolabi onu: ustte dondurucu, altta buzdolabi kapisi, solda ince kulplar."""
    img = Image.new("RGB", (w, h), (247, 247, 246))
    d = ImageDraw.Draw(img, "RGBA")
    split = int(h * 0.285)
    # ust dondurucu kapisi
    d.rectangle([0, 0, w, split - 3], fill=(250, 250, 249))
    # alt buzdolabi kapisi
    d.rectangle([0, split + 3, w, h], fill=(248, 248, 247))
    d.line([0, split, w, split], fill=(206, 208, 208), width=5)
    # yatay golgeler (kapiliari hafif iceri cek)
    d.rectangle([0, split - 12, w, split - 3], fill=(0, 0, 0, 16))
    # kenar vurgulari
    d.line([2, 2, w - 3, 2], fill=(255, 255, 255))
    d.line([w - 3, 2, w - 3, h - 3], fill=(212, 214, 214), width=3)
    # sol tarafta iki ince dikey celik kulp
    hw = int(w * 0.075)                                   # kalinlik
    hx = int(w * 0.20)
    _steel_bar_v(d, hx - hw, int(split * 0.20), hx + hw, int(split * 0.84))
    _steel_bar_v(d, hx - hw, int(split * 1.18), hx + hw, int(h * 0.92))
    # alt havalandirma izgarasi: girintili koyu serit + dikey slotlar
    gy0, gy1 = int(h * 0.945), int(h * 0.995)
    d.rectangle([int(w * 0.10), gy0, int(w * 0.90), gy1], fill=(214, 216, 217))
    for k in range(9):
        sx = int(w * 0.115) + k * int((w * 0.77) / 9)
        d.rectangle([sx, gy0 + 4, sx + int(w * 0.035), gy1 - 4], fill=(186, 190, 192))
    return img


def _steel_bar_v(d, x0, y0, x1, y1):
    """Dikey celik kulp: govde + sol tarafta isik, sagda yumusak golge."""
    r = (x1 - x0) // 2
    d.rounded_rectangle([x0, y0, x1, y1], radius=r, fill=(138, 144, 150))
    d.rounded_rectangle([x0, y0, x0 + (x1 - x0) * 0.62, y1], radius=int(r * 0.7), fill=(206, 211, 216))
    d.rounded_rectangle([x0 + 3, y0 + 4, x0 + int((x1 - x0) * 0.30), y1 - 4],
                        radius=int(r * 0.5), fill=(228, 232, 236))


def face_firin(w=1024, h=1024):
    """Ocak/firin onu: ustte 4 dugme, ortada kulp, altta koyu cam."""
    img = grad_img(w, h, (250, 250, 249), (236, 236, 234))
    d = ImageDraw.Draw(img, "RGBA")
    # kontrol paneli
    py = int(h * 0.155)
    d.rectangle([0, 0, w, py], fill=(243, 243, 242))
    d.line([0, py, w, py], fill=(220, 220, 218), width=3)
    for k in range(4):
        cx = int(w * (0.20 + k * 0.20))
        cy = py // 2
        r = int(w * 0.045)
        d.ellipse([cx - r, cy - r, cx + r, cy + r], fill=(238, 238, 236), outline=(186, 188, 188), width=3)
        d.ellipse([cx - r * 0.55, cy - r * 0.55, cx + r * 0.55, cy + r * 0.55], fill=(58, 60, 62))
        d.line([cx, cy, cx, cy - int(r * 0.75)], fill=(232, 232, 230), width=5)
    # kulp
    hy = int(h * 0.235)
    _steel_bar(d, int(w * 0.10), hy, int(w * 0.90), hy + int(h * 0.042), int(h * 0.020))
    # firin cami
    gx0, gy0, gx1, gy1 = int(w * 0.10), int(h * 0.33), int(w * 0.90), int(h * 0.86)
    d.rounded_rectangle([gx0 - 12, gy0 - 12, gx1 + 12, gy1 + 12], radius=18, fill=(226, 226, 224))
    d.rounded_rectangle([gx0, gy0, gx1, gy1], radius=10, fill=(32, 36, 40))
    gl = Image.new("L", (w, h), 0)
    ImageDraw.Draw(gl).polygon(
        [(gx0, gy1), (gx0 + (gx1 - gx0) * 0.45, gy0), (gx0 + (gx1 - gx0) * 0.72, gy0), (gx0 + (gx1 - gx0) * 0.25, gy1)],
        fill=54)
    gl = gl.filter(ImageFilter.GaussianBlur(24))
    img.paste(Image.new("RGB", (w, h), (150, 160, 172)), (0, 0), gl)
    # icerideki raf izleri
    d.line([gx0 + 20, gy0 + int((gy1 - gy0) * 0.42), gx1 - 20, gy0 + int((gy1 - gy0) * 0.42)], fill=(255, 255, 255, 18), width=4)
    d.line([gx0 + 20, gy0 + int((gy1 - gy0) * 0.70), gx1 - 20, gy0 + int((gy1 - gy0) * 0.70)], fill=(255, 255, 255, 12), width=4)
    # alt kapi + ayaklar hissi
    d.rectangle([0, int(h * 0.88), w, h], fill=(239, 239, 237))
    d.line([0, int(h * 0.88), w, int(h * 0.88)], fill=(216, 216, 214), width=3)
    return img


def face_ust_ocak(w=1024, h=1024):
    """Ocak ustu: tepeden gorunum, beyaz emaye, dort siyah gaz ocagi."""
    img = grad_img(w, h, (252, 252, 251), (238, 238, 236))
    d = ImageDraw.Draw(img, "RGBA")
    for p in [(0.29, 0.29), (0.71, 0.29), (0.29, 0.71), (0.71, 0.71)]:
        cx, cy = int(w * p[0]), int(h * p[1])
        r = int(w * 0.145)
        d.ellipse([cx - r, cy - r, cx + r, cy + r], fill=(28, 30, 32))
        d.ellipse([cx - r, cy - r, cx + r, cy + r], outline=(12, 12, 14), width=4)
        d.ellipse([cx - r * 0.46, cy - r * 0.46, cx + r * 0.46, cy + r * 0.46], fill=(44, 47, 50))
        # sacayak izleri
        for a in range(4):
            ang = a * np.pi / 4
            d.line([cx - r * 0.95 * np.cos(ang), cy - r * 0.95 * np.sin(ang),
                    cx + r * 0.95 * np.cos(ang), cy + r * 0.95 * np.sin(ang)],
                   fill=(150, 152, 154), width=7)
    return img


def face_tv(w=1024, h=544):
    """TV onu: ince siyah cerceve, ekranda cocuk cizgi filmi manzarasi."""
    img = grad_img(w, h, (30, 31, 34), (18, 19, 21))
    d = ImageDraw.Draw(img, "RGBA")
    b = int(min(w, h) * 0.016)                       # ince, esit cerceve
    sx0, sy0, sx1, sy1 = b, b, w - b, h - b
    sh = sy1 - sy0
    # govde
    d.rectangle([sx0, sy0, sx1, sy1], fill=(22, 23, 26))
    # ekran: gok
    scr = Image.new("RGB", (sx1 - sx0, sh), (120, 200, 245))
    sd = ImageDraw.Draw(scr)
    sw, shh = scr.size
    for i in range(shh):                       # dikey gok gecisi
        t = i / max(shh - 1, 1)
        sd.line([0, i, sw, i], fill=(int(120 + 40 * t), int(200 - 10 * t), int(245 - 20 * t)))
    sd.ellipse([sw * 0.74, shh * 0.10, sw * 0.74 + shh * 0.30, shh * 0.10 + shh * 0.30], fill=(255, 226, 96))
    sd.ellipse([sw * 0.76, shh * 0.12, sw * 0.74 + shh * 0.28, shh * 0.12 + shh * 0.26], fill=(255, 240, 170))
    for cx, cy, s in [(0.22, 0.20, 1.0), (0.48, 0.13, 0.8), (0.62, 0.24, 0.65)]:   # bulutlar
        for dx, dy in [(-1, 0), (0, -0.5), (1, 0), (0, 0.2)]:
            rr = shh * 0.09 * s
            sd.ellipse([sw * cx + dx * rr * 1.1 - rr, shh * cy + dy * rr - rr,
                        sw * cx + dx * rr * 1.1 + rr, shh * cy + dy * rr + rr], fill=(255, 255, 255))
    sd.ellipse([-sw * 0.15, shh * 0.60, sw * 0.55, shh * 1.35], fill=(112, 190, 96))   # tepelerer
    sd.ellipse([sw * 0.45, shh * 0.66, sw * 1.15, shh * 1.35], fill=(96, 176, 84))
    sd.ellipse([sw * 0.30, shh * 0.80, sw * 0.70, shh * 1.10], fill=(130, 205, 110))
    sd.rectangle([sw * 0.16, shh * 0.74, sw * 0.24, shh * 0.92], fill=(146, 96, 66))    # agac
    sd.ellipse([sw * 0.10, shh * 0.52, sw * 0.30, shh * 0.80], fill=(74, 150, 70))
    sd.rectangle([sw * 0.60, shh * 0.76, sw * 0.76, shh * 0.93], fill=(214, 92, 76))    # ev
    sd.polygon([(sw * 0.575, shh * 0.76), (sw * 0.68, shh * 0.66), (sw * 0.785, shh * 0.76)], fill=(168, 68, 58))
    sd.rectangle([sw * 0.655, shh * 0.83, sw * 0.705, shh * 0.93], fill=(110, 74, 52))
    img.paste(scr, (sx0, sy0))
    # ekran parlamasi
    gl = Image.new("L", (w, h), 0)
    ImageDraw.Draw(gl).polygon([(sx0, sy1), (sx0 + (sx1 - sx0) * 0.5, sy0), (sx0 + (sx1 - sx0) * 0.66, sy0), (sx0 + (sx1 - sx0) * 0.16, sy1)], fill=30)
    gl = gl.filter(ImageFilter.GaussianBlur(30))
    img.paste(Image.new("RGB", (w, h), (255, 255, 255)), (0, 0), gl)
    d.rectangle([sx0, sy0, sx1, sy0 + sh], outline=(70, 72, 76), width=2)
    d.rectangle([sx0, sy0, sx1, sy1], outline=(6, 6, 8), width=3)
    return img


def face_kapi_ic(w=512, h=1024):
    """Ic oda kapisi: beyaz, iki girintili panel, sagda gümest kollu kulp."""
    img = grad_img(w, h, (250, 250, 249), (236, 236, 234))
    d = ImageDraw.Draw(img, "RGBA")
    m = int(w * 0.10)
    _recess(img, [m, m, w - m, h - m], depth=26)
    # ust panel (kucuk)
    p = int(w * 0.21)
    u0, u1 = int(h * 0.10), int(h * 0.44)
    _recess(img, [p, u0, w - p, u1], depth=34)
    d.rectangle([p + 9, u0 + 9, w - p - 9, u1 - 9], fill=(242, 242, 240))
    _recess(img, [p + 9, u0 + 9, w - p - 9, u1 - 9], depth=14, light=False)
    # alt panel (buyuk)
    l0, l1 = int(h * 0.50), int(h * 0.92)
    _recess(img, [p, l0, w - p, l1], depth=34)
    d.rectangle([p + 9, l0 + 9, w - p - 9, l1 - 9], fill=(242, 242, 240))
    _recess(img, [p + 9, l0 + 9, w - p - 9, l1 - 9], depth=14, light=False)
    # sag tarafta gümest kollu kulp
    cx, cy = w - int(w * 0.15), int(h * 0.475)
    rr = int(w * 0.050)
    d.ellipse([cx - rr, cy - rr, cx + rr, cy + rr], fill=(176, 181, 186))
    d.ellipse([cx - rr, cy - rr, cx + rr, cy + rr], outline=(150, 156, 162), width=2)
    lw = int(w * 0.155)
    d.rounded_rectangle([cx - lw, cy - int(w * 0.026), cx - int(w * 0.012), cy + int(w * 0.030)],
                        radius=int(w * 0.024), fill=(186, 191, 196))
    d.rounded_rectangle([cx - lw + 4, cy - int(w * 0.020), cx - int(w * 0.030), cy + int(w * 0.012)],
                        radius=int(w * 0.014), fill=(224, 228, 232))
    return img


# ----------------------------------------------------------------------- main


def main():
    os.makedirs(DOK, exist_ok=True)
    print("Yuzey dokulari -> %s" % DOK)
    save(tex_wood("ahsap_koyu", None, (74, 46, 30), (128, 88, 58), 101, rings=7.0), "ahsap_koyu")
    save(tex_wood("ahsap_acik", None, (168, 130, 84), (226, 196, 152), 202, rings=6.0), "ahsap_acik")
    save(tex_lacquer("beyaz_lake", 303), "beyaz_lake")
    save(tex_granite("tezgah_tas", 404), "tezgah_tas")
    save(tex_steel("metal_celik", 505), "metal_celik")
    save(tex_fabric("kumas_gri", (152, 152, 155), 606), "kumas_gri")
    save(tex_fabric("kumas_beyaz", (243, 243, 240), 707, wrinkle=0.14), "kumas_beyaz")
    save(tex_fabric("kumas_mavi", (168, 198, 226), 808), "kumas_mavi")
    save(tex_tiles("fayans_beyaz", 909), "fayans_beyaz")
    save(tex_concrete("beton_zemin", 1010), "beton_zemin")
    save(face_kapi_ic(), "kapi_ic")          # kapi_ahsap.png zaten var (kodla cizildi) -> dokunulmadi

    print("\nOn yuz goruntuleri (gercek en-boy oraninda, dither'li palet):")
    for img, name in [
        (face_dolap_kapagi(1024, 1024), "on_dolap_kapagi"),
        (face_ust_dolap(1024, 592), "on_ust_dolap"),
        (face_cekmece(1024, 368), "on_cekmece"),
        (face_gardirop(512, 1024), "on_gardirop_kapagi"),
        (face_buzdolabi(512, 1024), "on_buzdolabi"),
        (face_firin(1024, 1024), "on_firin"),
        (face_ust_ocak(1024, 1024), "ust_ocak"),
        (face_tv(1024, 544), "on_tv"),
    ]:
        save(img, name, palette=True, dither=True, max_kb=500)
    print("\nBitti. Godot'ta bir kez --import calistir.")


if __name__ == "__main__":
    main()
