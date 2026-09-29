class_name Items
extends RefCounted
## Eşya kayıt defteri: eşyalar, aletler, kazma kuralları ve tarifler.
## Blokların eşya kimliği blok kimliğiyle aynıdır; blok olmayan eşyalar FIRST_ITEM'dan başlar.
## Kimlikler ileride kayıt dosyalarında kullanılacak: mevcut sayıları değiştirme.

const FIRST_ITEM := 1000
const APPLE := 1000
const STICK := 1001
const COAL := 1002
const IRON := 1003
const GOLD := 1004
const RUBY := 1005
const CRYSTAL := 1006
const RAW_IRON := 1007
const RAW_GOLD := 1008
const WOOD_PICKAXE := 1010
const STONE_PICKAXE := 1011
const IRON_PICKAXE := 1012
const CRYSTAL_PICKAXE := 1013
const WOOD_AXE := 1020
const STONE_AXE := 1021
const IRON_AXE := 1022
const WOOD_SWORD := 1030
const STONE_SWORD := 1031
const IRON_SWORD := 1032
const RUBY_SWORD := 1033

const MAX_STACK := 64
const ICON_DIR := "res://assets/textures/items/"

## Alet kademeleri: 1 tahta, 2 taş, 3 demir, 4 kristal/yakut.
const WOOD := Color("b08a52")
const STONE := Color("8a8a8a")
const IRONC := Color("dcdcdc")
const HANDLE := Color("6e4a2a")

## 8x8 ikon desenleri: harf -> "colors" içindeki renk, "_" boş.
const PICK := ["_hhhhh__", "h__s__h_", "___s____", "___s____", "___s____", "___s____", "___s____", "________"]
const AXE := ["__shh___", "__shhh__", "__shh___", "__s_____", "__s_____", "__s_____", "__s_____", "________"]
const SWORD := ["___h____", "___h____", "___h____", "___h____", "___h____", "_gggg___", "___s____", "___s____"]
const INGOT := ["________", "________", "__hhhh__", "_hhhhhh_", "hhhhhhd_", "_dddddd_", "________", "________"]
const NUGGET := ["________", "________", "__hh____", "_hhwhh__", "_hhhhhh_", "__hhhdd_", "___ddd__", "________"]
const GEM := ["________", "__hhh___", "_hhhhh__", "hhwhhhh_", "_hhhhd__", "__hhd___", "___d____", "________"]

## name: ad. food: yenince doldurduğu açlık. tool/tier: alet türü ve kademesi.
## damage: kılıcın vuruşa eklediği hasar. stack: bir yuvaya sığan en fazla sayı.
## uses: aletin kaç kullanımda kırılacağı (her blok ya da vuruş bir kullanım).
const DEFS := {
	APPLE: {"name": "Elma", "icon": "item_apple", "food": 4,
		"colors": {"r": Color("d8263f"), "d": Color("8e1426"), "g": Color("3b8a2a"), "b": Color("5e4426"), "w": Color("f7a0a8")},
		"pattern": ["____bg__", "___bgg__", "_rrbrr__", "rwrrrrr_", "rrrrrrr_", "rrrrrrd_", "_rrrrd__", "__rdd___"]},
	STICK: {"name": "Çubuk", "icon": "item_stick", "colors": {"s": HANDLE},
		"pattern": ["______s_", "_____s__", "____s___", "___s____", "__s_____", "_s______", "________", "________"]},
	COAL: {"name": "Kömür", "icon": "item_coal", "colors": {"h": Color("262626"), "d": Color("0d0d0d"), "w": Color("555555")},
		"pattern": ["________", "__hhh___", "_hwhhh__", "_hhhhhh_", "_hhhhhd_", "__hhdd__", "________", "________"]},
	IRON: {"name": "Demir", "icon": "item_iron", "colors": {"h": IRONC, "d": Color("9a9a9a")}, "pattern": INGOT},
	GOLD: {"name": "Altın", "icon": "item_gold", "colors": {"h": Color("f2cf3c"), "d": Color("b8911c")}, "pattern": INGOT},
	RUBY: {"name": "Yakut", "icon": "item_ruby", "colors": {"h": Color("d8263f"), "d": Color("8e1426"), "w": Color("f7a0a8")}, "pattern": GEM},
	CRYSTAL: {"name": "Kristal", "icon": "item_crystal", "colors": {"h": Color("45e0e6"), "d": Color("1f8a8f"), "w": Color("d8fbfc")}, "pattern": GEM},
	RAW_IRON: {"name": "Ham Demir", "icon": "item_raw_iron", "colors": {"h": Color("c9a184"), "d": Color("8a6a55")}, "pattern": NUGGET},
	RAW_GOLD: {"name": "Ham Altın", "icon": "item_raw_gold", "colors": {"h": Color("e8b93a"), "d": Color("a67c1c")}, "pattern": NUGGET},
	WOOD_PICKAXE: {"uses": 60, "name": "Tahta Kazma", "icon": "item_pickaxe_wood", "tool": "pickaxe", "tier": 1, "stack": 1, "colors": {"h": WOOD, "s": HANDLE}, "pattern": PICK},
	STONE_PICKAXE: {"uses": 130, "name": "Taş Kazma", "icon": "item_pickaxe_stone", "tool": "pickaxe", "tier": 2, "stack": 1, "colors": {"h": STONE, "s": HANDLE}, "pattern": PICK},
	IRON_PICKAXE: {"uses": 250, "name": "Demir Kazma", "icon": "item_pickaxe_iron", "tool": "pickaxe", "tier": 3, "stack": 1, "colors": {"h": IRONC, "s": HANDLE}, "pattern": PICK},
	CRYSTAL_PICKAXE: {"uses": 1500, "name": "Kristal Kazma", "icon": "item_pickaxe_crystal", "tool": "pickaxe", "tier": 4, "stack": 1, "colors": {"h": Color("45e0e6"), "s": HANDLE}, "pattern": PICK},
	WOOD_AXE: {"uses": 60, "name": "Tahta Balta", "icon": "item_axe_wood", "tool": "axe", "tier": 1, "stack": 1, "colors": {"h": WOOD, "s": HANDLE}, "pattern": AXE},
	STONE_AXE: {"uses": 130, "name": "Taş Balta", "icon": "item_axe_stone", "tool": "axe", "tier": 2, "stack": 1, "colors": {"h": STONE, "s": HANDLE}, "pattern": AXE},
	IRON_AXE: {"uses": 250, "name": "Demir Balta", "icon": "item_axe_iron", "tool": "axe", "tier": 3, "stack": 1, "colors": {"h": IRONC, "s": HANDLE}, "pattern": AXE},
	WOOD_SWORD: {"uses": 60, "name": "Tahta Kılıç", "icon": "item_sword_wood", "damage": 2, "stack": 1, "colors": {"h": WOOD, "g": HANDLE, "s": HANDLE}, "pattern": SWORD},
	STONE_SWORD: {"uses": 130, "name": "Taş Kılıç", "icon": "item_sword_stone", "damage": 3, "stack": 1, "colors": {"h": STONE, "g": HANDLE, "s": HANDLE}, "pattern": SWORD},
	IRON_SWORD: {"uses": 250, "name": "Demir Kılıç", "icon": "item_sword_iron", "damage": 4, "stack": 1, "colors": {"h": IRONC, "g": HANDLE, "s": HANDLE}, "pattern": SWORD},
	RUBY_SWORD: {"uses": 800, "name": "Yakut Kılıç", "icon": "item_sword_ruby", "damage": 6, "stack": 1, "colors": {"h": Color("d8263f"), "g": Color("f2cf3c"), "s": HANDLE}, "pattern": SWORD},
}

## Kırılınca bırakılan eşya; -1 hiçbir şey bırakmaz. Listede olmayan blok kendini bırakır.
const BLOCK_DROPS := {
	Blocks.GRASS: Blocks.DIRT,
	Blocks.STONE: Blocks.COBBLESTONE,
	Blocks.LEAVES: -1,
	Blocks.GLASS: -1,
	Blocks.COAL_ORE: COAL,
	Blocks.IRON_ORE: RAW_IRON,
	Blocks.GOLD_ORE: RAW_GOLD,
	Blocks.RUBY_ORE: RUBY,
	Blocks.CRYSTAL_ORE: CRYSTAL,
}

## Kırma süresi (elle, saniye), hızlandıran alet ve düşmesi için gereken en düşük kazma kademesi.
## Listede olmayan bloklar DEFAULT_MINING kuralını kullanır.
const DEFAULT_MINING := {"time": 0.6}
const MINING := {
	Blocks.LEAVES: {"time": 0.3},
	Blocks.GLASS: {"time": 0.4},
	Blocks.LOG: {"time": 2.0, "tool": "axe"},
	Blocks.PLANKS: {"time": 2.0, "tool": "axe"},
	Blocks.CRAFTING_TABLE: {"time": 2.0, "tool": "axe"},
	Blocks.FURNACE: {"time": 4.0, "tool": "pickaxe", "tier": 1},
	Blocks.HALLS_PORTAL: {"time": 2.0, "tool": "axe"},
	Blocks.CEILING_LIGHT: {"time": 0.4},
	Blocks.FACTORY_PORTAL: {"time": 2.0, "tool": "axe"},
	Blocks.LANTERN: {"time": 0.5},
	Blocks.BED: {"time": 0.6},
	Blocks.STONE: {"time": 4.0, "tool": "pickaxe", "tier": 1},
	Blocks.COBBLESTONE: {"time": 4.0, "tool": "pickaxe", "tier": 1},
	Blocks.BRICKS: {"time": 4.0, "tool": "pickaxe", "tier": 1},
	Blocks.COAL_ORE: {"time": 5.0, "tool": "pickaxe", "tier": 1},
	Blocks.IRON_ORE: {"time": 5.0, "tool": "pickaxe", "tier": 2},
	Blocks.GOLD_ORE: {"time": 5.0, "tool": "pickaxe", "tier": 3},
	Blocks.RUBY_ORE: {"time": 5.0, "tool": "pickaxe", "tier": 3},
	Blocks.CRYSTAL_ORE: {"time": 5.0, "tool": "pickaxe", "tier": 3},
}

## Tarifler: "in" malzemeler, "table": yakında çalışma masası gerekir.
const RECIPES := [
	{"out": Blocks.PLANKS, "count": 4, "in": {Blocks.LOG: 1}},
	{"out": STICK, "count": 4, "in": {Blocks.PLANKS: 2}},
	{"out": Blocks.CRAFTING_TABLE, "count": 1, "in": {Blocks.PLANKS: 4}},
	{"out": WOOD_PICKAXE, "count": 1, "in": {Blocks.PLANKS: 3, STICK: 2}, "table": true},
	{"out": WOOD_AXE, "count": 1, "in": {Blocks.PLANKS: 3, STICK: 2}, "table": true},
	{"out": WOOD_SWORD, "count": 1, "in": {Blocks.PLANKS: 2, STICK: 1}, "table": true},
	{"out": STONE_PICKAXE, "count": 1, "in": {Blocks.COBBLESTONE: 3, STICK: 2}, "table": true},
	{"out": STONE_AXE, "count": 1, "in": {Blocks.COBBLESTONE: 3, STICK: 2}, "table": true},
	{"out": STONE_SWORD, "count": 1, "in": {Blocks.COBBLESTONE: 2, STICK: 1}, "table": true},
	{"out": IRON_PICKAXE, "count": 1, "in": {IRON: 3, STICK: 2}, "table": true},
	{"out": IRON_AXE, "count": 1, "in": {IRON: 3, STICK: 2}, "table": true},
	{"out": IRON_SWORD, "count": 1, "in": {IRON: 2, STICK: 1}, "table": true},
	{"out": CRYSTAL_PICKAXE, "count": 1, "in": {CRYSTAL: 3, STICK: 2}, "table": true},
	{"out": RUBY_SWORD, "count": 1, "in": {RUBY: 2, GOLD: 1, STICK: 1}, "table": true},
	{"out": Blocks.FURNACE, "count": 1, "in": {Blocks.COBBLESTONE: 8}, "table": true},
	{"out": Blocks.HALLS_PORTAL, "count": 1, "in": {Blocks.PLANKS: 4, GOLD: 2}, "table": true},
	{"out": Blocks.BED, "count": 1, "in": {Blocks.PLANKS: 6}, "table": true},
	{"out": Blocks.LANTERN, "count": 2, "in": {COAL: 1, STICK: 1, Blocks.GLASS: 1}, "table": true},
	{"out": Blocks.FACTORY_PORTAL, "count": 1, "in": {Blocks.PLANKS: 4, RUBY: 2}, "table": true},
	{"out": Blocks.BRICKS, "count": 2, "in": {Blocks.COBBLESTONE: 2, Blocks.DIRT: 2}, "table": true},
]

## Fırın tarifleri: yakında fırın ve yakıt gerekir. Her eritme bir yakıt birimi harcar.
const SMELTING := [
	{"out": IRON, "count": 1, "in": {RAW_IRON: 1}},
	{"out": GOLD, "count": 1, "in": {RAW_GOLD: 1}},
	{"out": Blocks.GLASS, "count": 1, "in": {Blocks.SAND: 1}},
	{"out": Blocks.STONE, "count": 1, "in": {Blocks.COBBLESTONE: 1}},
	{"out": COAL, "count": 1, "in": {Blocks.LOG: 1}},
]

## Yakıtlar ve kaç eritmeye yettikleri; fırın bu sırayla yakar.
const FUEL := {COAL: 8, Blocks.LOG: 3, Blocks.PLANKS: 1}

static var _icons := {}


static func is_block(id: int) -> bool:
	return id > Blocks.AIR and id < FIRST_ITEM


static func display_name(id: int) -> String:
	if is_block(id):
		return Blocks.display_name(id)
	return DEFS[id]["name"] if DEFS.has(id) else ""


static func max_stack(id: int) -> int:
	return DEFS[id].get("stack", MAX_STACK) if DEFS.has(id) else MAX_STACK


static func food_value(id: int) -> int:
	return DEFS[id].get("food", 0) if DEFS.has(id) else 0


static func tool_type(id: int) -> String:
	return DEFS[id].get("tool", "") if DEFS.has(id) else ""


static func tool_tier(id: int) -> int:
	return DEFS[id].get("tier", 0) if DEFS.has(id) else 0


## Aletin toplam kullanım hakkı; alet değilse 0.
static func max_uses(id: int) -> int:
	return DEFS[id].get("uses", 0) if DEFS.has(id) else 0


static func attack_bonus(id: int) -> int:
	return DEFS[id].get("damage", 0) if DEFS.has(id) else 0


static func drop_for_block(block_id: int) -> int:
	return BLOCK_DROPS.get(block_id, block_id)


## Elde tutulan eşyayla bloğu kırma süresi (saniye).
static func break_time(block_id: int, held: int) -> float:
	var rule: Dictionary = MINING.get(block_id, DEFAULT_MINING)
	var t: float = rule["time"]
	if rule.has("tool") and tool_type(held) == rule["tool"]:
		t /= 1.0 + 1.5 * tool_tier(held)
	return t


## Bu eşyayla kırılınca blok bir şey bırakır mı (taş ve madenler kazma ister).
static func harvests(block_id: int, held: int) -> bool:
	var rule: Dictionary = MINING.get(block_id, DEFAULT_MINING)
	var need: int = rule.get("tier", 0)
	return need == 0 or (tool_type(held) == "pickaxe" and tool_tier(held) >= need)


## Blok olmayan eşyanın ikonu: assets/textures/items/<icon>.png ya da piksel desen.
static func item_icon(id: int) -> Texture2D:
	if _icons.has(id):
		return _icons[id]
	var def: Dictionary = DEFS[id]
	var path: String = ICON_DIR + def["icon"] + ".png"
	var tex: Texture2D
	if ResourceLoader.exists(path):
		tex = load(path)
	else:
		var pattern: Array = def["pattern"]
		var img := Image.create(pattern.size(), pattern.size(), false, Image.FORMAT_RGBA8)
		img.fill(Color.TRANSPARENT)
		for y in pattern.size():
			var row: String = pattern[y]
			for x in row.length():
				if def["colors"].has(row[x]):
					img.set_pixel(x, y, def["colors"][row[x]])
				elif row[x] == "d" and def["colors"].has("h"):
					img.set_pixel(x, y, def["colors"]["h"].darkened(0.3))
				elif row[x] == "w" and def["colors"].has("h"):
					img.set_pixel(x, y, def["colors"]["h"].lightened(0.5))
		tex = ImageTexture.create_from_image(img)
	_icons[id] = tex
	return tex
