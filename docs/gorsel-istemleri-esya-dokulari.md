# Eşya dokuları: görsel istemleri

Eşyalar köşeli parçalardan kuruluyor ve şu an düz renkli. Aşağıdaki **yüzey dokularını** üretirsen
oyun bu parçaları dokuyla kaplar: masa gerçek ahşap, dolap gerçek dolap kapağı gibi görünür.

**Kural:** hepsi KARE (1024x1024), yüzey görseli tamamen doldurur, tam karşıdan düz bakış.
Dosyaları `assets/textures/esya/dokular/` klasörüne tablodaki adla koy.

## 1. Malzeme dokuları (tekrar eden yüzey)

Her istemin SONUNA şunu ekle:

`, seamless tileable square texture, flat straight-on view, fills the whole image edge to edge, even soft lighting, no shadows, no perspective, no objects, no text, stylized realistic, crisp detail`

| Nerede kullanılır | Dosya adı | İstemin başı |
|---|---|---|
| Yemek masası, sandalye | `ahsap_koyu.png` | Dark walnut wood furniture surface with fine straight grain and a soft satin finish |
| Çalışma masası, gardırop, yatak, komodin | `ahsap_acik.png` | Light oak wood furniture surface with fine straight grain and a soft satin finish |
| Mutfak dolabı gövdesi, buzdolabı, beyaz mobilya | `beyaz_lake.png` | Clean glossy white lacquered cabinet surface with a very faint reflection |
| Mutfak tezgâhı üstü | `tezgah_tas.png` | Grey speckled granite kitchen countertop surface |
| Lavabo, ocak, kulplar | `metal_celik.png` | Brushed stainless steel surface with fine horizontal brush lines |
| Koltuk, sandalye minderi | `kumas_gri.png` | Soft grey woven sofa fabric with a fine textile weave |
| Yatak örtüsü, yastık | `kumas_beyaz.png` | Soft white cotton bed linen fabric with very subtle wrinkles |
| Emir'in yatak örtüsü | `kumas_mavi.png` | Soft light blue cotton blanket fabric with a fine weave |
| Banyo duvarı ve zemini | `fayans_beyaz.png` | White glossy square bathroom wall tiles with thin light grey grout lines |
| Garaj ve bodrum zemini | `beton_zemin.png` | Smooth grey polished concrete floor with faint stains |

## 2. Ön yüz görselleri (tek parça, tekrar etmez)

Bunlar eşyanın ön yüzüne bir kez kaplanır. Her istemin SONUNA şunu ekle:

`, flat straight-on orthographic front view, fills the whole image edge to edge, even soft lighting, no shadows, no perspective, no background, no text, stylized realistic, crisp detail`

| Nerede kullanılır | Dosya adı | Oran | İstemin başı |
|---|---|---|---|
| Mutfak alt dolap kapağı | `on_dolap_kapagi.png` | kare | A single white shaker-style kitchen cabinet door with a slim horizontal steel handle near the top |
| Mutfak üst dolap kapağı | `on_ust_dolap.png` | kare | A single white flat kitchen wall cabinet door with a slim horizontal steel handle near the bottom |
| Çekmece önü | `on_cekmece.png` | 2:1 yatay | A single light oak wooden drawer front with a round wooden knob in the center |
| Gardırop kapağı | `on_gardirop_kapagi.png` | 1:2 dikey | A single tall light oak wardrobe door with a recessed panel and a small round knob on the right side |
| Buzdolabı önü | `on_buzdolabi.png` | 1:2 dikey | The front of a white two-door refrigerator, small freezer door on top and tall fridge door below, slim vertical steel handles on the left |
| Ocak / fırın önü | `on_firin.png` | kare | The front of a white kitchen oven with a dark glass oven window, a steel handle bar and four round control knobs along the top |
| Ocak üstü | `ust_ocak.png` | kare | The top of a kitchen stove seen from directly above, four round black gas burners on a white enamel surface |
| TV ekranı | `on_tv.png` | 16:9 yatay | The front of a modern flat-screen TV with a thin black frame, the screen showing a colorful children's cartoon landscape |
| Giriş kapısı | `kapi_ahsap.png` | 1:2 dikey | A single wooden front door, warm brown oak with six raised panels and a brass handle on the right (bu dosya `assets/textures/esya/` klasörüne konur) |
| Oda kapısı (iç kapı) | `kapi_ic.png` | 1:2 dikey | A single white interior room door with two recessed panels and a silver lever handle on the right |

Önce 3-4 tanesini (ör. `ahsap_koyu`, `beyaz_lake`, `on_dolap_kapagi`, `kapi_ahsap`) üretip koy;
nasıl durduğunu görünce kalanına karar veririz.
