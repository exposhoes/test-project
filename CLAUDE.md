# EmirCRAFT

Minecraft benzeri, mobil (Android, sonra iOS) blok tabanlı hayatta kalma ve inşa oyunu.
Bu depo, "Claude Code Game Studios" şablonunun ajanları, komutları (skill) ve kurallarıyla çalışır
(`.claude/`, MIT lisansı: `.claude/CCGS-LICENSE`).

## Çalışma şekli (şablonun varsayılanlarından önce gelir)

- Oyunun sahibi **Mehmet**. Türkçe yazar; her zaman Türkçe cevap ver.
- Mehmet kod yazmaz ve sadece Android Studio emülatöründe test eder. Kodlamayı, kurulumu ve düzenlemeleri
  Claude yapar. Bu yüzden şablonun "yazmadan önce izin iste" ve "kullanıcı demeden commit yok" kuralları
  bu projede **geçerli değil**: işi yap, test et, commit'le ve `claude/project-thread-zypky7` dalına gönder.
  Mehmet'e sadece gerçekten onun vermesi gereken kararları sor (ör. yeni oyun özelliği seçimi).
- Görselleri Mehmet üretir; Claude ona tam satır İngilizce görsel istemleri verir (`docs/gorsel-istemleri*.md`).
- Karakterler internet yaratıklarından **esinlenen ama özgün** tasarımlardır; birebir kopya, isim veya logo yok.

## Teknoloji

- **Motor**: Godot 4.3 (proje ayarları 4.3; Mehmet'in bilgisayarında dışa aktarım Godot 4.7.2 ile yapılıyor)
- **Dil**: GDScript, GL Compatibility görüntüleyici, yatay ekran
- **Ayarlar**: `project.yaml` (engine/specialists/naming/commands blokları dolduruldu)

## Proje yapısı

Kod `src/` değil `scripts/` altında (şablonun `src/` varsayımını bu projede `scripts/` olarak oku):

```
scenes/menu.tscn, main.tscn   ana menü ve oyun
scripts/world/                blok kayıt defteri, doku atlası, chunk, arazi, dünya
scripts/player/               oyuncu, can/açlık, envanter
scripts/items/                eşyalar, aletler, tarifler, yere düşen eşya
scripts/mobs/                 yaratık tanımları (MobData) ve yapay zekâ
scripts/ui/                   HUD, dokunmatik kontroller, çanta/üretim, menüler
scripts/save/                 kayıt (user://world.save)
assets/textures/{blocks,mobs,items,ui}/   Mehmet'in görselleri
tests/                        başsız testler ve önizleme betikleri
tools/run_android.ps1         Android Studio ▶: çek, derle, kur, başlat
docs/PLAN.md                  yol haritası (Türkçe)
design/, production/          şablonun tasarım/üretim belgeleri
```

## Test

```
godot --headless --path . --script res://tests/smoke_test.gd
godot --headless --path . --script res://tests/save_test.gd
```
Yeni `class_name` eklediysen önce `godot --headless --path . --import` çalıştır.

## Şablondan gelenler

@.claude/docs/coordination-rules.md
@.claude/docs/coding-standards.md
@docs/engine-reference/godot/VERSION.md

- Dizin kuralları: @.claude/docs/directory-structure.md (kod için `scripts/` geçerli)
- `production/session-state/active.md` oturum kontrol noktasıdır; sıkıştırmadan sonra ilk onu oku.
- `.claude/scripts/` altındaki yardımcılar gözlem üretir, karar vermez.
