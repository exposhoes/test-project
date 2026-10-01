"""Diyalogları Microsoft Edge Türkçe sesleriyle seslendirir (pip install edge-tts).

Kullanım (proje klasöründe):
  godot --headless --path . --script res://tests/replik_listesi.gd -- replikler.json
  python tools/seslendir.py replikler.json            # eksik dosyaları üretir
  python tools/seslendir.py replikler.json --hepsi    # hepsini yeniden üretir

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
    "emir":        ("tr-TR-AhmetNeural", "+70Hz", "+8%"),   # erkek çocuk
    "ali":         ("tr-TR-AhmetNeural", "+55Hz", "+12%"),  # erkek çocuk, biraz farklı
    "komsu_cocuk": ("tr-TR-AhmetNeural", "+80Hz", "+5%"),   # erkek çocuk
    "zeynep":      ("tr-TR-EmelNeural",  "+60Hz", "+5%"),   # kız çocuk
    "anne":        ("tr-TR-EmelNeural",  "+0Hz",  "+0%"),   # kadın
    "ogretmen":    ("tr-TR-EmelNeural",  "-10Hz", "-5%"),   # kadın
    "doktor":      ("tr-TR-AhmetNeural", "+0Hz",  "-3%"),   # erkek
    "bakkal":      ("tr-TR-AhmetNeural", "-15Hz", "-8%"),   # yaşlı erkek
}
VARSAYILAN = ("tr-TR-AhmetNeural", "+0Hz", "+0%")


async def main() -> None:
    replikler = json.loads(pathlib.Path(sys.argv[1]).read_text(encoding="utf-8"))
    hepsi = "--hepsi" in sys.argv
    kok = pathlib.Path(__file__).resolve().parent.parent / "assets" / "audio" / "voices"
    yapilan = 0
    for r in replikler:
        hedef = kok / r["bolum"] / ("%02d.mp3" % r["satir"])
        if hedef.exists() and not hepsi:
            continue
        hedef.parent.mkdir(parents=True, exist_ok=True)
        ses, perde, hiz = SESLER.get(r["kim"], VARSAYILAN)
        await edge_tts.Communicate(r["metin"], ses, pitch=perde, rate=hiz).save(str(hedef))
        yapilan += 1
        print(hedef.relative_to(kok), r["kim"], r["metin"][:40])
    print("bitti:", yapilan, "dosya")


asyncio.run(main())
