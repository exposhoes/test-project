"""Karakter görünüm sayfasından (önden | yandan | arkadan) kutu model kaplaması üretir.
Çıktı: assets/textures/actors/<kod>_skin.png ve <kod>_skin.json (parça boyut/konum ve yüz UV'leri).
Actor.gd bu dosyalar varsa renkli kutular yerine bunları kullanır.
Çalıştır: python3 tools/art/build_actor.py"""
import json, os, sys
from PIL import Image, ImageFilter
sys.path.insert(0, os.path.dirname(__file__))
from pack_model_texture import cutout

SRC = os.path.join(os.path.dirname(__file__), "sources")
OUT = "assets/textures/actors/"
CELL, PAD = 256, 16


def cutout_bg(img, dark=28):
    """Yalnızca kenardan bağlı siyah arka planı şeffaf yapar (gözbebekleri gibi iç koyuluklar kalır),
    sonra kenarı 2 piksel içeri alıp şeffaf piksellerin rengini komşu renkle doldurur."""
    img = img.convert("RGBA")
    w, h = img.size
    px = img.load()
    seen = bytearray(w * h)
    stack = [(x, y) for x in range(w) for y in (0, h - 1)] + [(x, y) for y in range(h) for x in (0, w - 1)]
    while stack:
        x, y = stack.pop()
        if x < 0 or y < 0 or x >= w or y >= h or seen[y * w + x]:
            continue
        seen[y * w + x] = 1
        r, g, b, _ = px[x, y]
        if max(r, g, b) >= dark:
            continue
        px[x, y] = (r, g, b, 0)
        stack += [(x + 1, y), (x - 1, y), (x, y + 1), (x, y - 1)]
    alpha = img.getchannel("A").filter(ImageFilter.MinFilter(5))
    solid = img.copy()
    solid.putalpha(alpha)
    fill = None
    for radius in (3, 10, 30):
        blurred = solid.filter(ImageFilter.GaussianBlur(radius))
        fill = blurred if fill is None else Image.alpha_composite(blurred, fill)
    out = Image.alpha_composite(fill, solid).convert("RGB")
    out.putalpha(alpha)
    return out


def fill_black(img, dark=28):
    """Siyah arka planı komşu renklerle doldurur (saç uçları gibi kutudan taşan yerler)."""
    img = img.convert("RGBA")
    px = img.load()
    for y in range(img.height):
        for x in range(img.width):
            r, g, b, _ = px[x, y]
            if max(r, g, b) < dark:
                px[x, y] = (0, 0, 0, 0)
    fill = None
    for radius in (3, 8, 20, 50):
        blurred = img.filter(ImageFilter.GaussianBlur(radius))
        fill = blurred if fill is None else Image.alpha_composite(blurred, fill)
    base = Image.new("RGBA", img.size, (120, 90, 70, 255))
    return Image.alpha_composite(Image.alpha_composite(base, fill), img).convert("RGB")


def alpha_fill(img):
    """Şeffaf arka planlı sayfa: şeffaf pikselleri komşu renkle doldurur (siyah eldiven/bot korunur)."""
    img = img.convert("RGBA")
    fill = None
    for radius in (3, 8, 20, 50):
        blurred = img.filter(ImageFilter.GaussianBlur(radius))
        fill = blurred if fill is None else Image.alpha_composite(blurred, fill)
    base = Image.new("RGBA", img.size, (120, 90, 70, 255))
    return Image.alpha_composite(Image.alpha_composite(base, fill), img).convert("RGB")


def fill_holes(img):
    """Kafa yüzünde kenara bağlı olmayan şeffaf delikleri (göz parıltısı) beyazla doldurur."""
    img = img.copy()
    w, h = img.size
    px = img.load()
    seen = bytearray(w * h)
    stack = [(x, y) for x in range(w) for y in (0, h - 1)] + [(x, y) for y in range(h) for x in (0, w - 1)]
    while stack:
        x, y = stack.pop()
        if x < 0 or y < 0 or x >= w or y >= h or seen[y * w + x] or px[x, y][3] >= 128:
            continue
        seen[y * w + x] = 1
        stack += [(x + 1, y), (x - 1, y), (x, y + 1), (x, y - 1)]
    for y in range(h):
        for x in range(w):
            if px[x, y][3] < 128 and not seen[y * w + x]:
                px[x, y] = (255, 255, 255, 255)
    return img


ONLY = sys.argv[1:]  # ör. python3 tools/art/build_actor.py polis findik


def build(code, sheet, parts, height=1.8):
    if ONLY and code not in ONLY:
        return
    src = Image.open(os.path.join(SRC, sheet))
    # Yan karakter sayfaları (2026-10-02) şeffaf arka planlı: alfa kanalı doğrudan kullanılır.
    transparent = src.mode == "RGBA" and src.getchannel("A").getextrema()[0] == 0
    im = src.convert("RGBA") if transparent else src.convert("RGB")
    faces_order = ["front", "back", "left", "right", "top", "bottom"]
    cells = []
    meta = []
    for p in parts:
        uv = {}
        for f in faces_order:
            spec = p["faces"][f]
            rot = 0
            if isinstance(spec, dict):
                box, mirror, rot = spec["box"], spec.get("mirror", False), spec.get("rot", 0)
            elif isinstance(spec, tuple) and len(spec) == 2 and isinstance(spec[1], bool):
                box, mirror = spec
            else:
                box, mirror = spec, False
            x0, y0, x1, y1 = box
            if transparent:
                crop = im.crop(box)
                if p["name"] == "head" and f not in ("top", "bottom"):
                    crop = fill_holes(crop)
                if not (p["name"] == "head" and f not in ("top", "bottom")):
                    crop = alpha_fill(crop).convert("RGBA")
            elif p["name"] == "head" and f not in ("top", "bottom"):
                # Kafa: siyah arka plan şeffaf, kafa saçın gerçek biçiminde görünür.
                crop = cutout_bg(im.crop(box))
            else:
                if x1 - x0 > 60 and y1 - y0 > 60 and not INSET == 0:  # yuvarlak kenardaki parlak şeridi at
                    k = INSET if INSET else max(10, min(x1 - x0, y1 - y0) // 9)
                    box = (x0 + k, y0 + k, x1 - k, y1 - k)
                crop = fill_black(im.crop(box)).convert("RGBA")
            if mirror:
                crop = crop.transpose(Image.FLIP_LEFT_RIGHT)
            if rot:
                crop = crop.rotate(rot, expand=True)
            uv[f] = len(cells)
            cells.append(crop.resize((CELL, CELL), Image.LANCZOS))
        meta.append({"name": p["name"], "size": p["size"], "pos": p["pos"], "cells": uv})
    cols = 6
    rows = (len(cells) + cols - 1) // cols
    w = CELL + 2 * PAD
    atlas = Image.new("RGBA", (cols * w, rows * w))
    for i, c in enumerate(cells):
        x, y = (i % cols) * w, (i // cols) * w
        big = c.resize((w, w), Image.NEAREST)  # dolgu için kenarı uzat
        atlas.paste(big, (x, y))
        atlas.paste(c, (x + PAD, y + PAD))
    atlas.save(OUT + code + "_skin.png")
    for m in meta:
        for f, i in m["cells"].items():
            x, y = (i % cols) * w + PAD, (i // cols) * w + PAD
            m["cells"][f] = [x / atlas.width, y / atlas.height, (x + CELL) / atlas.width, (y + CELL) / atlas.height]
        m["uv"] = m.pop("cells")
    json.dump({"parts": meta}, open(OUT + code + "_skin.json", "w"), indent=1)
    print(code, atlas.size)


INSET = None  # kenar kırpma (piksel); None: yuvarlak kenarlı görseller için orana göre
S = 1.8 / 620.0   # piksel -> oyun birimi (görselde ayak ucu y=709)
FOOT = 709


def dim(x0, y0, x1, y1, depth_px):
    return [round((x1 - x0) * S, 3), round((y1 - y0) * S, 3), round(depth_px * S, 3)]


def cy(y0, y1):
    return round((FOOT - (y0 + y1) / 2) * S, 3)


def boy(head, head_side, hair_top, torso_top, arm_top=281):
    """Emir/Ali düzeni: önden 67-475, yandan (burun solda), arkadan önden +850 piksel."""
    hx0, hy0, hx1, hy1 = head
    arm_side = (646, arm_top, 748, 493)
    leg_side = (646, 494, 748, 709)
    red = (300, 420, 360, 480)
    parts = [
        {"name": "head", "size": dim(hx0, hy0, hx1, hy1, head_side[2] - head_side[0]), "pos": [0, cy(hy0, hy1), 0],
         "faces": {"front": head, "back": (hx0 + B, hy0, hx1 + B, hy1),
                   "left": head_side, "right": (head_side, True), "top": hair_top,
                   "bottom": (240, hy1 - 18, 300, hy1 - 4)}},
        {"name": "torso", "size": dim(168, torso_top, 372, 492, 103), "pos": [0, cy(torso_top, 492), 0],
         "faces": {"front": (168, torso_top, 372, 492), "back": (168 + B, torso_top, 372 + B, 492),
                   "left": arm_side, "right": (arm_side, True), "top": red, "bottom": (200, 500, 260, 540)}},
    ]
    for side, (fx0, fx1), (bx0, bx1) in ((1, (68, 168), (1222, 1324)), (-1, (372, 474), (918, 1018))):
        w = dim(fx0, arm_top, fx1, 493, 103)
        parts.append({"name": "arm", "size": w, "pos": [round(side * (0.296 + w[0] / 2), 3), cy(arm_top, 493), 0],
                      "faces": {"front": (fx0, arm_top, fx1, 493), "back": (bx0, arm_top, bx1, 493),
                                "left": arm_side, "right": (arm_side, True), "top": (80, arm_top + 20, 160, arm_top + 70),
                                "bottom": (80, 470, 160, 490)}})
    for side, (fx0, fx1), (bx0, bx1) in ((1, (172, 271), (1121, 1220)), (-1, (271, 370), (1022, 1121))):
        w = dim(fx0, 492, fx1, 709, 103)
        parts.append({"name": "leg", "size": w, "pos": [round(side * w[0] / 2, 3), cy(492, 709), 0],
                      "faces": {"front": (fx0, 492, fx1, 709), "back": (bx0, 492, bx1, 709),
                                "left": leg_side, "right": (leg_side, True), "top": (190, 500, 250, 540),
                                "bottom": (190, 670, 250, 700)}})
    return parts


B = 850
build("ali", "ali.png", boy((187, 106, 352, 280), (615, 104, 783, 280), (1060, 115, 1180, 160), 282, 283))


# Anne: uzun saç omuzlara iner, etek geniş; ayakkabılar ayrı küçük kutular.
PINK = (240, 300, 300, 340)
HEAD_SIDE = (612, 105, 788, 272)
ARM_SIDE = (646, 282, 748, 492)
SKIRT_SIDE = (634, 490, 766, 666)
anne = [
    {"name": "head", "size": dim(183, 106, 358, 272, 176), "pos": [0, cy(106, 272), 0],
     "faces": {"front": (183, 106, 358, 272), "back": (183 + B, 106, 358 + B, 272),
               "left": HEAD_SIDE, "right": (HEAD_SIDE, True), "top": (1070, 115, 1180, 160),
               "bottom": (250, 262, 300, 275)}},
    {"name": "torso", "size": dim(168, 272, 372, 488, 103), "pos": [0, cy(272, 488), 0],
     "faces": {"front": (168, 272, 372, 488), "back": (168 + B, 272, 372 + B, 488),
               "left": ARM_SIDE, "right": (ARM_SIDE, True), "top": PINK, "bottom": PINK}},
    {"name": "skirt", "size": dim(151, 488, 391, 668, 132), "pos": [0, cy(488, 668), 0],
     "faces": {"front": (151, 488, 391, 668), "back": (151 + B, 488, 391 + B, 668),
               "left": SKIRT_SIDE, "right": (SKIRT_SIDE, True), "top": PINK, "bottom": (200, 672, 260, 700)}},
]
for side, (fx0, fx1), (bx0, bx1) in ((1, (68, 168), (1222, 1324)), (-1, (372, 474), (918, 1018))):
    w = dim(fx0, 281, fx1, 493, 103)
    anne.append({"name": "arm", "size": w, "pos": [round(side * (0.296 + w[0] / 2), 3), cy(281, 493), 0],
                 "faces": {"front": (fx0, 281, fx1, 493), "back": (bx0, 281, bx1, 493),
                           "left": ARM_SIDE, "right": (ARM_SIDE, True), "top": (80, 300, 160, 360),
                           "bottom": (80, 470, 160, 490)}})
for side, (fx0, fx1) in ((1, (172, 270)), (-1, (272, 370))):
    anne.append({"name": "shoe", "size": dim(fx0, 666, fx1, 709, 110), "pos": [round(side * 0.143, 3), cy(666, 709), 0],
                 "faces": {f: (fx0 + 10, 676, fx1 - 10, 700) for f in ("front", "back", "left", "right", "top", "bottom")}})
build("anne", "anne.png", anne)


def tpose(head, torso, arm_y, arm_l, arm_r, legs, side, back_dx, foot, nose_right=False, sleeve=None):
    """Kollar yana açık (T-pozu) sayfa: kol şeritleri döndürülüp aşağı sarkan kola kaplanır.
    head/torso: önden kutu; arm_y: kol üst-alt; arm_l/arm_r: sol/sağ kol x aralığı (omuz gövde
    tarafında); legs: (x0, orta, x1, üst); side: yandan {"head","torso","leg","hand"} kutuları;
    back_dx: arkadan görünümün önden kayması (arkadan bakınca sol-sağ yer değiştirir)."""
    global FOOT
    FOOT = foot
    hx0, hy0, hx1, hy1 = head
    tx0, ty0, tx1, ty1 = torso
    sleeve = sleeve or (tx0 + 40, ty0 + 60, tx0 + 80, ty0 + 100)
    left_x0, right_x1 = arm_l[0], arm_r[1]

    def back(box):  # önden kutunun arkadan görünümdeki karşılığı (aynalı konum)
        x0, y0, x1, y1 = box
        return (left_x0 + right_x1 - x1 + back_dx, y0, left_x0 + right_x1 - x0 + back_dx, y1)

    hs = (side["head"], not nose_right) if False else side["head"]
    head_l, head_r = (side["head"], (side["head"], True)) if not nose_right else ((side["head"], True), side["head"])
    parts = [
        {"name": "head", "size": dim(*head, side["head"][2] - side["head"][0]), "pos": [0, cy(hy0, hy1), 0],
         "faces": {"front": head, "back": back(head), "left": head_l, "right": head_r,
                   "top": (back(head)[0] + 30, hy0 + 8, back(head)[2] - 30, hy0 + 50),
                   "bottom": ((hx0 + hx1) // 2 - 25, hy1 - 14, (hx0 + hx1) // 2 + 25, hy1 - 2)}},
        {"name": "torso", "size": dim(*torso, side["torso"][2] - side["torso"][0]), "pos": [0, cy(ty0, ty1), 0],
         "faces": {"front": torso, "back": back(torso), "left": side["torso"], "right": side["torso"],
                   "top": sleeve, "bottom": sleeve}},
    ]
    ay0, ay1 = arm_y
    for sgn, (x0, x1), rot in ((1, arm_l, 90), (-1, arm_r, -90)):
        length, th = x1 - x0, ay1 - ay0
        w = [round(th * S, 3), round(length * S, 3), round(th * S, 3)]
        box = (x0, ay0, x1, ay1)
        parts.append({"name": "arm", "size": w,
                      "pos": [round(sgn * ((tx1 - tx0) * S / 2 + w[0] / 2), 3), cy(ty0, ty0 + length), 0],
                      "faces": {"front": {"box": box, "rot": rot}, "back": {"box": back(box), "rot": -rot},
                                "left": {"box": box, "rot": rot}, "right": {"box": box, "rot": rot},
                                "top": sleeve, "bottom": side["hand"]}})
    lx0, lxm, lx1, ly0 = legs
    for sgn, (x0, x1) in ((1, (lx0, lxm)), (-1, (lxm, lx1))):
        w = dim(x0, ly0, x1, foot, side["leg"][2] - side["leg"][0])
        mx = (x0 + x1) // 2
        parts.append({"name": "leg", "size": w, "pos": [round(sgn * w[0] / 2, 3), cy(ly0, foot), 0],
                      "faces": {"front": (x0, ly0, x1, foot), "back": back((x0, ly0, x1, foot)),
                                "left": side["leg"], "right": (side["leg"], True),
                                "top": (mx - 20, ly0 + 8, mx + 20, ly0 + 40), "bottom": (mx - 20, foot - 30, mx + 20, foot - 6)}})
    return parts


KID_SIDE = {"torso": (649, 392, 739, 466), "leg": (654, 472, 735, 692), "hand": (664, 322, 722, 376)}
build("zeynep", "zeynep.png", tpose((200, 98, 356, 306), (190, 312, 364, 470), (314, 382), (23, 190), (364, 532),
      (196, 278, 360, 472), dict(KID_SIDE, head=(612, 98, 790, 306)), 822 - 5, 692))
build("ogretmen", "ogretmen.png", tpose((200, 121, 356, 306), (190, 312, 364, 470), (314, 382), (23, 190), (364, 532),
      (196, 278, 360, 472), dict(KID_SIDE, head=(614, 121, 790, 306)), 822 - 5, 692))
build("doktor", "doktor.png", tpose((222, 100, 362, 256), (190, 258, 398, 555), (268, 348), (23, 190), (398, 564),
      (206, 292, 380, 556), {"head": (614, 100, 762, 256), "torso": (636, 360, 755, 550), "leg": (653, 558, 735, 700),
      "hand": (666, 278, 724, 342)}, 790, 702, nose_right=True, sleeve=(240, 470, 280, 520)))


def down(head, torso, arm_y, arm_l, arm_r, legs, side, back_dx, foot, nose_right=False):
    """Kollar aşağıda duran sayfa (Emir/Anne düzeni) için genel parça listesi."""
    global FOOT
    FOOT = foot
    hx0, hy0, hx1, hy1 = head
    tx0, ty0, tx1, ty1 = torso
    left_x0, right_x1 = arm_l[0], arm_r[1]

    def back(box):
        x0, y0, x1, y1 = box
        return (left_x0 + right_x1 - x1 + back_dx, y0, left_x0 + right_x1 - x0 + back_dx, y1)

    head_l, head_r = (side["head"], (side["head"], True)) if not nose_right else ((side["head"], True), side["head"])
    arm_side = side["arm"]
    parts = [
        {"name": "head", "size": dim(*head, side["head"][2] - side["head"][0]), "pos": [0, cy(hy0, hy1), 0],
         "faces": {"front": head, "back": back(head), "left": head_l, "right": head_r,
                   "top": (back(head)[0] + 30, hy0 + 8, back(head)[2] - 30, hy0 + 40),
                   "bottom": ((hx0 + hx1) // 2 - 25, hy1 - 14, (hx0 + hx1) // 2 + 25, hy1 - 2)}},
        {"name": "torso", "size": dim(*torso, arm_side[2] - arm_side[0]), "pos": [0, cy(ty0, ty1), 0],
         "faces": {"front": torso, "back": back(torso), "left": arm_side, "right": (arm_side, True),
                   "top": (arm_l[0] + 20, arm_y[0] + 20, arm_l[1] - 20, arm_y[0] + 60),
                   "bottom": (legs[0] + 20, legs[3] + 6, legs[1] - 20, legs[3] + 30)}},
    ]
    ay0, ay1 = arm_y
    for sgn, (x0, x1) in ((1, arm_l), (-1, arm_r)):
        w = dim(x0, ay0, x1, ay1, arm_side[2] - arm_side[0])
        box = (x0, ay0, x1, ay1)
        parts.append({"name": "arm", "size": w, "pos": [round(sgn * ((tx1 - tx0) * S / 2 + w[0] / 2), 3), cy(ay0, ay1), 0],
                      "faces": {"front": box, "back": back(box), "left": arm_side, "right": (arm_side, True),
                                "top": (x0 + 20, ay0 + 20, x1 - 20, ay0 + 60), "bottom": (x0 + 20, ay1 - 20, x1 - 20, ay1 - 4)}})
    lx0, lxm, lx1, ly0 = legs
    for sgn, (x0, x1) in ((1, (lx0, lxm)), (-1, (lxm, lx1))):
        w = dim(x0, ly0, x1, foot, side["leg"][2] - side["leg"][0])
        mx = (x0 + x1) // 2
        parts.append({"name": "leg", "size": w, "pos": [round(sgn * w[0] / 2, 3), cy(ly0, foot), 0],
                      "faces": {"front": (x0, ly0, x1, foot), "back": back((x0, ly0, x1, foot)),
                                "left": side["leg"], "right": (side["leg"], True),
                                "top": (mx - 20, ly0 + 8, mx + 20, ly0 + 40), "bottom": (mx - 20, foot - 30, mx + 20, foot - 6)}})
    return parts


build("bakkal", "bakkal.png", down((212, 114, 355, 250), (178, 250, 390, 560), (253, 475), (70, 178), (390, 495),
      (178, 284, 390, 560), {"head": (623, 114, 764, 250), "arm": (640, 253, 745, 475), "leg": (640, 562, 746, 690)},
      819, 690))


# Emir (düz çizgi film tarzı, keskin kutular; 2400x1791 sayfa, burun sağda)
S = 1.8 / 1220.0
INSET = 9  # yalnızca siyah dış çizgiyi at
# Kafa görseldeki gibi keskin bir küp (ten bloğu); saç build_heads.py ile ayrı 3D parça olur.
build("emir", "emir2.png", down((290, 399, 577, 686), (254, 688, 611, 1103), (688, 1103), (78, 240), (625, 787),
      (257, 433, 608, 1103), {"head": (1076, 399, 1364, 686), "arm": (1143, 700, 1291, 1100), "leg": (1145, 1106, 1291, 1512)},
      1536, 1515, nose_right=True))


# Yan karakterler (2026-10-02): Minecraft gibi köşeli, şeffaf arka planlı 2048x2048 sayfa
# (önden | yandan, burun sağda | arkadan); kollar aşağıda, ayak ucu y=1760.
S = 1.85 / 1412.0  # yetişkin boyu (2.0 çocukların yanında çok iri duruyordu)
INSET = None
build("itfaiyeci", "itfaiyeci.png", down((227, 348, 550, 737), (225, 737, 552, 1270), (737, 1270), (64, 225), (552, 714),
      (225, 388, 552, 1270), {"head": (860, 348, 1185, 737), "arm": (942, 737, 1105, 1270), "leg": (942, 1270, 1105, 1760)},
      1269, 1760, nose_right=True))
build("polis", "polis.png", down((226, 348, 552, 737), (225, 737, 552, 1270), (737, 1270), (64, 225), (552, 714),
      (225, 388, 552, 1270), {"head": (860, 369, 1186, 737), "arm": (942, 737, 1105, 1270), "leg": (942, 1270, 1105, 1760)},
      1270, 1760, nose_right=True))


def findik():
    """Fındık (köpek): önden | yandan (burun solda) | arkadan sayfa; dört bacak, kuyruk, burun kutusu."""
    global S, FOOT
    S, FOOT = 0.75 / 757.0, 1412
    mid_z = 1112  # yandan görünümde gövdenin ortası

    def z(x0, x1):
        return round(((x0 + x1) / 2 - mid_z) * S, 3)

    def size(w, h, d):
        return [round(w * S, 3), round(h * S, 3), round(d * S, 3)]

    side_head = (716, 635, 1023, 982)
    parts = [
        {"name": "head", "size": size(408, 335, 307), "pos": [0, cy(655, 990), z(716, 1023)],
         "faces": {"front": (123, 655, 531, 990), "back": (1557, 655, 1944, 990), "left": side_head,
                   "right": (side_head, True), "top": (1650, 700, 1850, 760), "bottom": (240, 940, 300, 975)}},
        {"name": "snout", "size": size(182, 145, 101), "pos": [0, cy(800, 945), z(615, 716)],
         "faces": {"front": (236, 800, 418, 945), "back": (236, 800, 418, 945), "left": (615, 800, 716, 945),
                   "right": ((615, 800, 716, 945), True), "top": (650, 805, 700, 830), "bottom": (650, 915, 700, 940)}},
        {"name": "body", "size": size(327, 288, 536), "pos": [0, cy(900, 1188), z(844, 1380)],
         "faces": {"front": (164, 900, 491, 1188), "back": (1597, 900, 1914, 1188), "left": (844, 900, 1380, 1188),
                   "right": ((844, 900, 1380, 1188), True), "top": (1050, 1000, 1250, 1060),
                   "bottom": (1000, 1150, 1150, 1180)}},
        {"name": "tail", "size": size(68, 203, 121), "pos": [0, cy(697, 900), z(1332, 1453)],
         "faces": {"front": (1716, 776, 1784, 980), "back": (1716, 776, 1784, 980), "left": (1332, 697, 1453, 900),
                   "right": ((1332, 697, 1453, 900), True), "top": (1345, 705, 1440, 740),
                   "bottom": (1345, 860, 1440, 895)}},
    ]
    # Sıra: ön sol, ön sağ, arka sağ, arka sol (Actor çapraz bacakları birlikte sallar).
    legs = [((184, 306), (894, 1023), 327 - 245), ((358, 470), (894, 1023), 327 - 414),
            ((1791, 1893), (1228, 1351), -(1842 - 1750.5)), ((1618, 1740), (1228, 1351), -(1679 - 1750.5))]
    for (fx0, fx1), (sx0, sx1), dx in legs:
        front = (fx0, 1188, fx1, 1412)
        side = (sx0, 1188, sx1, 1412)
        parts.append({"name": "leg", "size": size(fx1 - fx0, 224, sx1 - sx0), "pos": [round(dx * S, 3), cy(1188, 1412), z(sx0, sx1)],
                      "faces": {"front": front, "back": front, "left": side, "right": (side, True),
                                "top": (fx0 + 20, 1195, fx1 - 20, 1230), "bottom": (fx0 + 20, 1380, fx1 - 20, 1405)}})
    return parts


build("findik", "findik.png", findik())
