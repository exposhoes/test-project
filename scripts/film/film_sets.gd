class_name FilmSets
extends RefCounted
## Film setlerinin dünyası: düz çimenlik üzerinde her zaman aynı yerde duran kalıcı setler
## (Emir'in köy evi, okul...). World'e arazi üreticisi olarak verilir; setlerin blokları chunk üretilirken basılır.
## Senaryolar (episodes.gd) konumları "ev.yatak" gibi set noktalarıyla verir; yeni set eklemek için
## SETS'e köşe noktası, _build'e bir inşa fonksiyonu, POINTS'e noktalar eklenir.

const GROUND := 10
## Her setin sol-ön-alt köşesi (setin zemin katı bu y'de başlar).
const SETS := {
	"ev": Vector3i(0, GROUND + 1, 0),
	"okul": Vector3i(48, GROUND + 1, 0),
}
## Setlerdeki adlandırılmış noktalar (köşeye göre, blok ortası için .5).
const POINTS := {
	"ev": {
		"yatak": Vector3(1.5, 1.0, 2.0),          # Emir'in uzandığı yer (yatak üstü)
		"yatak_yani": Vector3(2.8, 0, 2.0),
		"mutfak": Vector3(6.5, 0, 2.6),
		"ocak": Vector3(7.5, 0, 1.4),
		"masa": Vector3(5.0, 0, 3.2),
		"canta": Vector3(2.2, 0, 5.0),
		"kapi_ici": Vector3(4.5, 0, 5.8),
		"kapi_disi": Vector3(4.5, 0, 9.0),
		"bahce": Vector3(8.0, 0, 11.0),
		"yol": Vector3(4.5, 0, 16.0),
		"kam_yatak": Vector3(4.2, 2.3, 4.8),
		"kam_mutfak": Vector3(3.0, 2.2, 5.2),
		"kam_oda": Vector3(7.8, 2.6, 5.8),
		"kam_dis": Vector3(10.0, 4.0, 15.0),
		"kam_kapi": Vector3(6.5, 1.8, 11.5),
	},
	"okul": {
		"sinif_kapi": Vector3(7.5, 0, 10.5),
		"tahta": Vector3(7.5, 0, 1.6),
		"sira_1": Vector3(4.5, 0, 5.0),
		"sira_2": Vector3(10.5, 0, 5.0),
		"sira_3": Vector3(4.5, 0, 7.5),
		"sira_4": Vector3(10.5, 0, 7.5),
		"bahce": Vector3(7.5, 0, 16.0),
		"kaydirak": Vector3(14.0, 0, 17.0),
		"top_alani": Vector3(3.0, 0, 18.0),
		"kam_sinif": Vector3(7.5, 2.6, 9.5),
		"kam_tahta": Vector3(7.5, 2.2, 3.5),
		"kam_bahce": Vector3(7.5, 5.0, 26.0),
	},
}

var _blocks := {}  # Vector3i -> blok id


func _init() -> void:
	_build_house(SETS["ev"])
	_build_school(SETS["okul"])


## Set noktasının dünya konumu: "ev.yatak" ya da doğrudan Vector3.
static func point(p) -> Vector3:
	if p is Vector3:
		return p
	var parts := String(p).split(".")
	var corner: Vector3i = SETS[parts[0]]
	return Vector3(corner) + POINTS[parts[0]][parts[1]]


func start_position() -> Vector3:
	return point("ev.bahce")


func spawn_y(_x: int, _z: int) -> int:
	return GROUND + 1


func generate(chunk: Chunk) -> void:
	var base := chunk.origin()
	for z in Chunk.SIZE:
		for x in Chunk.SIZE:
			chunk.set_local(x, 0, z, Blocks.BEDROCK)
			for y in range(1, GROUND - 3):
				chunk.set_local(x, y, z, Blocks.STONE)
			for y in range(GROUND - 3, GROUND):
				chunk.set_local(x, y, z, Blocks.DIRT)
			chunk.set_local(x, GROUND, z, Blocks.GRASS)
			var g := Vector2i(base.x + x, base.z + z)
			# Setlerden uzakta ara sıra ağaç: arka plan boş görünmesin.
			if _tree_spot(g):
				for y in range(GROUND + 1, GROUND + 5):
					chunk.set_local(x, y, z, Blocks.LOG)
				for dy in range(3, 6):
					for dz in range(-1, 2):
						for dx in range(-1, 2):
							var lx := x + dx
							var lz := z + dz
							if lx >= 0 and lx < Chunk.SIZE and lz >= 0 and lz < Chunk.SIZE and (dx != 0 or dz != 0 or dy == 5):
								chunk.set_local(lx, GROUND + 1 + dy, lz, Blocks.LEAVES)
	for pos: Vector3i in _blocks:
		var lx := pos.x - base.x
		var lz := pos.z - base.z
		if lx >= 0 and lx < Chunk.SIZE and lz >= 0 and lz < Chunk.SIZE:
			chunk.set_local(lx, pos.y, lz, _blocks[pos])


func _tree_spot(g: Vector2i) -> bool:
	var lx := posmod(g.x, 16)
	var lz := posmod(g.y, 16)
	if lx < 3 or lx > 12 or lz < 3 or lz > 12:
		return false
	# Setlerin ve önlerindeki yolun çevresi boş kalsın.
	if g.x > -8 and g.x < 72 and g.y > -8 and g.y < 32:
		return false
	return (hash(g) % 23) == 0


func _put(p: Vector3i, id: int) -> void:
	_blocks[p] = id


func _fill(o: Vector3i, from: Vector3i, to: Vector3i, id: int) -> void:
	for y in range(from.y, to.y + 1):
		for z in range(from.z, to.z + 1):
			for x in range(from.x, to.x + 1):
				_put(o + Vector3i(x, y, z), id)


## Kutunun sadece duvarları (içi boş).
func _walls(o: Vector3i, from: Vector3i, to: Vector3i, id: int) -> void:
	for y in range(from.y, to.y + 1):
		for z in range(from.z, to.z + 1):
			for x in range(from.x, to.x + 1):
				if x == from.x or x == to.x or z == from.z or z == to.z:
					_put(o + Vector3i(x, y, z), id)


## Emir'in köy evi: iç ölçü 9x7, kütük köşeler, taş temel, tahta duvar, pencereler, çatı.
## İçeride yatak (sol arka), mutfak (sağ arka: tezgâh + ocak), masa, çanta sandığı, fener.
func _build_house(o: Vector3i) -> void:
	_fill(o, Vector3i(-1, -1, -1), Vector3i(9, -1, 7), Blocks.COBBLESTONE)
	_fill(o, Vector3i(0, -1, 0), Vector3i(8, -1, 6), Blocks.PLANKS)
	_walls(o, Vector3i(-1, 0, -1), Vector3i(9, 2, 7), Blocks.PLANKS)
	for c in [Vector3i(-1, 0, -1), Vector3i(9, 0, -1), Vector3i(-1, 0, 7), Vector3i(9, 0, 7)]:
		_fill(o, c, c + Vector3i(0, 2, 0), Blocks.LOG)
	# Kademeli çatı (arka ve önden içeri doğru daralır).
	for step in 4:
		_fill(o, Vector3i(-2, 3 + step, -2 + step), Vector3i(10, 3 + step, 8 - step), Blocks.BRICKS)
	_fill(o, Vector3i(-1, 3, -1), Vector3i(9, 3, 7), Blocks.BRICKS)
	# Kapı (ön duvar ortası) ve pencereler.
	_fill(o, Vector3i(4, 0, 7), Vector3i(4, 1, 7), Blocks.AIR)
	for w in [Vector3i(1, 1, 7), Vector3i(7, 1, 7), Vector3i(2, 1, -1), Vector3i(6, 1, -1), Vector3i(-1, 1, 3), Vector3i(9, 1, 3)]:
		_put(o + w, Blocks.GLASS)
	# Eşyalar.
	_put(o + Vector3i(1, 0, 1), Blocks.BED)
	_put(o + Vector3i(1, 0, 2), Blocks.BED)
	_put(o + Vector3i(7, 0, 0), Blocks.CRAFTING_TABLE)
	_put(o + Vector3i(8, 0, 0), Blocks.FURNACE)
	_put(o + Vector3i(6, 0, 0), Blocks.CHEST)
	_put(o + Vector3i(5, 0, 3), Blocks.CRAFTING_TABLE)
	_put(o + Vector3i(1, 0, 5), Blocks.CHEST)
	_put(o + Vector3i(0, 2, 6), Blocks.LANTERN)
	_put(o + Vector3i(8, 2, 6), Blocks.LANTERN)
	# Ön bahçe: taş yol ve çalılar.
	for z in range(8, 17):
		_put(o + Vector3i(4, -1, z), Blocks.GRAVEL)
	for b in [Vector3i(1, 0, 9), Vector3i(7, 0, 9), Vector3i(2, 0, 10)]:
		_put(o + b, Blocks.BERRY_BUSH)


## Okul: tuğla bina, önde sınıf (sıralar, kara tahta), arkada oyun bahçesi (kaydırak, top alanı).
func _build_school(o: Vector3i) -> void:
	_fill(o, Vector3i(-1, -1, -1), Vector3i(15, -1, 11), Blocks.COBBLESTONE)
	_fill(o, Vector3i(0, -1, 0), Vector3i(14, -1, 10), Blocks.PLANKS)
	_walls(o, Vector3i(-1, 0, -1), Vector3i(15, 3, 11), Blocks.BRICKS)
	_fill(o, Vector3i(-1, 4, -1), Vector3i(15, 4, 11), Blocks.STONE)
	_fill(o, Vector3i(-1, 5, -1), Vector3i(15, 5, -1), Blocks.BRICKS)
	# Kapı ve pencereler.
	_fill(o, Vector3i(7, 0, 11), Vector3i(8, 1, 11), Blocks.AIR)
	for x in [1, 2, 4, 5, 10, 11, 13]:
		_fill(o, Vector3i(x, 1, 11), Vector3i(x, 2, 11), Blocks.GLASS)
	for z in [2, 3, 6, 7]:
		_fill(o, Vector3i(-1, 1, z), Vector3i(-1, 2, z), Blocks.GLASS)
		_fill(o, Vector3i(15, 1, z), Vector3i(15, 2, z), Blocks.GLASS)
	# Kara tahta (arka duvarda koyu şerit) ve öğretmen masası.
	_fill(o, Vector3i(4, 1, 0), Vector3i(11, 2, 0), Blocks.BEDROCK)
	_put(o + Vector3i(7, 0, 2), Blocks.CRAFTING_TABLE)
	# Sıralar.
	for row in [4, 7]:
		for x in [3, 4, 5, 9, 10, 11]:
			_put(o + Vector3i(x, 0, row), Blocks.PLANKS)
	_put(o + Vector3i(3, 2, 5), Blocks.LANTERN)
	_put(o + Vector3i(11, 2, 5), Blocks.LANTERN)
	# Bahçe: kapıdan yol, renkli oyuncak tuğlalarından kaydırak ve kum havuzu.
	for z in range(12, 20):
		_fill(o, Vector3i(7, -1, z), Vector3i(8, -1, z), Blocks.GRAVEL)
	for i in 4:
		_fill(o, Vector3i(15, 0, 16 + i), Vector3i(15, 3 - i, 16 + i), Blocks.TOY_BRICK_RED)
	_fill(o, Vector3i(16, 0, 16), Vector3i(16, 3, 16), Blocks.TOY_BRICK_BLUE)
	_fill(o, Vector3i(0, -1, 16), Vector3i(4, -1, 20), Blocks.SAND)
	for c in [Vector3i(-1, 0, 15), Vector3i(5, 0, 15), Vector3i(-1, 0, 21), Vector3i(5, 0, 21)]:
		_put(o + c, Blocks.TOY_BRICK_YELLOW)
