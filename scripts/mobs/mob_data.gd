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
const MOBS := {
	"tokmak": {"name": "Tokmakçı", "health": 16, "damage": 3, "behavior": Behavior.HOSTILE, "habitat": Habitat.OVERWORLD, "night_only": true,
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
	"lavabo": {"name": "Lavabo Kafa", "health": 8, "damage": 2, "behavior": Behavior.HOSTILE, "habitat": Habitat.OVERWORLD,
		"primary": Color("f4f4f4"), "secondary": Color("e7b99a"), "height": 1.4, "width": 0.9, "speed": 3.5},
	"mercek": {"name": "Mercek", "behavior": Behavior.ALLY, "habitat": Habitat.OVERWORLD,
		"primary": Color("1f2a44"), "secondary": Color("555a60"), "height": 1.9, "width": 0.7, "speed": 3.0},
	"basbekci": {"name": "Bas Bekçi", "behavior": Behavior.ALLY, "habitat": Habitat.OVERWORLD,
		"primary": Color("333333"), "secondary": Color("111111"), "height": 2.0, "width": 0.8, "speed": 2.8},
	"ekran": {"name": "Ekran Adam", "behavior": Behavior.ALLY, "habitat": Habitat.OVERWORLD,
		"primary": Color("6b1f2c"), "secondary": Color("7a5530"), "height": 1.9, "width": 0.7, "speed": 3.0},
	"bosluk": {"name": "Boşluk Gölgesi", "behavior": Behavior.HOSTILE, "habitat": Habitat.YELLOW_HALLS,
		"primary": Color("0b0b0f"), "secondary": Color("1a1024"), "height": 3.2, "width": 0.6, "speed": 2.5},
	"siritkan": {"name": "Sırıtkan", "behavior": Behavior.HOSTILE, "habitat": Habitat.YELLOW_HALLS,
		"primary": Color("050505"), "secondary": Color("050505"), "height": 1.2, "width": 0.9, "speed": 2.2},
	"balonkafa": {"name": "Balon Kafa", "behavior": Behavior.HOSTILE, "habitat": Habitat.YELLOW_HALLS,
		"primary": Color("f2d21b"), "secondary": Color("f2d21b"), "height": 1.9, "width": 0.9, "speed": 3.8},
	"pence": {"name": "Pençe", "behavior": Behavior.HOSTILE, "habitat": Habitat.YELLOW_HALLS,
		"primary": Color("b9b6ae"), "secondary": Color("1b1b1b"), "height": 1.0, "width": 1.2, "speed": 5.5},
	"civit": {"name": "Çivit", "behavior": Behavior.HOSTILE, "habitat": Habitat.TOY_FACTORY,
		"primary": Color("4b3bb0"), "secondary": Color("f0f0f0"), "height": 3.4, "width": 1.2, "speed": 2.4},
	"yosun": {"name": "Yosun", "behavior": Behavior.HOSTILE, "habitat": Habitat.TOY_FACTORY,
		"primary": Color("4c8a3a"), "secondary": Color("2e5b22"), "height": 3.0, "width": 0.8, "speed": 3.2},
	"kivilcim": {"name": "Kıvılcım", "behavior": Behavior.NEUTRAL, "habitat": Habitat.TOY_FACTORY,
		"primary": Color("f2801e"), "secondary": Color("e85a8a"), "height": 1.0, "width": 1.0, "speed": 6.0},
	"bando": {"name": "Bando", "behavior": Behavior.NEUTRAL, "habitat": Habitat.TOY_FACTORY,
		"primary": Color("c0202e"), "secondary": Color("2a4fb0"), "height": 2.2, "width": 1.2, "speed": 2.6},
	"kocakurbaga": {"name": "Koca Kurbağa", "health": 30, "damage": 4, "behavior": Behavior.NEUTRAL, "habitat": Habitat.OVERWORLD,
		"primary": Color("8fd13f"), "secondary": Color("5c9a25"), "height": 3.0, "width": 1.8, "speed": 1.8},
	"pembeleylek": {"name": "Pembe Leylek", "behavior": Behavior.HOSTILE, "habitat": Habitat.TOY_FACTORY,
		"primary": Color("f07ab0"), "secondary": Color("f4c430"), "height": 2.6, "width": 0.9, "speed": 3.4},
	"fermuar": {"name": "Fermuar", "behavior": Behavior.HOSTILE, "habitat": Habitat.TOY_FACTORY,
		"primary": Color("1f8a8a"), "secondary": Color("f5f5f5"), "height": 3.2, "width": 0.8, "speed": 4.0},
	"dugme": {"name": "Düğme", "behavior": Behavior.ALLY, "habitat": Habitat.TOY_FACTORY,
		"primary": Color("f29b82"), "secondary": Color("f5d330"), "height": 3.0, "width": 0.8, "speed": 3.6},
	"misil": {"name": "Mışıl", "behavior": Behavior.HOSTILE, "habitat": Habitat.TOY_FACTORY,
		"primary": Color("b9a3e3"), "secondary": Color("f2e6a0"), "height": 1.2, "width": 1.0, "speed": 4.2},
	"kutucuk": {"name": "Kutucuk", "behavior": Behavior.HOSTILE, "habitat": Habitat.TOY_FACTORY,
		"primary": Color("d9343a"), "secondary": Color("2f6fd9"), "height": 1.6, "width": 1.0, "speed": 3.0},
}


static func ids_for(habitat: int, night: bool) -> PackedStringArray:
	var ids := PackedStringArray()
	for id in MOBS:
		var m: Dictionary = MOBS[id]
		if m["habitat"] == habitat and (night or not m.get("night_only", false)):
			ids.append(id)
	return ids
