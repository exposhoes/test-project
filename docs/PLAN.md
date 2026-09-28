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
scenes/menu.tscn            ana menü (giriş sahnesi)
scenes/main.tscn            oyun
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
3. **Üretim (yapıldı):** 36 yuvalı çanta, Çanta ekranında 16 tarif, çalışma masası, tahta/taş/demir/kristal kazma,
   balta ve kılıçlar (Yakut Kılıç dahil). Kır basılı tutularak kırılır; taş ve madenler kazma ister,
   madenler kömür/ham demir/ham altın/yakut/kristal bırakır.
   Aletler aşınır (tahta 60, taş 130, demir 250, yakut kılıç 800, kristal kazma 1500 kullanım; yuvada renkli çubuk).
   Fırın (8 kırık taş, masada): Çanta'nın Fırın sekmesinde ham demir/altın, kum, kırık taş ve kütük eritilir;
   her eritme bir yakıt harcar (kömür 8, kütük 3, tahta 1 eritmeye yeter).
4. **Kayıt (yapıldı):** dünya değişiklikleri, gün saati, oyuncunun konumu, can/açlık ve envanter `user://world.save`
   dosyasına 20 saniyede bir ve uygulama arka plana atılınca yazılıyor. Yeni dünya açma ana menüyle gelecek.
5. **Dostlar (yapıldı):** Mercek, Bas Bekçi ve Ekran Adam'a elinde demirle Koy'a basınca evcilleşir;
   seni takip eder, çok uzaklaşırsa yanına ışınlanır, 12 blok içindeki düşmanlara saldırır, yavaşça can yeniler
   ve kayıtla birlikte saklanır. Sana vurulmaz.
   **Yaratık yetenekleri:** Tokmakçı kapı çalma, Sırıtkan ışıktan kaçma, Yosun sese yönelme, Mışıl uyku gazı vb.
6. **Boyutlar:** "Sarı Koridorlar" (Backrooms esinli) ve "Oyuncak Fabrikası" (Poppy/Banban/Rainbow esinli) portallarla.
7. **Performans:** chunk üretimini arka plan iş parçacığına taşıma, greedy meshing.
8. **Menü (yapıldı):** ana menü (Devam Et / Yeni Dünya, arkada dönen yaratık vitrini), oyun içinde II ile duraklatma
   ve "Kaydet ve Ana Menü". Ayarlar (ana menüde ve duraklatmada): bakış hızı 0,5x-2x,
   görüş mesafesi Çok yakın-Çok uzak (2-8 chunk); `user://settings.cfg` dosyasında saklanır.
9. **Yayın:** Android (APK/AAB) ve iOS dışa aktarım ayarları, uygulama ikonu, mağaza görselleri.

## Çalıştırma
- Godot 4.3'ü indir, bu klasörü **Import** ile aç, F5.
- Bilgisayarda: WASD/yön tuşları, fare ile bak (tıklayınca imleç kilitlenir, Esc bırakır), sol tık kır, sağ tık koy, 1-9 / tekerlek blok seç.
- Test: `godot --headless --path . --script res://tests/smoke_test.gd` ve `res://tests/save_test.gd`
