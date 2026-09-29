# Gerçekçi görsel istemleri (yatak, kitaplık, karakterler)

Hepsini **kare (1:1), 512x512** üret; oyuna koyarken ben 128'e küçültüp atlasa ekleyeceğim.
İstemler İngilizce, olduğu gibi yapıştır. Dosya adları her istemin başında.
İpucu: aynı grubun (ör. yatak üstü + yatak yanı) hepsini **aynı sohbette/aynı seed ile** üret ki renkler tutsun.

Ortak ek (blok dokuları için sonuna ekle): `seamless tileable, flat even lighting, no shadows, no perspective, top-down or straight-on orthographic, no text, no watermark`

## A. Yatak  →  assets/textures/blocks/

A1. bed_top.png
Photorealistic top-down view of a made single bed: white cotton duvet with soft natural wrinkles, a plump white pillow at the top edge, blue striped border on the duvet, fabric weave visible, filling the whole square, straight overhead orthographic, soft even lighting, no shadows, no text

A2. bed_side.png
Photorealistic straight-on side view of a wooden bed frame: warm oak headboard/footboard wood grain on the lower half, blue and white duvet hanging over the edge in soft folds on the upper half, filling the whole square, orthographic, even lighting, no text

A3. bed_pillow.png
Photorealistic close-up of a white cotton pillow with a light blue pillowcase seam, soft wrinkles, fabric weave, filling the whole square, straight-on, even lighting

## B. Kitaplık ve ev eşyaları  →  assets/textures/blocks/

B1. bookshelf.png
Photorealistic straight-on front view of a wooden bookshelf with three shelves full of hardcover books in varied muted colors (red, green, navy, mustard, brown), visible gold lettering-free spines, dark walnut wood frame with grain, filling the whole square, orthographic, even lighting, no text

B2. bookshelf_top.png
Photorealistic top view of a dark walnut wood board with fine wood grain, seamless, filling the whole square

B3. planks.png
Photorealistic seamless oak wood planks texture, warm honey color, visible grain and small knots, 4 horizontal boards, top-down, even lighting

B4. dark_planks.png
Photorealistic seamless dark walnut parquet floor planks, horizontal boards, fine grain, slight sheen, top-down, even lighting

B5. plaster.png
Photorealistic seamless warm off-white painted plaster wall, very subtle roughness, even lighting

B6. roof_tile.png
Photorealistic seamless terracotta clay roof tiles in staggered overlapping rows, slightly weathered, orthographic, even lighting

B7. rug.png
Photorealistic top-down Turkish wool rug, deep red field with cream and gold geometric border and diamond medallion pattern, visible wool fibers, filling the whole square

B8. chest_side.png
Photorealistic straight-on front of a wooden treasure chest with dark iron bands and a brass lock, oak grain, filling the whole square, orthographic, even lighting

B9. crafting_top.png
Photorealistic top-down view of a carpenter's workbench surface: worn oak tabletop with saw marks, small pencil lines, a few nail holes, filling the whole square, even lighting

## C. Karakter yüzleri  →  assets/textures/actors/<kod>_face.png  (+ _face_talk.png)

Hepsi: `front-facing passport-style portrait, face fills the whole square, neutral light grey background, soft studio lighting, photorealistic, stylized 3D animated-film look (Pixar-like, not a real person), no text`
Konuşan hal için aynı istemi kullanıp sonuna `, mouth open mid-sentence` ekle.

C1. emir_face.png
Cheerful 8 year old village boy, warm peach skin, short messy dark brown hair with fringe, big friendly brown eyes, rosy cheeks, gentle smile

C2. anne_face.png
Kind young mother in her early 30s, warm skin, long dark brown hair falling on both sides, soft brown eyes, warm gentle smile

C3. ali_face.png
Energetic 8 year old boy, light tan skin, short black hair, mischievous grin with a missing front tooth, bright black eyes

C4. zeynep_face.png
Clever 8 year old girl, peach skin with light freckles, copper ginger hair with fringe, bright green eyes, confident smile

C5. ogretmen_face.png
Friendly elderly school teacher, peach skin, short grey hair, thin black rectangular glasses, kind eye wrinkles, warm smile

C6. doktor_face.png
Friendly young doctor, light tan skin, short neat black hair, warm dark eyes, reassuring smile, white collar visible at the bottom

C7. bakkal_face.png
Cheerful elderly neighborhood shopkeeper, peach skin, short grey hair, thick grey mustache, twinkling kind eyes, big smile

## D. Karakter kıyafet dokuları  →  assets/textures/actors/<kod>_<parça>.png

Kare, düz, kalıp/model yok, sadece kumaşın kendisi: `seamless fabric texture, flat even lighting, no folds, no shadows, no text`

D1. emir_shirt.png — `photorealistic red cotton t-shirt jersey fabric, fine knit weave`
D2. emir_jeans.png — `photorealistic mid-blue denim fabric, visible diagonal twill weave, slight fading`
D3. anne_dress.png — `photorealistic soft pink cotton fabric with a tiny white floral print`
D4. ali_shirt.png — `photorealistic sky blue cotton jersey fabric with thin white stripes`
D5. zeynep_shirt.png — `photorealistic lavender purple cotton knit fabric`
D6. ogretmen_jacket.png — `photorealistic green wool tweed blazer fabric, fine herringbone weave`
D7. doktor_coat.png — `photorealistic crisp white medical coat cotton fabric, subtle weave`
D8. bakkal_apron.png — `photorealistic orange canvas apron fabric, coarse weave`

## E. Tam boy karakter kartı (isteğe bağlı, afiş/kapak için)

E1. emir_ali_kapak.png (16:9, 1280x720)
Two stylized 3D animated-film boys standing side by side in a sunny village street: a cheerful 8 year old boy with messy dark brown hair, red t-shirt and blue jeans, and a mischievous 8 year old boy with short black hair, sky blue striped shirt, missing front tooth, warm golden hour light, soft depth of field, Pixar-like look, no text

## Nasıl teslim edilecek
Görselleri bana ekleyerek gönder; ben adlandırıp doğru klasöre koyar, atlası 128 px destekleyecek şekilde güncellerim. Önce **A1-A2 (yatak) ve B1 (kitaplık)** ile başlayıp nasıl göründüğüne bakalım, beğenirsen gerisini üretirsin.
