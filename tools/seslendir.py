"""Diyalogları Microsoft Edge Türkçe sesleriyle seslendirir (pip install edge-tts).

Kullanım (proje klasöründe):
  godot --headless --path . --script res://tests/replik_listesi.gd -- replikler.json
  python tools/seslendir.py replikler.json            # eksik dosyaları üretir
  python tools/seslendir.py replikler.json --hepsi    # hepsini yeniden üretir
  python tools/seslendir.py replikler.json --kim emir,anne   # sadece bu karakterleri yeniden üretir

Çıktı: assets/audio/voices/<bölüm>/<NN>.mp3 (oyun bunu otomatik çalar).
Türkçe'de iki ses var: Ahmet (erkek) ve Emel (kadın). Çocuk sesleri bunların
inceltilmiş hâli; her karakterin tonu aşağıdaki tabloda sabittir.
"""
import asyncio
import json
import pathlib
import sys

import edge_tts

# karakter: (ses, perde, hız). Perde Hz cinsinden; + ince, - kalın.
SESLER = {
    "emir":        ("tr-TR-EmelNeural",  "+45Hz", "+6%"),   # ince erkek çocuk sesi (Mehmet istedi)
    "ali":         ("tr-TR-EmelNeural",  "+35Hz", "+12%"),  # ince erkek çocuk sesi (Mehmet istedi), biraz farklı
    "komsu_cocuk": ("tr-TR-EmelNeural",  "+55Hz", "+3%"),   # erkek çocuk
    "zeynep":      ("tr-TR-EmelNeural",  "+60Hz", "+5%"),   # kız çocuk
    "anne":        ("tr-TR-EmelNeural",  "-20Hz", "+8%"),   # olgun anne sesi: biraz kalın, canlı ve hızlı (Mehmet istedi)
    "ogretmen":    ("tr-TR-EmelNeural",  "-5Hz",  "+10%"),  # kadın, canlı ve hızlı (Mehmet istedi)
    "doktor":      ("tr-TR-AhmetNeural", "+0Hz",  "-3%"),   # erkek
    "bakkal":      ("tr-TR-AhmetNeural", "-15Hz", "-8%"),   # yaşlı erkek
}
VARSAYILAN = ("tr-TR-AhmetNeural", "+0Hz", "+0%")


# Tüm karakterlere eklenen hız (Mehmet "konuşmaları hızlandır" dedi).
GENEL_HIZ = 15


def _hz(v: str) -> int:
    return int(v.replace("Hz", ""))


def _yuzde(v: str) -> int:
    return int(v.replace("%", ""))


def duygu(metin: str, perde: str, hiz: str) -> tuple[str, str]:
    """Replikteki işaretlere göre ton: ünlem heyecanlı (ince, hızlı), soru meraklı,
    üç nokta durgun/üzgün (yavaş, kalın), kahkaha neşeli."""
    p, h = _hz(perde), _yuzde(hiz)
    kucuk = metin.lower()
    if "?!" in metin or "!!" in metin:
        p, h = p + 18, h + 15
    elif "!" in metin:
        p, h = p + 10, h + 10
    elif "?" in metin:
        p, h = p + 8, h + 4
    if "haha" in kucuk or "hihi" in kucuk:
        p, h = p + 12, h + 8
    if metin.rstrip().endswith("...") or "eyvah" in kucuk or "üzgün" in kucuk:
        p, h = p - 8, h - 10
    return f"{p:+d}Hz", f"{h + GENEL_HIZ:+d}%"


async def main() -> None:
    replikler = json.loads(pathlib.Path(sys.argv[1]).read_text(encoding="utf-8"))
    hepsi = "--hepsi" in sys.argv
    kimler = set()
    if "--kim" in sys.argv:
        kimler = set(sys.argv[sys.argv.index("--kim") + 1].split(","))
    kok = pathlib.Path(__file__).resolve().parent.parent / "assets" / "audio" / "voices"
    yapilan = 0
    for r in replikler:
        hedef = kok / r["bolum"] / ("%02d.mp3" % r["satir"])
        if kimler and r["kim"] not in kimler:
            continue
        if hedef.exists() and not hepsi and not kimler:
            continue
        hedef.parent.mkdir(parents=True, exist_ok=True)
        ses, perde, hiz = SESLER.get(r["kim"], VARSAYILAN)
        perde, hiz = duygu(r["metin"], perde, hiz)
        try:
            await edge_tts.Communicate(r["metin"], ses, pitch=perde, rate=hiz).save(str(hedef))
        except Exception as hata:  # "..." gibi okunacak sesi olmayan replik ya da ağ hatası: atla, sonra tekrar denenir
            hedef.unlink(missing_ok=True)
            print("ATLANDI", r["bolum"], r["satir"], repr(r["metin"][:40]), type(hata).__name__)
            continue
        yapilan += 1
        print(hedef.relative_to(kok), r["kim"], r["metin"][:40])
    print("bitti:", yapilan, "dosya")


asyncio.run(main())
