# EmirCRAFT — Görsel İstemleri (v1)

Bu dosyadaki İngilizce istemleri olduğu gibi bir AI görsel üreticiye (Midjourney, DALL·E, Leonardo, Ideogram vb.) yapıştırabilirsin.
Karakterler, verdiğin listeden **esinlenen ama birebir kopya olmayan** özgün tasarımlardır: isimler, renkler, silüetler ve detaylar
değiştirildi. İstemlerde hiçbir marka/oyun/karakter adı geçmiyor; bu hem telif riskini azaltır hem de üreticinin kopya çizmesini önler.

---

## 0. Nasıl teslim edeceksin (önemli)

Her karakter için **2 görsel** yeterli:

| # | Ne | Boyut | Dosya adı |
|---|----|-------|-----------|
| A | Konsept turnaround (önden, yandan, arkadan) | 1536×1024 (3:2), düz açık gri arka plan | `mob_<kod>_concept.png` |
| B | Yüz dokusu (kafanın ön yüzü, piksel sanat) | 1024×1024 kare üret, ben 32×32'ye küçülteceğim | `mob_<kod>_face.png` |

Bloklar için her blok yüzeyi **1 görsel**: 1024×1024 kare, kenarları birbirine uyan (seamless/tileable) piksel sanat.
Ben bunları 32×32'ye indirip oyunun doku atlasına koyacağım. Dosya adları aşağıda her istemin yanında yazıyor.

Yaratıkların 3B modellerini ben kodda kutulardan (voxel) kuruyorum; konsept görsel bana şekli ve renkleri, yüz dokusu da kimliği veriyor.
Bu yüzden konsept görsellerin **kutu kutu, köşeli** olması çok önemli.

Görselleri bu klasöre koyman yeterli: `/mnt/project-files/emircraft/gorseller/` (ya da sohbete ekle).

### Ortak stil eki (her istemin SONUNA ekle)

Karakterler için:
```
blocky voxel art style, every body part made of rectangular cuboids like a sandbox block game mob, flat pixel-art textures on each face, 32x32 texel density, no smooth curves, no realistic rendering, orthographic view, character turnaround sheet showing front view, side view and back view side by side, neutral T-pose, plain light grey background, even soft lighting, no text, no logo, no watermark, 3:2 aspect ratio
```

Yüz dokusu için (B görseli):
```
single square pixel art texture of the front face of a blocky voxel character head, 32x32 pixel grid, hard pixel edges, limited palette of max 16 colors, fills the whole canvas edge to edge, flat front view, no background, no shading gradients, no text, no watermark, 1:1 aspect ratio
```

Bloklar için:
```
seamless tileable square pixel art block texture for a sandbox voxel game, 32x32 pixel grid, hard pixel edges, limited palette, top-down flat view, even lighting, no perspective, no border, no text, no watermark, 1:1 aspect ratio
```

---

## 1. Karakterler ve yaratıklar

Her karakterde: Türkçe açıklama (oyundaki rolü) + **A istemi** (konsept) + **B istemi** (yüz). İstemlerin sonuna yukarıdaki stil ekini koymayı unutma.

### 1.1 Tokmakçı — `tokmak` (esin: Tung Tung Sahur)
Rol: Gece 03:00 civarı ortaya çıkan, elindeki tokmakla kapılara vuran düşman. Kapı kapalıysa gürültü yapar, açıksa içeri girer.
- **A:** `A tall living tree-log creature with a cylindrical-looking but square-cut birch-bark body, short stubby legs, long thin arms, one hand holding a heavy wooden mallet, a carved face with wide round eyes and a stretched open grin, a small red night-cap on top, lantern hanging from its belt, mischievous night-watchman vibe`
- **B:** `front face of a pale birch-bark wooden head, wide round black eyes with tiny white highlights, stretched open grin showing dark mouth, carved wood grain lines, dark knot marks`

### 1.2 Tüylüpaşa — `tuylupasa` (esin: Osmankuş)
Rol: Nötr kuş. Beslenince evcilleşir, oyuncunun omzunda durur, yakındaki düşmanları ötüşüyle haber verir.
- **A:** `A chubby round-bodied pigeon-like bird made of cubes, dusty teal feathers, oversized head, tiny orange legs, a proud upright plume of three tall feathers on its head, a thick curled black moustache under the beak, small golden vest on its chest, dignified and funny expression`
- **B:** `front face of a teal feathered bird head, small proud half-closed eyes, short yellow-orange beak in the center, thick black curled moustache under the beak, lighter teal cheek feathers`

### 1.3 Lavabo Kafa — `lavabo` (esin: Skibidi Toilet)
Rol: Zıplayarak ilerleyen, ısıran düşman. Su kenarlarında çoğalır.
- **A:** `A bouncing white ceramic washbasin mob, a goofy human-like head with messy hair popping out of the basin bowl, chrome faucet sticking out of the back of the basin like a tail, small pipe underneath used as a pogo leg, water droplets flying, silly menacing expression`
- **B:** `front face of a goofy cartoon human head, wide staring eyes with small pupils, raised eyebrows, huge open singing mouth, messy brown hair fringe at the top, peach skin tone`

### 1.4 Mercek — `mercek` (esin: Cameraman)
Rol: Köylü/muhafız. Köyleri korur, oyuncuya ticaret yapar. Lavabo Kafalara karşı müttefik.
- **A:** `A tall humanoid guard in a dark navy suit and tie, its head is a boxy vintage camcorder with a big round lens as the face, a small red recording light on top, grey fingerless gloves, heavy boots, calm protective stance`
- **B:** `front face of a boxy dark grey camcorder, one large round glass lens in the center with blue reflection rings, small red LED at the top right corner, metal screws in the corners`

### 1.5 Bas Bekçi — `basbekci` (esin: Speakerman)
Rol: Müttefik muhafız. Ses dalgasıyla düşmanları geri iter (knockback).
- **A:** `A broad-shouldered humanoid guard in a charcoal suit, its head is a big square boombox speaker with two woofers stacked vertically, glowing lime-green ring lights around the woofers, a cable hanging down its back, strong heroic stance`
- **B:** `front face of a square black speaker cabinet, two round woofers stacked vertically, glowing lime green rings around each woofer, small grille dots between them`

### 1.6 Ekran Adam — `ekran` (esin: TV Man)
Rol: Nadir müttefik. Ekranında gösterdiği sembolle düşmanları kısa süre dondurur (stun).
- **A:** `A slim humanoid in a burgundy suit, its head is a chunky retro CRT monitor with a curved wooden-brown casing, the screen shows a glowing pixel symbol of a spiral, two small antennas on top, one hand raised towards the viewer`
- **B:** `front face of a retro CRT television, brown wooden frame, glowing cyan screen with a white pixel spiral symbol in the middle, two small knobs at the bottom right`

### 1.7 Boşluk Gölgesi — `bosluk` (esin: Entity 67 / Backrooms)
Rol: "Sarı Koridorlar" boyutunda dolaşan uzun gölge. Bakınca donar, bakmayınca yaklaşır.
- **A:** `An extremely tall and thin shadow humanoid made of pitch-black cubes, arms reaching below its knees, faint static noise pixels on its edges, no visible face except two tiny dim white dots, slightly hunched, standing in a yellow wallpapered corridor`
- **B:** `front face of a pure black head with subtle dark purple static noise pixels, two tiny dim white square eyes near the top, no mouth`

### 1.8 Sırıtkan — `siritkan` (esin: Smiler / Backrooms)
Rol: Sadece karanlıkta görünen düşman. Işık (meşale) onu uzak tutar.
- **A:** `A floating mob that is almost invisible in darkness, only a cube-shaped head of shadow with a huge glowing white toothy grin and two glowing white slit eyes, faint smoky particles below instead of a body, spooky but cartoonish`
- **B:** `front face of a black head, two glowing white narrow slit eyes, a huge glowing white wide grin with many square teeth spanning almost the full width`

### 1.9 Balon Kafa — `balonkafa` (esin: Partygoer / Backrooms)
Rol: Sarı Koridorlarda parti müziğiyle gelen düşman. Yakalarsa oyuncuyu rastgele bir odaya ışınlar.
- **A:** `A plump humanoid made of bright yellow rubbery cubes, a round-ish cube head with a painted-on black smile and two black dot eyes, a tiny striped party cone hat, confetti falling around, short arms holding a bunch of cube-shaped balloons, unsettling cheerful vibe`
- **B:** `front face of a bright yellow smooth head, two small black oval eyes, a thin wide painted black smile, no nose, slight glossy highlight pixels`

### 1.10 Pençe — `pence` (esin: Hound / Backrooms)
Rol: Hızlı, dört ayak üstünde koşan avcı. Sesle yönelir; eğilerek (sneak) yürümek onu kandırır.
- **A:** `A gaunt four-legged crawling humanoid creature made of pale grey cubes, long thin limbs, spine bumps along its back, messy dark hair hanging over its face, long cube fingers like claws, low hunting pose`
- **B:** `front face of a pale grey head mostly hidden behind strands of black hair, one visible small white eye glint, thin dark mouth line`

### 1.11 Çivit — `civit` (esin: Blue / Rainbow Friends)
Rol: "Oyuncak Fabrikası" boyutunun devi. Yavaş ama uzun kollu, oyuncuyu kutunun içine saklanınca göremez.
- **A:** `A towering indigo-violet giant made of cubes, very long dangling arms, hunched posture, small head compared to the body, a single tilted paper-origami boat hat on its head, dripping indigo goo pixels from its mouth, big googly eyes of different sizes`
- **B:** `front face of an indigo violet head, two googly eyes of different sizes with black pupils looking in different directions, open mouth dripping purple goo, darker violet shading`

### 1.12 Yosun — `yosun` (esin: Green / Rainbow Friends)
Rol: Kör avcı. Görmez ama duyar; koşmak onu çeker, yürümek güvenli.
- **A:** `A tall slender moss-green creature made of cubes, extremely long arms and fingers reaching the ground, small leafy vines growing on its shoulders, eyes covered by a thick horizontal band of moss (blind), wide mouth, sneaky creeping pose`
- **B:** `front face of a moss green head, a thick horizontal strip of darker mossy leaves covering where the eyes would be, wide thin mouth below, tiny leaf pixels`

### 1.13 Kıvılcım — `kivilcim` (esin: Orange / Rainbow Friends)
Rol: Hızlı kertenkele. Aç kalınca saldırır; yem kutusuna yiyecek koymak onu sakinleştirir.
- **A:** `A fast lizard-like creature made of bright tangerine orange cubes, long flat body, long tail, short legs, two tiny horns on its head, big hungry eyes, long pink tongue sticking out, running pose leaving a trail of orange spark pixels`
- **B:** `front face of a bright orange lizard head, two big round yellow eyes with black slit pupils, wide mouth with a pink tongue sticking out, darker orange scale pixels`

### 1.14 Bando — `bando` (esin: Banban / Garten of Banban)
Rol: Oyuncak Fabrikası'nın maskotu. Önce dost gibi görünür, gece düşmanlaşır.
- **A:** `A chubby round mascot creature made of crimson red cubes, short legs, big smiling face, a tall blue marching-band drum major hat with a white feather, a small drum strapped to its belly, white gloves, friendly but slightly creepy smile`
- **B:** `front face of a crimson red mascot head, two big black eyes with white highlights, wide friendly smile with small white teeth, rosy cheek pixels`

### 1.15 Koca Kurbağa — `kocakurbaga` (esin: Jumbo Josh / Garten of Banban)
Rol: Nötr dev. Oyuncuyu kucaklayıp havaya atar; kızdırılmazsa zararsızdır.
- **A:** `A huge bulky frog-like giant made of lime-green cubes, round belly, stubby legs, very wide mouth, one tiny curl of dark hair on top of its head, big friendly eyes, arms open wide for a hug`
- **B:** `front face of a lime green frog-like head, two big round friendly eyes on top, extremely wide smiling mouth, tiny dark hair curl at the top center`

### 1.16 Pembe Leylek — `pembeleylek` (esin: Opila Bird / Garten of Banban)
Rol: Uçan düşman. Yuvası (yumurtaları) varken çok saldırgan, yavruları küçük uçan mob.
- **A:** `A tall flamingo-pink bird made of cubes, long thin legs, long neck, oversized box-shaped beak that opens very wide, small wings, a white bib-shaped chest patch, three small pink chick birds following it`
- **B:** `front face of a pink bird head, two small black eyes high up, a large boxy yellow beak taking the lower half, slightly open`

### 1.17 Fermuar — `fermuar` (esin: Huggy Wuggy / Poppy Playtime)
Rol: Oyuncak Fabrikası'nın ana avcısı. Uzun kollarıyla uzaktan yakalar.
- **A:** `A tall lanky plush toy monster made of fuzzy cubes, deep teal fur, very long arms and legs, large round button eyes, a big zipper mouth running across its face that is half-unzipped showing sharp felt teeth, stitched seams on its body`
- **B:** `front face of a fuzzy teal plush head, two large round white button eyes with four holes each, a wide horizontal zipper mouth half open with small white felt triangle teeth`

### 1.18 Düğme — `dugme` (esin: Kissy Missy / Poppy Playtime)
Rol: Fermuar'ın eşi ama oyuncuya yardım eder: kapıları açar, ipucu verir.
- **A:** `A tall lanky plush toy made of fuzzy cubes, soft coral-peach fur, long arms and legs, large round button eyes with eyelashes, a stitched zipper smile that is closed, a big yellow bow on its head, gentle helpful pose`
- **B:** `front face of a fuzzy coral peach plush head, two large round white button eyes with long eyelashes, closed stitched zipper smile, yellow bow corner visible at the top`

### 1.19 Mışıl — `misil` (esin: CatNap / Poppy Playtime)
Rol: Uyku gazı püskürten kedi. Gazına yakalanan oyuncunun ekranı kararır ve yavaşlar.
- **A:** `A long slinky cat creature made of soft lilac cubes, sleepy crescent-moon shaped eyes, a big smile, a crescent moon pendant on its chest, lilac purple mist coming from its mouth, long tail, crawling on all fours`
- **B:** `front face of a soft lilac cat head, two small triangular ears at the top corners, sleepy closed crescent eyes, wide smile, faint lilac mist pixels near the mouth`

### 1.20 Kutucuk — `kutucuk` (esin: Boxy Boo / Poppy Playtime)
Rol: Sandık gibi durup oyuncu yaklaşınca çıkan tuzak düşman. Kutudan uzayan mekanik kolları var.
- **A:** `A jack-in-the-box style trap mob, a red and yellow striped toy cube box with a crank on its side, a boxy blue robot-toy head popping out on a coiled spring, long extending mechanical arms with clamp hands coming out of the box, playful menacing grin`
- **B:** `front face of a boxy blue toy robot head, two round white eyes with small black pupils, wide grin with square white teeth, small yellow bolts on the sides`

### 1.21 Oyuncu — `oyuncu` (varsayılan kahraman "Emir")
- **A:** `A friendly young adventurer made of cubes, short brown hair, bright red hoodie with a small white pickaxe logo, dark blue jeans, brown boots, a small backpack, confident smile`
- **B:** `front face of a cheerful young adventurer head, short brown hair fringe, brown eyes, small smile, light tan skin tone`

---

## 2. Blok dokuları

Her istemin sonuna **blok stil ekini** koy. Parantez içindeki dosya adıyla kaydet.

### Doğal bloklar
| Dosya | İstem |
|-------|-------|
| `grass_top.png` | `lush green grass seen from above, small tufts and a few tiny yellow flowers` |
| `grass_side.png` | `side of a grass block: top quarter green grass with jagged dripping edge, rest brown soil with small pebbles` |
| `dirt.png` | `rich brown soil with small pebbles and darker clumps` |
| `stone.png` | `smooth grey stone with subtle cracks and speckles` |
| `cobblestone.png` | `rough grey cobblestones of different sizes with dark mortar lines` |
| `sand.png` | `pale golden sand with fine grain speckles` |
| `gravel.png` | `mixed grey and brown gravel pebbles` |
| `log_side.png` | `oak tree bark, vertical rough brown bark lines` |
| `log_top.png` | `cross-section of an oak log, concentric tree rings, bark border` |
| `leaves.png` | `dense green tree leaves cluster with small gaps (gaps pure transparent)` |
| `planks.png` | `horizontal light oak wooden planks with nail dots` |
| `glass.png` | `clear glass pane with light blue frame border and a white shine streak, center transparent` |
| `water.png` | `deep blue water surface with light ripple highlights` |
| `snow.png` | `fresh white snow with light blue shading specks` |
| `bedrock.png` | `unbreakable dark grey and black chaotic rock` |

### Madenler
| Dosya | İstem |
|-------|-------|
| `coal_ore.png` | `grey stone with black coal chunks embedded` |
| `iron_ore.png` | `grey stone with beige-orange iron specks embedded` |
| `gold_ore.png` | `grey stone with shiny yellow gold nuggets embedded` |
| `ruby_ore.png` | `grey stone with glowing red faceted ruby crystals embedded` |
| `crystal_ore.png` | `grey stone with glowing cyan crystal shards embedded` |

### Yapım blokları
| Dosya | İstem |
|-------|-------|
| `crafting_top.png` | `top of a wooden crafting table, grid of four squares, small tools resting on it` |
| `crafting_side.png` | `side of a wooden crafting table with a saw and hammer hanging` |
| `furnace_front.png` | `front of a stone furnace, dark square opening at the bottom with orange glowing fire` |
| `bricks.png` | `red clay bricks with light grey mortar` |
| `torch.png` | `a single small wooden torch stick with a bright yellow-orange flame, centered, rest transparent` |

### "Sarı Koridorlar" boyutu (Backrooms esinli)
| Dosya | İstem |
|-------|-------|
| `yellow_wallpaper.png` | `old mono-yellow wallpaper with a faint repeating chevron pattern and slight stains` |
| `damp_carpet.png` | `damp worn beige-yellow office carpet, slightly darker wet patches` |
| `ceiling_tile.png` | `off-white office ceiling tile with tiny holes` |
| `ceiling_light.png` | `glowing white fluorescent ceiling light panel, bright and slightly flickering` |

### "Oyuncak Fabrikası" boyutu (Poppy/Banban/Rainbow esinli)
| Dosya | İstem |
|-------|-------|
| `toy_brick_red.png` | `glossy red plastic toy building brick seen from above with round studs` |
| `toy_brick_blue.png` | `glossy blue plastic toy building brick seen from above with round studs` |
| `toy_brick_yellow.png` | `glossy yellow plastic toy building brick seen from above with round studs` |
| `factory_floor.png` | `checkered grey and teal factory floor tiles, slightly scratched` |
| `conveyor.png` | `top of a black rubber conveyor belt with yellow hazard stripes on the edges` |
| `playroom_wall.png` | `pastel playroom wall with painted clouds and stars, slightly faded` |

---

## 3. Eşya ve arayüz (isteğe bağlı, sonra da olur)

Eşya ikonları için stil eki: `single pixel art game item icon, 32x32 pixel grid, hard pixel edges, centered, transparent background, slight dark outline, no text, 1:1`

| Dosya | İstem |
|-------|-------|
| `item_pickaxe_wood.png` | `wooden pickaxe` |
| `item_pickaxe_stone.png` | `stone pickaxe with wooden handle` |
| `item_sword_iron.png` | `iron sword with brown leather grip` |
| `item_axe_stone.png` | `stone axe with wooden handle` |
| `item_ruby.png` | `faceted red ruby gem` |
| `item_apple.png` | `red apple with a green leaf` |
| `ui_heart.png` | `red pixel heart for health bar` |
| `ui_drumstick.png` | `cooked meat drumstick for hunger bar` |
| `ui_slot.png` | `dark grey inventory slot square with a lighter bevel border, center semi-transparent` |
| `app_icon.png` | `app icon (1024x1024) for a voxel sandbox game named EmirCRAFT: a grass block with a pickaxe crossed over it, bright sky blue background, bold and readable` |

---

## 4. Öncelik sırası (hepsini birden yapmana gerek yok)

1. Bloklar: `grass_top`, `grass_side`, `dirt`, `stone`, `cobblestone`, `sand`, `log_side`, `log_top`, `leaves`, `planks` → oyun hemen "gerçek" görünür.
2. Oyuncu (`oyuncu`) + ilk 3 yaratık: `tokmak`, `lavabo`, `mercek`.
3. Kalan yaratıklar ve boyut blokları.

Görseller gelene kadar oyun, kodda üretilen geçici renkli dokularla çalışıyor; dosyayı `assets/textures/blocks/` klasörüne koyduğum anda otomatik olarak gerçeğiyle değişiyor.
