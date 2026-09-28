class_name Dimension
extends RefCounted
## Oyunun boyutları. Kimlikler kayıt dosyasında kullanılır: değiştirme.
## Yeryüzü dışındaki her boyuta kendi kapı bloğuyla girilir; oradaki kapı yeryüzüne döndürür.

enum { OVERWORLD, HALLS, FACTORY }

## name: gösterilen ad. habitat: doğan yaratıkların yaşam alanı. portal: giriş kapısı bloğu.
## ambience: döngülü ortam sesi (Sfx). indoor: gökyüzü yok, hep aynı ışık (background/ambient/fog renkleri ve sis yoğunluğu).
const DEFS := {
	OVERWORLD: {"name": "Yeryüzü", "habitat": MobData.Habitat.OVERWORLD},
	HALLS: {"name": "Sarı Koridorlar", "habitat": MobData.Habitat.YELLOW_HALLS, "portal": Blocks.HALLS_PORTAL, "ambience": "hum_halls",
		"indoor": {"background": Color("4a4326"), "ambient": Color("fff0b0"), "energy": 0.95, "fog": Color("b9a64e"), "fog_density": 0.045}},
	FACTORY: {"name": "Oyuncak Fabrikası", "habitat": MobData.Habitat.TOY_FACTORY, "portal": Blocks.FACTORY_PORTAL, "ambience": "music_factory",
		"indoor": {"background": Color("2b2440"), "ambient": Color("ffe8f4"), "energy": 1.0, "fog": Color("cfa9e0"), "fog_density": 0.022}},
}


static func display_name(dim: int) -> String:
	return DEFS[dim]["name"]


## Bu blok bir boyut kapısıysa o boyut, değilse -1.
static func for_portal(block_id: int) -> int:
	for dim in DEFS:
		if DEFS[dim].get("portal", -1) == block_id:
			return dim
	return -1


static func is_portal(block_id: int) -> bool:
	return for_portal(block_id) != -1


## Oyuncunun kapıyı kullanınca gideceği boyut: yeryüzünden kapının boyutuna, başka yerden yeryüzüne.
static func destination(current: int, portal_block: int) -> int:
	return for_portal(portal_block) if current == OVERWORLD else OVERWORLD
