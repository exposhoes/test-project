"""Model dokusu paketler: ön | yan | üst üç kare, her birinin çevresine kenar uzatmalı dolgu.
Dolgu, uzaktan (mipmap) ve bilinear örneklemede bölgelerin birbirine sızıp kenarda
beyaz/açık çizgi yapmasını önler. CubeModel.PAD ve CELL ile aynı olmalı."""
import sys
from PIL import Image

CELL, PAD = 512, 32


def padded(img: Image.Image) -> Image.Image:
    img = img.convert("RGB").resize((CELL, CELL), Image.LANCZOS)
    out = Image.new("RGB", (CELL + 2 * PAD, CELL + 2 * PAD))
    out.paste(img, (PAD, PAD))
    # kenar pikselini dışarı uzat
    out.paste(img.crop((0, 0, CELL, 1)).resize((CELL, PAD)), (PAD, 0))
    out.paste(img.crop((0, CELL - 1, CELL, CELL)).resize((CELL, PAD)), (PAD, CELL + PAD))
    col = out.crop((PAD, 0, PAD + 1, CELL + 2 * PAD)).resize((PAD, CELL + 2 * PAD))
    out.paste(col, (0, 0))
    col = out.crop((PAD + CELL - 1, 0, PAD + CELL, CELL + 2 * PAD)).resize((PAD, CELL + 2 * PAD))
    out.paste(col, (PAD + CELL, 0))
    return out


def pack(front, side, top, path):
    w = CELL + 2 * PAD
    out = Image.new("RGB", (w * 3, w))
    for i, im in enumerate((front, side, top)):
        out.paste(padded(im), (i * w, 0))
    out.save(path)


if __name__ == "__main__":
    pack(*[Image.open(p) for p in sys.argv[1:4]], sys.argv[4])
