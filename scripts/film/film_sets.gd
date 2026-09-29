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
	"hastane": Vector3i(-40, GROUND + 1, 0),
	"bakkal": Vector3i(0, GROUND + 1, -36),
	"park": Vector3i(40, GROUND + 1, -36),
	"saha": Vector3i(-40, GROUND + 1, -36),
}
## Setlerdeki adlandırılmış noktalar (köşeye göre, blok ortası için .5).
const POINTS := {
	"ev": {
		"yatak": Vector3(1.5, 1.0, 2.0),          # Emir'in uzandığı yer (yatak üstü)
		"yatak_yani": Vector3(2.8, 0, 2.0),
		"mutfak": Vector3(6.5, 0, 2.6),
		"ocak": Vector3(7.5, 0, 1.4),
		"masa": Vector3(5.5, 0, 4.4),
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
		"sira_3": Vector3(4.5, 0, 8.5),
		"sira_4": Vector3(10.5, 0, 8.5),
		"bahce": Vector3(7.5, 0, 16.0),
		"kaydirak": Vector3(14.0, 0, 17.0),
		"top_alani": Vector3(3.0, 0, 18.0),
		"kam_sinif": Vector3(7.5, 2.6, 9.5),
		"kam_tahta": Vector3(7.5, 2.2, 3.5),
		"kam_bahce": Vector3(7.5, 5.0, 26.0),
	},
	"hastane": {
		"giris": Vector3(6.5, 0, 9.0),
		"dis": Vector3(6.5, 0, 14.0),
		"danisma": Vector3(6.5, 0, 6.5),
		"danisma_arka": Vector3(6.5, 0, 4.6),
		"yatak_1": Vector3(1.5, 1.0, 2.0),
		"yatak_1_yani": Vector3(2.8, 0, 2.0),
		"yatak_2": Vector3(11.5, 1.0, 2.0),
		"yatak_2_yani": Vector3(10.2, 0, 2.0),
		"bekleme": Vector3(2.0, 0, 6.5),
		"kam_ic": Vector3(6.5, 2.6, 8.0),
		"kam_yatak": Vector3(4.6, 2.5, 6.4),
		"kam_dis": Vector3(12.0, 4.5, 18.0),
	},
	"bakkal": {
		"kapi": Vector3(5.5, 0, 8.6),
		"dis": Vector3(5.5, 0, 12.0),
		"tezgah_on": Vector3(5.5, 0, 4.4),
		"tezgah_arka": Vector3(5.5, 0, 2.2),
		"raf": Vector3(1.6, 0, 5.0),
		"dondurma": Vector3(9.3, 0, 5.0),
		"kam_ic": Vector3(9.0, 2.3, 3.8),
		"kam_tezgah": Vector3(3.0, 2.0, 6.8),
		"kam_dis": Vector3(9.0, 4.0, 16.0),
	},
	"park": {
		"bank": Vector3(4.5, 0, 6.0),
		"bank_yani": Vector3(7.5, 0, 6.0),
		"ortu": Vector3(10.0, 0, 9.0),
		"ortu_yani": Vector3(11.5, 0, 10.5),
		"agac": Vector3(3.0, 0, 11.0),
		"giris": Vector3(8.0, 0, 16.0),
		"kam_genel": Vector3(8.0, 5.0, 20.0),
		"kam_ortu": Vector3(8.2, 2.0, 7.0),
		"kam_bank": Vector3(5.5, 1.8, 9.5),
	},
	"saha": {
		"orta": Vector3(11.0, 0, 7.0),
		"kale_sol": Vector3(2.0, 0, 7.0),
		"kale_sag": Vector3(20.0, 0, 7.0),
		"penalti": Vector3(6.0, 0, 7.0),
		"kenar": Vector3(11.0, 0, 15.5),
		"kenar_2": Vector3(13.0, 0, 15.5),
		"kam_genel": Vector3(11.0, 6.0, 22.0),
		"kam_kale": Vector3(9.0, 2.2, 9.5),
		"kam_kenar": Vector3(12.0, 2.0, 12.0),
	},
}

var _blocks := {}  # Vector3i -> blok id


func _init() -> void:
	_build_house(SETS["ev"])
	_build_school(SETS["okul"])
	_build_hospital(SETS["hastane"])
	_build_shop(SETS["bakkal"])
	_build_park(SETS["park"])
	_build_field(SETS["saha"])


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
	if g.x > -48 and g.x < 72 and g.y > -48 and g.y < 32:
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
	_fill(o, Vector3i(0, -1, 0), Vector3i(8, -1, 6), Blocks.DARK_PLANKS)
	# Sıva duvarlar, kütük köşe direkleri ve tavan kirişi.
	_walls(o, Vector3i(-1, 0, -1), Vector3i(9, 3, 7), Blocks.PLASTER)
	for c in [Vector3i(-1, 0, -1), Vector3i(9, 0, -1), Vector3i(-1, 0, 7), Vector3i(9, 0, 7)]:
		_fill(o, c, c + Vector3i(0, 3, 0), Blocks.LOG)
	_walls(o, Vector3i(-1, 3, -1), Vector3i(9, 3, 7), Blocks.LOG)
	_fill(o, Vector3i(-1, 0, -1), Vector3i(9, 0, -1), Blocks.COBBLESTONE)
	# Kiremit beşik çatı (önden ve arkadan içe doğru eğimli), alınlıklar sıva.
	for step in 5:
		_fill(o, Vector3i(-2, 4 + step, -2 + step), Vector3i(10, 4 + step, 8 - step), Blocks.ROOF_TILE)
		if step < 4:
			_fill(o, Vector3i(-1, 4 + step, -1 + step), Vector3i(-1, 4 + step, 7 - step), Blocks.PLASTER)
			_fill(o, Vector3i(9, 4 + step, -1 + step), Vector3i(9, 4 + step, 7 - step), Blocks.PLASTER)
	_fill(o, Vector3i(0, 4, 0), Vector3i(8, 4, 6), Blocks.PLANKS)
	# Kapı (ön duvar ortası, 3 blok yüksek) ve iki blokluk pencereler.
	_fill(o, Vector3i(4, 0, 7), Vector3i(4, 2, 7), Blocks.AIR)
	for w in [Vector3i(1, 1, 7), Vector3i(6, 1, 7), Vector3i(1, 1, -1), Vector3i(6, 1, -1)]:
		_fill(o, w, w + Vector3i(1, 1, 0), Blocks.GLASS)
	for w in [Vector3i(-1, 1, 2), Vector3i(9, 1, 2)]:
		_fill(o, w, w + Vector3i(0, 1, 1), Blocks.GLASS)
	# Emir'in odası: yatak, kitaplık, sandık.
	_put(o + Vector3i(1, 0, 1), Blocks.BED)
	_put(o + Vector3i(1, 0, 2), Blocks.BED)
	_fill(o, Vector3i(2, 0, 0), Vector3i(3, 1, 0), Blocks.BOOKSHELF)
	_put(o + Vector3i(1, 0, 5), Blocks.CHEST)
	# Mutfak: tezgah, fırın, dolap.
	_put(o + Vector3i(7, 0, 0), Blocks.CRAFTING_TABLE)
	_put(o + Vector3i(8, 0, 0), Blocks.FURNACE)
	_put(o + Vector3i(6, 0, 0), Blocks.CHEST)
	# Oturma alanı: masa ve kırmızı halı.
	_put(o + Vector3i(5, 0, 3), Blocks.CRAFTING_TABLE)
	_fill(o, Vector3i(3, -1, 4), Vector3i(6, -1, 5), Blocks.RUG)
	_put(o + Vector3i(0, 3, 6), Blocks.LANTERN)
	_put(o + Vector3i(8, 3, 6), Blocks.LANTERN)
	_put(o + Vector3i(4, 3, 2), Blocks.LANTERN)
	# Ön bahçe: taş yol, çiçek tarhları, çit gibi çalı sırası.
	for z in range(8, 17):
		_put(o + Vector3i(4, -1, z), Blocks.GRAVEL)
	for x in [0, 1, 2, 6, 7]:
		_put(o + Vector3i(x, 0, 8), Blocks.FLOWERS)
	for z in range(8, 16):
		_put(o + Vector3i(-2, 0, z), Blocks.LEAVES)
		_put(o + Vector3i(11, 0, z), Blocks.LEAVES)
	_put(o + Vector3i(2, 0, 11), Blocks.BERRY_BUSH)


## Okul: tuğla bina, önde sınıf (sıralar, kara tahta), arkada oyun bahçesi (kaydırak, top alanı).
func _build_school(o: Vector3i) -> void:
	_fill(o, Vector3i(-1, -1, -1), Vector3i(15, -1, 11), Blocks.COBBLESTONE)
	_fill(o, Vector3i(0, -1, 0), Vector3i(14, -1, 10), Blocks.PLANKS)
	_walls(o, Vector3i(-1, 0, -1), Vector3i(15, 3, 11), Blocks.BRICKS)
	_fill(o, Vector3i(-1, 4, -1), Vector3i(15, 4, 11), Blocks.STONE)
	_fill(o, Vector3i(-2, 5, -2), Vector3i(16, 5, 12), Blocks.ROOF_TILE)
	_fill(o, Vector3i(0, 6, 0), Vector3i(14, 6, 10), Blocks.ROOF_TILE)
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
	# Tavan lambaları, kitaplıklar, zemin ve sınıf panosu.
	for lx in [3, 7, 11]:
		_put(o + Vector3i(lx, 3, 5), Blocks.CEILING_LIGHT)
	_fill(o, Vector3i(0, 0, 1), Vector3i(0, 1, 3), Blocks.BOOKSHELF)
	_fill(o, Vector3i(14, 0, 1), Vector3i(14, 1, 3), Blocks.BOOKSHELF)
	_fill(o, Vector3i(0, -1, 0), Vector3i(14, -1, 10), Blocks.DARK_PLANKS)
	_fill(o, Vector3i(1, 1, 10), Vector3i(4, 2, 10), Blocks.PLAYROOM_WALL)
	# Bahçe: kapıdan yol, renkli oyuncak tuğlalarından kaydırak ve kum havuzu.
	for z in range(12, 20):
		_fill(o, Vector3i(7, -1, z), Vector3i(8, -1, z), Blocks.GRAVEL)
	for i in 4:
		_fill(o, Vector3i(15, 0, 16 + i), Vector3i(15, 3 - i, 16 + i), Blocks.TOY_BRICK_RED)
	_fill(o, Vector3i(16, 0, 16), Vector3i(16, 3, 16), Blocks.TOY_BRICK_BLUE)
	_fill(o, Vector3i(0, -1, 16), Vector3i(4, -1, 20), Blocks.SAND)
	for c in [Vector3i(-1, 0, 15), Vector3i(5, 0, 15), Vector3i(-1, 0, 21), Vector3i(5, 0, 21)]:
		_put(o + c, Blocks.TOY_BRICK_YELLOW)
	for x in [1, 2, 3, 4, 5, 10, 11, 12, 13]:
		_put(o + Vector3i(x, 0, 12), Blocks.FLOWERS)


## Hastane: beyaz duvarlar, kapının üstünde kırmızı artı, içeride danışma masası, iki hasta yatağı, bekleme sandalyeleri.
func _build_hospital(o: Vector3i) -> void:
	_fill(o, Vector3i(-1, -1, -1), Vector3i(13, -1, 9), Blocks.COBBLESTONE)
	_fill(o, Vector3i(0, -1, 0), Vector3i(12, -1, 8), Blocks.SNOW)
	_walls(o, Vector3i(-1, 0, -1), Vector3i(13, 3, 9), Blocks.SNOW)
	_fill(o, Vector3i(-1, 4, -1), Vector3i(13, 4, 9), Blocks.STONE)
	_fill(o, Vector3i(6, 0, 9), Vector3i(7, 1, 9), Blocks.GLASS)
	_fill(o, Vector3i(6, 0, 9), Vector3i(6, 1, 9), Blocks.AIR)
	for x in [1, 2, 3, 9, 10, 11]:
		_fill(o, Vector3i(x, 1, 9), Vector3i(x, 2, 9), Blocks.GLASS)
	# Kırmızı artı (kapının üstünde).
	_put(o + Vector3i(6, 3, 10), Blocks.TOY_BRICK_RED)
	_put(o + Vector3i(6, 4, 10), Blocks.TOY_BRICK_RED)
	_put(o + Vector3i(6, 5, 10), Blocks.TOY_BRICK_RED)
	_put(o + Vector3i(5, 4, 10), Blocks.TOY_BRICK_RED)
	_put(o + Vector3i(7, 4, 10), Blocks.TOY_BRICK_RED)
	# Danışma masası, yataklar, bekleme sandalyeleri, ışıklar.
	for x in range(5, 9):
		_put(o + Vector3i(x, 0, 5), Blocks.CRAFTING_TABLE if x == 6 else Blocks.PLANKS)
	for b in [Vector3i(1, 0, 1), Vector3i(1, 0, 2), Vector3i(11, 0, 1), Vector3i(11, 0, 2)]:
		_put(o + b, Blocks.BED)
	for z in [5, 7]:
		_put(o + Vector3i(0, 0, z), Blocks.TOY_BRICK_BLUE)
	_put(o + Vector3i(0, 2, 8), Blocks.LANTERN)
	_put(o + Vector3i(12, 2, 8), Blocks.LANTERN)
	_put(o + Vector3i(6, 2, 0), Blocks.LANTERN)
	for z in range(10, 15):
		_put(o + Vector3i(6, -1, z), Blocks.GRAVEL)
	# Gerçekçi dokunuşlar: karo tavan ve floresan lambalar, yatak aralarında perde, girişte çiçekler.
	_fill(o, Vector3i(0, 3, 0), Vector3i(12, 3, 8), Blocks.CEILING_TILE)
	for l in [Vector3i(3, 3, 2), Vector3i(9, 3, 2), Vector3i(6, 3, 6)]:
		_put(o + l, Blocks.CEILING_LIGHT)
	_fill(o, Vector3i(3, 0, 0), Vector3i(3, 1, 1), Blocks.PLAYROOM_WALL)
	_fill(o, Vector3i(9, 0, 0), Vector3i(9, 1, 1), Blocks.PLAYROOM_WALL)
	_fill(o, Vector3i(0, -1, 0), Vector3i(12, -1, 8), Blocks.PLASTER)
	for x in [3, 4, 8, 9]:
		_put(o + Vector3i(x, 0, 10), Blocks.FLOWERS)


## Mahalle bakkalı: tuğla dükkân, camlı vitrin, renkli tente, tezgâh, raflar (sandıklar), dondurma dolabı.
func _build_shop(o: Vector3i) -> void:
	_fill(o, Vector3i(-1, -1, -1), Vector3i(11, -1, 9), Blocks.COBBLESTONE)
	_fill(o, Vector3i(0, -1, 0), Vector3i(10, -1, 8), Blocks.PLANKS)
	_walls(o, Vector3i(-1, 0, -1), Vector3i(11, 3, 9), Blocks.BRICKS)
	_fill(o, Vector3i(-1, 4, -1), Vector3i(11, 4, 9), Blocks.PLANKS)
	_fill(o, Vector3i(5, 0, 9), Vector3i(5, 1, 9), Blocks.AIR)
	for x in [1, 2, 3, 7, 8, 9]:
		_fill(o, Vector3i(x, 0, 9), Vector3i(x, 2, 9), Blocks.GLASS)
	# Çizgili tente.
	for x in range(-1, 12):
		_put(o + Vector3i(x, 3, 10), Blocks.TOY_BRICK_RED if x % 2 == 0 else Blocks.SNOW)
	# Tezgâh, raflar, dondurma dolabı.
	for x in range(3, 8):
		_put(o + Vector3i(x, 0, 3), Blocks.PLANKS)
	_put(o + Vector3i(5, 0, 3), Blocks.CRAFTING_TABLE)
	for z in range(1, 8):
		_put(o + Vector3i(0, 0, z), Blocks.CHEST)
		_put(o + Vector3i(0, 1, z), Blocks.CHEST if z % 2 == 0 else Blocks.BERRY_BUSH)
	for z in range(4, 7):
		_put(o + Vector3i(10, 0, z), Blocks.GLASS)
		_put(o + Vector3i(10, 1, z), Blocks.TOY_BRICK_BLUE)
	_put(o + Vector3i(5, 2, 0), Blocks.LANTERN)
	_put(o + Vector3i(0, 2, 8), Blocks.LANTERN)
	for z in range(10, 14):
		_put(o + Vector3i(5, -1, z), Blocks.GRAVEL)
	# Arka duvarda renkli ürün rafları, kapıda paspas, önde saksı çiçekleri.
	_fill(o, Vector3i(1, 0, 0), Vector3i(9, 1, 0), Blocks.BOOKSHELF)
	_put(o + Vector3i(5, -1, 8), Blocks.RUG)
	for x in [2, 3, 7, 8]:
		_put(o + Vector3i(x, 0, 11), Blocks.FLOWERS)


## Park: çakıl yollar, banklar, piknik örtüsü (renkli oyuncak tuğlaları), büyük ağaçlar, çiçek çalıları.
func _build_park(o: Vector3i) -> void:
	for x in range(0, 17):
		_put(o + Vector3i(x, -1, 14), Blocks.GRAVEL)
	for z in range(0, 17):
		_put(o + Vector3i(8, -1, z), Blocks.GRAVEL)
	for x in range(3, 7):
		_put(o + Vector3i(x, 0, 5), Blocks.PLANKS)
	_put(o + Vector3i(3, 0, 6), Blocks.LOG)
	_put(o + Vector3i(6, 0, 6), Blocks.LOG)
	for z in range(8, 11):
		for x in range(9, 12):
			_put(o + Vector3i(x, -1, z), Blocks.TOY_BRICK_RED if (x + z) % 2 == 0 else Blocks.SNOW)
	_put(o + Vector3i(10, 0, 8), Blocks.CHEST)
	for t in [Vector3i(2, 0, 11), Vector3i(14, 0, 3), Vector3i(1, 0, 1)]:
		_fill(o, t, t + Vector3i(0, 4, 0), Blocks.LOG)
		_fill(o, t + Vector3i(-2, 3, -2), t + Vector3i(2, 5, 2), Blocks.LEAVES)
		_fill(o, t + Vector3i(0, 3, 0), t + Vector3i(0, 4, 0), Blocks.LOG)
	for b in [Vector3i(12, 0, 12), Vector3i(13, 0, 12), Vector3i(5, 0, 12), Vector3i(15, 0, 7)]:
		_put(o + b, Blocks.BERRY_BUSH)
	# Sokak lambaları ve çiçek tarhları.
	for l in [Vector3i(7, 0, 13), Vector3i(9, 0, 3), Vector3i(1, 0, 13)]:
		_fill(o, l, l + Vector3i(0, 2, 0), Blocks.LOG)
		_put(o + l + Vector3i(0, 3, 0), Blocks.LANTERN)
	for f in [Vector3i(12, 0, 1), Vector3i(13, 0, 1), Vector3i(14, 0, 1), Vector3i(0, 0, 7), Vector3i(0, 0, 8), Vector3i(15, 0, 13), Vector3i(16, 0, 13)]:
		_put(o + f, Blocks.FLOWERS)


## Futbol sahası: beyaz çizgiler, iki kale, kenarda seyirci bankı.
func _build_field(o: Vector3i) -> void:
	for x in range(0, 23):
		_put(o + Vector3i(x, -1, 0), Blocks.SNOW)
		_put(o + Vector3i(x, -1, 14), Blocks.SNOW)
	for z in range(0, 15):
		_put(o + Vector3i(0, -1, z), Blocks.SNOW)
		_put(o + Vector3i(22, -1, z), Blocks.SNOW)
		_put(o + Vector3i(11, -1, z), Blocks.SNOW)
	for gx in [0, 22]:
		_fill(o, Vector3i(gx, 0, 5), Vector3i(gx, 2, 5), Blocks.LOG)
		_fill(o, Vector3i(gx, 0, 9), Vector3i(gx, 2, 9), Blocks.LOG)
		_fill(o, Vector3i(gx, 2, 5), Vector3i(gx, 2, 9), Blocks.LOG)
	for x in range(9, 16):
		_put(o + Vector3i(x, 0, 17), Blocks.PLANKS)


## Karakter bu hücrede durabilir mi (ayak ve baş hizası boş mu)?
func is_free(cell: Vector3i) -> bool:
	return _blocks.get(cell, Blocks.AIR) == Blocks.AIR and _blocks.get(cell + Vector3i.UP, Blocks.AIR) == Blocks.AIR


## Eşyaların etrafından dolaşan yürüme yolu (ızgarada genişlik öncelikli arama).
## Ara noktaları döner; son nokta hedefin kendisidir. Yol yoksa boş dizi döner.
func route(from: Vector3, to: Vector3) -> Array[Vector3]:
	var y := floori(from.y + 0.01)
	var start := Vector2i(floori(from.x), floori(from.z))
	var goal := Vector2i(floori(to.x), floori(to.z))
	var result: Array[Vector3] = []
	if start == goal or _clear_line(from, to, y):
		result.append(to)
		return result
	var prev := {start: start}
	var queue: Array[Vector2i] = [start]
	var dirs := [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]
	while not queue.is_empty() and not prev.has(goal):
		var c: Vector2i = queue.pop_front()
		for d: Vector2i in dirs:
			var n := c + d
			if prev.has(n) or (n - start).length_squared() > 40 * 40:
				continue
			if n != goal and not is_free(Vector3i(n.x, y, n.y)):
				continue
			prev[n] = c
			queue.append(n)
	if not prev.has(goal):
		return result
	var cells: Array[Vector2i] = []
	var c2 := goal
	while c2 != start:
		cells.push_front(c2)
		c2 = prev[c2]
	# Düz görünen kısımları atla: bir önceki noktadan açıkça görünen en uzak hücreye git.
	var here := from
	var i := 0
	while i < cells.size():
		var j := cells.size() - 1
		while j > i:
			var p := Vector3(cells[j].x + 0.5, from.y, cells[j].y + 0.5)
			if _clear_line(here, p, y):
				break
			j -= 1
		var wp := Vector3(cells[j].x + 0.5, from.y, cells[j].y + 0.5)
		if j == cells.size() - 1:
			break
		result.append(wp)
		here = wp
		i = j + 1
	result.append(to)
	return result


func _clear_line(a: Vector3, b: Vector3, y: int) -> bool:
	var steps := int(ceil(Vector2(b.x - a.x, b.z - a.z).length() * 4.0)) + 1
	for k in range(1, steps + 1):
		var q := a.lerp(b, float(k) / steps)
		# Karakter gövdesi ~0.3 genişlikte: kenarları da yokla.
		for off in [Vector2(0.25, 0.25), Vector2(-0.25, 0.25), Vector2(0.25, -0.25), Vector2(-0.25, -0.25)]:
			if not is_free(Vector3i(floori(q.x + off.x), y, floori(q.z + off.y))):
				return false
	return true
