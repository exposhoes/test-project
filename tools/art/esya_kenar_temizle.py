"""Eşya görsellerinin (assets/textures/esya/*.png) kenarındaki beyaz haleyi temizler.

Arka planı silinmiş görsellerde nesnenin kenarında yarı saydam, beyaza çalan pikseller kalır;
oyunda bu, eşyanın kenarında beyaz çizgi olarak görünür. Bu betik:
  1. yarı saydam pikselleri atar (alfa eşiği),
  2. nesnenin kenarından 2 piksel kırpar (hale tamamen gitsin),
  3. saydam alanı nesnede bulunmayan bir anahtar renge boyar; böylece oyun beyaz eşyaların
     (buzdolabı, tezgâh) beyaz kısımlarını arka plan sanıp delmez.
Kullanım: python tools/art/esya_kenar_temizle.py [dosya ...]   (dosya verilmezse klasördeki hepsi)
Asıl dosyanın yedeği yanına <ad>.png.orijinal olarak bir kez alınır (Godot bunu içe aktarmaz).
"""
import pathlib
import shutil
import sys

import numpy as np
from PIL import Image

KLASOR = pathlib.Path(__file__).resolve().parent.parent.parent / "assets" / "textures" / "esya"
ANAHTAR = (255, 0, 255)
KIRP = 2


def temizle(yol: pathlib.Path) -> None:
    yedek = yol.with_suffix(".png.orijinal")
    if not yedek.exists():
        shutil.copy(yol, yedek)
    a = np.array(Image.open(yedek).convert("RGBA"))
    dolu = a[..., 3] >= 200
    # Kenardan KIRP piksel aşındır (4 komşudan biri boşsa pikseli at).
    for _ in range(KIRP):
        ic = dolu.copy()
        ic[1:, :] &= dolu[:-1, :]
        ic[:-1, :] &= dolu[1:, :]
        ic[:, 1:] &= dolu[:, :-1]
        ic[:, :-1] &= dolu[:, 1:]
        dolu = ic
    a[..., 3] = np.where(dolu, 255, 0)
    a[~dolu, 0], a[~dolu, 1], a[~dolu, 2] = ANAHTAR
    Image.fromarray(a, "RGBA").save(yol)
    print("temizlendi:", yol.name)


dosyalar = [pathlib.Path(p) for p in sys.argv[1:]] or sorted(KLASOR.glob("*.png"))
for d in dosyalar:
    temizle(d)
