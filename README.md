# EmirCRAFT

Blok tabanlı, mobil (Android/iOS) hayatta kalma ve inşa oyunu. Godot 4.3 ile yazılıyor.

![Ekran görüntüsü](docs/ekran-goruntusu.png)

- Teknik plan ve yol haritası: [docs/PLAN.md](docs/PLAN.md)
- Karakter ve doku görsel istemleri: [docs/gorsel-istemleri.md](docs/gorsel-istemleri.md)

## Hızlı başlangıç
1. [Godot 4.3](https://godotengine.org/download) indir.
2. Godot'ta **Import** → bu klasördeki `project.godot`.
3. **F5** ile çalıştır.

Bilgisayar kontrolleri: WASD hareket, Space zıpla, fare bak, sol tık basılı tut kır / tıkla vur, sağ tık koy veya ye, 1-9 yuva seç, E çanta, Esc duraklat.
Telefonda: sol yarıda joystick, sağ yarıda sürükleyerek bak, sağ alttaki Zıpla / Kır / Koy düğmeleri, sağ üstte Çanta ve duraklatma (II). Kır'ı basılı tutunca blok kırılır, önünde yaratık varsa vurur.

Oyun boş envanterle başlar: kırdığın bloklar yere düşer, üstünden geçince toplanır. Koy düğmesi seçili bloğu koyar, seçili eşya elmaysa yer.
Çanta ekranında tariflere dokunarak üretirsin: kütük → tahta → çubuk → çalışma masası → kazma. Aletler için masanın yanında olmalısın.

Oyun kendini 20 saniyede bir ve arka plana atılınca kaydeder; açınca kaldığın yerden devam edersin.
