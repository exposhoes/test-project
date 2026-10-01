# Bloklar: gerçekçi doku istemleri

Binalar bloklardan kuruluyor. Her bloğun yüzeyi kare bir doku. Aşağıdaki görselleri üretip
tablodaki adla `assets/textures/blocks/` klasörüne koyarsan oyun kodla çizilmiş dokunun yerine
seninkini kullanır (oyun görseli 128 piksele küçültür; sen 1024x1024 üretebilirsin).

**Kurallar (hepsi için):** kare görsel, yüzey görseli tamamen doldurur, tam karşıdan düz bakış,
perspektif yok, gölge yok, kenarları birbirine uyar (yan yana dizilince dikiş görünmez).

Her istemin SONUNA şunu ekle:

`, seamless tileable square texture, flat straight-on view, fills the whole image edge to edge, even soft lighting, no shadows, no perspective, no objects, no text, stylized realistic, slightly pixelated game texture`

## Ev (dış)

| Blok | Dosya adı | İstemin başı |
|---|---|---|
| Krem sıvalı dış duvar | `facade_cream.png` | Smooth cream colored painted stucco house wall with very subtle plaster grain |
| Beyaz söve / çerçeve | `trim_white.png` | Clean white painted plaster trim surface with a faint brush texture |
| Taş temel (su basman) | `stone_base.png` | Grey cut stone block foundation wall with thin mortar lines, rectangular stones |
| Kırmızı tuğla duvar | `bricks.png` | Red clay brick wall with light grey mortar, neat running bond pattern |
| Kiremit çatı | `roof_terracotta.png` | Terracotta clay roof tiles in neat overlapping rows, warm orange red |
| Koyu çatı kiremidi | `roof_tile.png` | Dark brown ceramic roof shingles in neat overlapping rows |
| Dış kapı ahşabı | `planks.png` | Warm light oak wooden planks, horizontal boards with fine wood grain |

## Ev (iç)

| Blok | Dosya adı | İstemin başı |
|---|---|---|
| İç duvar (sıva) | `plaster.png` | Smooth off-white interior wall paint with a very subtle plaster texture |
| Koyu parke zemin | `dark_planks.png` | Dark walnut hardwood parquet floor boards with fine grain, horizontal planks |
| Tavan | `ceiling_tile.png` | Plain white ceiling surface with very fine matte texture |
| Sarı duvar kâğıdı | `yellow_wallpaper.png` | Soft pastel yellow wallpaper with a tiny subtle pattern |

## Pencere (tek görsel, ben ikiye bölerim)

Pencere iki blok yüksekliğinde. Bunu **dikey (1:2 oranında, ör. 1024x2048)** tek görsel olarak üret,
`pencere_tam.png` adıyla koy; üst ve alt yarıyı (`window_top.png`, `window_bottom.png`) ben ayırırım.

İstem: `A tall white framed house window with four glass panes and a cross bar, light blue reflective glass, white wooden frame filling the whole image, flat straight-on view, fills the whole image edge to edge, even soft lighting, no shadows, no perspective, no wall around it, no text, stylized realistic, slightly pixelated game texture`

## Sokak ve bahçe

| Blok | Dosya adı | İstemin başı |
|---|---|---|
| Çim (üstten) | `grass_top.png` | Short green lawn grass seen from directly above |
| Toprak | `dirt.png` | Brown garden soil with tiny pebbles seen from directly above |
| Kaldırım / taş yol | `cobblestone.png` | Grey paving stones sidewalk with thin joints seen from directly above |
| Asfalt / çakıl | `gravel.png` | Dark grey asphalt road surface with fine gravel grain seen from directly above |
| Düz taş | `stone.png` | Light grey smooth concrete stone surface with subtle speckles |
| Kum | `sand.png` | Fine pale beach sand seen from directly above |
| Ağaç gövdesi (yan) | `log_side.png` | Brown tree bark with vertical grooves |
| Ağaç gövdesi (üst) | `log_top.png` | Cut tree trunk cross-section with growth rings, round rings centered |
| Yaprak | `leaves.png` | Dense green tree leaves foliage |

## Şimdilik kodla kalanlar

Balkon korkuluğu, çit ve cam aralarından arkası görünen (saydam) dokular; bunlar şimdilik kodla
çiziliyor. Kapı ayrı bir açılır model, doku olarak yukarıdaki ahşap kullanılıyor.
