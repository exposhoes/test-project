"""Replik ses dosyalarını (assets/audio/voices/**/*.mp3) aynı ses yüksekliğine getirir.

ElevenLabs sesleri karakterden karaktere çok farklı yükseklikte geliyor (ör. Emir -18 dB,
Öğretmen -33 dB); videoda biri bağırıyor, diğeri duyulmuyor gibi oluyor. Bu betik her dosyanın
ortalama seviyesini HEDEF dB'ye çeker, tepe noktaları kırpılmasın diye sınırlayıcı kullanır.
Seviyesi zaten hedefe yakın (±1 dB) olan dosyaya dokunmaz; tekrar tekrar çalıştırılabilir.

Kullanım: python tools/ses_seviyesi.py [bölüm ...]     (bölüm verilmezse hepsi)
"""
import os
import pathlib
import re
import shutil
import subprocess
import sys

KOK = pathlib.Path(__file__).resolve().parent.parent / "assets" / "audio" / "voices"
FFMPEG = shutil.which("ffmpeg") or r"C:\ffmpeg\ffmpeg.exe"
HEDEF = -19.0  # ortalama dB


def seviye(yol: pathlib.Path) -> float:
    cikti = subprocess.run([FFMPEG, "-hide_banner", "-i", str(yol), "-af", "volumedetect", "-f", "null", "-"],
                           capture_output=True, text=True, encoding="utf-8", errors="replace").stderr
    m = re.search(r"mean_volume:\s*(-?[\d.]+) dB", cikti)
    return float(m.group(1)) if m else HEDEF


def esitle(yol: pathlib.Path) -> bool:
    fark = HEDEF - seviye(yol)
    if abs(fark) <= 1.0:
        return False
    gecici = yol.with_suffix(".tmp.mp3")
    subprocess.run([FFMPEG, "-v", "error", "-y", "-i", str(yol), "-af",
                    f"volume={fark:.1f}dB,alimiter=limit=0.9:level=disabled", "-c:a", "libmp3lame", "-b:a", "128k",
                    str(gecici)], check=True)
    os.replace(gecici, yol)
    return True


def main() -> None:
    bolumler = sys.argv[1:]
    degisen = 0
    dosyalar = sorted(KOK.glob("*/*.mp3"))
    for d in dosyalar:
        if d.name.endswith(".tmp.mp3") or (bolumler and d.parent.name not in bolumler):
            continue
        if esitle(d):
            degisen += 1
    print("ses seviyesi eşitlendi: %d dosya değişti (hedef %.0f dB)" % (degisen, HEDEF))


if __name__ == "__main__":
    main()
