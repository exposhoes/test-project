"""EmirCRAFT item icons (32x32 RGBA), deterministic pixel art.

Every icon named in scripts/items/items.gd DEFS is drawn here and written to
assets/textures/items/<icon>.png. Shapes are built from simple geometry
(capsules, circles, polygons) sampled at pixel centres, shaded from a
top-left light, then wrapped in a 1px dark outline.
Tools point diagonally: head top-right, handle bottom-left.
"""
import math, os
from PIL import Image

OUT = "/home/claude/test-project/assets/textures/items"
N = 32
OUTLINE = (24, 16, 14, 255)


def hx(s, a=255):
    s = s.lstrip("#")
    return (int(s[0:2], 16), int(s[2:4], 16), int(s[4:6], 16), a)


def pal(*c):
    """Shades dark -> light."""
    return [hx(x) for x in c]


# 5 shades per material, darkest first
WOOD = pal("5e4424", "86633a", "b08a52", "c9a36a", "e0c08a")
STONE = pal("454545", "626262", "8a8a8a", "a6a6a6", "c4c4c4")
IRON = pal("6e7278", "9a9ea4", "c8ccd0", "e2e4e6", "ffffff")
CRYSTAL = pal("12666b", "1f9aa0", "45e0e6", "8ef0f3", "e0fdfe")
RUBY = pal("5e0a18", "8e1426", "d8263f", "f0566a", "ffb0b8")
GOLD = pal("7a5a10", "b8911c", "f2cf3c", "f8e27a", "fff6c8")
HANDLE = pal("3e2814", "553820", "6e4a2a", "8a6038", "a47a4c")
COAL = pal("0a0a0a", "1c1c1c", "2e2e2e", "4a4a4a", "6e6e6e")
RAW_IRON = pal("5e4636", "8a6a55", "b08c72", "c9a184", "e2c4a8")
RAW_GOLD = pal("6e5010", "a67c1c", "d49e2a", "e8b93a", "f8dc80")
APPLE = pal("5e0a18", "8e1426", "c01e36", "d8263f", "f7a0a8")
LEAF = pal("1e4a14", "2e6a20", "3b8a2a", "5aac40", "80c860")

LIGHT = (-0.7071, -0.7071)  # light comes from top-left


def seg_dist(px, py, ax, ay, bx, by):
    dx, dy = bx - ax, by - ay
    t = max(0.0, min(1.0, ((px - ax) * dx + (py - ay) * dy) / (dx * dx + dy * dy)))
    return math.hypot(px - (ax + t * dx), py - (ay + t * dy)), t


class Icon:
    def __init__(self):
        self.g = {}

    def put(self, x, y, col):
        if 0 <= x < N and 0 <= y < N:
            self.g[(x, y)] = col

    def capsule(self, a, b, r, shades, tip=False):
        """Rod from a to b; shaded across its width (lit side upper-left)."""
        ax, ay = a; bx, by = b
        L = math.hypot(bx - ax, by - ay)
        nx, ny = -(by - ay) / L, (bx - ax) / L  # a normal
        if nx * LIGHT[0] + ny * LIGHT[1] < 0:
            nx, ny = -nx, -ny                    # make it face the light
        for y in range(N):
            for x in range(N):
                cx, cy = x + 0.5, y + 0.5
                d, t = seg_dist(cx, cy, ax, ay, bx, by)
                rr = r * (1.0 - t * 0.85) if tip else r
                if d <= rr:
                    s = ((cx - ax) * nx + (cy - ay) * ny) / max(rr, 0.6)
                    k = 3 if s > 0.35 else (2 if s > -0.35 else 1)
                    self.put(x, y, shades[k])

    def disc(self, cx, cy, r, shades, spec=True):
        for y in range(N):
            for x in range(N):
                dx, dy = x + 0.5 - cx, y + 0.5 - cy
                d = math.hypot(dx, dy)
                if d <= r:
                    lit = -(dx * LIGHT[0] + dy * LIGHT[1]) / r  # -1..1
                    lit = -lit
                    k = 3 if lit > 0.3 else (2 if lit > -0.35 else 1)
                    if d > r - 1.2 and lit < -0.2:
                        k = 1
                    self.put(x, y, shades[k])
        if spec:
            self.put(int(cx - r * 0.45), int(cy - r * 0.45), shades[4])

    def poly(self, pts, col):
        n = len(pts)
        for y in range(N):
            for x in range(N):
                cx, cy = x + 0.5, y + 0.5
                inside = False
                j = n - 1
                for i in range(n):
                    xi, yi = pts[i]; xj, yj = pts[j]
                    if (yi > cy) != (yj > cy) and cx < (xj - xi) * (cy - yi) / (yj - yi) + xi:
                        inside = not inside
                    j = i
                if inside:
                    self.put(x, y, col)

    def image(self, outline=OUTLINE):
        img = Image.new("RGBA", (N, N), (0, 0, 0, 0))
        px = img.load()
        for (x, y), c in self.g.items():
            px[x, y] = c
        for y in range(N):
            for x in range(N):
                if (x, y) in self.g:
                    continue
                for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
                    if (x + dx, y + dy) in self.g:
                        px[x, y] = outline
                        break
        return img


# ---------------- tools ----------------
# handle axis: bottom-left (5,27) -> top-right; unit vectors along/perp
AX = (0.7071, -0.7071)   # along handle, toward head
PL = (-0.7071, -0.7071)  # perpendicular, toward upper-left


def handle(ic, top=(21.5, 10.5)):
    ic.capsule((5.5, 26.5), top, 1.5, HANDLE)
    # grip wraps
    for t in (6, 9):
        x, y = int(5.5 + t * AX[0]), int(26.5 + t * AX[1])
        ic.put(x, y, HANDLE[0]); ic.put(x + 1, y + 1, HANDLE[0])


def pickaxe(m):
    def fn():
        ic = Icon(); handle(ic, (20.5, 11.5))
        # curved head: arc of a circle centred down the handle, concave toward it
        cx, cy, R = 13.0, 19.0, 13.5
        for y in range(N):
            for x in range(N):
                dx, dy = x + 0.5 - cx, y + 0.5 - cy
                d = math.hypot(dx, dy)
                ang = math.degrees(math.atan2(-dy, dx)) - 45.0  # 0 = up-right
                a = abs(ang)
                if a > 62:
                    continue
                half = 3.0 * (1 - (a / 62) ** 2) + 0.7
                off = d - R
                if abs(off) <= half:
                    rel = off / half
                    k = 4 if rel > 0.6 and a < 40 else (3 if rel > 0.05 else (2 if rel > -0.55 else 1))
                    ic.put(x, y, m[k])
        # socket where head meets handle
        for p in ((20, 11), (21, 11), (20, 12), (21, 10)):
            ic.put(*p, m[0])
        return ic.image()
    return fn


def axe(m):
    def fn():
        ic = Icon(); handle(ic, (22.5, 9.5))
        ox, oy = 5.5, 26.5
        for y in range(N):
            for x in range(N):
                cx, cy = x + 0.5 - ox, y + 0.5 - oy
                u = cx * AX[0] + cy * AX[1]
                v = cx * PL[0] + cy * PL[1]
                # blade on the upper-left side, fanning out
                if 0.8 <= v <= 11.0:
                    lo = 15.5 - v * 0.6
                    hi = 21.5 + v * 0.3
                    if lo <= u <= hi:
                        k = 2
                        if v > 9.8: k = 4
                        elif v > 8.4: k = 3
                        elif u < lo + 1.2: k = 1
                        elif u > hi - 1.0: k = 3
                        ic.put(x, y, m[k])
                # small poll on the other side
                if -3.2 <= v <= -0.8 and 17.5 <= u <= 21.0:
                    ic.put(x, y, m[1] if v < -2.2 else m[2])
        return ic.image()
    return fn


def sword(m, guard=HANDLE):
    def fn():
        ic = Icon()
        gx, gy = 10.5, 21.5  # guard centre
        tipx, tipy = 27.5, 4.5
        L = math.hypot(tipx - gx, tipy - gy)
        for y in range(N):
            for x in range(N):
                cx, cy = x + 0.5 - gx, y + 0.5 - gy
                u = cx * AX[0] + cy * AX[1]
                v = cx * PL[0] + cy * PL[1]
                if 0 <= u <= L:
                    w = 2.4 if u < L - 5 else 2.4 * (L - u) / 5 + 0.3
                    if abs(v) <= w:
                        k = 4 if abs(v) < 0.6 and u < L - 2 else (3 if v > 0 else 1)
                        if abs(v) > w - 0.9 and v > 0: k = 3
                        ic.put(x, y, m[k if k != 1 else 2] if v > -1.2 else m[1])
        # fuller line
        for t in range(3, int(L) - 4):
            ic.put(int(gx + t * AX[0]), int(gy + t * AX[1]), m[4])
        # guard crossbar perpendicular to blade
        ic.capsule((gx - 4.0, gy - 4.0), (gx + 4.0, gy + 4.0), 1.5, guard)
        # grip + pommel
        ic.capsule((gx - 1.0, gy + 1.0), (5.0, 27.0), 1.2, HANDLE)
        ic.disc(4.5, 27.5, 1.9, guard, spec=False)
        return ic.image()
    return fn


# ---------------- materials ----------------
def ingot(m):
    def fn():
        ic = Icon()
        # isometric bar: top face, front face, right end
        top = [(9, 12), (25, 12), (28, 16), (6, 16)]
        front = [(6, 16), (28, 16), (27, 22), (5, 22)]
        ic.poly(front, m[1])
        ic.poly(top, m[3])
        ic.poly([(24, 12), (25, 12), (28, 16), (27, 16)], m[2])
        for x in range(9, 23):
            ic.put(x, 12, m[4])
        for x in range(7, 27):
            ic.put(x, 16, m[2])
        for x in range(6, 27):
            ic.put(x, 21, m[0])
        ic.put(10, 13, m[4]); ic.put(11, 13, m[4])
        return ic.image()
    return fn


def gem(m):
    def fn():
        ic = Icon()
        # brilliant cut seen from the side: crown on top, pavilion below
        crown = [(10, 8), (22, 8), (27, 14), (5, 14)]
        pav = [(5, 14), (27, 14), (16, 28)]
        ic.poly(pav, m[1])
        ic.poly([(5, 14), (16, 14), (16, 28)], m[2])
        ic.poly([(11, 14), (16, 14), (16, 27)], m[3])
        ic.poly(crown, m[2])
        ic.poly([(10, 8), (16, 8), (14, 14), (5, 14)], m[3])
        ic.poly([(16, 8), (22, 8), (27, 14), (19, 14)], m[1])
        ic.poly([(13, 8), (19, 8), (17, 13), (14, 13)], m[4])
        for x in range(5, 27):
            ic.put(x, 14, m[4] if x < 16 else m[2])
        ic.put(11, 10, m[4]); ic.put(10, 11, m[4])
        return ic.image()
    return fn


def lumps(m, blobs, spark=None):
    def fn():
        ic = Icon()
        for cx, cy, r in blobs:
            ic.disc(cx, cy, r, m)
        if spark:
            for p in spark:
                ic.put(*p, m[4])
        return ic.image()
    return fn


NUGGET_BLOBS = [(13.5, 18.5, 6.5), (20.5, 15.5, 5.5), (19.0, 22.0, 5.0), (11.0, 11.5, 3.5)]


def raw_ore(m):
    def fn():
        ic = Icon()
        for cx, cy, r in NUGGET_BLOBS:
            ic.disc(cx, cy, r, m)
        # pitted texture
        for p in ((15, 20), (22, 18), (18, 24), (12, 16), (21, 13)):
            ic.put(*p, m[1])
        for p in ((16, 19), (23, 17)):
            ic.put(*p, m[4])
        return ic.image()
    return fn


def coal():
    ic = Icon()
    ic.poly([(9, 9), (19, 6), (26, 11), (27, 20), (21, 26), (10, 26), (5, 19), (6, 12)], COAL[1])
    ic.poly([(9, 9), (19, 6), (26, 11), (17, 15), (6, 12)], COAL[3])
    ic.poly([(6, 12), (17, 15), (13, 26), (10, 26), (5, 19)], COAL[2])
    ic.poly([(17, 15), (26, 11), (27, 20), (21, 26), (13, 26)], COAL[1])
    ic.poly([(21, 26), (27, 20), (26, 23)], COAL[0])
    for p in ((10, 10), (11, 10), (18, 8), (8, 14), (22, 12), (15, 18)):
        ic.put(*p, COAL[4])
    return ic.image()


def apple():
    ic = Icon()
    ic.disc(11.5, 18.5, 7.5, APPLE)
    ic.disc(20.5, 18.5, 7.5, APPLE, spec=False)
    ic.disc(16.0, 22.0, 7.0, APPLE, spec=False)
    # top dimple
    for p in ((15, 11), (16, 11), (16, 12)):
        ic.g.pop(p, None)
    ic.put(15, 12, APPLE[1]); ic.put(17, 12, APPLE[1])
    # shine
    for p in ((9, 15), (9, 16), (10, 14), (10, 15), (11, 14), (9, 17)):
        ic.put(*p, APPLE[4])
    # stem + leaf
    ic.capsule((15.5, 12.0), (17.5, 5.5), 1.0, HANDLE)
    ic.poly([(18, 8), (22, 4), (27, 4), (25, 8), (20, 10)], LEAF[2])
    ic.poly([(18, 8), (22, 4), (27, 4)], LEAF[3])
    for p in ((20, 8), (22, 7), (24, 6)):
        ic.put(*p, LEAF[1])
    return ic.image()


def stick():
    ic = Icon()
    ic.capsule((6.5, 26.5), (25.5, 6.5), 1.5, HANDLE)
    ic.capsule((15.5, 17.0), (12.5, 13.0), 0.8, HANDLE)  # twig stub
    for p in ((11, 21), (19, 13)):
        ic.put(*p, HANDLE[0])
    return ic.image()


TEX = {
    "item_apple": apple, "item_stick": stick, "item_coal": coal,
    "item_iron": ingot(IRON), "item_gold": ingot(GOLD),
    "item_ruby": gem(RUBY), "item_crystal": gem(CRYSTAL),
    "item_raw_iron": raw_ore(RAW_IRON), "item_raw_gold": raw_ore(RAW_GOLD),
    "item_pickaxe_wood": pickaxe(WOOD), "item_pickaxe_stone": pickaxe(STONE),
    "item_pickaxe_iron": pickaxe(IRON), "item_pickaxe_crystal": pickaxe(CRYSTAL),
    "item_axe_wood": axe(WOOD), "item_axe_stone": axe(STONE), "item_axe_iron": axe(IRON),
    "item_sword_wood": sword(WOOD, WOOD), "item_sword_stone": sword(STONE),
    "item_sword_iron": sword(IRON), "item_sword_ruby": sword(RUBY, GOLD),
}

if __name__ == "__main__":
    import sys
    os.makedirs(OUT, exist_ok=True)
    for name, fn in TEX.items():
        fn().save(os.path.join(OUT, name + ".png"))
    print("wrote", len(TEX))
    if len(sys.argv) > 1:  # optional contact sheet path
        from PIL import ImageDraw
        cols, cw, ch = 5, 150, 150
        rows = (len(TEX) + cols - 1) // cols
        sheet = Image.new("RGBA", (cols * cw, rows * ch), (128, 128, 128, 255))
        d = ImageDraw.Draw(sheet)
        for i, name in enumerate(TEX):
            t = Image.open(os.path.join(OUT, name + ".png")).resize((128, 128), Image.NEAREST)
            x, y = (i % cols) * cw + 11, (i // cols) * ch + 4
            sheet.alpha_composite(t, (x, y))
            d.text((x, y + 131), name, fill=(255, 255, 255, 255))
        sheet.save(sys.argv[1])
