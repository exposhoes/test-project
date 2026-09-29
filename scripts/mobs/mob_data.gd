class_name MobData
extends RefCounted
## Oyundaki tüm karakter ve yaratıkların tanımı.
## Görseller docs/gorsel-istemleri.md içindeki istemlerle üretilip
## assets/textures/mobs/mob_<kod>_face.png olarak eklendiğinde otomatik kullanılır.

enum Behavior { PASSIVE, NEUTRAL, HOSTILE, ALLY }
enum Habitat { OVERWORLD, YELLOW_HALLS, TOY_FACTORY }

## height: toplam boy (blok), width: gövde genişliği, speed: blok/sn, night_only: sadece gece doğar.
## health (varsayılan 10) ve damage (varsayılan 2) yarım kalp birimindedir.
## İsteğe bağlı "parts": [boyut, merkez, renk, (doku)] kutuları ve "face": [kenar, merkez] ile özel model;
## verilmezse boy/genişlikten genel bir model kurulur. Model -Z yönüne bakar.
## "face" kenarı sayı (kare) ya da Vector2 (dikdörtgen) olabilir. "face_glow": yüz gölgelenmez, karanlıkta da parlar.
## "reach": saldırı mesafesine eklenen blok (uzun kollular). "ability": özel yetenek (mob.gd):
##   hop: zıplayarak ilerler · stare: bakılınca donar, bakılmayınca hızlanır · hears: sadece koşan oyuncuyu duyar
##   teleport: yakalayınca oyuncuyu ışınlar · gas: uyku gazı · ambush: yaklaşana kadar kıpırdamaz
##   toss: oyuncuyu havaya atar · night_hostile: gece düşmanlaşır · fears_light: fenerden ve elinde fener tutandan kaçar
##   (evcil) warn: düşman yaklaşınca öterek haber verir
## "tame_item": bu eşya verilince evcilleşir (dostlarda varsayılan demir).
##   (dostlar) shockwave: çevredeki tüm düşmanları iter · stun: vurduğunu dondurur
const MOBS := {
	"tokmak": {"name": "Tokmakçı", "reach": 0.8, "health": 16, "damage": 3, "behavior": Behavior.HOSTILE, "habitat": Habitat.OVERWORLD, "night_only": true,
		"primary": Color("e8dcc0"), "secondary": Color("b8322f"), "height": 2.4, "width": 0.8, "speed": 3.0,
		# Konsept: docs/konseptler/mob_tokmak_concept.png — uzun huş kütüğü gövde, kırmızı bere, tokmak ve fener.
		"parts": [
			[Vector3(0.14, 0.4, 0.14), Vector3(-0.15, 0.2, 0), Color("e8dcc0"), "birch_bark"],
			[Vector3(0.14, 0.4, 0.14), Vector3(0.15, 0.2, 0), Color("e8dcc0"), "birch_bark"],
			[Vector3(0.6, 1.9, 0.5), Vector3(0, 1.35, 0), Color("e8dcc0"), "birch_bark"],
			[Vector3(0.62, 0.1, 0.52), Vector3(0, 0.95, 0), Color("6e4a2a")],
			[Vector3(0.36, 0.14, 0.3), Vector3(0, 2.37, 0), Color("b8322f")],
			[Vector3(0.2, 0.1, 0.18), Vector3(0.1, 2.48, 0), Color("b8322f")],
			[Vector3(0.1, 0.9, 0.1), Vector3(-0.36, 1.35, 0), Color("ddd0b0")],
			[Vector3(0.1, 0.9, 0.1), Vector3(0.36, 1.35, 0), Color("ddd0b0")],
			[Vector3(0.07, 0.8, 0.07), Vector3(0.36, 1.1, -0.12), Color("6e4a2a")],
			[Vector3(0.3, 0.24, 0.24), Vector3(0.36, 1.5, -0.12), Color("8a6238")],
			[Vector3(0.14, 0.18, 0.14), Vector3(-0.3, 0.8, -0.2), Color("f2b33a")],
		],
		"face": [0.56, Vector3(0, 1.98, -0.25)]},
	"tuylupasa": {"name": "Tüylüpaşa", "ability": "warn", "tame_item": Items.APPLE, "health": 4, "behavior": Behavior.PASSIVE, "habitat": Habitat.OVERWORLD,
		"primary": Color("4f8a86"), "secondary": Color("e3833a"), "height": 1.05, "width": 0.6, "speed": 2.0,
		# Konsept: docs/konseptler/mob_tuylupasa_concept.png — teal gövde, huş renkli kafa, altın yelek, üç tüylü sorguç.
		"parts": [
			[Vector3(0.05, 0.12, 0.05), Vector3(-0.1, 0.06, 0), Color("e3833a")],
			[Vector3(0.05, 0.12, 0.05), Vector3(0.1, 0.06, 0), Color("e3833a")],
			[Vector3(0.5, 0.42, 0.42), Vector3(0, 0.33, 0), Color("4f8a86")],
			[Vector3(0.36, 0.14, 0.02), Vector3(0, 0.46, -0.215), Color("c9a02e")],
			[Vector3(0.08, 0.32, 0.36), Vector3(-0.29, 0.34, 0), Color("447a76")],
			[Vector3(0.08, 0.32, 0.36), Vector3(0.29, 0.34, 0), Color("447a76")],
			[Vector3(0.24, 0.08, 0.2), Vector3(0, 0.4, 0.28), Color("447a76")],
			[Vector3(0.46, 0.46, 0.46), Vector3(0, 0.77, 0), Color("e8dcc0"), "birch_bark"],
			[Vector3(0.07, 0.3, 0.07), Vector3(0, 1.15, 0), Color("4f8a86")],
			[Vector3(0.06, 0.24, 0.06), Vector3(-0.1, 1.11, 0), Color("4f8a86")],
			[Vector3(0.06, 0.24, 0.06), Vector3(0.1, 1.11, 0), Color("4f8a86")],
		],
		"face": [0.46, Vector3(0, 0.77, -0.23)]},
	"lavabo": {"name": "Lavabo Kafa", "ability": "hop", "health": 8, "damage": 2, "behavior": Behavior.HOSTILE, "habitat": Habitat.OVERWORLD,
		"primary": Color("f4f4f4"), "secondary": Color("e7b99a"), "height": 1.5, "width": 0.8, "speed": 3.5,
		# Konsept: docs/konseptler/mob_lavabo_concept.png — lavabo gövde, kıvırcık saçlı kafa, T kollar, boru ve yay bacak.
		"parts": [
			[Vector3(0.2, 0.16, 0.2), Vector3(0, 0.08, 0), Color("b8322f")],
			[Vector3(0.09, 0.42, 0.09), Vector3(0, 0.37, 0), Color("a3a9ae")],
			[Vector3(0.8, 0.44, 0.6), Vector3(0, 0.8, 0), Color("eef1f2")],
			[Vector3(0.6, 0.02, 0.4), Vector3(0, 1.02, -0.04), Color("aab2b8")],
			[Vector3(0.06, 0.14, 0.06), Vector3(0, 0.96, 0.33), Color("b5bbc0")],
			[Vector3(0.06, 0.06, 0.16), Vector3(0, 1.0, 0.4), Color("b5bbc0")],
			[Vector3(0.4, 0.08, 0.08), Vector3(-0.6, 0.86, 0), Color("e7b99a")],
			[Vector3(0.4, 0.08, 0.08), Vector3(0.6, 0.86, 0), Color("e7b99a")],
			[Vector3(0.4, 0.4, 0.4), Vector3(0, 1.21, 0.05), Color("e7b99a")],
			[Vector3(0.44, 0.1, 0.44), Vector3(0, 1.44, 0.05), Color("6b3f1f")],
			[Vector3(0.44, 0.34, 0.06), Vector3(0, 1.27, 0.26), Color("6b3f1f")],
		],
		"face": [0.4, Vector3(0, 1.21, -0.15)]},
	"mercek": {"name": "Mercek", "health": 20, "damage": 3, "behavior": Behavior.ALLY, "habitat": Habitat.OVERWORLD,
		"primary": Color("1f2a44"), "secondary": Color("555a60"), "height": 2.0, "width": 0.7, "speed": 3.0,
		# Konsept: docs/konseptler/mob_mercek_concept.png — lacivert takım elbise, kamera kafa, kırmızı kayıt ışığı.
		"parts": [
			[Vector3(0.22, 0.18, 0.3), Vector3(-0.12, 0.09, -0.03), Color("1a1d22")],
			[Vector3(0.22, 0.18, 0.3), Vector3(0.12, 0.09, -0.03), Color("1a1d22")],
			[Vector3(0.2, 0.62, 0.24), Vector3(-0.12, 0.49, 0), Color("1f2a44")],
			[Vector3(0.2, 0.62, 0.24), Vector3(0.12, 0.49, 0), Color("1f2a44")],
			[Vector3(0.56, 0.64, 0.3), Vector3(0, 1.12, 0), Color("243150")],
			[Vector3(0.06, 0.4, 0.02), Vector3(0, 1.22, -0.16), Color("3b4450")],
			[Vector3(0.16, 0.6, 0.16), Vector3(-0.36, 1.13, 0), Color("243150")],
			[Vector3(0.16, 0.6, 0.16), Vector3(0.36, 1.13, 0), Color("243150")],
			[Vector3(0.14, 0.12, 0.14), Vector3(-0.36, 0.78, 0), Color("6b6f75")],
			[Vector3(0.14, 0.12, 0.14), Vector3(0.36, 0.78, 0), Color("6b6f75")],
			[Vector3(0.12, 0.06, 0.12), Vector3(0, 1.47, 0), Color("e7b99a")],
			[Vector3(0.46, 0.44, 0.5), Vector3(0, 1.72, 0), Color("555a60")],
			[Vector3(0.06, 0.2, 0.2), Vector3(-0.26, 1.72, 0), Color("2a2e33")],
			[Vector3(0.06, 0.2, 0.2), Vector3(0.26, 1.72, 0), Color("2a2e33")],
			[Vector3(0.2, 0.06, 0.3), Vector3(0, 1.97, 0.02), Color("2a2e33")],
			[Vector3(0.06, 0.04, 0.06), Vector3(0.07, 2.02, -0.1), Color("e02020")],
		],
		"face": [Vector2(0.46, 0.44), Vector3(0, 1.72, -0.25)]},
	"basbekci": {"name": "Bas Bekçi", "ability": "shockwave", "health": 26, "damage": 4, "behavior": Behavior.ALLY, "habitat": Habitat.OVERWORLD, "face_glow": true,
		"primary": Color("333333"), "secondary": Color("111111"), "height": 2.05, "width": 0.8, "speed": 2.8,
		# Konsept: docs/konseptler/mob_basbekci_concept.png — siyah takım, çift hoparlörlü kafa, sırtında kablo.
		"parts": [
			[Vector3(0.24, 0.06, 0.3), Vector3(-0.13, 0.03, -0.02), Color("1a1a1a")],
			[Vector3(0.24, 0.06, 0.3), Vector3(0.13, 0.03, -0.02), Color("1a1a1a")],
			[Vector3(0.22, 0.7, 0.26), Vector3(-0.13, 0.41, 0), Color("2b2b2b")],
			[Vector3(0.22, 0.7, 0.26), Vector3(0.13, 0.41, 0), Color("2b2b2b")],
			[Vector3(0.66, 0.62, 0.34), Vector3(0, 1.07, 0), Color("333333")],
			[Vector3(0.18, 0.6, 0.18), Vector3(-0.42, 1.08, 0), Color("333333")],
			[Vector3(0.18, 0.6, 0.18), Vector3(0.42, 1.08, 0), Color("333333")],
			[Vector3(0.2, 0.05, 0.2), Vector3(-0.42, 0.8, 0), Color("777777")],
			[Vector3(0.2, 0.05, 0.2), Vector3(0.42, 0.8, 0), Color("777777")],
			[Vector3(0.52, 0.62, 0.44), Vector3(0, 1.7, 0), Color("3a3a3a")],
			[Vector3(0.05, 0.8, 0.05), Vector3(0, 1.1, 0.2), Color("555555")],
		],
		"face": [Vector2(0.48, 0.58), Vector3(0, 1.7, -0.22)]},
	"ekran": {"name": "Ekran Adam", "ability": "stun", "health": 20, "damage": 3, "behavior": Behavior.ALLY, "habitat": Habitat.OVERWORLD, "face_glow": true,
		"primary": Color("6b1f2c"), "secondary": Color("7a5530"), "height": 2.1, "width": 0.7, "speed": 3.0,
		# Konsept: docs/konseptler/mob_ekran_concept.png — bordo takım, ahşap kasalı tüplü TV kafa, iki anten.
		"parts": [
			[Vector3(0.22, 0.08, 0.3), Vector3(-0.12, 0.04, -0.03), Color("4a1520")],
			[Vector3(0.22, 0.08, 0.3), Vector3(0.12, 0.04, -0.03), Color("4a1520")],
			[Vector3(0.2, 0.74, 0.24), Vector3(-0.12, 0.45, 0), Color("6b1f2c")],
			[Vector3(0.2, 0.74, 0.24), Vector3(0.12, 0.45, 0), Color("6b1f2c")],
			[Vector3(0.56, 0.62, 0.3), Vector3(0, 1.13, 0), Color("7a2433")],
			[Vector3(0.16, 0.6, 0.16), Vector3(-0.36, 1.14, 0), Color("7a2433")],
			[Vector3(0.16, 0.6, 0.16), Vector3(0.36, 1.14, 0), Color("7a2433")],
			[Vector3(0.12, 0.1, 0.12), Vector3(-0.36, 0.79, 0), Color("e0a888")],
			[Vector3(0.12, 0.1, 0.12), Vector3(0.36, 0.79, 0), Color("e0a888")],
			[Vector3(0.14, 0.08, 0.14), Vector3(0, 1.48, 0), Color("3a2a20")],
			[Vector3(0.56, 0.5, 0.44), Vector3(0, 1.77, 0), Color("7a5530")],
			[Vector3(0.42, 0.34, 0.16), Vector3(0, 1.77, 0.3), Color("5e4024")],
			[Vector3(0.03, 0.22, 0.03), Vector3(-0.1, 2.12, 0), Color("888888")],
			[Vector3(0.03, 0.22, 0.03), Vector3(0.1, 2.12, 0), Color("888888")],
		],
		"face": [Vector2(0.56, 0.5), Vector3(0, 1.77, -0.22)]},
	"bosluk": {"name": "Boşluk Gölgesi", "ability": "stare", "behavior": Behavior.HOSTILE, "habitat": Habitat.OVERWORLD, "night_only": true, "face_glow": true,
		"primary": Color("0b0b0f"), "secondary": Color("1a1024"), "height": 2.7, "width": 0.6, "speed": 2.5,
		# Konsept: docs/konseptler/mob_bosluk_concept.png — upuzun, sıska, simsiyah gövde; karanlıkta parlayan iki göz.
		# Sarı Koridorlar boyutu gelene kadar geceleri normal dünyada doğar.
		"parts": [
			[Vector3(0.14, 1.3, 0.14), Vector3(-0.1, 0.65, 0), Color("0b0b0f")],
			[Vector3(0.14, 1.3, 0.14), Vector3(0.1, 0.65, 0), Color("0b0b0f")],
			[Vector3(0.34, 0.16, 0.2), Vector3(0, 1.36, 0), Color("111118")],
			[Vector3(0.2, 0.3, 0.16), Vector3(0, 1.59, 0), Color("0b0b0f")],
			[Vector3(0.46, 0.5, 0.24), Vector3(0, 1.99, 0), Color("111118")],
			[Vector3(0.1, 1.5, 0.1), Vector3(-0.3, 1.5, 0), Color("0b0b0f")],
			[Vector3(0.1, 1.5, 0.1), Vector3(0.3, 1.5, 0), Color("0b0b0f")],
			[Vector3(0.08, 0.1, 0.08), Vector3(0, 2.29, 0), Color("0b0b0f")],
			[Vector3(0.34, 0.36, 0.34), Vector3(0, 2.52, 0), Color("0b0b0f")],
		],
		"face": [0.34, Vector3(0, 2.52, -0.17)]},
	"siritkan": {"name": "Sırıtkan", "ability": "fears_light", "health": 12, "damage": 3, "behavior": Behavior.HOSTILE, "habitat": Habitat.YELLOW_HALLS, "face_glow": true,
		"primary": Color("050505"), "secondary": Color("050505"), "height": 1.2, "width": 0.9, "speed": 2.2,
		# Konsept: docs/konseptler/mob_siritkan_concept.png
		"parts": [
			[Vector3(0.3, 0.3, 0.3), Vector3(0, 0.38, 0), Color("4a3b55")],
			[Vector3(0.24, 0.24, 0.24), Vector3(0.08, 0.14, 0.05), Color("3d3048")],
			[Vector3(0.2, 0.2, 0.2), Vector3(-0.1, 0.24, -0.04), Color("5a4a66")],
			[Vector3(0.7, 0.7, 0.7), Vector3(0, 0.88, 0), Color("1c1424")],
		],
		"face": [Vector2(0.7, 0.39), Vector3(0, 0.88, -0.37)]},
	"balonkafa": {"name": "Balon Kafa", "ability": "teleport", "health": 10, "damage": 2, "behavior": Behavior.HOSTILE, "habitat": Habitat.YELLOW_HALLS,
		"primary": Color("f2d21b"), "secondary": Color("f2d21b"), "height": 1.9, "width": 0.9, "speed": 3.8,
		# Konsept: docs/konseptler/mob_balonkafa_concept.png
		"parts": [
			[Vector3(0.22, 0.6, 0.22), Vector3(-0.15, 0.3, 0), Color("f2d21a")],
			[Vector3(0.22, 0.6, 0.22), Vector3(0.15, 0.3, 0), Color("f2d21a")],
			[Vector3(0.6, 0.8, 0.45), Vector3(0, 1.0, 0), Color("f5d81c")],
			[Vector3(0.45, 0.16, 0.16), Vector3(-0.5, 1.25, 0), Color("f2d21a")],
			[Vector3(0.45, 0.16, 0.16), Vector3(0.5, 1.25, 0), Color("f2d21a")],
			[Vector3(0.5, 0.5, 0.5), Vector3(0, 1.66, 0), Color("f5d81c")],
			[Vector3(0.15, 0.25, 0.15), Vector3(0, 2.03, 0), Color("4a78d9")],
			[Vector3(0.25, 0.25, 0.25), Vector3(-0.8, 1.9, 0), Color("e03030")],
			[Vector3(0.25, 0.25, 0.25), Vector3(-0.62, 2.05, 0.1), Color("3a7be0")],
			[Vector3(0.25, 0.25, 0.25), Vector3(-0.9, 2.1, -0.1), Color("3fbf4a")],
		],
		"face": [0.5, Vector3(0, 1.66, -0.27)]},
	"pence": {"name": "Pençe", "ability": "hears", "health": 8, "damage": 3, "behavior": Behavior.HOSTILE, "habitat": Habitat.YELLOW_HALLS,
		"primary": Color("b9b6ae"), "secondary": Color("1b1b1b"), "height": 1.0, "width": 1.2, "speed": 5.5,
		# Konsept: docs/konseptler/mob_pence_concept.png
		"parts": [
			[Vector3(0.1, 0.7, 0.1), Vector3(-0.2, 0.35, -0.35), Color("b9b6ae")],
			[Vector3(0.1, 0.7, 0.1), Vector3(0.2, 0.35, -0.35), Color("b9b6ae")],
			[Vector3(0.1, 0.7, 0.1), Vector3(-0.2, 0.35, 0.35), Color("b9b6ae")],
			[Vector3(0.1, 0.7, 0.1), Vector3(0.2, 0.35, 0.35), Color("b9b6ae")],
			[Vector3(0.4, 0.3, 1.0), Vector3(0, 0.78, 0), Color("c8c5bd")],
			[Vector3(0.1, 0.08, 0.1), Vector3(0, 0.97, -0.2), Color("a9a69e")],
			[Vector3(0.1, 0.08, 0.1), Vector3(0, 0.97, 0.15), Color("a9a69e")],
			[Vector3(0.44, 0.44, 0.4), Vector3(0, 0.8, -0.62), Color("2a2a2a")],
		],
		"face": [0.42, Vector3(0, 0.78, -0.84)]},
	"civit": {"name": "Çivit", "reach": 1.5, "health": 24, "damage": 4, "behavior": Behavior.HOSTILE, "habitat": Habitat.TOY_FACTORY,
		"primary": Color("4b3bb0"), "secondary": Color("f0f0f0"), "height": 3.4, "width": 1.2, "speed": 2.4,
		# Konsept: docs/konseptler/mob_civit_concept.png
		"parts": [
			[Vector3(0.3, 0.8, 0.3), Vector3(-0.22, 0.4, 0), Color("4b2ea8")],
			[Vector3(0.3, 0.8, 0.3), Vector3(0.22, 0.4, 0), Color("4b2ea8")],
			[Vector3(0.8, 1.0, 0.6), Vector3(0, 1.3, 0), Color("5534b8")],
			[Vector3(0.22, 1.5, 0.22), Vector3(-0.55, 1.05, 0), Color("4b2ea8")],
			[Vector3(0.22, 1.5, 0.22), Vector3(0.55, 1.05, 0), Color("4b2ea8")],
			[Vector3(0.42, 0.42, 0.4), Vector3(0, 2.0, -0.05), Color("5534b8")],
			[Vector3(0.5, 0.18, 0.3), Vector3(0, 2.3, 0), Color("e8e2d4")],
		],
		"face": [0.42, Vector3(0, 2.0, -0.26)]},
	"yosun": {"name": "Yosun", "ability": "hears", "health": 18, "damage": 3, "behavior": Behavior.HOSTILE, "habitat": Habitat.TOY_FACTORY,
		"primary": Color("4c8a3a"), "secondary": Color("2e5b22"), "height": 3.0, "width": 0.8, "speed": 3.2,
		# Konsept: docs/konseptler/mob_yosun_concept.png
		"parts": [
			[Vector3(0.18, 1.3, 0.18), Vector3(-0.12, 0.65, 0), Color("4f7a28")],
			[Vector3(0.18, 1.3, 0.18), Vector3(0.12, 0.65, 0), Color("4f7a28")],
			[Vector3(0.5, 0.9, 0.3), Vector3(0, 1.75, 0), Color("5b8a2e")],
			[Vector3(0.14, 1.6, 0.14), Vector3(-0.4, 1.4, 0), Color("5b8a2e")],
			[Vector3(0.14, 1.6, 0.14), Vector3(0.4, 1.4, 0), Color("5b8a2e")],
			[Vector3(0.24, 0.4, 0.14), Vector3(-0.4, 0.45, 0), Color("4a7324")],
			[Vector3(0.24, 0.4, 0.14), Vector3(0.4, 0.45, 0), Color("4a7324")],
			[Vector3(0.5, 0.45, 0.45), Vector3(0, 2.45, 0), Color("5b8a2e")],
			[Vector3(0.52, 0.12, 0.47), Vector3(0, 2.72, 0), Color("7a4a24")],
		],
		"face": [Vector2(0.5, 0.45), Vector3(0, 2.45, -0.225)]},
	"kivilcim": {"name": "Kıvılcım", "health": 6, "damage": 1, "behavior": Behavior.NEUTRAL, "habitat": Habitat.TOY_FACTORY,
		"primary": Color("f2801e"), "secondary": Color("e85a8a"), "height": 1.0, "width": 1.0, "speed": 6.0,
		# Konsept: docs/konseptler/mob_kivilcim_concept.png
		"parts": [
			[Vector3(0.15, 0.25, 0.15), Vector3(-0.3, 0.12, -0.35), Color("d9620c")],
			[Vector3(0.15, 0.25, 0.15), Vector3(0.3, 0.12, -0.35), Color("d9620c")],
			[Vector3(0.15, 0.25, 0.15), Vector3(-0.3, 0.12, 0.35), Color("d9620c")],
			[Vector3(0.15, 0.25, 0.15), Vector3(0.3, 0.12, 0.35), Color("d9620c")],
			[Vector3(0.45, 0.35, 1.1), Vector3(0, 0.38, 0), Color("e87314")],
			[Vector3(0.2, 0.2, 0.8), Vector3(0, 0.3, 0.9), Color("e87314")],
			[Vector3(0.55, 0.4, 0.5), Vector3(0, 0.55, -0.75), Color("e87314")],
			[Vector3(0.08, 0.14, 0.08), Vector3(-0.16, 0.82, -0.75), Color("c9560a")],
			[Vector3(0.08, 0.14, 0.08), Vector3(0.16, 0.82, -0.75), Color("c9560a")],
		],
		"face": [Vector2(0.55, 0.36), Vector3(0, 0.55, -1.0)]},
	"bando": {"name": "Bando", "ability": "night_hostile", "health": 16, "damage": 3, "behavior": Behavior.NEUTRAL, "habitat": Habitat.TOY_FACTORY,
		"primary": Color("c0202e"), "secondary": Color("2a4fb0"), "height": 2.2, "width": 1.2, "speed": 2.6,
		# Konsept: docs/konseptler/mob_bando_concept.png
		"parts": [
			[Vector3(0.18, 0.4, 0.18), Vector3(-0.15, 0.2, 0), Color("b3172f")],
			[Vector3(0.18, 0.4, 0.18), Vector3(0.15, 0.2, 0), Color("b3172f")],
			[Vector3(0.7, 0.6, 0.5), Vector3(0, 0.7, 0), Color("c21a36")],
			[Vector3(0.35, 0.2, 0.2), Vector3(0, 0.7, -0.33), Color("b88a5a")],
			[Vector3(0.4, 0.13, 0.13), Vector3(-0.55, 0.9, 0), Color("c21a36")],
			[Vector3(0.4, 0.13, 0.13), Vector3(0.55, 0.9, 0), Color("c21a36")],
			[Vector3(0.7, 0.55, 0.55), Vector3(0, 1.28, 0), Color("c21a36")],
			[Vector3(0.4, 0.35, 0.4), Vector3(0, 1.73, 0), Color("1f4fb3")],
			[Vector3(0.08, 0.2, 0.08), Vector3(0, 2.0, 0), Color("eeeeee")],
		],
		"face": [Vector2(0.7, 0.55), Vector3(0, 1.28, -0.3)]},
	"kocakurbaga": {"name": "Koca Kurbağa", "ability": "toss", "health": 30, "damage": 4, "behavior": Behavior.NEUTRAL, "habitat": Habitat.OVERWORLD,
		"primary": Color("8fd13f"), "secondary": Color("5c9a25"), "height": 3.0, "width": 1.8, "speed": 1.8,
		# Konsept: docs/konseptler/mob_kocakurbaga_concept.png
		"parts": [
			[Vector3(0.5, 0.8, 0.5), Vector3(-0.4, 0.4, 0), Color("86b81a")],
			[Vector3(0.5, 0.8, 0.5), Vector3(0.4, 0.4, 0), Color("86b81a")],
			[Vector3(1.5, 1.3, 1.1), Vector3(0, 1.45, 0), Color("9ccf1f")],
			[Vector3(1.0, 0.9, 0.02), Vector3(0, 1.4, -0.56), Color("b7e03a")],
			[Vector3(0.9, 0.3, 0.3), Vector3(-1.2, 1.8, 0), Color("9ccf1f")],
			[Vector3(0.9, 0.3, 0.3), Vector3(1.2, 1.8, 0), Color("9ccf1f")],
			[Vector3(1.2, 0.9, 1.0), Vector3(0, 2.55, 0), Color("9ccf1f")],
			[Vector3(0.08, 0.15, 0.08), Vector3(0, 3.07, 0), Color("2a2a1a")],
		],
		"face": [Vector2(1.2, 0.9), Vector3(0, 2.55, -0.52)]},
	# Boss: kendiliğinden doğmaz; Oyuncak Fabrikası'na ilk girişte bir salonda bekler (main.gd).
	"floresan": {"name": "Floresan Dev", "boss": true, "reach": 0.8, "health": 90, "damage": 4,
		"behavior": Behavior.HOSTILE, "habitat": Habitat.YELLOW_HALLS, "loot": {Items.CRYSTAL: 3, Items.GOLD: 8},
		"primary": Color("d8cf9a"), "secondary": Color("8a8150"), "height": 3.5, "width": 1.2, "speed": 3.3, "face_glow": true,
		"parts": [
			[Vector3(0.28, 1.6, 0.28), Vector3(-0.25, 0.8, 0), Color("8a8150")],
			[Vector3(0.28, 1.6, 0.28), Vector3(0.25, 0.8, 0), Color("8a8150")],
			[Vector3(0.9, 1.1, 0.5), Vector3(0, 2.1, 0), Color("b8ae72")],
			[Vector3(0.2, 1.7, 0.2), Vector3(-0.58, 1.75, 0), Color("a89f66")],
			[Vector3(0.2, 1.7, 0.2), Vector3(0.58, 1.75, 0), Color("a89f66")],
			[Vector3(1.0, 0.7, 0.6), Vector3(0, 3.0, 0), Color("fff6c8")],
		],
		"face": [Vector2(1.0, 0.7), Vector3(0, 3.0, -0.32)]},
	"patron": {"name": "Fabrika Patronu", "boss": true, "loot": {Items.CRYSTAL: 4, Items.RUBY: 4, Items.GOLD: 6}, "ability": "toss", "reach": 1.5, "health": 120, "damage": 5,
		"behavior": Behavior.HOSTILE, "habitat": Habitat.TOY_FACTORY,
		"primary": Color("5a6a7a"), "secondary": Color("f2c230"), "height": 4.6, "width": 2.2, "speed": 2.2,
		"parts": [
			[Vector3(0.6, 1.4, 0.7), Vector3(-0.5, 0.7, 0), Color("3a4550")],
			[Vector3(0.6, 1.4, 0.7), Vector3(0.5, 0.7, 0), Color("3a4550")],
			[Vector3(1.9, 1.7, 1.2), Vector3(0, 2.25, 0), Color("5a6a7a")],
			[Vector3(1.2, 0.9, 0.04), Vector3(0, 2.3, -0.62), Color("f2c230")],
			[Vector3(0.5, 1.6, 0.5), Vector3(-1.25, 2.1, 0), Color("4a5866")],
			[Vector3(0.5, 1.6, 0.5), Vector3(1.25, 2.1, 0), Color("4a5866")],
			[Vector3(0.7, 0.5, 0.7), Vector3(-1.25, 1.1, 0), Color("d9343a")],
			[Vector3(0.7, 0.5, 0.7), Vector3(1.25, 1.1, 0), Color("d9343a")],
			[Vector3(1.3, 1.1, 1.1), Vector3(0, 3.65, 0), Color("6a7a8a")],
			[Vector3(0.1, 0.5, 0.1), Vector3(0, 4.45, 0), Color("2a2a2a")],
			[Vector3(0.25, 0.25, 0.25), Vector3(0, 4.7, 0), Color("ff3030")],
		],
		"face": [Vector2(1.1, 0.9), Vector3(0, 3.65, -0.57)], "face_glow": true},
	"pembeleylek": {"name": "Pembe Leylek", "health": 14, "damage": 3, "behavior": Behavior.HOSTILE, "habitat": Habitat.TOY_FACTORY,
		"primary": Color("f07ab0"), "secondary": Color("f4c430"), "height": 2.6, "width": 0.9, "speed": 3.4,
		# Konsept: docs/konseptler/mob_pembeleylek_concept.png
		"parts": [
			[Vector3(0.08, 1.1, 0.08), Vector3(-0.12, 0.55, 0), Color("d8636e")],
			[Vector3(0.08, 1.1, 0.08), Vector3(0.12, 0.55, 0), Color("d8636e")],
			[Vector3(0.6, 0.55, 0.5), Vector3(0, 1.37, 0), Color("e87a80")],
			[Vector3(0.4, 0.35, 0.02), Vector3(0, 1.4, -0.26), Color("f2f2f2")],
			[Vector3(0.6, 0.08, 0.08), Vector3(-0.55, 1.55, 0), Color("e87a80")],
			[Vector3(0.6, 0.08, 0.08), Vector3(0.55, 1.55, 0), Color("e87a80")],
			[Vector3(0.14, 0.45, 0.14), Vector3(0, 1.87, 0), Color("e87a80")],
			[Vector3(0.5, 0.5, 0.5), Vector3(0, 2.33, 0), Color("e87a80")],
		],
		"face": [0.5, Vector3(0, 2.33, -0.27)]},
	"fermuar": {"name": "Fermuar", "reach": 2.0, "health": 16, "damage": 3, "behavior": Behavior.HOSTILE, "habitat": Habitat.TOY_FACTORY,
		"primary": Color("1f8a8a"), "secondary": Color("f5f5f5"), "height": 3.2, "width": 0.8, "speed": 4.0,
		# Konsept: docs/konseptler/mob_fermuar_concept.png
		"parts": [
			[Vector3(0.14, 0.9, 0.14), Vector3(-0.12, 0.45, 0), Color("1c6b6b")],
			[Vector3(0.14, 0.9, 0.14), Vector3(0.12, 0.45, 0), Color("1c6b6b")],
			[Vector3(0.45, 0.8, 0.28), Vector3(0, 1.3, 0), Color("1f7373")],
			[Vector3(1.0, 0.13, 0.13), Vector3(-0.72, 1.62, 0), Color("1c6b6b")],
			[Vector3(1.0, 0.13, 0.13), Vector3(0.72, 1.62, 0), Color("1c6b6b")],
			[Vector3(0.58, 0.58, 0.5), Vector3(0, 2.0, 0), Color("1f7373")],
		],
		"face": [0.58, Vector3(0, 2.0, -0.27)]},
	"dugme": {"name": "Düğme", "health": 20, "damage": 3, "behavior": Behavior.ALLY, "habitat": Habitat.TOY_FACTORY,
		"primary": Color("f29b82"), "secondary": Color("f5d330"), "height": 3.0, "width": 0.8, "speed": 3.6,
		# Konsept: docs/konseptler/mob_dugme_concept.png
		"parts": [
			[Vector3(0.16, 0.8, 0.16), Vector3(-0.12, 0.4, 0), Color("e8826b")],
			[Vector3(0.16, 0.8, 0.16), Vector3(0.12, 0.4, 0), Color("e8826b")],
			[Vector3(0.5, 0.7, 0.3), Vector3(0, 1.15, 0), Color("ee8a72")],
			[Vector3(0.5, 0.16, 0.16), Vector3(-0.5, 1.4, 0), Color("e8826b")],
			[Vector3(0.5, 0.16, 0.16), Vector3(0.5, 1.4, 0), Color("e8826b")],
			[Vector3(0.62, 0.62, 0.55), Vector3(0, 1.81, 0), Color("f08f78")],
			[Vector3(0.5, 0.2, 0.12), Vector3(0, 2.2, 0), Color("f0c93a")],
		],
		"face": [Vector2(0.62, 0.62), Vector3(0, 1.81, -0.3)]},
	"misil": {"name": "Mışıl", "ability": "gas", "health": 10, "damage": 2, "behavior": Behavior.HOSTILE, "habitat": Habitat.TOY_FACTORY,
		"primary": Color("b9a3e3"), "secondary": Color("f2e6a0"), "height": 1.2, "width": 1.0, "speed": 4.2,
		# Konsept: docs/konseptler/mob_misil_concept.png
		"parts": [
			[Vector3(0.14, 0.35, 0.14), Vector3(-0.17, 0.17, -0.3), Color("b597d9")],
			[Vector3(0.14, 0.35, 0.14), Vector3(0.17, 0.17, -0.3), Color("b597d9")],
			[Vector3(0.14, 0.35, 0.14), Vector3(-0.17, 0.17, 0.3), Color("b597d9")],
			[Vector3(0.14, 0.35, 0.14), Vector3(0.17, 0.17, 0.3), Color("b597d9")],
			[Vector3(0.5, 0.42, 0.9), Vector3(0, 0.55, 0), Color("c9a8e8")],
			[Vector3(0.12, 0.5, 0.12), Vector3(0, 0.95, 0.48), Color("c9a8e8")],
			[Vector3(0.6, 0.6, 0.6), Vector3(0, 1.0, -0.5), Color("c9a8e8")],
			[Vector3(0.12, 0.16, 0.08), Vector3(-0.2, 1.38, -0.5), Color("a98bd0")],
			[Vector3(0.12, 0.16, 0.08), Vector3(0.2, 1.38, -0.5), Color("a98bd0")],
		],
		"face": [0.6, Vector3(0, 1.0, -0.8)]},
	"kutucuk": {"name": "Kutucuk", "ability": "ambush", "health": 12, "damage": 2, "behavior": Behavior.HOSTILE, "habitat": Habitat.TOY_FACTORY,
		"primary": Color("d9343a"), "secondary": Color("2f6fd9"), "height": 1.6, "width": 1.0, "speed": 3.0,
		# Konsept: docs/konseptler/mob_kutucuk_concept.png
		"parts": [
			[Vector3(0.2, 0.1, 0.2), Vector3(-0.2, 0.05, 0), Color("8e1c22")],
			[Vector3(0.2, 0.1, 0.2), Vector3(0.2, 0.05, 0), Color("8e1c22")],
			[Vector3(0.8, 0.7, 0.8), Vector3(0, 0.45, 0), Color("d9343a")],
			[Vector3(0.14, 0.66, 0.02), Vector3(-0.2, 0.45, -0.41), Color("f2c230")],
			[Vector3(0.14, 0.66, 0.02), Vector3(0.2, 0.45, -0.41), Color("f2c230")],
			[Vector3(0.2, 0.35, 0.2), Vector3(0, 0.97, 0), Color("4a6a85")],
			[Vector3(0.1, 0.6, 0.1), Vector3(-0.5, 1.05, 0), Color("6f8aa0")],
			[Vector3(0.1, 0.6, 0.1), Vector3(0.5, 1.05, 0), Color("6f8aa0")],
			[Vector3(0.22, 0.08, 0.1), Vector3(-0.5, 1.38, 0), Color("9aa4ad")],
			[Vector3(0.22, 0.08, 0.1), Vector3(0.5, 1.38, 0), Color("9aa4ad")],
			[Vector3(0.55, 0.55, 0.55), Vector3(0, 1.4, 0), Color("5a86a8")],
		],
		"face": [0.55, Vector3(0, 1.4, -0.275)]},
}


## Yenilen yaratığın bırakabileceği eşyalar, yaşadığı yere göre: [eşya, olasılık, en az, en çok].
## Boss'ların kendi "loot" sözlüğü vardır.
const HABITAT_LOOT := {
	Habitat.OVERWORLD: [[Items.COAL, 0.5, 1, 2], [Items.RAW_IRON, 0.25, 1, 1], [Items.APPLE, 0.2, 1, 1]],
	Habitat.YELLOW_HALLS: [[Items.RAW_GOLD, 0.4, 1, 2], [Items.CRYSTAL, 0.08, 1, 1]],
	Habitat.TOY_FACTORY: [[Items.RUBY, 0.3, 1, 1], [Items.RAW_GOLD, 0.3, 1, 2], [Items.CRYSTAL, 0.1, 1, 1]],
}


## rng ile bu yaratığın ganimetini seçer: {eşya: adet}.
static func roll_loot(id: String, rng: RandomNumberGenerator) -> Dictionary:
	var m: Dictionary = MOBS[id]
	if m.has("loot"):
		return m["loot"]
	var out := {}
	for entry: Array in HABITAT_LOOT.get(m["habitat"], []):
		if rng.randf() < entry[1]:
			out[entry[0]] = rng.randi_range(entry[2], entry[3])
	return out


static func ids_for(habitat: int, night: bool) -> PackedStringArray:
	var ids := PackedStringArray()
	for id in MOBS:
		var m: Dictionary = MOBS[id]
		if m["habitat"] == habitat and not m.get("boss", false) and (night or not m.get("night_only", false)):
			ids.append(id)
	return ids
