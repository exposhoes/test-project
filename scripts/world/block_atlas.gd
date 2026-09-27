class_name BlockAtlas
extends RefCounted
## Tüm blok dokularını tek bir atlas görseline dizer.
## `res://assets/textures/blocks/<ad>.png` varsa onu kullanır, yoksa koddan geçici bir doku üretir.

const TILE := 32
const COLUMNS := 8
const TEXTURE_DIR := "res://assets/textures/blocks/"

var texture: ImageTexture
var _index := {}
var _rows := 1


func _init() -> void:
	var names := Blocks.all_texture_names()
	_rows = maxi(1, ceili(float(names.size()) / COLUMNS))
	var atlas := Image.create(TILE * COLUMNS, TILE * _rows, false, Image.FORMAT_RGBA8)
	for i in names.size():
		var tile := _load_tile(names[i])
		atlas.blit_rect(tile, Rect2i(0, 0, TILE, TILE), Vector2i((i % COLUMNS) * TILE, (i / COLUMNS) * TILE))
		_index[names[i]] = i
	texture = ImageTexture.create_from_image(atlas)


## Atlas içindeki UV dikdörtgeni (0..1). Kenar taşmasını önlemek için yarım teksel içeriden.
func uv_rect(texture_name: String) -> Rect2:
	var i: int = _index[texture_name]
	var size := Vector2(1.0 / COLUMNS, 1.0 / _rows)
	var inset := Vector2(0.5 / (TILE * COLUMNS), 0.5 / (TILE * _rows))
	var origin := Vector2((i % COLUMNS) * size.x, (i / COLUMNS) * size.y)
	return Rect2(origin + inset, size - inset * 2.0)


## Arayüz ikonları için atlastan tek bir kare.
func icon(block_id: int) -> AtlasTexture:
	var tex := AtlasTexture.new()
	tex.atlas = texture
	var i: int = _index[Blocks.texture_for(block_id, Blocks.Face.SOUTH)]
	tex.region = Rect2((i % COLUMNS) * TILE, (i / COLUMNS) * TILE, TILE, TILE)
	return tex


func _load_tile(texture_name: String) -> Image:
	var path := TEXTURE_DIR + texture_name + ".png"
	if ResourceLoader.exists(path):
		var loaded := load(path) as Texture2D
		if loaded:
			var img := loaded.get_image()
			if img.is_compressed():
				img.decompress()
			img.convert(Image.FORMAT_RGBA8)
			img.resize(TILE, TILE, Image.INTERPOLATE_NEAREST)
			return img
	return _placeholder(texture_name)


## Görseller gelene kadar oyunun oynanabilir görünmesi için basit desenli doku.
func _placeholder(texture_name: String) -> Image:
	var base: Color = Blocks.PLACEHOLDER_COLORS.get(texture_name, Color.MAGENTA)
	var rng := RandomNumberGenerator.new()
	rng.seed = hash(texture_name)
	var img := Image.create(TILE, TILE, false, Image.FORMAT_RGBA8)
	for y in TILE:
		for x in TILE:
			var c := base.darkened(rng.randf_range(0.0, 0.18))
			if texture_name.ends_with("_ore"):
				c = Blocks.PLACEHOLDER_COLORS["stone"].darkened(rng.randf_range(0.0, 0.15))
				if rng.randf() < 0.12:
					c = base
			elif texture_name == "grass_side" and y < 7 + (x * 7 % 3):
				c = Blocks.PLACEHOLDER_COLORS["grass_top"].darkened(rng.randf_range(0.0, 0.15))
			elif texture_name == "leaves" and rng.randf() < 0.15:
				c = Color.TRANSPARENT
			elif texture_name == "glass":
				var edge := x == 0 or y == 0 or x == TILE - 1 or y == TILE - 1
				c = base if edge else Color(1, 1, 1, 0)
			elif texture_name == "log_top":
				var d := Vector2(x, y).distance_to(Vector2(TILE / 2.0, TILE / 2.0))
				c = Blocks.PLACEHOLDER_COLORS["log_side"] if d > TILE * 0.45 else (base.darkened(0.25) if int(d) % 4 == 0 else base)
			elif texture_name in ["planks", "crafting_side"] and y % 8 == 0:
				c = base.darkened(0.35)
			elif texture_name == "bricks" and (y % 8 == 0 or (x + (y / 8) * 8) % 16 == 0):
				c = Color("c8c2b8")
			elif texture_name.begins_with("toy_brick") and Vector2(x % 16, y % 16).distance_to(Vector2(8, 8)) < 4.5:
				c = base.lightened(0.2)
			img.set_pixel(x, y, c)
	return img
