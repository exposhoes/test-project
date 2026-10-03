"""YouTube kapağına sabit stilde yazı ve logo bindirir (her kapakta aynı font, renk ve yer).

Kapak standardı (docs/youtube-kapak-ve-seo.md ile aynı):
- Boyut 1280x720; görsel ortadan kırpılıp sığdırılır.
- Yazı: Arial Black, BÜYÜK HARF, en çok iki satır; sol alt köşe (sol 44 px, alt 40 px boşluk),
  genişliğin en çok %62'si, yüksekliğin en çok %36'sı; satıra sığacak en büyük punto.
- 1. satır sarı (#FFD60A), 2. satır beyaz; kalın lacivert çerçeve (#14213D) ve siyah gölge.
- Logo: sol üst köşe, genişliğin %27'si.

Kullanım:
  python tools/art/kapak.py girdi.png cikti.jpg "ŞEHRİME" "HOŞ GELDİN!"
"""
import pathlib
import sys

from PIL import Image, ImageDraw, ImageFilter, ImageFont

KOK = pathlib.Path(__file__).resolve().parent.parent.parent
LOGO = KOK / "assets" / "textures" / "logo" / "emircraft_logo.png"
FONTLAR = [r"C:\Windows\Fonts\ariblk.ttf", r"C:\Windows\Fonts\impact.ttf"]
EN, BOY = 1280, 720
SARI, BEYAZ, CERCEVE = "#FFD60A", "#FFFFFF", "#14213D"
SOL, ALT = 44, 40
YAZI_EN, YAZI_BOY = 0.62, 0.36
CERCEVE_KALINLIK = 0.085  # punto oranı
LOGO_EN = 0.27


def sigdir(im: Image.Image) -> Image.Image:
    """Görseli 16:9'a ortadan kırpar ve 1280x720'ye getirir."""
    im = im.convert("RGB")
    oran = EN / BOY
    if im.width / im.height > oran:
        w = int(im.height * oran)
        x = (im.width - w) // 2
        im = im.crop((x, 0, x + w, im.height))
    else:
        h = int(im.width / oran)
        y = (im.height - h) // 2
        im = im.crop((0, y, im.width, y + h))
    return im.resize((EN, BOY), Image.LANCZOS)


def font_sec(punto: int) -> ImageFont.FreeTypeFont:
    for yol in FONTLAR:
        if pathlib.Path(yol).exists():
            return ImageFont.truetype(yol, punto)
    return ImageFont.load_default()


def punto_bul(satirlar: list[str]) -> int:
    """Bütün satırlar yazı alanına sığacak en büyük punto."""
    for punto in range(150, 30, -2):
        f = font_sec(punto)
        en = max(f.getbbox(s)[2] - f.getbbox(s)[0] for s in satirlar)
        boy = len(satirlar) * punto * 1.08
        if en <= EN * YAZI_EN and boy <= BOY * YAZI_BOY:
            return punto
    return 32


def kapak(girdi: str, cikti: str, satirlar: list[str]) -> None:
    im = sigdir(Image.open(girdi))
    satirlar = [s.upper().replace("İ", "İ") for s in satirlar if s]
    kat = Image.new("RGBA", im.size, (0, 0, 0, 0))
    if satirlar:
        # Yazının arkası biraz koyulaşır ki her görselde okunsun.
        golge = Image.new("L", im.size, 0)
        ImageDraw.Draw(golge).rectangle((0, int(BOY * 0.55), int(EN * 0.75), BOY), fill=120)
        golge = golge.filter(ImageFilter.GaussianBlur(90))
        im = Image.composite(Image.new("RGB", im.size, "#000000"), im, golge)
        punto = punto_bul(satirlar)
        f = font_sec(punto)
        kalin = max(4, int(punto * CERCEVE_KALINLIK))
        ciz = ImageDraw.Draw(kat)
        y = BOY - ALT - int(len(satirlar) * punto * 1.08)
        for i, s in enumerate(satirlar):
            renk = SARI if i == 0 else BEYAZ
            ciz.text((SOL + kalin, y + kalin + 3), s, font=f, fill=(0, 0, 0, 150), stroke_width=kalin, stroke_fill=(0, 0, 0, 150))
            ciz.text((SOL, y), s, font=f, fill=renk, stroke_width=kalin, stroke_fill=CERCEVE)
            y += int(punto * 1.08)
    if LOGO.exists():
        logo = Image.open(LOGO).convert("RGBA")
        logo = logo.crop(logo.getbbox())
        w = int(EN * LOGO_EN)
        logo = logo.resize((w, int(logo.height * w / logo.width)), Image.LANCZOS)
        kat.alpha_composite(logo, (24, 18))
    son = Image.alpha_composite(im.convert("RGBA"), kat).convert("RGB")
    son.save(cikti, quality=92)
    print("kapak:", cikti, son.size, "satır:", satirlar)


if __name__ == "__main__":
    kapak(sys.argv[1], sys.argv[2], sys.argv[3:5])
