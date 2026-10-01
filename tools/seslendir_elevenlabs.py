"""Bölümleri ElevenLabs ile BÖLÜM BÖLÜM seslendirir; karakter hakkı yetmeyen bölüme hiç başlamaz.

Böylece bir bölümün sesleri ya tamamen ElevenLabs ya tamamen Microsoft olur (yarım kalmaz) ve
hak bitince var olan ses dosyaları silinmez. Hangi replikler ElevenLabs ile üretildi bilgisi
assets/audio/voices/_elevenlabs.json dosyasında tutulur; metni değişmeyen replik yeniden üretilmez.

Kullanım (proje klasöründe; anahtar ELEVENLABS_API_KEY ortam değişkeninde):
  godot --headless --path . --script res://tests/replik_listesi.gd -- replikler.json
  python tools/seslendir_elevenlabs.py replikler.json                # sırayla, hak yettiğince
  python tools/seslendir_elevenlabs.py replikler.json bolum1 okul1   # sadece bu bölümler
  python tools/seslendir_elevenlabs.py replikler.json --durum        # sadece özet, üretim yok
Ses kimlikleri: tools/elevenlabs_sesler.json
"""
import hashlib
import json
import os
import pathlib
import sys
import urllib.error
import urllib.request

KOK = pathlib.Path(__file__).resolve().parent.parent
SESLER_DIR = KOK / "assets" / "audio" / "voices"
KAYIT = SESLER_DIR / "_elevenlabs.json"
AYAR = json.loads((pathlib.Path(__file__).resolve().parent / "elevenlabs_sesler.json").read_text(encoding="utf-8"))


def anahtar() -> str:
    k = os.environ.get("ELEVENLABS_API_KEY", "")
    if not k and os.name == "nt":  # setx ile kaydedilen anahtar açık terminallere gelmez; kayıt defterinden oku
        import winreg
        with winreg.OpenKey(winreg.HKEY_CURRENT_USER, "Environment") as h:
            k = winreg.QueryValueEx(h, "ELEVENLABS_API_KEY")[0]
    return k.strip()


def kalan_hak() -> int:
    istek = urllib.request.Request("https://api.elevenlabs.io/v1/user/subscription", headers={"xi-api-key": anahtar()})
    with urllib.request.urlopen(istek, timeout=30) as c:
        s = json.loads(c.read().decode("utf-8"))
    return int(s["character_limit"]) - int(s["character_count"])


def uret(metin: str, ses_id: str) -> bytes:
    istek = urllib.request.Request(
        f"https://api.elevenlabs.io/v1/text-to-speech/{ses_id}?output_format=mp3_44100_128",
        data=json.dumps({"text": metin, "model_id": AYAR.get("model", "eleven_multilingual_v2"), "language_code": "tr",
                         "voice_settings": {"stability": 0.4, "similarity_boost": 0.8, "style": 0.45}}).encode(),
        headers={"xi-api-key": anahtar(), "Content-Type": "application/json", "Accept": "audio/mpeg"},
    )
    with urllib.request.urlopen(istek, timeout=90) as c:
        return c.read()


def iz(r: dict, ses_id: str) -> str:
    return hashlib.sha1((ses_id + "|" + r["metin"]).encode("utf-8")).hexdigest()[:12]


def main() -> None:
    replikler = json.loads(pathlib.Path(sys.argv[1]).read_text(encoding="utf-8"))
    istenen = [a for a in sys.argv[2:] if not a.startswith("--")]
    sadece_durum = "--durum" in sys.argv
    sesler = {k: v for k, v in AYAR["sesler"].items() if v and not v.startswith("BURAYA")}
    kayit = json.loads(KAYIT.read_text(encoding="utf-8")) if KAYIT.exists() else {}
    bolumler: dict[str, list] = {}
    for r in replikler:
        bolumler.setdefault(r["bolum"], []).append(r)
    hak = kalan_hak()
    print("Kalan karakter hakkı:", hak)
    for bolum, satirlar in bolumler.items():
        if istenen and bolum not in istenen:
            continue
        eksik = []
        for r in satirlar:
            ses_id = sesler.get(r["kim"])
            if not ses_id or not any(ch.isalnum() for ch in r["metin"]):
                continue  # sesi tanımsız karakter ya da "..." gibi okunmayan replik: Microsoft/sessiz kalır
            if kayit.get("%s/%02d" % (bolum, r["satir"])) != iz(r, ses_id):
                eksik.append((r, ses_id))
        gereken = sum(len(r["metin"]) for r, _ in eksik)
        if not eksik:
            print("%-12s tamam (ElevenLabs)" % bolum)
            continue
        if sadece_durum:
            print("%-12s bekliyor: %d replik, %d karakter" % (bolum, len(eksik), gereken))
            continue
        if gereken > hak:
            print("%-12s ATLANDI: %d karakter gerekiyor, kalan hak %d" % (bolum, gereken, hak))
            continue
        # Önce hepsini belleğe üret; biri bile başarısız olursa bölümün dosyalarına dokunma.
        try:
            uretilen = [(r, ses_id, uret(r["metin"], ses_id)) for r, ses_id in eksik]
        except urllib.error.HTTPError as hata:
            print("%-12s HATA %s: %s" % (bolum, hata.code, hata.read().decode("utf-8", "replace")[:200]))
            hak = kalan_hak()
            continue
        for r, ses_id, veri in uretilen:
            hedef = SESLER_DIR / bolum / ("%02d.mp3" % r["satir"])
            hedef.parent.mkdir(parents=True, exist_ok=True)
            hedef.write_bytes(veri)
            kayit["%s/%02d" % (bolum, r["satir"])] = iz(r, ses_id)
        KAYIT.write_text(json.dumps(kayit, indent="\t", sort_keys=True), encoding="utf-8")
        hak -= gereken
        print("%-12s üretildi: %d replik, %d karakter (kalan ~%d)" % (bolum, len(eksik), gereken, hak))
    print("Bitti. Kalan karakter hakkı:", kalan_hak())


main()
