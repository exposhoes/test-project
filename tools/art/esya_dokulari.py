"""Mehmet'in eşya dokusu görsellerini oyunun kullandığı dosyalara çevirir.

Kaynak: docs/kaynak-gorseller/esya-dokulari/<ad>.png
Hedef:  assets/textures/esya/dokular/<ad>.png  (kapi_ahsap.png -> assets/textures/esya/)

- Malzeme dokuları (ahşap, kumaş, metal...) sadece küçültülür.
- Ön yüz görsellerinde nesnenin etrafındaki boşluk/çerçeve kırpılır; kutular görsele bakılarak
  768 piksellik ölçüye göre yazıldı (görsel başka boyuttaysa orantılanır).

Kullanım: python tools/art/esya_dokulari.py
"""
import pathlib

from PIL import Image

KOK = pathlib.Path(__file__).resolve().parent.parent.parent
KAYNAK = KOK / "docs" / "kaynak-gorseller" / "esya-dokulari"
HEDEF = KOK / "assets" / "textures" / "esya" / "dokular"
BOY = 512
MALZEME = ["ahsap_koyu", "ahsap_acik", "beyaz_lake", "tezgah_tas", "metal_celik", "kumas_gri",
           "kumas_beyaz", "kumas_mavi", "fayans_beyaz", "beton_zemin"]
# ad: (sol, üst, sağ, alt) — 768x768 ölçüsünde.
ON_YUZ = {
    "on_dolap_kapagi": (157, 61, 609, 705),
    "on_ust_dolap": (176, 55, 582, 701),
    "on_cekmece": (4, 4, 764, 594),          # alttaki ikinci şerit atılır
    "on_gardirop_kapagi": (221, 76, 382, 711),  # iki kapaklı dolaptan tek kapak
    "on_buzdolabi": (213, 50, 541, 716),
    "on_firin": (20, 30, 748, 738),
    "ust_ocak": (22, 32, 748, 738),
    "on_tv": (98, 181, 671, 534),            # ayaklar atılır, sadece ekran ve çerçeve
    "kapi_ic": (270, 84, 500, 699),          # kasa atılır, sadece kanat
    "kapi_ahsap": (249, 64, 519, 721),
}


def kaydet(im: Image.Image, yol: pathlib.Path) -> None:
    im = im.convert("RGB")
    im.thumbnail((BOY, BOY), Image.LANCZOS)
    im.save(yol)


HEDEF.mkdir(parents=True, exist_ok=True)
for ad in MALZEME:
    k = KAYNAK / f"{ad}.png"
    if k.exists():
        kaydet(Image.open(k), HEDEF / f"{ad}.png")
        print("malzeme", ad)
for ad, kutu in ON_YUZ.items():
    k = KAYNAK / f"{ad}.png"
    if not k.exists():
        continue
    im = Image.open(k)
    o = im.width / 768.0
    parca = im.crop(tuple(int(round(v * o)) for v in kutu))
    hedef = (HEDEF.parent if ad == "kapi_ahsap" else HEDEF) / f"{ad}.png"
    kaydet(parca, hedef)
    print("ön yüz ", ad, parca.size)
