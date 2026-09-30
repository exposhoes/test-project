"""Model dokusu paketler: ön | yan | üst üç kare, her birinin çevresine kenar uzatmalı dolgu.
Dolgu, uzaktan (mipmap) ve bilinear örneklemede bölgelerin birbirine sızıp kenarda
beyaz/açık çizgi yapmasını önler. CubeModel.PAD ve CELL ile aynı olmalı."""
import sys
from PIL import Image

CELL, PAD = 512, 32


def trim_edges(img: Image.Image, extra: int = 6, limit: int = 24) -> Image.Image:
    """Kenardaki parlak (kenar parlaması) ya da siyah (arka plan) satır/sütunları kırpar, sonra
    `extra` piksel daha içeri girer. Böylece bloğun kenarlarında beyaz/koyu çizgi kalmaz."""
    img = img.convert("RGB")
    w, h = img.size
    px = img.load()

    def bad(vals):
        m = sum(sum(v) / 3 for v in vals) / len(vals)
        return m > 175 or m < 35

    l, t, r, b = 0, 0, w, h
    for _ in range(limit):
        if bad([px[l, y] for y in range(t, b)]): l += 1
        if bad([px[r - 1, y] for y in range(t, b)]): r -= 1
        if bad([px[x, t] for x in range(l, r)]): t += 1
        if bad([px[x, b - 1] for x in range(l, r)]): b -= 1
    return img.crop((l + extra, t + extra, r - extra, b - extra))


def padded(img: Image.Image) -> Image.Image:
    img = img.convert("RGBA").resize((CELL, CELL), Image.LANCZOS)
    out = Image.new("RGBA", (CELL + 2 * PAD, CELL + 2 * PAD))
    out.paste(img, (PAD, PAD))
    # kenar pikselini dışarı uzat
    out.paste(img.crop((0, 0, CELL, 1)).resize((CELL, PAD)), (PAD, 0))
    out.paste(img.crop((0, CELL - 1, CELL, CELL)).resize((CELL, PAD)), (PAD, CELL + PAD))
    col = out.crop((PAD, 0, PAD + 1, CELL + 2 * PAD)).resize((PAD, CELL + 2 * PAD))
    out.paste(col, (0, 0))
    col = out.crop((PAD + CELL - 1, 0, PAD + CELL, CELL + 2 * PAD)).resize((PAD, CELL + 2 * PAD))
    out.paste(col, (PAD + CELL, 0))
    return out


def cutout(img: Image.Image, dark: int = 28) -> Image.Image:
    """Siyah arka planı şeffaf yapar (masa gibi altı açık modeller için)."""
    img = img.convert("RGBA")
    px = img.load()
    for y in range(img.height):
        for x in range(img.width):
            r, g, b, _ = px[x, y]
            if max(r, g, b) < dark:
                px[x, y] = (r, g, b, 0)
    # Kenardaki açık renkli kenar yumuşatma piksellerini at (beyaz hale bırakmasın).
    from PIL import ImageFilter
    alpha = img.getchannel("A").filter(ImageFilter.MinFilter(9))
    # Şeffaf piksellerin rengini komşu ahşap rengiyle doldur (uzaktan koyu/açık sızma olmasın).
    solid = img.copy()
    solid.putalpha(alpha)
    fill = Image.new("RGBA", img.size)
    for radius in (4, 12, 32):
        blurred = solid.filter(ImageFilter.GaussianBlur(radius))
        fill = Image.alpha_composite(blurred, fill) if fill.getbbox() else blurred
    rgb = Image.alpha_composite(fill, solid).convert("RGB")
    rgb.putalpha(alpha)
    return rgb


def pack(front, side, top, path):
    w = CELL + 2 * PAD
    out = Image.new("RGBA", (w * 3, w))
    for i, im in enumerate((front, side, top)):
        out.paste(padded(im), (i * w, 0))
    out.save(path)


if __name__ == "__main__":
    pack(*[Image.open(p) for p in sys.argv[1:4]], sys.argv[4])
