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
	"pazar": Vector3i(-8, GROUND + 1, 32),
	"oyun": Vector3i(83, GROUND + 1, 32),
}
## Şehrin kapladığı alan (x, z); ağaçlar bunun dışında çıkar.
const CITY_MIN := Vector2i(-64, -56)
const CITY_MAX := Vector2i(100, 52)

## Setlerdeki adlandırılmış noktalar (köşeye göre, blok ortası için .5).
const POINTS := {
	"ev": {
		"yatak": Vector3(1.5, 0.42, 2.0),          # Emir'in uzandığı yer (yatak üstü)
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
		"sira_1": Vector3(4.5, 0, 5.6),
		"sira_2": Vector3(10.5, 0, 5.6),
		"sira_3": Vector3(4.5, 0, 8.6),
		"sira_4": Vector3(10.5, 0, 8.6),
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
		"yatak_1": Vector3(1.5, 0.42, 2.0),
		"yatak_1_yani": Vector3(2.8, 0, 2.0),
		"yatak_2": Vector3(11.5, 0.42, 2.0),
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
	"pazar": {
		"giris": Vector3(16.5, 0, -1.5),
		"tezgah1_on": Vector3(2.5, 0, 0.5),
		"tezgah1_arka": Vector3(2.5, 0, 3.5),
		"tezgah2_on": Vector3(8.5, 0, 0.5),
		"cesme_yani": Vector3(16.5, 0, 10.0),
		"orta": Vector3(11.5, 0, 6.0),
		"kam_genel": Vector3(16.0, 6.0, -6.0),
		"kam_tezgah": Vector3(4.8, 2.3, -1.2),
	},
	"oyun": {
		"giris": Vector3(8.0, 0, -1.5),
		"orta": Vector3(8.0, 0, 4.5),
		"kaydirak_alt": Vector3(2.5, 0, 2.5),
		"kaydirak_yani": Vector3(4.8, 0, 3.5),
		"salincak": Vector3(9.5, 0, 5.3),
		"salincak_2": Vector3(11.0, 0, 5.3),
		"kum": Vector3(12.0, 0, 4.5),
		"bank_yani": Vector3(4.5, 0, 8.3),
		"kam_genel": Vector3(13.5, 6.0, -4.5),
		"kam_kaydirak": Vector3(6.0, 2.2, 0.5),
		"kam_salincak": Vector3(15.0, 2.6, 5.5),
	},
}

var _blocks := {}  # Vector3i -> blok id
var _by_chunk := {}  # Vector2i (chunk) -> [[Vector3i, id], ...]; chunk üretimi hızlı olsun


func _init() -> void:
	_build_city()
	_build_house(SETS["ev"])
	_build_school(SETS["okul"])
	_build_hospital(SETS["hastane"])
	_build_shop(SETS["bakkal"])
	_build_park(SETS["park"])
	_build_field(SETS["saha"])
	_connect_sets()
	for pos: Vector3i in _blocks:
		var key := Vector2i(floori(pos.x / float(Chunk.SIZE)), floori(pos.z / float(Chunk.SIZE)))
		if not _by_chunk.has(key):
			_by_chunk[key] = []
		_by_chunk[key].append([pos, _blocks[pos]])


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
	var key := Vector2i(floori(base.x / float(Chunk.SIZE)), floori(base.z / float(Chunk.SIZE)))
	for entry: Array in _by_chunk.get(key, []):
		var pos: Vector3i = entry[0]
		chunk.set_local(pos.x - base.x, pos.y, pos.z - base.z, entry[1])


func _tree_spot(g: Vector2i) -> bool:
	var lx := posmod(g.x, 16)
	var lz := posmod(g.y, 16)
	if lx < 3 or lx > 12 or lz < 3 or lz > 12:
		return false
	# Setlerin ve önlerindeki yolun çevresi boş kalsın.
	if g.x > CITY_MIN.x - 8 and g.x < CITY_MAX.x + 8 and g.y > CITY_MIN.y - 8 and g.y < CITY_MAX.y + 8:
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
func is_air(cell: Vector3i) -> bool:
	return _blocks.get(cell, Blocks.AIR) == Blocks.AIR and cell.y > GROUND


## İki nokta arası bloklara çarpmadan görülebiliyor mu (kamera kadrajı için).
func clear_sight(a: Vector3, b: Vector3) -> bool:
	var n := int(ceil(a.distance_to(b) * 4.0))
	for i in range(1, n):
		if not is_air(Vector3i((a.lerp(b, float(i) / n)).floor())):
			return false
	return true


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


# --- Şehir: setler gerçek bir mahallenin içinde dursun (yollar, kaldırımlar, apartmanlar, dükkânlar). ---

const AVENUES_Z := [25, -16]   # doğu-batı caddeleri (4 şeritlik asfaltın ilk z'si)
const STREETS_X := [-15, 28, 76]  # kuzey-güney sokakları (asfaltın ilk x'i)
const WALLS := [Blocks.BRICKS, Blocks.PLASTER, Blocks.CONCRETE, Blocks.SNOW, Blocks.YELLOW_WALLPAPER, Blocks.BRICKS]
const CAR_COLORS := [Blocks.TOY_BRICK_RED, Blocks.TOY_BRICK_BLUE, Blocks.TOY_BRICK_YELLOW, Blocks.SNOW]
const Y0 := GROUND + 1


func _build_city() -> void:
	var o := Vector3i(0, Y0, 0)
	# Kaldırımlar önce, asfalt üstüne; kavşaklarda asfalt kazanır.
	for az: int in AVENUES_Z:
		_fill(o, Vector3i(CITY_MIN.x, -1, az - 2), Vector3i(CITY_MAX.x, -1, az + 5), Blocks.SIDEWALK)
	for sx: int in STREETS_X:
		_fill(o, Vector3i(sx - 2, -1, CITY_MIN.y), Vector3i(sx + 5, -1, CITY_MAX.y), Blocks.SIDEWALK)
	for az: int in AVENUES_Z:
		_fill(o, Vector3i(CITY_MIN.x, -1, az), Vector3i(CITY_MAX.x, -1, az + 3), Blocks.ASPHALT)
		for x in range(CITY_MIN.x, CITY_MAX.x + 1):
			if posmod(x, 4) < 2 and not _near_street(x):
				_put(o + Vector3i(x, -1, az + 2), Blocks.ROAD_LINE)
	for sx: int in STREETS_X:
		_fill(o, Vector3i(sx, -1, CITY_MIN.y), Vector3i(sx + 3, -1, CITY_MAX.y), Blocks.ASPHALT)
		for z in range(CITY_MIN.y, CITY_MAX.y + 1):
			if posmod(z, 4) < 2 and not _near_avenue(z):
				_put(o + Vector3i(sx + 2, -1, z), Blocks.ROAD_LINE)
	# Sokak lambaları ve kaldırım ağaçları.
	for az: int in AVENUES_Z:
		for x in range(CITY_MIN.x + 4, CITY_MAX.x, 12):
			if not _near_street(x):
				_lamp(o + Vector3i(x, 0, az - 2))
				_lamp(o + Vector3i(x + 6, 0, az + 5))
		for x in range(CITY_MIN.x + 10, CITY_MAX.x, 12):
			if not _near_street(x):
				_tree(o + Vector3i(x, 0, az + 5))
	for sx: int in STREETS_X:
		for z in range(CITY_MIN.y + 4, CITY_MAX.y, 12):
			if not _near_avenue(z):
				_lamp(o + Vector3i(sx - 2, 0, z))
				_tree(o + Vector3i(sx + 5, 0, z + 6))
	# Park etmiş arabalar.
	var i := 0
	for az: int in AVENUES_Z:
		for x in range(CITY_MIN.x + 7, CITY_MAX.x - 4, 17):
			if not _near_street(x) and not _near_street(x + 3):
				_car(o + Vector3i(x, 0, az + (0 if i % 2 == 0 else 2)), CAR_COLORS[i % CAR_COLORS.size()], true)
			i += 1
	for sx: int in STREETS_X:
		for z in range(CITY_MIN.y + 9, CITY_MAX.y - 4, 19):
			if not _near_avenue(z) and not _near_avenue(z + 3):
				_car(o + Vector3i(sx + (0 if i % 2 == 0 else 2), 0, z), CAR_COLORS[i % CAR_COLORS.size()], false)
			i += 1
	# Kuzey sırası: caddeye bakan apartmanlar ve altı dükkânlı binalar.
	_row(Vector2i(-62, 32), Vector2i(-20, 32), -1)
	_bazaar(SETS["pazar"])
	_row(Vector2i(35, 32), Vector2i(72, 32), -1)
	_playground(SETS["oyun"])
	# Güney sırası.
	_row(Vector2i(-62, -40), Vector2i(-20, -40), 1)
	_mosque(Vector3i(-6, Y0, -54))
	_row(Vector2i(14, -40), Vector2i(24, -40), 1)
	_row(Vector2i(35, -40), Vector2i(72, -40), 1)
	_row(Vector2i(83, -40), Vector2i(98, -40), 1)
	# Setlerin aralarındaki boş parseller.
	_building(Vector3i(14, Y0, -8), Vector2i(10, 10), 4, 0, true, -1)
	_building(Vector3i(14, Y0, 6), Vector2i(10, 12), 2, 1, true, 1)
	_building(Vector3i(35, Y0, -8), Vector2i(10, 10), 5, 2, false, -1)
	_building(Vector3i(35, Y0, 6), Vector2i(10, 12), 3, 3, true, 1)
	_building(Vector3i(67, Y0, -8), Vector2i(7, 26), 4, 4, false, 1)
	_building(Vector3i(-59, Y0, -8), Vector2i(14, 26), 5, 5, false, 1)
	_building(Vector3i(-8, Y0, -8), Vector2i(4, 10), 2, 0, true, -1)
	_building(Vector3i(-25, Y0, -8), Vector2i(6, 10), 3, 1, true, -1)
	_building(Vector3i(14, Y0, -36), Vector2i(10, 14), 4, 2, true, 1)
	_building(Vector3i(59, Y0, -36), Vector2i(14, 14), 5, 3, false, 1)
	_building(Vector3i(-59, Y0, -36), Vector2i(14, 14), 3, 4, true, 1)
	_building(Vector3i(-8, Y0, -36), Vector2i(4, 14), 2, 5, true, 1)
	_building(Vector3i(83, Y0, -8), Vector2i(12, 26), 6, 0, false, -1)


func _connect_sets() -> void:
	# Setlerin bahçe yolları caddelere bağlansın.
	var o := Vector3i(0, Y0, 0)
	_fill(o, Vector3i(4, -1, 17), Vector3i(4, -1, 22), Blocks.GRAVEL)
	_fill(o, Vector3i(55, -1, 20), Vector3i(56, -1, 22), Blocks.GRAVEL)
	_fill(o, Vector3i(-34, -1, 15), Vector3i(-34, -1, 22), Blocks.GRAVEL)
	_fill(o, Vector3i(5, -1, -22), Vector3i(5, -1, -19), Blocks.GRAVEL)


func _near_street(x: int) -> bool:
	for sx: int in STREETS_X:
		if x >= sx - 3 and x <= sx + 6:
			return true
	return false


func _near_avenue(z: int) -> bool:
	for az: int in AVENUES_Z:
		if z >= az - 3 and z <= az + 6:
			return true
	return false


## Bir sıra bina: from.x'ten to.x'e, cephesi caddeye (face: -1 kuzey sırası güneye bakar, 1 güney sırası kuzeye).
func _row(from: Vector2i, to: Vector2i, face: int) -> void:
	var x := from.x
	var k := hash(from) % 7
	while x + 8 <= to.x:
		var w := 8 + (k % 3) * 2
		if x + w > to.x:
			w = to.x - x
		var depth := 10
		var z := from.y if face == -1 else from.y - depth + 1
		_building(Vector3i(x, Y0, z), Vector2i(w, depth), 3 + (k * 5) % 4, k, k % 2 == 0, face)
		x += w + 2
		k += 1


## Apartman: her kat 4 blok; pencereler, düz çatı ve korkuluk. shop=true ise zemin kat camlı dükkân ve tente.
## face: kapının olduğu cephe (-1: düşük z tarafı, 1: yüksek z tarafı).
func _building(c: Vector3i, size: Vector2i, floors: int, style: int, shop: bool, face: int) -> void:
	var wall: int = WALLS[posmod(style, WALLS.size())]
	var h := floors * 4
	var o := Vector3i.ZERO
	var a := c
	var b := c + Vector3i(size.x - 1, h - 1, size.y - 1)
	_fill(o, Vector3i(a.x, a.y - 1, a.z), Vector3i(b.x, a.y - 1, b.z), Blocks.CONCRETE)
	_walls(o, a, b, wall)
	for f in floors:
		var fy := a.y + f * 4
		if f > 0:
			_fill(o, Vector3i(a.x + 1, fy - 1, a.z + 1), Vector3i(b.x - 1, fy - 1, b.z - 1), Blocks.PLANKS)
		# Pencereler (her iki blokta bir, iki blok yüksek).
		for x in range(a.x + 1, b.x, 2):
			_fill(o, Vector3i(x, fy + 1, a.z), Vector3i(x, fy + 2, a.z), Blocks.GLASS)
			_fill(o, Vector3i(x, fy + 1, b.z), Vector3i(x, fy + 2, b.z), Blocks.GLASS)
		for z in range(a.z + 1, b.z, 2):
			_fill(o, Vector3i(a.x, fy + 1, z), Vector3i(a.x, fy + 2, z), Blocks.GLASS)
			_fill(o, Vector3i(b.x, fy + 1, z), Vector3i(b.x, fy + 2, z), Blocks.GLASS)
		# Kat arası kuşak.
		_walls(o, Vector3i(a.x, fy + 3, a.z), Vector3i(b.x, fy + 3, b.z), Blocks.CONCRETE if wall != Blocks.CONCRETE else Blocks.STONE)
	# Çatı ve korkuluk, çatıda su deposu.
	_fill(o, Vector3i(a.x, b.y + 1, a.z), Vector3i(b.x, b.y + 1, b.z), Blocks.CONCRETE)
	_walls(o, Vector3i(a.x, b.y + 2, a.z), Vector3i(b.x, b.y + 2, b.z), Blocks.STONE)
	_put(Vector3i(a.x + 2, b.y + 2, a.z + 2), Blocks.FURNACE)
	var fz := a.z if face == -1 else b.z
	var out := -1 if face == -1 else 1
	var mid := a.x + size.x / 2
	if shop:
		# Camlı vitrin, çizgili tente, içi ışıklı.
		_fill(o, Vector3i(a.x + 1, a.y, fz), Vector3i(b.x - 1, a.y + 2, fz), Blocks.GLASS)
		var awning: int = [Blocks.TOY_BRICK_RED, Blocks.TOY_BRICK_BLUE, Blocks.TOY_BRICK_YELLOW][posmod(style, 3)]
		for x in range(a.x, b.x + 1):
			_put(Vector3i(x, a.y + 3, fz + out), awning if x % 2 == 0 else Blocks.SNOW)
		_put(Vector3i(mid, a.y + 2, fz - out), Blocks.CEILING_LIGHT)
		_fill(o, Vector3i(a.x + 1, a.y, fz - out * (size.y - 2)), Vector3i(b.x - 1, a.y + 1, fz - out * (size.y - 2)), Blocks.BOOKSHELF)
	_fill(o, Vector3i(mid, a.y, fz), Vector3i(mid, a.y + 1, fz), Blocks.AIR)
	_put(Vector3i(mid, a.y + 2, fz + out), Blocks.LANTERN)


func _lamp(p: Vector3i) -> void:
	_fill(Vector3i.ZERO, p, p + Vector3i(0, 3, 0), Blocks.STONE)
	_put(p + Vector3i(0, 4, 0), Blocks.LANTERN)


func _tree(p: Vector3i) -> void:
	_fill(Vector3i.ZERO, p, p + Vector3i(0, 3, 0), Blocks.LOG)
	_fill(Vector3i.ZERO, p + Vector3i(-1, 3, -1), p + Vector3i(1, 5, 1), Blocks.LEAVES)
	_put(p + Vector3i(0, 3, 0), Blocks.LOG)


## Basit blok araba: renkli gövde, camlı kabin, koyu tekerlek izi. along_x: yol doğu-batı.
func _car(p: Vector3i, color: int, along_x: bool) -> void:
	var l := Vector3i(3, 0, 1) if along_x else Vector3i(1, 0, 3)
	_fill(Vector3i.ZERO, p, p + l, color)
	var cab := p + (Vector3i(1, 1, 0) if along_x else Vector3i(0, 1, 1))
	_fill(Vector3i.ZERO, cab, cab + (Vector3i(1, 0, 1) if along_x else Vector3i(1, 0, 1)), Blocks.GLASS)


## Mahalle camisi: taş gövde, basamaklı kubbe, iki minare, avlu ve şadırvan.
func _mosque(c: Vector3i) -> void:
	var o := Vector3i.ZERO
	# Avlu (caddeye doğru, kuzeyde).
	_fill(o, c + Vector3i(-2, -1, 14), c + Vector3i(17, -1, 15), Blocks.SIDEWALK)
	_put(c + Vector3i(7, 0, 14), Blocks.GLASS)
	_put(c + Vector3i(8, 0, 14), Blocks.GLASS)
	# Gövde.
	_fill(o, c + Vector3i(0, -1, 0), c + Vector3i(15, -1, 13), Blocks.CONCRETE)
	_walls(o, c, c + Vector3i(15, 6, 13), Blocks.SNOW)
	for x in range(2, 14, 3):
		_fill(o, c + Vector3i(x, 2, 13), c + Vector3i(x, 4, 13), Blocks.GLASS)
	for z in range(2, 12, 3):
		_fill(o, c + Vector3i(0, 2, z), c + Vector3i(0, 4, z), Blocks.GLASS)
		_fill(o, c + Vector3i(15, 2, z), c + Vector3i(15, 4, z), Blocks.GLASS)
	_fill(o, c + Vector3i(7, 0, 13), c + Vector3i(8, 3, 13), Blocks.AIR)
	_fill(o, c + Vector3i(0, 7, 0), c + Vector3i(15, 7, 13), Blocks.CONCRETE)
	_fill(o, c + Vector3i(1, -1, 1), c + Vector3i(14, -1, 12), Blocks.RUG)
	# Basamaklı kubbe (merkez 7.5, 6.5).
	var r := 6.0
	for dy in 7:
		var rr := sqrt(maxf(0.0, r * r - float(dy * dy)))
		for z in range(0, 14):
			for x in range(0, 16):
				if Vector2(x - 7.5, z - 6.5).length() <= rr:
					_put(c + Vector3i(x, 8 + dy, z), Blocks.CONCRETE if dy < 6 else Blocks.TOY_BRICK_YELLOW)
	_put(c + Vector3i(7, 15, 6), Blocks.TOY_BRICK_YELLOW)
	# İki ince minare ve şerefeleri.
	for mx in [-2, 17]:
		var b := c + Vector3i(mx, 0, 13)
		_fill(o, b, b + Vector3i(0, 20, 0), Blocks.SNOW)
		_fill(o, b + Vector3i(-1, 14, -1), b + Vector3i(1, 14, 1), Blocks.STONE)
		_fill(o, b + Vector3i(0, 21, 0), b + Vector3i(0, 22, 0), Blocks.TOY_BRICK_YELLOW)


## Semt pazarı: taş zemin, iki sıra tenteli tezgâh, kasalar, meyve sebze, ortada çeşme.
## Mahalle oyun alanı: kum zemin, kaydırak, salıncak, tahterevalli, kum havuzu, banklar.
func _playground(c: Vector3i) -> void:
	var o := Vector3i.ZERO
	_fill(o, c + Vector3i(0, -1, 0), c + Vector3i(15, -1, 9), Blocks.SAND)
	# Alçak çit (çalı), önde giriş boşluğu.
	for x in range(0, 16):
		if x < 7 or x > 9:
			_put(c + Vector3i(x, 0, 0), Blocks.LEAVES)
		_put(c + Vector3i(x, 0, 10), Blocks.LEAVES)
	for z in range(0, 11):
		_put(c + Vector3i(-1, 0, z), Blocks.LEAVES)
		_put(c + Vector3i(16, 0, z), Blocks.LEAVES)
	# Kaydırak: arkada merdiven, üstte platform, öne inen kırmızı oluk.
	_fill(o, c + Vector3i(1, 0, 8), c + Vector3i(3, 0, 8), Blocks.TOY_BRICK_YELLOW)
	_fill(o, c + Vector3i(1, 1, 7), c + Vector3i(3, 1, 7), Blocks.TOY_BRICK_YELLOW)
	_fill(o, c + Vector3i(1, 2, 5), c + Vector3i(3, 2, 6), Blocks.TOY_BRICK_BLUE)
	for p in [Vector3i(1, 0, 5), Vector3i(3, 0, 5), Vector3i(1, 0, 6), Vector3i(3, 0, 6)]:
		_fill(o, c + p, c + p + Vector3i(0, 1, 0), Blocks.LOG)
	_fill(o, c + Vector3i(1, 4, 5), c + Vector3i(3, 4, 6), Blocks.TOY_BRICK_RED)
	_fill(o, c + Vector3i(2, 1, 4), c + Vector3i(2, 1, 4), Blocks.TOY_BRICK_RED)
	_put(c + Vector3i(2, 0, 3), Blocks.TOY_BRICK_RED)
	# Salıncak: iki direk, üst kiriş, iki oturak.
	_fill(o, c + Vector3i(8, 0, 7), c + Vector3i(8, 3, 7), Blocks.LOG)
	_fill(o, c + Vector3i(12, 0, 7), c + Vector3i(12, 3, 7), Blocks.LOG)
	_fill(o, c + Vector3i(8, 4, 7), c + Vector3i(12, 4, 7), Blocks.LOG)
	_put(c + Vector3i(9, 1, 7), Blocks.TOY_BRICK_BLUE)
	_put(c + Vector3i(11, 1, 7), Blocks.TOY_BRICK_RED)
	# Tahterevalli.
	_put(c + Vector3i(9, 0, 2), Blocks.LOG)
	_fill(o, c + Vector3i(7, 1, 2), c + Vector3i(11, 1, 2), Blocks.TOY_BRICK_YELLOW)
	# Kum havuzu.
	_walls(o, c + Vector3i(12, 0, 1), c + Vector3i(15, 0, 3), Blocks.PLANKS)
	# Banklar ve çiçekler.
	_fill(o, c + Vector3i(5, 0, 9), c + Vector3i(6, 0, 9), Blocks.DARK_PLANKS)
	_fill(o, c + Vector3i(14, 0, 8), c + Vector3i(15, 0, 8), Blocks.DARK_PLANKS)
	_put(c + Vector3i(0, 0, 9), Blocks.FLOWERS)
	_put(c + Vector3i(15, 0, 6), Blocks.FLOWERS)
	_lamp(c + Vector3i(0, 0, 1))
	_lamp(c + Vector3i(15, 0, 9))


func _bazaar(c: Vector3i) -> void:
	var o := Vector3i.ZERO
	_fill(o, c + Vector3i(0, -1, 0), c + Vector3i(32, -1, 12), Blocks.COBBLESTONE)
	var awnings := [Blocks.TOY_BRICK_RED, Blocks.TOY_BRICK_BLUE, Blocks.TOY_BRICK_YELLOW, Blocks.SNOW]
	var goods := [Blocks.BERRY_BUSH, Blocks.FLOWERS, Blocks.LEAVES, Blocks.TOY_BRICK_YELLOW, Blocks.TOY_BRICK_RED]
	var k := 0
	for row_z in [2, 9]:
		for x0 in range(1, 31, 6):
			if x0 >= 13 and x0 <= 18:
				continue
			# Tezgâh: 4 blok uzun masa, üstünde mal, arkasında kasa, köşede direkler, üstte tente.
			_fill(o, c + Vector3i(x0, 0, row_z), c + Vector3i(x0 + 3, 0, row_z), Blocks.PLANKS)
			# Mal kenarlarda; ortası boş kalsın ki satıcının yüzü görünsün.
			var back: int = row_z + (1 if row_z == 2 else -1)
			_put(c + Vector3i(x0, 1, row_z), goods[k % goods.size()])
			_put(c + Vector3i(x0 + 3, 1, row_z), goods[(k + 2) % goods.size()])
			_put(c + Vector3i(x0 + 2, 0, back), Blocks.CHEST)
			for px in [x0, x0 + 3]:
				_fill(o, c + Vector3i(px, 0, back), c + Vector3i(px, 2, back), Blocks.LOG)
			for ax in range(x0, x0 + 4):
				_fill(o, c + Vector3i(ax, 3, row_z - 1), c + Vector3i(ax, 3, row_z + 1), awnings[k % awnings.size()] if ax % 2 == 0 else Blocks.SNOW)
			k += 1
	# Ortada çeşme.
	_walls(o, c + Vector3i(14, 0, 4), c + Vector3i(18, 0, 8), Blocks.STONE)
	_fill(o, c + Vector3i(15, -1, 5), c + Vector3i(17, -1, 7), Blocks.GLASS)
	_fill(o, c + Vector3i(16, 0, 6), c + Vector3i(16, 2, 6), Blocks.STONE)
	_put(c + Vector3i(16, 3, 6), Blocks.LANTERN)
