class_name Blocks
extends RefCounted
## Blok kayıt defteri.
## ID'ler ileride kayıt dosyalarında kullanılacak: mevcut sırayı değiştirme, yeni blokları sona ekle.

enum {
	AIR,
	GRASS,
	DIRT,
	STONE,
	COBBLESTONE,
	SAND,
	GRAVEL,
	LOG,
	LEAVES,
	PLANKS,
	GLASS,
	BEDROCK,
	COAL_ORE,
	IRON_ORE,
	GOLD_ORE,
	RUBY_ORE,
	CRYSTAL_ORE,
	SNOW,
	BRICKS,
	CRAFTING_TABLE,
	YELLOW_WALLPAPER,
	DAMP_CARPET,
	TOY_BRICK_RED,
	TOY_BRICK_BLUE,
	TOY_BRICK_YELLOW,
	FURNACE,
	HALLS_PORTAL,
	CEILING_TILE,
	CEILING_LIGHT,
	FACTORY_PORTAL,
	PLAYROOM_WALL,
	LANTERN,
	BED,
	CHEST,
	BERRY_BUSH,
	PLASTER,
	ROOF_TILE,
	BOOKSHELF,
	RUG,
	DARK_PLANKS,
	FLOWERS,
	ASPHALT,
	ROAD_LINE,
	SIDEWALK,
	CONCRETE,
}

## Yüz yönleri: +X, -X, +Y, -Y, +Z, -Z
enum Face { EAST, WEST, TOP, BOTTOM, SOUTH, NORTH }

## "all": her yüz aynı doku. "top"/"side"/"bottom" ayrı ayrı verilebilir.
const DEFS := {
	GRASS: {"name": "Çimen", "top": "grass_top", "side": "grass_side", "bottom": "dirt"},
	DIRT: {"name": "Toprak", "all": "dirt"},
	STONE: {"name": "Taş", "all": "stone"},
	COBBLESTONE: {"name": "Kırık Taş", "all": "cobblestone"},
	SAND: {"name": "Kum", "all": "sand"},
	GRAVEL: {"name": "Çakıl", "all": "gravel"},
	LOG: {"name": "Kütük", "top": "log_top", "side": "log_side", "bottom": "log_top"},
	LEAVES: {"name": "Yaprak", "all": "leaves", "transparent": true},
	PLANKS: {"name": "Tahta", "all": "planks"},
	GLASS: {"name": "Cam", "all": "glass", "transparent": true},
	BEDROCK: {"name": "Anakaya", "all": "bedrock", "unbreakable": true},
	COAL_ORE: {"name": "Kömür Madeni", "all": "coal_ore"},
	IRON_ORE: {"name": "Demir Madeni", "all": "iron_ore"},
	GOLD_ORE: {"name": "Altın Madeni", "all": "gold_ore"},
	RUBY_ORE: {"name": "Yakut Madeni", "all": "ruby_ore"},
	CRYSTAL_ORE: {"name": "Kristal Madeni", "all": "crystal_ore"},
	SNOW: {"name": "Kar", "top": "snow", "side": "snow", "bottom": "dirt"},
	BRICKS: {"name": "Tuğla", "all": "bricks"},
	CRAFTING_TABLE: {"name": "Çalışma Masası", "top": "crafting_top", "side": "crafting_side", "bottom": "planks"},
	YELLOW_WALLPAPER: {"name": "Sarı Duvar Kağıdı", "all": "yellow_wallpaper"},
	DAMP_CARPET: {"name": "Nemli Halı", "all": "damp_carpet"},
	TOY_BRICK_RED: {"name": "Kırmızı Oyuncak Blok", "all": "toy_brick_red"},
	TOY_BRICK_BLUE: {"name": "Mavi Oyuncak Blok", "all": "toy_brick_blue"},
	TOY_BRICK_YELLOW: {"name": "Sarı Oyuncak Blok", "all": "toy_brick_yellow"},
	FURNACE: {"name": "Fırın", "top": "furnace_top", "side": "furnace_side", "bottom": "cobblestone"},
	HALLS_PORTAL: {"name": "Koridor Kapısı", "top": "planks", "side": "halls_portal", "bottom": "planks"},
	CEILING_TILE: {"name": "Tavan Karosu", "all": "ceiling_tile"},
	CEILING_LIGHT: {"name": "Floresan Lamba", "all": "ceiling_light"},
	FACTORY_PORTAL: {"name": "Fabrika Kapısı", "top": "planks", "side": "factory_portal", "bottom": "planks"},
	PLAYROOM_WALL: {"name": "Oyun Odası Duvarı", "all": "playroom_wall"},
	LANTERN: {"name": "Fener", "all": "lantern", "light": true},
	BED: {"name": "Yatak", "top": "bed_top", "side": "bed_side", "bottom": "planks", "transparent": true, "model": true},
	BERRY_BUSH: {"name": "Çilek Çalısı", "all": "berry_bush", "transparent": true},
	CHEST: {"name": "Sandık", "top": "chest_top", "side": "chest_side", "bottom": "planks"},
	PLASTER: {"name": "Sıva Duvar", "all": "plaster"},
	ROOF_TILE: {"name": "Kiremit", "all": "roof_tile"},
	BOOKSHELF: {"name": "Kitaplık", "top": "planks", "side": "bookshelf", "bottom": "planks"},
	RUG: {"name": "Halı", "all": "rug"},
	DARK_PLANKS: {"name": "Koyu Tahta", "all": "dark_planks"},
	FLOWERS: {"name": "Çiçek", "all": "flowers", "transparent": true},
	ASPHALT: {"name": "Asfalt", "all": "asphalt"},
	ROAD_LINE: {"name": "Yol Çizgisi", "all": "road_line"},
	SIDEWALK: {"name": "Kaldırım", "all": "sidewalk"},
	CONCRETE: {"name": "Beton", "all": "concrete"},
}

## Görsel gelene kadar kullanılan geçici renkler (doku adı -> renk).
const PLACEHOLDER_COLORS := {
	"grass_top": Color("5da83a"),
	"grass_side": Color("7a5230"),
	"dirt": Color("7a5230"),
	"stone": Color("7d7d7d"),
	"cobblestone": Color("6a6a6a"),
	"sand": Color("dcc98a"),
	"gravel": Color("857b73"),
	"log_top": Color("a9824e"),
	"log_side": Color("5e4426"),
	"leaves": Color("3b8a2a"),
	"planks": Color("b08a52"),
	"glass": Color("bfe6f5"),
	"bedrock": Color("2e2e2e"),
	"coal_ore": Color("1c1c1c"),
	"iron_ore": Color("d8a47f"),
	"gold_ore": Color("f2cf3c"),
	"ruby_ore": Color("d8263f"),
	"crystal_ore": Color("45e0e6"),
	"snow": Color("f2f7fa"),
	"bricks": Color("a24a3a"),
	"crafting_top": Color("9c7444"),
	"crafting_side": Color("8a6238"),
	"yellow_wallpaper": Color("cfc26a"),
	"damp_carpet": Color("a99a5c"),
	"toy_brick_red": Color("d9343a"),
	"toy_brick_blue": Color("2f6fd9"),
	"toy_brick_yellow": Color("f2c230"),
	"furnace_top": Color("7a7a7a"),
	"furnace_side": Color("6e6e6e"),
	"halls_portal": Color("e8d56a"),
	"ceiling_tile": Color("d9d3b8"),
	"ceiling_light": Color("fffbe6"),
	"factory_portal": Color("e85a8a"),
	"playroom_wall": Color("a9d6f0"),
	"lantern": Color("ffd35a"),
	"bed_top": Color("c8323c"),
	"bed_side": Color("8a5a32"),
	"chest_top": Color("a8733e"),
	"berry_bush": Color("3f7a2a"),
	"chest_side": Color("a8733e"),
	"plaster": Color("efe8d8"),
	"roof_tile": Color("b8452e"),
	"bookshelf": Color("6b4a2a"),
	"rug": Color("b3262e"),
	"dark_planks": Color("5a3b22"),
	"flowers": Color("3f8a2e"),
	"asphalt": Color("3a3c40"),
	"road_line": Color("3a3c40"),
	"sidewalk": Color("b9b5ad"),
	"concrete": Color("9ea3a8"),
}


static func is_solid(id: int) -> bool:
	return id != AIR


## Blok yüzleri yerine 3D model ile çizilen bloklar (ör. yatak, BedModel).
static func has_model(id: int) -> bool:
	return DEFS.has(id) and DEFS[id].get("model", false)


static func is_transparent(id: int) -> bool:
	return id == AIR or DEFS[id].get("transparent", false)


static func is_breakable(id: int) -> bool:
	return id != AIR and not DEFS[id].get("unbreakable", false)


## Çevresini aydınlatan blok mu (fener).
static func is_light(id: int) -> bool:
	return id != AIR and DEFS[id].get("light", false)


static func display_name(id: int) -> String:
	return DEFS[id]["name"] if DEFS.has(id) else "Hava"


static func texture_for(id: int, face: int) -> String:
	var def: Dictionary = DEFS[id]
	if def.has("all"):
		return def["all"]
	match face:
		Face.TOP:
			return def["top"]
		Face.BOTTOM:
			return def["bottom"]
		_:
			return def["side"]


## Atlasın içermesi gereken tüm doku adları, sabit sırayla.
static func all_texture_names() -> PackedStringArray:
	var names := PackedStringArray()
	for id in DEFS:
		for face in 6:
			var tex := texture_for(id, face)
			if not names.has(tex):
				names.append(tex)
	return names
