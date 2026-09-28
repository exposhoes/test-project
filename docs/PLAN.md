# EmirCRAFT — Teknik Plan

## Hedef
Android ve iOS için, blok kırma/koyma, inşa ve hayatta kalma odaklı bir voxel sandbox oyunu.
Karakterler popüler internet yaratıklarından **esinlenen ama özgün** tasarımlardır (bkz. `docs/gorsel-istemleri.md`).

## Teknoloji
| Konu | Seçim | Neden |
|------|-------|-------|
| Motor | Godot 4.3, GDScript | Ücretsiz, açık kaynak, Android + iOS dışa aktarımı, hafif |
| Görüntüleme | GL Compatibility | Eski/ucuz Android cihazlarda da çalışır |
| Dünya | 16×64×16 chunk, yüz eleme (face culling), doku atlası | Mobilde düşük çizim çağrısı |
| Arazi | FastNoiseLite (simplex) | Motorda hazır, tohum (seed) ile tekrarlanabilir |
| Kontrol | Sol joystick, sağ sürükle-bak, Zıpla/Kır/Koy düğmeleri | Tek elle değil, iki başparmakla oynanır |

## Klasör yapısı
```
scenes/main.tscn            giriş sahnesi
scripts/main.gd             dünya + oyuncu + arayüz + gece/gündüz + yaratık doğurma
scripts/world/              blok kayıt defteri, doku atlası, chunk, arazi üretici, dünya
scripts/player/             oyuncu (hareket, kır/koy), can/açlık, envanter
scripts/items/              eşya listesi ve yere düşen eşya
scripts/ui/                 HUD (hızlı erişim çubuğu) ve dokunmatik kontroller
scripts/mobs/               20 yaratığın tanımı ve temel yapay zekâ
assets/textures/blocks/     <doku_adı>.png  (ör. grass_top.png)
assets/textures/mobs/       mob_<kod>_face.png
assets/textures/items/      item_<ad>.png (ör. item_apple.png)
tests/                      başsız duman testi, ekran görüntüsü
```

## Görseller nasıl bağlanıyor
- Blok dokusu `assets/textures/blocks/<ad>.png` olarak eklenince atlas onu kullanır; yoksa koddan geçici desen üretir.
- Yaratık yüzü `assets/textures/mobs/mob_<kod>_face.png` olarak eklenince kafanın ön yüzüne giydirilir.
- Konsept görseller yaratıkların kutu modelini (boy, oran, renk) ayarlamak için referanstır.

## Yol haritası
1. **İskelet (bu PR):** sonsuz arazi, chunk yükleme, yürüme/zıplama, blok kırma/koyma, hızlı erişim çubuğu,
   dokunmatik kontroller, gece-gündüz, 20 yaratığın tanımı ve dünyada dolaşan ilk yaratıklar.
2. **Hayatta kalma (yapıldı):** can ve açlık, düşman hasarı, düşme hasarı, yaratıklara vurma, ölüm/yeniden doğma.
   Kırılan bloklar yere düşüyor ve toplanıyor; 9 yuvalı envanter, 64'lük yığınlar, koyunca harcanıyor.
   Yapraktan elma düşüyor, seçip Koy'a basınca yeniyor. Tam envanter ekranı üretimle gelecek.
3. **Üretim:** çalışma masası, tarifler, aletler (kazma/balta/kılıç), kazma hızı.
4. **Kayıt:** dünyada yapılan değişiklikleri cihaza kaydetme (şu an uzaklaşınca değişiklikler sıfırlanıyor).
5. **Yaratık yetenekleri:** Tokmakçı kapı çalma, Sırıtkan ışıktan kaçma, Yosun sese yönelme, Mışıl uyku gazı vb.
6. **Boyutlar:** "Sarı Koridorlar" (Backrooms esinli) ve "Oyuncak Fabrikası" (Poppy/Banban/Rainbow esinli) portallarla.
7. **Performans:** chunk üretimini arka plan iş parçacığına taşıma, greedy meshing.
8. **Yayın:** Android (APK/AAB) ve iOS dışa aktarım ayarları, uygulama ikonu, mağaza görselleri.

## Çalıştırma
- Godot 4.3'ü indir, bu klasörü **Import** ile aç, F5.
- Bilgisayarda: WASD/yön tuşları, fare ile bak (tıklayınca imleç kilitlenir, Esc bırakır), sol tık kır, sağ tık koy, 1-9 / tekerlek blok seç.
- Test: `godot --headless --path . --script res://tests/smoke_test.gd`
