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
			elif texture_name == "furnace_side" and x >= 8 and x < 24 and y >= 14 and y < 28:
				# Ağız: üstte karanlık, altta kor.
				c = Color("1a1a1a") if y < 21 else Color("e8741c").lerp(Color("f7c948"), rng.randf())
			elif texture_name.begins_with("furnace") and (x == 0 or y == 0 or x == TILE - 1 or y == TILE - 1):
				c = base.darkened(0.4)
			elif texture_name == "halls_portal":
				# Ahşap çerçeveli, içi parlayan sarı kapı.
				var frame := x < 4 or x >= TILE - 4 or y < 3
				c = Blocks.PLACEHOLDER_COLORS["planks"].darkened(0.2) if frame else base.lightened(0.15 + 0.25 * sin(y * 0.4 + x * 0.2))
			elif texture_name == "factory_portal":
				# Ahşap çerçeve, içinde dönen renkli şeritler.
				var frame := x < 4 or x >= TILE - 4 or y < 3
				var band := int((x + y + 2 * sin(x * 0.5)) / 5.0) % 3
				c = Blocks.PLACEHOLDER_COLORS["planks"].darkened(0.2) if frame else [base, Color("f2c230"), Color("2f6fd9")][band]
			elif texture_name == "playroom_wall" and (Vector2(x % 16, y % 16).distance_to(Vector2(5, 6)) < 2.5 or (x + y * 3) % 23 == 0):
				c = Color("fdf6c8")
			elif texture_name == "lantern":
				# Koyu demir çerçeve, ortada parlayan alev.
				var edge := x < 3 or x >= TILE - 3 or y < 3 or y >= TILE - 3 or x == TILE / 2 or y == TILE / 2
				var glow := 1.0 - Vector2(x, y).distance_to(Vector2(TILE / 2.0, TILE / 2.0)) / (TILE * 0.6)
				c = Color("2a2522") if edge else base.lightened(glow * 0.6)
			elif texture_name == "ceiling_tile" and (x % 16 == 0 or y % 16 == 0):
				c = base.darkened(0.3)
			elif texture_name == "ceiling_light":
				c = base if (x > 2 and x < TILE - 3 and y > 2 and y < TILE - 3) else Color("b8b29a")
			elif texture_name == "yellow_wallpaper" and x % 6 == 0:
				c = base.darkened(0.12)
			elif texture_name.begins_with("toy_brick") and Vector2(x % 16, y % 16).distance_to(Vector2(8, 8)) < 4.5:
				c = base.lightened(0.2)
			elif texture_name == "roof_tile":
				# Üst üste binen kiremit sıraları.
				var row := y / 6
				c = base.darkened(0.35) if y % 6 == 5 or (x + row * 4) % 8 == 0 else base.lightened(0.08 * (y % 6) / 5.0)
			elif texture_name == "bookshelf":
				var shelf := y % 16 < 2 or x < 2 or x >= TILE - 2
				var book_colors: Array[Color] = [Color("c0392b"), Color("2e86c1"), Color("27ae60"), Color("f1c40f"), Color("8e44ad"), Color("e67e22")]
				c = Blocks.PLACEHOLDER_COLORS["planks"].darkened(0.1) if shelf else book_colors[(x / 3 + (y / 16) * 2) % book_colors.size()].darkened(0.1 if x % 3 == 0 else 0.0)
			elif texture_name == "rug":
				var border := x < 3 or y < 3 or x >= TILE - 3 or y >= TILE - 3
				var diamond: bool = absi(x - TILE / 2) + absi(y - TILE / 2) in [8, 9]
				c = Color("e0b040") if border or diamond else base.darkened(rng.randf_range(0.0, 0.08))
			elif texture_name == "dark_planks" and y % 8 == 0:
				c = base.darkened(0.35)
			elif texture_name == "plaster":
				c = base.darkened(rng.randf_range(0.0, 0.06))
			elif texture_name == "flowers":
				var stem := x % 8 == 4 and y > 12
				var bloom := Vector2(x % 8, y).distance_to(Vector2(4, 10)) < 2.5
				var petal: Color = [Color("ff5a8a"), Color("ffd23f"), Color("ffffff"), Color("b07aff")][(x / 8) % 4]
				c = petal if bloom else (base if stem or y > 26 else Color.TRANSPARENT)
			img.set_pixel(x, y, c)
	return img
