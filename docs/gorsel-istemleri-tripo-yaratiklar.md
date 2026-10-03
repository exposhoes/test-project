# Tripo3D için yaratık (kahraman) görsel istemleri

Oyunun başında tasarladığımız 23 karakterin 3B modeli (GLB) için görsel istemleri. İnsan
karakterlerin istemleri ayrı belgede: `docs/gorsel-istemleri-tripo.md`.

Her istem tam ve eksiksiz; hiçbir şey ekleme, kutudaki metnin tamamını olduğu gibi kopyala-yapıştır. Sıra: görseli üret → kontrol et → Tripo'ya
yükle → GLB'yi aşağıdaki dosya adıyla kaydet → bana gönder.

## Görseli Tripo'ya yüklemeden önce kontrol et

- Tek karakter var, tüm vücut görünüyor, arka plan düz beyaz mı?
- Kollarla gövde arasında ve iki bacak arasında boşluk var mı?
- Elde tutulan eşya (tokmak, balon, davul) gövdeye ya da bacağa yapışmamış mı?
- Görselde yazı, logo, zemin gölgesi, ikinci bir görünüş yok mu?

Biri bile hayırsa görseli yeniden ürettir.

## Tripo ayarları

**A grubu (iki ayaklı, kolları olan 15 karakter):** HD Model · Texture açık, 2K · Remove Lighting
açık · PBR kapalı · Topology Triangle · Polycount 10000 → Rig: Humanoid → Animate: Idle, Walk, Run,
Attack (varsa Jump, Wave) → önizlemede kolları ve bacakları kontrol et → Export: GLB, animasyonlar dahil.

**B grubu (kuş, dört ayaklı, zıplayan, süzülen 8 karakter):** Aynı model ayarları. Rig adımında
"Quadruped" seçeneği çıkarsa onu dene; çıkmazsa ya da sonuç bozuksa **rig yapmadan** GLB olarak
dışa aktar. Bu karakterleri oyunda kodla hareket ettireceğiz (zıplama, süzülme, sallanma).


## A grubu: iki ayaklı karakterler

### 1. Oyuncu → `mob_oyuncu.glb`
```
A friendly young adventurer boy, short brown hair, bright red hoodie with a small white pickaxe shape on the chest, dark blue jeans, brown boots, a small backpack on his back, confident smile, chunky blocky toy figure made of cubes and rectangular blocks, single character, full body, front view, standing in a neutral A-pose with both arms held straight and slightly away from the body, clear gap between each arm and the torso, legs apart with a clear gap between them, feet flat on the ground, symmetrical, flat matte colors, even soft studio lighting, plain pure white background, no shadow on the ground, no text, no logo, no watermark, no other objects, 1:1 aspect ratio
```

### 2. Tokmakçı → `mob_tokmak.glb`
```
A tall living tree-log creature with a square-cut birch-bark body, short stubby legs, long thin arms, a carved face with wide round eyes and a stretched open grin, a small red night-cap on top, a small lantern hanging from its belt, a heavy wooden mallet held in its right hand well away from the body, chunky blocky toy figure made of cubes and rectangular blocks, single character, full body, front view, standing in a neutral A-pose with both arms held straight and slightly away from the body, clear gap between each arm and the torso, legs apart with a clear gap between them, feet flat on the ground, symmetrical, flat matte colors, even soft studio lighting, plain pure white background, no shadow on the ground, no text, no logo, no watermark, no other objects, 1:1 aspect ratio
```

### 3. Mercek → `mob_mercek.glb`
```
A tall humanoid guard in a dark navy suit and tie, its head is a boxy vintage camcorder with one big round lens as the face, a small red recording light on top, grey fingerless gloves, heavy boots, chunky blocky toy figure made of cubes and rectangular blocks, single character, full body, front view, standing in a neutral A-pose with both arms held straight and slightly away from the body, clear gap between each arm and the torso, legs apart with a clear gap between them, feet flat on the ground, symmetrical, flat matte colors, even soft studio lighting, plain pure white background, no shadow on the ground, no text, no logo, no watermark, no other objects, 1:1 aspect ratio
```

### 4. Bas Bekçi → `mob_basbekci.glb`
```
A broad-shouldered humanoid guard in a charcoal suit, its head is a big square boombox speaker with two woofers stacked vertically, lime-green rings around the woofers, a short cable hanging down its back, chunky blocky toy figure made of cubes and rectangular blocks, single character, full body, front view, standing in a neutral A-pose with both arms held straight and slightly away from the body, clear gap between each arm and the torso, legs apart with a clear gap between them, feet flat on the ground, symmetrical, flat matte colors, even soft studio lighting, plain pure white background, no shadow on the ground, no text, no logo, no watermark, no other objects, 1:1 aspect ratio
```

### 5. Ekran Adam → `mob_ekran.glb`
```
A slim humanoid in a burgundy suit, its head is a chunky retro CRT monitor with a wooden-brown casing, the screen shows a glowing cyan spiral symbol, two small antennas on top, chunky blocky toy figure made of cubes and rectangular blocks, single character, full body, front view, standing in a neutral A-pose with both arms held straight and slightly away from the body, clear gap between each arm and the torso, legs apart with a clear gap between them, feet flat on the ground, symmetrical, flat matte colors, even soft studio lighting, plain pure white background, no shadow on the ground, no text, no logo, no watermark, no other objects, 1:1 aspect ratio
```

### 6. Boşluk Gölgesi → `mob_bosluk.glb`
```
An extremely tall and thin shadow humanoid made of pitch-black cubes, very long arms reaching below its knees, no face except two tiny dim white dot eyes, slightly hunched shoulders, chunky blocky toy figure made of cubes and rectangular blocks, single character, full body, front view, standing in a neutral A-pose with both arms held straight and slightly away from the body, clear gap between each arm and the torso, legs apart with a clear gap between them, feet flat on the ground, symmetrical, flat matte colors, even soft studio lighting, plain pure white background, no shadow on the ground, no text, no logo, no watermark, no other objects, 1:1 aspect ratio
```

### 7. Balon Kafa → `mob_balonkafa.glb`
```
A plump humanoid made of bright yellow rubbery cubes, a rounded cube head with a painted black smile and two black dot eyes, a tiny striped party cone hat, short arms, empty hands, chunky blocky toy figure made of cubes and rectangular blocks, single character, full body, front view, standing in a neutral A-pose with both arms held straight and slightly away from the body, clear gap between each arm and the torso, legs apart with a clear gap between them, feet flat on the ground, symmetrical, flat matte colors, even soft studio lighting, plain pure white background, no shadow on the ground, no text, no logo, no watermark, no other objects, 1:1 aspect ratio
```

### 8. Çivit → `mob_civit.glb`
```
A towering indigo-violet giant, very long dangling arms, hunched posture, small head compared to the body, a single tilted paper-boat hat on its head, big googly eyes of two different sizes, a few indigo drips under its mouth, chunky blocky toy figure made of cubes and rectangular blocks, single character, full body, front view, standing in a neutral A-pose with both arms held straight and slightly away from the body, clear gap between each arm and the torso, legs apart with a clear gap between them, feet flat on the ground, symmetrical, flat matte colors, even soft studio lighting, plain pure white background, no shadow on the ground, no text, no logo, no watermark, no other objects, 1:1 aspect ratio
```

### 9. Yosun → `mob_yosun.glb`
```
A tall slender moss-green creature, extremely long arms and long fingers, small leafy vines growing on its shoulders, eyes covered by a thick horizontal band of moss, wide mouth, chunky blocky toy figure made of cubes and rectangular blocks, single character, full body, front view, standing in a neutral A-pose with both arms held straight and slightly away from the body, clear gap between each arm and the torso, legs apart with a clear gap between them, feet flat on the ground, symmetrical, flat matte colors, even soft studio lighting, plain pure white background, no shadow on the ground, no text, no logo, no watermark, no other objects, 1:1 aspect ratio
```

### 10. Bando → `mob_bando.glb`
```
A chubby round mascot creature made of crimson red cubes, short legs, big smiling face, a tall blue marching-band hat with a white feather, a small drum strapped to its belly, white gloves, chunky blocky toy figure made of cubes and rectangular blocks, single character, full body, front view, standing in a neutral A-pose with both arms held straight and slightly away from the body, clear gap between each arm and the torso, legs apart with a clear gap between them, feet flat on the ground, symmetrical, flat matte colors, even soft studio lighting, plain pure white background, no shadow on the ground, no text, no logo, no watermark, no other objects, 1:1 aspect ratio
```

### 11. Koca Kurbağa → `mob_kocakurbaga.glb`
```
A huge bulky frog-like giant made of lime-green cubes, round belly, stubby legs, very wide mouth, one tiny curl of dark hair on top of its head, big friendly eyes, chunky blocky toy figure made of cubes and rectangular blocks, single character, full body, front view, standing in a neutral A-pose with both arms held straight and slightly away from the body, clear gap between each arm and the torso, legs apart with a clear gap between them, feet flat on the ground, symmetrical, flat matte colors, even soft studio lighting, plain pure white background, no shadow on the ground, no text, no logo, no watermark, no other objects, 1:1 aspect ratio
```

### 12. Fermuar → `mob_fermuar.glb`
```
A tall lanky plush toy monster with deep teal fuzzy fur, very long arms and legs, large round button eyes, a big zipper mouth across its face half-unzipped showing felt teeth, stitched seams on its body, chunky blocky toy figure made of cubes and rectangular blocks, single character, full body, front view, standing in a neutral A-pose with both arms held straight and slightly away from the body, clear gap between each arm and the torso, legs apart with a clear gap between them, feet flat on the ground, symmetrical, flat matte colors, even soft studio lighting, plain pure white background, no shadow on the ground, no text, no logo, no watermark, no other objects, 1:1 aspect ratio
```

### 13. Düğme → `mob_dugme.glb`
```
A tall lanky plush toy with soft coral-peach fuzzy fur, long arms and legs, large round button eyes with eyelashes, a closed stitched zipper smile, a big yellow bow on its head, chunky blocky toy figure made of cubes and rectangular blocks, single character, full body, front view, standing in a neutral A-pose with both arms held straight and slightly away from the body, clear gap between each arm and the torso, legs apart with a clear gap between them, feet flat on the ground, symmetrical, flat matte colors, even soft studio lighting, plain pure white background, no shadow on the ground, no text, no logo, no watermark, no other objects, 1:1 aspect ratio
```

### 14. Fabrika Patronu → `mob_patron.glb`
```
A giant toy factory robot boss, boxy grey-blue metal body with a big yellow chest panel, thick short legs, long arms ending in red boxy fists, square head with glowing red eyes and a yellow grille mouth, a small antenna with a red light bulb on top, chunky blocky toy figure made of cubes and rectangular blocks, single character, full body, front view, standing in a neutral A-pose with both arms held straight and slightly away from the body, clear gap between each arm and the torso, legs apart with a clear gap between them, feet flat on the ground, symmetrical, flat matte colors, even soft studio lighting, plain pure white background, no shadow on the ground, no text, no logo, no watermark, no other objects, 1:1 aspect ratio
```

### 15. Floresan Dev → `mob_floresan.glb`
```
A very tall thin creepy giant, long beige legs and very long thin arms, narrow khaki torso, its head is a flat glowing cream ceiling light panel with an empty square-eyed face, chunky blocky toy figure made of cubes and rectangular blocks, single character, full body, front view, standing in a neutral A-pose with both arms held straight and slightly away from the body, clear gap between each arm and the torso, legs apart with a clear gap between them, feet flat on the ground, symmetrical, flat matte colors, even soft studio lighting, plain pure white background, no shadow on the ground, no text, no logo, no watermark, no other objects, 1:1 aspect ratio
```

## B grubu: iki ayaklı olmayan karakterler

### 16. Tüylüpaşa → `mob_tuylupasa.glb` (oyunda: yürür, zıplar)
```
A chubby round-bodied pigeon-like bird, dusty teal feathers, oversized head, tiny orange legs, a proud upright plume of three tall feathers on its head, a thick curled black moustache under the beak, a small golden vest on its chest, wings folded but slightly away from the body, chunky blocky toy figure made of cubes and rectangular blocks, single character, whole body visible, three-quarter front view, every limb clearly separated from the body, flat matte colors, even soft studio lighting, plain pure white background, no shadow on the ground, no text, no logo, no watermark, no other objects, 1:1 aspect ratio
```

### 17. Lavabo Kafa → `mob_lavabo.glb` (oyunda: zıplar)
```
A white ceramic washbasin creature, a goofy human-like head with messy hair popping out of the basin bowl, a chrome faucet sticking out of the back of the basin like a tail, one short pipe underneath used as a single pogo leg, silly menacing expression, chunky blocky toy figure made of cubes and rectangular blocks, single character, whole body visible, three-quarter front view, every limb clearly separated from the body, flat matte colors, even soft studio lighting, plain pure white background, no shadow on the ground, no text, no logo, no watermark, no other objects, 1:1 aspect ratio
```

### 18. Sırıtkan → `mob_siritkan.glb` (oyunda: süzülür)
```
A floating cube-shaped head made of dark shadow, a huge glowing white toothy grin and two glowing white slit eyes, a short wisp of dark smoke below instead of a body, chunky blocky toy figure made of cubes and rectangular blocks, single character, whole body visible, three-quarter front view, every limb clearly separated from the body, flat matte colors, even soft studio lighting, plain pure white background, no shadow on the ground, no text, no logo, no watermark, no other objects, 1:1 aspect ratio
```

### 19. Pençe → `mob_pence.glb` (oyunda: dört ayak üstünde koşar)
```
A gaunt four-legged crawling humanoid creature made of pale grey cubes, long thin limbs, bumps along its spine, messy dark hair hanging over its face, long cube fingers like claws, standing on all fours with all four limbs spread apart, chunky blocky toy figure made of cubes and rectangular blocks, single character, whole body visible, three-quarter front view, every limb clearly separated from the body, flat matte colors, even soft studio lighting, plain pure white background, no shadow on the ground, no text, no logo, no watermark, no other objects, 1:1 aspect ratio
```

### 20. Kıvılcım → `mob_kivilcim.glb` (oyunda: dört ayak üstünde koşar)
```
A lizard-like creature made of bright tangerine orange cubes, long flat body, long tail, four short legs spread apart, two tiny horns on its head, big hungry eyes, a short pink tongue sticking out, chunky blocky toy figure made of cubes and rectangular blocks, single character, whole body visible, three-quarter front view, every limb clearly separated from the body, flat matte colors, even soft studio lighting, plain pure white background, no shadow on the ground, no text, no logo, no watermark, no other objects, 1:1 aspect ratio
```

### 21. Pembe Leylek → `mob_pembeleylek.glb` (oyunda: yürür)
```
A tall flamingo-pink bird, two long thin legs apart, long neck, oversized box-shaped beak slightly open, small wings held slightly away from the body, a white bib-shaped chest patch, chunky blocky toy figure made of cubes and rectangular blocks, single character, whole body visible, three-quarter front view, every limb clearly separated from the body, flat matte colors, even soft studio lighting, plain pure white background, no shadow on the ground, no text, no logo, no watermark, no other objects, 1:1 aspect ratio
```

### 22. Mışıl → `mob_misil.glb` (oyunda: dört ayak üstünde yürür)
```
A long slinky cat creature made of soft lilac cubes, sleepy crescent-moon shaped eyes, a big smile, a crescent moon pendant on its chest, long tail, standing on all fours with all four legs spread apart, chunky blocky toy figure made of cubes and rectangular blocks, single character, whole body visible, three-quarter front view, every limb clearly separated from the body, flat matte colors, even soft studio lighting, plain pure white background, no shadow on the ground, no text, no logo, no watermark, no other objects, 1:1 aspect ratio
```

### 23. Kutucuk → `mob_kutucuk.glb` (oyunda: yerinde durur, fırlar)
```
A jack-in-the-box toy, a red and yellow striped cube box with a crank on its side, a boxy blue robot-toy head popping out of the top on a coiled spring, two long mechanical arms with clamp hands coming out of the sides of the box and held away from it, playful menacing grin, chunky blocky toy figure made of cubes and rectangular blocks, single character, whole body visible, three-quarter front view, every limb clearly separated from the body, flat matte colors, even soft studio lighting, plain pure white background, no shadow on the ground, no text, no logo, no watermark, no other objects, 1:1 aspect ratio
```

## Sıra önerisi

Önce üç tane üretip gönder, oyunda nasıl durduğuna bakalım: **Oyuncu**, **Mercek**, **Tokmakçı**.
Beğenirsen kalan A grubunu, en son B grubunu yap.

## Şu anki durum

Oyun yaratıkları şimdilik kodla çizilen köşeli parçalardan kuruyor; `mob_<ad>.glb` dosyalarını
okuyan kod henüz yok. İlk GLB geldiğinde bu destek eklenecek (film karakterlerindeki gibi:
dosya varsa model, yoksa eski köşeli hali).
