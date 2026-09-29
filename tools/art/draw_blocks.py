"""EmirCRAFT block textures (32x32 RGBA), deterministic pixel art."""
import math, os, random
from PIL import Image

OUT = "/home/claude/test-project/assets/textures/blocks"
N = 32


def hx(s, a=255):
    s = s.lstrip("#")
    return (int(s[0:2], 16), int(s[2:4], 16), int(s[4:6], 16), a)


def pal(*c):
    return [hx(x) for x in c]


def new(fill=(0, 0, 0, 255)):
    return Image.new("RGBA", (N, N), fill)


def noise_fill(img, p, rng, weights):
    px = img.load()
    for y in range(N):
        for x in range(N):
            px[x, y] = rng.choices(p, weights)[0]


def blob(px, cx, cy, r, col, wrap=True):
    for dy in range(-r, r + 1):
        for dx in range(-r, r + 1):
            if dx * dx + dy * dy <= r * r + r * 0.5:
                x, y = cx + dx, cy + dy
                if wrap:
                    px[x % N, y % N] = col
                elif 0 <= x < N and 0 <= y < N:
                    px[x, y] = col


# ---------------- natural ----------------
def dirt(rng):
    p = pal("8a5e38", "7a5230", "6a4628", "5a3b21", "9b6d44")
    img = new(); noise_fill(img, p[:2], rng, [1, 3]); px = img.load()
    for _ in range(14):
        x, y = rng.randrange(N), rng.randrange(N)
        px[x, y] = p[3]; px[(x + 1) % N, y] = p[2]
    for _ in range(8):
        x, y = rng.randrange(N), rng.randrange(N)
        px[x, y] = p[4]; px[x, (y + 1) % N] = p[0]
    return img


def grass_top(rng):
    p = pal("4e9430", "5da83a", "6dbb45", "3f7d26", "82cc58")
    img = new(); noise_fill(img, p[:3], rng, [2, 5, 2]); px = img.load()
    for _ in range(40):  # little blade tufts
        x, y = rng.randrange(N), rng.randrange(N)
        px[x, y] = p[3]; px[x, (y - 1) % N] = p[4]
    return img


def grass_side(rng):
    img = dirt(rng); px = img.load()
    g = pal("4e9430", "5da83a", "6dbb45", "3f7d26")
    for x in range(N):
        depth = 6 + (2 if x % 7 in (2, 3) else 0) + (1 if x % 5 == 0 else 0)
        for y in range(depth):
            px[x, y] = g[3] if y == depth - 1 else rng.choice(g[:3])
        if x % 7 == 2:
            px[x, depth] = g[3]
    return img


def stone(rng):
    p = pal("8a8a8a", "7d7d7d", "6f6f6f", "5f5f5f", "9a9a9a")
    img = new(); noise_fill(img, p[:3], rng, [2, 5, 2]); px = img.load()
    # soft cracks
    for _ in range(5):
        x, y = rng.randrange(N), rng.randrange(N)
        for i in range(rng.randint(3, 6)):
            px[x % N, y % N] = p[3]; px[x % N, (y - 1) % N] = p[4] if i % 2 else px[x % N, (y - 1) % N]
            x += 1; y += rng.choice((0, 0, 1, -1))
    return img


def cobblestone(rng):
    p = pal("4a4a4a", "5e5e5e", "6f6f6f", "808080", "939393")
    img = new(p[0]); px = img.load()
    # rough cells via Voronoi (wrapped) -> seamless
    pts = [(rng.randrange(N), rng.randrange(N)) for _ in range(11)]
    shades = [rng.choice(p[1:4]) for _ in pts]
    def near(x, y):
        best = []
        for i, (a, b) in enumerate(pts):
            dx = min(abs(x - a), N - abs(x - a)); dy = min(abs(y - b), N - abs(y - b))
            best.append((dx * dx + dy * dy, i))
        best.sort(); return best
    for y in range(N):
        for x in range(N):
            b = near(x, y)
            if math.sqrt(b[1][0]) - math.sqrt(b[0][0]) < 1.3:
                px[x, y] = p[0]
            else:
                c = shades[b[0][1]]
                a, bb = pts[b[0][1]]
                if near(x, (y + 2) % N)[0][1] != b[0][1]:
                    c = p[4]
                px[x, y] = c
    return img


def sand(rng):
    p = pal("e6d59a", "dcc98a", "cfba78", "c2ab68", "f0e2b0")
    img = new(); noise_fill(img, p[:3], rng, [3, 5, 2]); px = img.load()
    for y in (6, 22):  # gentle wind ripples
        for x in range(N):
            yy = (y + round(1.5 * math.sin(x * 2 * math.pi / N))) % N
            px[x, yy] = p[3]; px[x, (yy - 1) % N] = p[4]
    return img


def gravel(rng):
    p = pal("5e5650", "746a62", "857b73", "9a918a", "b1a9a2")
    img = new(); noise_fill(img, p[1:3], rng, [1, 1]); px = img.load()
    for _ in range(26):
        x, y, r = rng.randrange(N), rng.randrange(N), rng.choice((1, 1, 2))
        col = rng.choice(p[2:5])
        blob(px, x, y, r, col)
        px[(x + r) % N, (y + r) % N] = p[0]
    return img


def bedrock(rng):
    p = pal("1a1a1a", "2e2e2e", "444444", "5a5a5a")
    img = new(); noise_fill(img, p[:2], rng, [1, 2]); px = img.load()
    for _ in range(12):
        blob(px, rng.randrange(N), rng.randrange(N), rng.choice((1, 2)), rng.choice(p[2:4]))
    for _ in range(8):
        blob(px, rng.randrange(N), rng.randrange(N), 1, p[0])
    return img


def snow(rng):
    p = pal("f2f7fa", "e4ecf2", "d3dee8", "ffffff")
    img = new(); noise_fill(img, p[:2], rng, [4, 1]); px = img.load()
    for _ in range(10):
        x, y = rng.randrange(N), rng.randrange(N)
        px[x, y] = p[2]; px[(x + 1) % N, y] = p[3]
    return img


def log_side(rng):
    p = pal("4a3520", "5e4426", "6f5230", "3a2a18")
    img = new(); px = img.load()
    for x in range(N):
        base = p[1] if (x // 3) % 2 else p[2]
        for y in range(N):
            px[x, y] = base
    for x in range(0, N, 5):
        for y in range(N):
            if rng.random() < 0.8: px[x, y] = p[0]
    for _ in range(3):  # knots
        x, y = rng.randrange(3, N - 3), rng.randrange(N)
        px[x, y] = p[3]; px[x, (y + 1) % N] = p[3]; px[x - 1, y] = p[0]; px[x + 1, (y+1) % N] = p[0]
    return img


def log_top(rng):
    bark = pal("5e4426", "4a3520")
    p = pal("c29a62", "a9824e", "8c6a3c")
    img = new(); px = img.load()
    c = (N - 1) / 2
    for y in range(N):
        for x in range(N):
            d = max(abs(x - c), abs(y - c)) * 0.55 + math.hypot(x - c, y - c) * 0.45
            if d > 14: px[x, y] = bark[(x + y) % 2]
            elif d > 13: px[x, y] = bark[1]
            else:
                ring = int(d) % 4
                px[x, y] = p[2] if ring == 0 else (p[0] if ring == 2 else p[1])
    return img


def leaves(rng):
    p = pal("2c6e1f", "3b8a2a", "4ea135", "63b848", "1f5316")
    img = new(); px = img.load()
    for y in range(N):
        for x in range(N):
            px[x, y] = rng.choices(p[:3], [2, 4, 2])[0]
    # leaf clusters with highlight top-left, shadow bottom-right
    for _ in range(18):
        x, y = rng.randrange(N), rng.randrange(N)
        px[x, y] = p[3]; px[(x + 1) % N, y] = p[2]; px[x, (y + 1) % N] = p[2]
        px[(x + 1) % N, (y + 1) % N] = p[4]
    holes = rng.sample([(x, y) for y in range(N) for x in range(N)], int(N * N * 0.15))
    for x, y in holes:
        px[x, y] = (0, 0, 0, 0)
    return img


def planks(rng):
    p = pal("c49c62", "b08a52", "9c7644", "6e5230", "d2ad75")
    img = new(); px = img.load()
    offs = [0, 13, 5, 21]
    for y in range(N):
        row = y // 8
        for x in range(N):
            c = p[1] if (x + row) % 9 else p[2]
            if (x * 7 + y * 3 + row) % 11 == 0: c = p[0]
            if y % 8 == 0: c = p[3]
            elif y % 8 == 1: c = p[4]
            elif (x - offs[row]) % N == 0: c = p[3]
            px[x, y] = c
        # nails
    for row in range(4):
        for dx in (2, 16 + 2):
            x = (offs[row] + dx) % N
            px[x, row * 8 + 4] = p[3]
    return img


def glass(rng):
    img = new((0, 0, 0, 0)); px = img.load()
    f1, f2, hl = hx("e6f6fc"), hx("9fcfe2"), hx("ffffff", 200)
    for i in range(N):
        for t, c in ((0, f1), (1, f2)):
            px[i, t] = c; px[t, i] = c
            px[i, N - 1 - t] = f2 if t == 0 else f1; px[N - 1 - t, i] = f2 if t == 0 else f1
    for k in range(7):  # streaks
        px[5 + k, 12 - k] = hl
        px[6 + k, 12 - k] = hl
        px[9 + k, 17 - k] = hx("ffffff", 140)
    for k in range(4):
        px[22 + k, 27 - k] = hx("ffffff", 140)
    return img


def ore(color_pal, shape="blob"):
    def f(rng):
        img = stone(rng); px = img.load()
        spots = [(7, 8), (21, 6), (13, 19), (25, 22), (5, 25)]
        for cx, cy in spots:
            cx += rng.randint(-1, 1); cy += rng.randint(-1, 1)
            cells = [(0, 0), (1, 0), (0, 1), (1, 1), (-1, 0), (0, -1), (2, 1), (1, 2), (-1, 1), (2, 0), (0, 2), (1, -1)]
            for i, (dx, dy) in enumerate(cells[: rng.randint(9, 12)]):
                x, y = cx + dx, cy + dy
                if 0 <= x < N and 0 <= y < N:
                    px[x, y] = color_pal[1]
            px[cx, cy] = color_pal[2]  # highlight
            if 0 <= cx + 1 < N and 0 <= cy + 2 < N: px[cx + 1, cy + 2] = color_pal[0]
            if 0 <= cx + 2 < N and 0 <= cy + 1 < N: px[cx + 2, cy + 1] = color_pal[0]
        return img
    return f


# ---------------- crafted ----------------
def bricks(rng):
    mortar = pal("c8c2b8", "b3ada3")
    p = pal("b25646", "a24a3a", "8e3e30", "c46a58")
    img = new(); px = img.load()
    for y in range(N):
        row = y // 8
        for x in range(N):
            off = 0 if row % 2 == 0 else 8
            if y % 8 == 0 or (x + off) % 16 == 0:
                px[x, y] = mortar[0] if y % 8 == 0 else mortar[1]
            else:
                c = rng.choices(p[:3], [2, 5, 1])[0]
                if y % 8 == 1: c = p[3]
                if y % 8 == 7: c = p[2]
                px[x, y] = c
    return img


def crafting_top(rng):
    img = planks(rng); px = img.load()
    frame, dark, grid = hx("6e5230"), hx("4a3520"), hx("8a6238")
    for i in range(N):
        for t in (0, 1, 30, 31):
            px[i, t] = frame; px[t, i] = frame
    # 3x3 grid in center
    for y in range(5, 27):
        for x in range(5, 27):
            px[x, y] = hx("c8a26a") if ((x - 5) % 7 and (y - 5) % 7) else dark
    for x in range(5, 27):
        px[x, 26] = dark
    for y in range(5, 27):
        px[26, y] = dark
    return img


def crafting_side(rng):
    img = planks(rng); px = img.load()
    frame, dark, steel, steel2, handle = hx("6e5230"), hx("4a3520"), hx("a9b0b6"), hx("7c858c"), hx("5e4426")
    for i in range(N):
        for t in (0, 1, 30, 31):
            px[i, t] = frame; px[t, i] = frame
    # dark backboard band with a hammer and saw
    for y in range(4, 16):
        for x in range(3, 29):
            px[x, y] = hx("8a6238")
    # hammer
    for y in range(6, 15): px[9, y] = handle; px[10, y] = handle
    for x in range(6, 14):
        for y in (5, 6, 7): px[x, y] = steel if y < 7 else steel2
    # saw
    for x in range(16, 27):
        for y in range(8, 12): px[x, y] = steel if y < 11 else steel2
        if x % 2 == 0: px[x, 12] = steel2
    for y in range(7, 13): px[15, y] = handle; px[14, y] = handle
    return img


def furnace_side(rng):
    p = pal("5a5a5a", "6e6e6e", "7c7c7c", "3a3a3a")
    img = new(); noise_fill(img, p[:3], rng, [2, 5, 2]); px = img.load()
    for i in range(N):
        for t in (0, N - 1):
            px[i, t] = p[3]; px[t, i] = p[3]
    # stone block lines
    for x in range(1, N - 1): px[x, 10] = p[0]
    # mouth
    for y in range(13, 28):
        for x in range(8, 24):
            px[x, y] = hx("1a1a1a")
    for x in range(7, 25): px[x, 12] = p[3]; px[x, 28] = p[3]
    for y in range(12, 29): px[7, y] = p[3]; px[24, y] = p[3]
    # embers
    emb = pal("e8741c", "f7c948", "b8401a", "ffe8a0")
    for y in range(21, 28):
        for x in range(8, 24):
            h = 21 + abs(math.sin(x * 0.9)) * 3
            if y >= h:
                px[x, y] = rng.choices(emb, [4, 3, 2, 1])[0]
    # grate bars
    for x in range(8, 24, 4):
        for y in range(13, 20): px[x, y] = hx("2a2a2a")
    return img


def furnace_top(rng):
    p = pal("6a6a6a", "7a7a7a", "888888", "3a3a3a")
    img = new(); noise_fill(img, p[:3], rng, [2, 5, 2]); px = img.load()
    for i in range(N):
        for t in (0, N - 1):
            px[i, t] = p[3]; px[t, i] = p[3]
    # chimney vent
    for y in range(10, 22):
        for x in range(10, 22):
            edge = x in (10, 21) or y in (10, 21)
            px[x, y] = p[3] if edge else (hx("222222") if (y % 3) else hx("555555"))
    return img


# ---------------- backrooms / playroom ----------------
def yellow_wallpaper(rng):
    p = pal("d9cc74", "cfc26a", "b8ab58", "e6da8c")
    img = new(); px = img.load()
    for y in range(N):
        for x in range(N):
            m = x % 8
            c = p[1]
            if m == 0: c = p[2]
            elif m == 1: c = p[3]
            elif m == 4: c = p[0]
            if m == 4 and y % 8 == 3: c = p[2]  # small diamond motif
            if m in (3, 5) and y % 8 == 4: c = p[2]
            if m == 4 and y % 8 == 5: c = p[2]
            if rng.random() < 0.05: c = p[2] if c != p[2] else p[1]
            px[x, y] = c
    return img


def damp_carpet(rng):
    p = pal("b3a466", "a99a5c", "9a8b50", "857744", "746838")
    img = new(); noise_fill(img, p[:3], rng, [2, 4, 2]); px = img.load()
    # fibre texture: alternate diagonal
    for y in range(N):
        for x in range(N):
            if (x + y * 2) % 4 == 0: px[x, y] = p[2]
    # damp stain (wrapped blob)
    for y in range(N):
        for x in range(N):
            dx = min(abs(x - 20), N - abs(x - 20)); dy = min(abs(y - 12), N - abs(y - 12))
            d = math.hypot(dx * 1.2, dy)
            if d < 7 + math.sin(x * 0.8) * 1.2:
                px[x, y] = p[3] if d < 5 else p[4] if d > 6 else p[3]
    return img


def toy_brick(base, light, dark, shadow):
    def f(rng):
        img = new(hx(base)); px = img.load()
        for y in range(N):
            for x in range(N):
                if y % 16 == 15 or x % 16 == 15: px[x, y] = hx(dark)
                elif y % 16 == 0 or x % 16 == 0: px[x, y] = hx(light)
        for cy in (8, 24):
            for cx in (8, 24):
                for y in range(N):
                    for x in range(N):
                        d = math.hypot(x - cx + 0.5, y - cy + 0.5)
                        if d < 5:
                            px[x, y] = hx(light) if (x - cx) + (y - cy) < -2 else hx(base)
                        elif d < 6 and (x - cx) + (y - cy) > 0:
                            px[x, y] = hx(shadow)
                # stud highlight
                px[cx - 2, cy - 3] = hx("ffffff"); px[cx - 3, cy - 2] = hx("ffffff")
        return img
    return f


def ceiling_tile(rng):
    p = pal("e3ddc4", "d9d3b8", "c9c2a4", "a39c80")
    img = new(); noise_fill(img, p[:2], rng, [1, 3]); px = img.load()
    for _ in range(40):  # acoustic pinholes
        px[rng.randrange(N), rng.randrange(N)] = p[2]
    for i in range(N):
        px[i, 0] = p[3]; px[0, i] = p[3]; px[i, 16] = p[3]; px[16, i] = p[3]
        px[i, 1] = p[0]; px[1, i] = p[0]; px[i, 17] = p[0]; px[17, i] = p[0]
    return img


def ceiling_light(rng):
    frame, inner = hx("b8b29a"), hx("8f8a74")
    img = new(frame); px = img.load()
    for i in range(N):
        px[i, 0] = inner; px[0, i] = inner; px[i, N - 1] = inner; px[N - 1, i] = inner
    for y in range(3, N - 3):
        for x in range(3, N - 3):
            px[x, y] = hx("fffbe6") if (y - 3) % 9 else hx("e8e2c4")
    for y in (7, 16, 25):
        for x in range(5, N - 5):
            px[x, y] = hx("ffffff")
    return img


def playroom_wall(rng):
    p = pal("a9d6f0", "9accea", "bfe2f6")
    img = new(); px = img.load()
    for y in range(N):
        for x in range(N):
            px[x, y] = p[0] if ((x + y) // 4) % 2 == 0 else p[1]
    star, star2 = hx("fdf6c8"), hx("f2d86a")
    def st(cx, cy):
        for dx, dy in ((0, 0), (1, 0), (-1, 0), (0, 1), (0, -1)): px[(cx + dx) % N, (cy + dy) % N] = star
        for dx, dy in ((2, 0), (-2, 0), (0, 2), (0, -2)): px[(cx + dx) % N, (cy + dy) % N] = star2
    st(6, 7); st(22, 22)
    # clouds
    for cx, cy in ((22, 6), (7, 24)):
        for dx in range(-3, 4):
            for dy in range(-1, 2):
                if abs(dx) + abs(dy) < 4: px[(cx + dx) % N, (cy + dy) % N] = hx("ffffff")
        px[cx - 1, cy - 2] = hx("ffffff"); px[cx, cy - 2] = hx("ffffff")
    return img


def portal_frame(px):
    wood, dark, light = hx("8d6e42"), hx("5e4426"), hx("a88452")
    for y in range(N):
        for x in range(N):
            if x < 4 or x >= N - 4 or y < 3:
                c = wood
                if x in (0, N - 1) or y == 0: c = dark
                elif x in (3, N - 4) or y == 2: c = dark
                elif x == 1 or y == 1: c = light
                px[x, y] = c
    # base threshold
    for x in range(N):
        px[x, N - 1] = dark


def halls_portal(rng):
    img = new(); px = img.load()
    glow = pal("f7ec9a", "e8d56a", "d4bf4a", "fffbd8")
    for y in range(N):
        for x in range(N):
            v = 0.5 + 0.5 * math.sin(y * 0.45 + x * 0.25)
            d = abs(x - 15.5) / 12
            idx = 3 if (v > 0.85 and d < 0.5) else 0 if v > 0.5 else 1 if v > 0.2 else 2
            px[x, y] = glow[idx]
    portal_frame(px)
    return img


def factory_portal(rng):
    img = new(); px = img.load()
    cols = pal("e85a8a", "f2c230", "2f6fd9", "5ac86a")
    for y in range(N):
        for x in range(N):
            ang = math.atan2(y - 17, x - 15.5); r = math.hypot(x - 15.5, y - 17)
            band = int((ang / (2 * math.pi) * 4 + r / 5) * 1) % 4
            px[x, y] = cols[band]
            if r < 2: px[x, y] = hx("ffffff")
    portal_frame(px)
    return img


def lantern(rng):
    iron, iron2 = hx("2a2522"), hx("46403a")
    img = new(iron); px = img.load()
    for y in range(3, N - 3):
        for x in range(3, N - 3):
            d = math.hypot(x - 15.5, (y - 17) * 0.8) / 13
            px[x, y] = hx("fff3c0") if d < 0.2 else hx("ffe07a") if d < 0.45 else hx("ffd35a") if d < 0.75 else hx("e8a83a")
    for i in range(N):  # cross bars
        px[15, i] = iron; px[16, i] = iron2; px[i, 15] = iron; px[i, 16] = iron2
    for i in range(N):
        px[i, 2] = iron2; px[2, i] = iron2; px[i, N - 3] = iron2; px[N - 3, i] = iron2
    # flame in the lower-center cells
    fl = [(0, 0, "fff8d8"), (0, -1, "ffe07a"), (0, -2, "f29a2a"), (-1, 0, "f29a2a"), (1, 0, "f29a2a"), (0, 1, "e8741c")]
    for cx, cy in ((9, 10), (22, 10), (9, 23), (22, 23)):
        for dx, dy, c in fl: px[cx + dx, cy + dy] = hx(c)
    return img


def bed_top(rng):
    # Kırmızı yorgan, üstte beyaz yastık, ahşap kenar.
    img = new(hx("c8323c"))
    px = img.load()
    red, dark, light = hx("c8323c"), hx("962028"), hx("e05a62")
    wood, wood_d = hx("8a5a32"), hx("5e3c1e")
    for y in range(32):
        for x in range(32):
            if x < 2 or x > 29 or y < 2 or y > 29:
                px[x, y] = wood_d if (x in (0, 31) or y in (0, 31)) else wood
            elif y < 11:
                px[x, y] = hx("f2efe6") if 4 <= x <= 27 and 4 <= y <= 9 else hx("d8d2c4")
            else:
                c = red
                if (x + y) % 8 == 0:
                    c = light
                elif y == 11 or (x - 2) % 9 == 0:
                    c = dark
                px[x, y] = c
    return img


def bed_side(rng):
    # Ahşap ayaklar üstünde yorgan kenarı; blok tam küp olduğu için boşluklar koyu ahşap.
    img = new(hx("4a2f18"))
    px = img.load()
    for y in range(32):
        for x in range(32):
            if y < 6:
                continue
            if y < 18:
                px[x, y] = hx("962028") if y in (6, 17) else (hx("e05a62") if (x + y) % 8 == 0 else hx("c8323c"))
            elif y < 24:
                px[x, y] = hx("5e3c1e") if y in (18, 23) else hx("8a5a32")
            elif x < 5 or x > 26:
                px[x, y] = hx("5e3c1e") if x in (0, 4, 27, 31) else hx("8a5a32")
    return img


def chest_side(rng):
    # Ahşap tahtalar, koyu kenarlar, ortada metal kilit.
    img = new(hx("a8733e"))
    px = img.load()
    for y in range(32):
        for x in range(32):
            c = hx("a8733e")
            if y % 8 == 0:
                c = hx("7a4f28")
            elif (x * 3 + y * 5 + rng.randrange(4)) % 11 == 0:
                c = hx("b8844c")
            if x < 2 or x > 29 or y < 2 or y > 29:
                c = hx("5a3a1c")
            if y in (12, 13):
                c = hx("5a3a1c")
            px[x, y] = c
    for y in range(10, 19):
        for x in range(13, 19):
            px[x, y] = hx("3a3a3a") if x in (13, 18) or y in (10, 18) else hx("d8d8d0")
    px[15, 15] = px[16, 15] = hx("3a3a3a")
    return img


def chest_top(rng):
    img = new(hx("a8733e"))
    px = img.load()
    for y in range(32):
        for x in range(32):
            c = hx("b07a42") if (x // 8) % 2 else hx("a8733e")
            if x % 8 == 0:
                c = hx("7a4f28")
            if x < 2 or x > 29 or y < 2 or y > 29:
                c = hx("5a3a1c")
            px[x, y] = c
    return img


def berry_bush(rng):
    # Sık yapraklı çalı, kırmızı çilekler; kenarlarda az boşluk.
    img = new(hx("3f7a2a"))
    px = img.load()
    greens = [hx("2f5e1e"), hx("3f7a2a"), hx("4f9434"), hx("62a842")]
    for y in range(32):
        for x in range(32):
            px[x, y] = greens[rng.randrange(4)]
            if (x < 2 or x > 29 or y < 2) and rng.random() < 0.5:
                px[x, y] = (0, 0, 0, 0)
    for _ in range(9):
        cx, cy = rng.randrange(3, 28), rng.randrange(3, 28)
        for dx, dy in ((0, 0), (1, 0), (0, 1), (1, 1)):
            px[cx + dx, cy + dy] = hx("e0303c")
        px[cx, cy] = hx("ff8a94")
        px[cx + 1, cy + 1] = hx("9a1a24")
    return img


TEX = {
    "grass_side": grass_side, "grass_top": grass_top, "dirt": dirt, "stone": stone,
    "cobblestone": cobblestone, "sand": sand, "gravel": gravel, "log_side": log_side,
    "log_top": log_top, "leaves": leaves, "planks": planks, "glass": glass, "bedrock": bedrock,
    "coal_ore": ore(pal("0e0e0e", "1c1c1c", "3a3a3a")),
    "iron_ore": ore(pal("a8704a", "d8a47f", "f0cfae")),
    "gold_ore": ore(pal("b8900e", "f2cf3c", "fff1a0")),
    "ruby_ore": ore(pal("8e1022", "d8263f", "ff8a9a")),
    "crystal_ore": ore(pal("1a9aa0", "45e0e6", "d8ffff")),
    "snow": snow, "bricks": bricks, "crafting_side": crafting_side, "crafting_top": crafting_top,
    "yellow_wallpaper": yellow_wallpaper, "damp_carpet": damp_carpet,
    "toy_brick_red": toy_brick("d9343a", "f06a6e", "a8222a", "b82a30"),
    "toy_brick_blue": toy_brick("2f6fd9", "6a9cf0", "1f4ea8", "2658b8"),
    "toy_brick_yellow": toy_brick("f2c230", "ffe07a", "c89a18", "d8a820"),
    "furnace_side": furnace_side, "furnace_top": furnace_top, "halls_portal": halls_portal,
    "ceiling_tile": ceiling_tile, "ceiling_light": ceiling_light, "factory_portal": factory_portal,
    "playroom_wall": playroom_wall, "lantern": lantern,
    "bed_top": bed_top, "bed_side": bed_side,
    "chest_side": chest_side, "chest_top": chest_top,
    "berry_bush": berry_bush,
}

if __name__ == "__main__":
    os.makedirs(OUT, exist_ok=True)
    for i, (name, fn) in enumerate(TEX.items()):
        rng = random.Random(1000 + i * 7919)
        fn(rng).save(os.path.join(OUT, name + ".png"))
    # contact sheet
    from PIL import ImageDraw
    cols, cw, ch = 7, 150, 150
    rows = (len(TEX) + cols - 1) // cols
    sheet = Image.new("RGBA", (cols * cw, rows * ch), (60, 40, 70, 255))
    d = ImageDraw.Draw(sheet)
    for i, name in enumerate(TEX):
        t = Image.open(os.path.join(OUT, name + ".png")).resize((128, 128), Image.NEAREST)
        x, y = (i % cols) * cw + 11, (i // cols) * ch + 4
        sheet.alpha_composite(t, (x, y))
        d.text((x, y + 131), name, fill=(255, 255, 255, 255))
    sheet.save(os.path.join(os.path.dirname(os.path.abspath(__file__)), "blocks_sheet.png"))
    print("wrote", len(TEX))
