"""Mehmet'in görsellerinden (tools/art/sources) model dokularını ve blok simgelerini üretir.
Çalıştır: python3 tools/art/build_models.py"""
import os, sys
sys.path.insert(0, os.path.dirname(__file__))
from PIL import Image
from pack_model_texture import pack, cutout, trim_edges

SRC = os.path.join(os.path.dirname(__file__), "sources")
M = "assets/textures/models/"
B = "assets/textures/blocks/"


def src(name):
    return Image.open(os.path.join(SRC, name)).convert("RGB")


def icon(img, path):
    img.convert("RGB").resize((128, 128), Image.LANCZOS).save(path)


# Kitaplık: ön | ahşap yan | ahşap üst
im = src("kitaplik.png")
front = trim_edges(im.crop((54, 94, 506, 656)))
wood = trim_edges(im.crop((570, 130, 695, 630)))
pack(front, wood, wood, M + "bookshelf.png"); icon(front, B + "bookshelf.png")

# Sandık: kilitli ön | bantlı yan | bantlı üst
im = src("sandik.png")
front = trim_edges(im.crop((74, 231, 438, 544)))
top = trim_edges(im.crop((945, 245, 1300, 517)))
pack(front, top, top, M + "chest.png"); icon(front, B + "chest_side.png"); icon(top, B + "chest_top.png")

# Çalışma masası: altı açık, siyah arka plan şeffaf
im = src("calisma_masasi.png")
front = cutout(im.crop((62, 276, 458, 556)))
side = cutout(im.crop((548, 276, 833, 556)))
top = trim_edges(im.crop((944, 268, 1300, 508)))
pack(front, side, top, M + "crafting_table.png"); icon(front, B + "crafting_side.png"); icon(top, B + "crafting_top.png")

# Fırın: alevli ön | tuğla yan | bacalı üst (üstteki taş kapak ve baca küpe sığmadığı için dışarıda)
im = src("firin.png")
front = trim_edges(im.crop((82, 290, 448, 576)))
side = trim_edges(im.crop((530, 290, 848, 576)))
top = trim_edges(im.crop((926, 198, 1318, 578)))
pack(front, side, top, M + "furnace.png"); icon(front, B + "furnace_side.png"); icon(top, B + "furnace_top.png")
print("tamam")

# Fener: gövde ve sap, siyah arka plan şeffaf; üstte kademeli kapak
im = src("fener.png")
front = cutout(im.crop((110, 147, 428, 579)))
side = cutout(im.crop((529, 146, 847, 579)))
top = trim_edges(im.crop((940, 215, 1295, 566)))
pack(front, side, top, M + "lantern.png"); icon(front, B + "lantern.png")
print("fener tamam")
