"""Bölümleri ElevenLabs ile BÖLÜM BÖLÜM seslendirir; karakter hakkı yetmeyen bölüme hiç başlamaz.

- Bir bölümün sesleri ya tamamen üretilir ya hiç dokunulmaz; hata olursa var olan dosyalar silinmez.
- Hangi replik hangi sesle üretildi bilgisi assets/audio/voices/_elevenlabs.json dosyasında tutulur;
  metni ve sesi değişmeyen replik yeniden üretilmez (hak boşa gitmez).
- Ses sabitliği: ElevenLabs aynı sesi her üretimde biraz farklı (kalın/ince) okuyabiliyor. Karakterin
  hedef perdesi (tools/elevenlabs_sesler.json "hedef_perde", Hz) yazılıysa her replik hedefe yakın çıkana
  kadar birkaç kez denenir ve en yakını seçilir. (numpy ve ffmpeg gerekir; yoksa tek deneme yapılır.)

Kullanım (proje klasöründe; anahtar ELEVENLABS_API_KEY ortam değişkeninde):
  godot --headless --path . --script res://tests/replik_listesi.gd -- replikler.json
  python tools/seslendir_elevenlabs.py replikler.json                    # sırayla, hak yettiğince
  python tools/seslendir_elevenlabs.py replikler.json bolum1 okul1       # sadece bu bölümler
  python tools/seslendir_elevenlabs.py replikler.json okul1 --kim emir --zorla   # bu karakteri yeniden üret
  python tools/seslendir_elevenlabs.py replikler.json --durum            # sadece özet, üretim yok
"""
import hashlib
import json
import os
import pathlib
import shutil
import subprocess
import sys
import tempfile
import urllib.error
import urllib.request

KOK = pathlib.Path(__file__).resolve().parent.parent
SESLER_DIR = KOK / "assets" / "audio" / "voices"
KAYIT = SESLER_DIR / "_elevenlabs.json"
AYAR = json.loads((pathlib.Path(__file__).resolve().parent / "elevenlabs_sesler.json").read_text(encoding="utf-8"))
HEDEF_PERDE = AYAR.get("hedef_perde", {})
PERDE_PAYI = float(AYAR.get("perde_payi", 0.1))
DENEME = int(AYAR.get("deneme", 4))
FFMPEG = shutil.which("ffmpeg") or r"C:\ffmpeg\ffmpeg.exe"


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


def ayar(kim: str) -> dict:
    """Karakterin sabit ses ayarı (tools/elevenlabs_sesler.json > ayarlar); her bölümde aynı ses çıkması için."""
    a = AYAR.get("ayarlar", {})
    return {k: v for k, v in {**a.get("varsayilan", {}), **a.get(kim, {})}.items() if k != "seed"}


def uret(r: dict, ses_id: str, tohum: int, onceki: str = "", sonraki: str = "") -> bytes:
    # Komşu replikler (previous_text/next_text) tonlamayı sahneye uygun ve duygulu yapar.
    istek = urllib.request.Request(
        f"https://api.elevenlabs.io/v1/text-to-speech/{ses_id}?output_format=mp3_44100_128",
        data=json.dumps({"text": r["metin"], "model_id": AYAR.get("model", "eleven_multilingual_v2"), "language_code": "tr",
                         "seed": tohum, "voice_settings": ayar(r["kim"]),
                         "previous_text": onceki, "next_text": sonraki}).encode(),
        headers={"xi-api-key": anahtar(), "Content-Type": "application/json", "Accept": "audio/mpeg"},
    )
    with urllib.request.urlopen(istek, timeout=90) as c:
        return c.read()


def perde(veri: bytes) -> float:
    """Sesin ortanca temel frekansı (Hz); ölçülemezse 0."""
    try:
        import numpy as np
    except ImportError:
        return 0.0
    if not pathlib.Path(FFMPEG).exists():
        return 0.0
    with tempfile.NamedTemporaryFile(suffix=".mp3", delete=False) as f:
        f.write(veri)
        yol = f.name
    try:
        ham = subprocess.run([FFMPEG, "-v", "error", "-i", yol, "-ac", "1", "-ar", "16000", "-f", "s16le", "-"],
                             capture_output=True).stdout
    finally:
        os.unlink(yol)
    x = np.frombuffer(ham, dtype=np.int16).astype(np.float32) / 32768.0
    n, adim, f0 = 640, 160, []
    for i in range(0, len(x) - n, adim):
        w = x[i:i + n]
        if np.sqrt(np.mean(w * w)) < 0.02:
            continue
        w = w - w.mean()
        ac = np.correlate(w, w, "full")[n - 1:]
        k = 26 + int(np.argmax(ac[26:133]))  # 120-600 Hz
        if ac[k] > 0.45 * ac[0]:
            f0.append(16000 / k)
    return float(np.median(f0)) if f0 else 0.0


def sabit_uret(r: dict, ses_id: str, onceki: str = "", sonraki: str = "") -> tuple[bytes, float, int]:
    """Repliği üretir; hedef perde tanımlıysa hedefe en yakın denemeyi seçer. (ses, perde, deneme sayısı)"""
    hedef = float(HEDEF_PERDE.get(r["kim"], 0))
    taban = int(hashlib.sha1((r["bolum"] + str(r["satir"])).encode()).hexdigest()[:6], 16)
    en_iyi = None
    for d in range(DENEME if hedef else 1):
        veri = uret(r, ses_id, taban + d * 101, onceki, sonraki)
        p = perde(veri) if hedef else 0.0
        fark = abs(p - hedef) / hedef if hedef and p else (0.0 if not hedef else 9.0)
        if en_iyi is None or fark < en_iyi[3]:
            en_iyi = (veri, p, d + 1, fark)
        if fark <= PERDE_PAYI:
            break
    return en_iyi[0], en_iyi[1], en_iyi[2]


def iz(r: dict, ses_id: str) -> str:
    return hashlib.sha1((ses_id + "|" + r["metin"]).encode("utf-8")).hexdigest()[:12]


def main() -> None:
    replikler = json.loads(pathlib.Path(sys.argv[1]).read_text(encoding="utf-8"))
    secenek = sys.argv[2:]
    kimler = set(secenek[secenek.index("--kim") + 1].split(",")) if "--kim" in secenek else set()
    atla = {secenek[secenek.index("--kim") + 1]} if "--kim" in secenek else set()
    istenen = [a for a in secenek if not a.startswith("--") and a not in atla]
    sadece_durum = "--durum" in secenek
    zorla = "--zorla" in secenek
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
            if kimler and r["kim"] not in kimler:
                continue
            if (zorla and kimler) or kayit.get("%s/%02d" % (bolum, r["satir"])) != iz(r, ses_id):
                eksik.append((r, ses_id))
        # Perde denemeleri de haktan düşer; en kötü durumu hesaba kat.
        gereken = sum(len(r["metin"]) * (DENEME if r["kim"] in HEDEF_PERDE else 1) for r, _ in eksik)
        if not eksik:
            print("%-12s tamam (ElevenLabs)" % bolum)
            continue
        if sadece_durum:
            print("%-12s bekliyor: %d replik, en çok %d karakter" % (bolum, len(eksik), gereken))
            continue
        if gereken > hak:
            print("%-12s ATLANDI: en çok %d karakter gerekiyor, kalan hak %d" % (bolum, gereken, hak))
            continue
        # Önce hepsini belleğe üret; biri bile başarısız olursa bölümün dosyalarına dokunma.
        try:
            uretilen = []
            for r, ses_id in eksik:
                i = satirlar.index(r)
                onceki = satirlar[i - 1]["metin"] if i > 0 else ""
                sonraki = satirlar[i + 1]["metin"] if i + 1 < len(satirlar) else ""
                veri, p, deneme = sabit_uret(r, ses_id, onceki, sonraki)
                uretilen.append((r, ses_id, veri))
                print("   %s/%02d %-8s perde=%3.0f Hz, %d deneme: %s" % (bolum, r["satir"], r["kim"], p, deneme, r["metin"][:36]))
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
        hak = kalan_hak()
        print("%-12s üretildi: %d replik (kalan hak %d)" % (bolum, len(eksik), hak))
    print("Bitti. Kalan karakter hakkı:", kalan_hak())


main()
