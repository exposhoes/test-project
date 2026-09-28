class_name Items
extends RefCounted
## Eşya kayıt defteri. Blokların eşya kimliği blok kimliğiyle aynıdır;
## blok olmayan eşyalar FIRST_ITEM'dan başlar.
## Kimlikler ileride kayıt dosyalarında kullanılacak: yeni eşyaları sona ekle.

const FIRST_ITEM := 1000
const APPLE := 1000

const MAX_STACK := 64
const ICON_DIR := "res://assets/textures/items/"

## food: yenince doldurduğu açlık (yarım but). pattern: görsel gelene kadar çizilen 8x8 ikon.
const DEFS := {
	APPLE: {"name": "Elma", "icon": "item_apple", "food": 4,
		"colors": {"r": Color("d8263f"), "d": Color("8e1426"), "g": Color("3b8a2a"), "b": Color("5e4426"), "w": Color("f7a0a8")},
		"pattern": ["____bg__", "___bgg__", "_rrbrr__", "rwrrrrr_", "rrrrrrr_", "rrrrrrd_", "_rrrrd__", "__rdd___"]},
}

## Kırılınca bırakılan eşya; -1 hiçbir şey bırakmaz.
const BLOCK_DROPS := {
	Blocks.GRASS: Blocks.DIRT,
	Blocks.STONE: Blocks.COBBLESTONE,
	Blocks.LEAVES: -1,
	Blocks.GLASS: -1,
}

static var _icons := {}


static func is_block(id: int) -> bool:
	return id > Blocks.AIR and id < FIRST_ITEM


static func display_name(id: int) -> String:
	if is_block(id):
		return Blocks.display_name(id)
	return DEFS[id]["name"] if DEFS.has(id) else ""


static func food_value(id: int) -> int:
	return DEFS[id].get("food", 0) if DEFS.has(id) else 0


static func drop_for_block(block_id: int) -> int:
	return BLOCK_DROPS.get(block_id, block_id)


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
		tex = ImageTexture.create_from_image(img)
	_icons[id] = tex
	return tex
