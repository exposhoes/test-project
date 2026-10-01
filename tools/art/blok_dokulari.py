"""Mehmet'in gerçekçi blok görsellerini oyunun blok dokularına çevirir.

Kaynak: docs/kaynak-gorseller/bloklar-gercekci/<ad>.png (1024x1024, arka planı beyaz olabilir)
Hedef:  assets/textures/blocks/<ad>.png (256x256; oyun atlasa 128 piksel olarak alır)

- Düz dokular (duvar, çatı, zemin) sadece küçültülür.
- Çit ve balkon korkuluğu: beyaz arka plan saydam yapılır, nesne bloğun tabanına oturtulur.
- Pencere: tek görselden (window_top.png, tam pencere) çerçeve alınır, camlar saydam yapılır ve
  iki blok yüksekliğindeki pencere üst/alt yarıya bölünür (window_top.png, window_bottom.png).

Kullanım: python tools/art/blok_dokulari.py
"""
import pathlib

import numpy as np
from PIL import Image, ImageDraw

KOK = pathlib.Path(__file__).resolve().parent.parent.parent
KAYNAK = KOK / "docs" / "kaynak-gorseller" / "bloklar-gercekci"
HEDEF = KOK / "assets" / "textures" / "blocks"
BOY = 256
DUZ = ["asphalt", "bricks", "cobblestone", "concrete", "dark_planks", "facade_cream", "grass_top",
       "planks", "plaster", "roof_terracotta", "stone_base", "trim_white"]
# Beyaz arka planlı, aralıkları saydam olacak dokular: ad -> bloğun yüksekliğine oranı.
ARALIKLI = {"fence_white": 0.8, "balcony_rail": 1.0}
# window_top.png içindeki pencere: (çerçeve kutusu, cam kutuları) piksel olarak.
PENCERE_CERCEVE = (135, 135, 890, 826)
PENCERE_CAMLAR = [(198, 198, 460, 780), (565, 198, 826, 780)]


def duz(ad: str) -> None:
    Image.open(KAYNAK / f"{ad}.png").convert("RGB").resize((BOY, BOY), Image.LANCZOS).save(HEDEF / f"{ad}.png")


def aralikli(ad: str, yukseklik: float) -> None:
    a = np.array(Image.open(KAYNAK / f"{ad}.png").convert("RGB")).astype(int)
    dolu = a.min(axis=2) < 244  # beyaz arka plan dışı
    ys, xs = np.where(dolu)
    kutu = (xs.min(), ys.min(), xs.max() + 1, ys.max() + 1)
    rgba = np.dstack([a, np.where(dolu, 255, 0)]).astype(np.uint8)
    parca = Image.fromarray(rgba, "RGBA").crop(kutu)
    h = int(BOY * yukseklik)
    parca = parca.resize((BOY, h), Image.LANCZOS)
    alfa = np.array(parca)[..., 3]
    p = np.array(parca)
    p[..., 3] = np.where(alfa >= 128, 255, 0)  # oyun alfa kesmesi kullanıyor: yarı saydam kenar bırakma
    tuval = Image.new("RGBA", (BOY, BOY), (0, 0, 0, 0))
    tuval.paste(Image.fromarray(p, "RGBA"), (0, BOY - h))
    tuval.save(HEDEF / f"{ad}.png")


def pencere() -> None:
    kaynak = Image.open(KAYNAK / "window_top.png").convert("RGBA")
    x0, y0, x1, y1 = PENCERE_CERCEVE
    a = np.array(kaynak)
    for cx0, cy0, cx1, cy1 in PENCERE_CAMLAR:
        a[cy0:cy1, cx0:cx1, 3] = 0
    tam = Image.fromarray(a, "RGBA").crop(PENCERE_CERCEVE).resize((BOY, BOY * 2), Image.LANCZOS)
    p = np.array(tam)
    p[..., 3] = np.where(p[..., 3] >= 128, 255, 0)
    tam = Image.fromarray(p, "RGBA")
    # Camda birkaç ince ışık yansıması (cam olduğu anlaşılsın).
    ciz = ImageDraw.Draw(tam)
    sx, sy = BOY / (x1 - x0), BOY * 2 / (y1 - y0)
    for cx0, cy0, cx1, cy1 in PENCERE_CAMLAR:
        gx0, gy0 = (cx0 - x0) * sx, (cy0 - y0) * sy
        gw, gh = (cx1 - cx0) * sx, (cy1 - cy0) * sy
        for kay in (0.25, 0.4):
            ciz.line([(gx0 + gw * (kay + 0.3), gy0 + gh * 0.12), (gx0 + gw * kay, gy0 + gh * 0.42)],
                     fill=(235, 245, 255, 255), width=2)
    tam.crop((0, 0, BOY, BOY)).save(HEDEF / "window_top.png")
    tam.crop((0, BOY, BOY, BOY * 2)).save(HEDEF / "window_bottom.png")


for ad in DUZ:
    if (KAYNAK / f"{ad}.png").exists():
        duz(ad)
        print("düz     ", ad)
for ad, oran in ARALIKLI.items():
    aralikli(ad, oran)
    print("aralıklı", ad)
pencere()
print("pencere  window_top, window_bottom")
