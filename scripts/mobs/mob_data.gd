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
##   toss: oyuncuyu havaya atar · night_hostile: gece düşmanlaşır
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
	"tuylupasa": {"name": "Tüylüpaşa", "health": 4, "behavior": Behavior.PASSIVE, "habitat": Habitat.OVERWORLD,
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
	"siritkan": {"name": "Sırıtkan", "health": 12, "damage": 3, "behavior": Behavior.HOSTILE, "habitat": Habitat.YELLOW_HALLS, "face_glow": true,
		"primary": Color("050505"), "secondary": Color("050505"), "height": 1.2, "width": 0.9, "speed": 2.2},
	"balonkafa": {"name": "Balon Kafa", "ability": "teleport", "health": 10, "damage": 2, "behavior": Behavior.HOSTILE, "habitat": Habitat.YELLOW_HALLS,
		"primary": Color("f2d21b"), "secondary": Color("f2d21b"), "height": 1.9, "width": 0.9, "speed": 3.8},
	"pence": {"name": "Pençe", "ability": "hears", "health": 8, "damage": 3, "behavior": Behavior.HOSTILE, "habitat": Habitat.YELLOW_HALLS,
		"primary": Color("b9b6ae"), "secondary": Color("1b1b1b"), "height": 1.0, "width": 1.2, "speed": 5.5},
	"civit": {"name": "Çivit", "reach": 1.5, "health": 24, "damage": 4, "behavior": Behavior.HOSTILE, "habitat": Habitat.TOY_FACTORY,
		"primary": Color("4b3bb0"), "secondary": Color("f0f0f0"), "height": 3.4, "width": 1.2, "speed": 2.4},
	"yosun": {"name": "Yosun", "ability": "hears", "health": 18, "damage": 3, "behavior": Behavior.HOSTILE, "habitat": Habitat.TOY_FACTORY,
		"primary": Color("4c8a3a"), "secondary": Color("2e5b22"), "height": 3.0, "width": 0.8, "speed": 3.2},
	"kivilcim": {"name": "Kıvılcım", "health": 6, "damage": 1, "behavior": Behavior.NEUTRAL, "habitat": Habitat.TOY_FACTORY,
		"primary": Color("f2801e"), "secondary": Color("e85a8a"), "height": 1.0, "width": 1.0, "speed": 6.0},
	"bando": {"name": "Bando", "ability": "night_hostile", "health": 16, "damage": 3, "behavior": Behavior.NEUTRAL, "habitat": Habitat.TOY_FACTORY,
		"primary": Color("c0202e"), "secondary": Color("2a4fb0"), "height": 2.2, "width": 1.2, "speed": 2.6},
	"kocakurbaga": {"name": "Koca Kurbağa", "ability": "toss", "health": 30, "damage": 4, "behavior": Behavior.NEUTRAL, "habitat": Habitat.OVERWORLD,
		"primary": Color("8fd13f"), "secondary": Color("5c9a25"), "height": 3.0, "width": 1.8, "speed": 1.8},
	"pembeleylek": {"name": "Pembe Leylek", "health": 14, "damage": 3, "behavior": Behavior.HOSTILE, "habitat": Habitat.TOY_FACTORY,
		"primary": Color("f07ab0"), "secondary": Color("f4c430"), "height": 2.6, "width": 0.9, "speed": 3.4},
	"fermuar": {"name": "Fermuar", "reach": 2.0, "health": 16, "damage": 3, "behavior": Behavior.HOSTILE, "habitat": Habitat.TOY_FACTORY,
		"primary": Color("1f8a8a"), "secondary": Color("f5f5f5"), "height": 3.2, "width": 0.8, "speed": 4.0},
	"dugme": {"name": "Düğme", "health": 20, "damage": 3, "behavior": Behavior.ALLY, "habitat": Habitat.TOY_FACTORY,
		"primary": Color("f29b82"), "secondary": Color("f5d330"), "height": 3.0, "width": 0.8, "speed": 3.6},
	"misil": {"name": "Mışıl", "ability": "gas", "health": 10, "damage": 2, "behavior": Behavior.HOSTILE, "habitat": Habitat.TOY_FACTORY,
		"primary": Color("b9a3e3"), "secondary": Color("f2e6a0"), "height": 1.2, "width": 1.0, "speed": 4.2},
	"kutucuk": {"name": "Kutucuk", "ability": "ambush", "health": 12, "damage": 2, "behavior": Behavior.HOSTILE, "habitat": Habitat.TOY_FACTORY,
		"primary": Color("d9343a"), "secondary": Color("2f6fd9"), "height": 1.6, "width": 1.0, "speed": 3.0},
}


static func ids_for(habitat: int, night: bool) -> PackedStringArray:
	var ids := PackedStringArray()
	for id in MOBS:
		var m: Dictionary = MOBS[id]
		if m["habitat"] == habitat and (night or not m.get("night_only", false)):
			ids.append(id)
	return ids
