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
	"market": Vector3i(13, GROUND + 1, -36),
	"lokanta": Vector3i(-60, GROUND + 1, -10),
	"pastane": Vector3i(-26, GROUND + 1, -10),
	"otopark": Vector3i(-60, GROUND + 1, -37),
	"ali_ev": Vector3i(38, GROUND + 1, 36),
	"zeynep_ev": Vector3i(58, GROUND + 1, 36),
	"ogretmen_ev": Vector3i(-60, GROUND + 1, 36),
	"itfaiye": Vector3i(-26, GROUND + 1, 2),
}
## Karakter evleri (_build_family_house): aynı plan, farklı cephe. Noktalar FAMILY_POINTS'ten.
const FAMILY_HOUSES := {"ali_ev": Blocks.BRICKS, "zeynep_ev": Blocks.PLASTER, "ogretmen_ev": Blocks.FACADE_CREAM}
## Ev başına koltuk rengi (FilmProps "ad@renk" boyaması).
const FAMILY_SOFA := {"ali_ev": "2f5d8a", "zeynep_ev": "c76b8f", "ogretmen_ev": "5f8a4f"}
const FAMILY_POINTS := {
	"kapi_disi": Vector3(4.5, 0, -2.0),
	"kapi_ici": Vector3(4.5, 0, 1.6),
	"bahce": Vector3(9.0, 0, -3.0),
	"salon": Vector3(5.5, 0, 5.0),
	"mutfak": Vector3(12.5, 0, 4.0),
	"oda": Vector3(3.5, 5, 4.5),
	"ebeveyn": Vector3(11.0, 5, 4.5),
	"kam_genel": Vector3(2.0, 8.0, -19.0),
	"kam_dis": Vector3(9.0, 3.0, -9.0),
	"kam_salon": Vector3(7.2, 2.3, 2.0),
	"kam_mutfak": Vector3(9.6, 2.3, 7.0),
	"banyo": Vector3(5.5, 5, 7.8),
	"kam_oda": Vector3(6.3, 7.3, 1.6),
	"kam_banyo": Vector3(5.5, 7.6, 7.1),
	"kam_ebeveyn": Vector3(12.5, 7.3, 7.0),
}
## Şehrin kapladığı alan (x, z); ağaçlar bunun dışında çıkar.
const CITY_MIN := Vector2i(-64, -56)
const CITY_MAX := Vector2i(100, 52)

## Setlerdeki adlandırılmış noktalar (köşeye göre, blok ortası için .5).
const POINTS := {
	"ali_ev": FAMILY_POINTS,
	"zeynep_ev": FAMILY_POINTS,
	"ogretmen_ev": FAMILY_POINTS,
	"ev": {
		"yatak": Vector3(1.5, 0.42, 2.0),          # Emir'in uzandığı yer (yatak üstü)
		"yatak_yani": Vector3(2.8, 0, 2.0),
		"mutfak": Vector3(6.5, 0, 2.6),
		"ocak": Vector3(7.5, 0, 1.4),
		"mutfak_on": Vector3(6.8, 0, 4.0),       # mutfakla oda arası, konuşma yeri
		"masa": Vector3(5.5, 0, 4.4),
		"canta": Vector3(2.0, 0, 5.4),          # çalışma masasının önü (masa z=6)
		"kapi_ici": Vector3(4.5, 0, 5.8),
		"kapi_disi": Vector3(4.5, 0, 9.0),
		"bahce": Vector3(8.0, 0, 11.0),
		"yol": Vector3(4.5, 0, 16.0),
		"kam_yatak": Vector3(4.2, 2.3, 4.8),
		"kam_mutfak": Vector3(3.0, 2.2, 5.2),
		"kam_oda": Vector3(7.8, 2.6, 5.8),
		"kam_dis": Vector3(10.0, 4.0, 15.0),
		"kam_kapi": Vector3(6.5, 1.8, 11.5),
		"salon": Vector3(15.0, 0, 3.5),
		"salon_kapi": Vector3(10.5, 0, 4.5),
		"koridor": Vector3(6.5, 0, -2.5),
		"banyo": Vector3(2.5, 0, -6.5),
		"camasir": Vector3(-5.0, 0, -6.5),
		"garaj": Vector3(-3.5, 0, 3.0),
		"merdiven": Vector3(9.5, 0, -6.5),
		"bodrum": Vector3(8.5, -4, -5.5),
		"yatak_odasi": Vector3(4.0, 5, 4.5),
		"ust_kat": Vector3(4.5, 5, -6.0),
		"teras": Vector3(14.5, 5, 4.5),
		"yan_bahce": Vector3(21.0, 0, 6.0),
		"kam_salon": Vector3(16.2, 2.4, 6.2),
		"kam_banyo": Vector3(4.4, 2.4, -5.2),
		"kam_garaj": Vector3(-2.4, 2.2, 6.2),
		"kam_bodrum": Vector3(14.0, -2.3, -2.4),
		"kam_yatak_odasi": Vector3(7.6, 7.2, 5.8),
		"kam_teras": Vector3(15.6, 7.0, 6.4),
		"kam_bahce": Vector3(24.0, 2.5, 20.5),
		"kam_ev_genel": Vector3(20.0, 7.0, 20.0),
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
		"agac_onu": Vector3(10.5, 0, 19.3),          # bahçedeki ağacın önü (saklambaçta ebe sayar)
		"kam_agac_arka": Vector3(10.5, 2.3, 15.2),
		"top_alani": Vector3(3.0, 0, 18.0),
		"kam_sinif": Vector3(7.5, 2.6, 9.5),
		"kam_tahta": Vector3(7.5, 2.2, 3.5),
		"kam_bahce": Vector3(7.5, 5.0, 26.0),
		"koridor": Vector3(17.0, 0, 6.0),
		"merdiven": Vector3(16.5, 0, -3.0),
		"kantin": Vector3(22.5, 0, 2.5),
		"kantin_masa": Vector3(22.5, 0, 7.0),
		"ogretmenler": Vector3(23.5, 0, -3.0),
		"mudur": Vector3(12.5, 0, -5.5),
		"tuvalet": Vector3(2.5, 0, -5.5),
		"arka_koridor": Vector3(7.5, 0, -2.5),
		"okul_kapi": Vector3(17.0, 0, 13.5),
		"bayrak": Vector3(11.0, 0, 16.5),
		"basket": Vector3(-7.5, 0, 1.5),
		"sinif_b": Vector3(7.5, 5, 8.5),
		"sinif_b_tahta": Vector3(7.5, 5, 1.6),
		"resim_odasi": Vector3(7.5, 5, -4.0),
		"kutuphane": Vector3(20.5, 5, -1.0),
		"ust_koridor": Vector3(16.5, 5, 6.0),
		"kam_koridor": Vector3(16.5, 2.5, 10.2),
		"kam_kantin": Vector3(19.5, 2.5, 9.5),
		"kam_ogretmenler": Vector3(24.3, 2.6, -7.5),
		"kam_mudur": Vector3(13.6, 2.3, -5.2),
		"kam_sinif_b": Vector3(7.5, 7.6, 9.5),
		"kam_kutuphane": Vector3(19.5, 7.5, 9.5),
		"kam_resim": Vector3(13.5, 7.4, -2.5),
		"kam_basket": Vector3(-1.5, 3.5, 12.0),
		"kam_okul_genel": Vector3(12.0, 9.0, 30.0),
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
		"kam_yatak": Vector3(4.2, 2.5, 3.6),
		"kam_dis": Vector3(12.0, 4.5, 18.0),
		"muayene": Vector3(3.0, 0, -3.0),
		"muayene_doktor": Vector3(1.5, 0, -6.0),
		"muayene_yatak": Vector3(5.5, 0.42, -5.5),
		"eczane_on": Vector3(8.5, 0, -2.5),
		"eczane_arka": Vector3(8.5, 0, -5.0),
		"ambulans": Vector3(9.5, 0, 16.0),
		"kam_muayene": Vector3(4.6, 2.4, -2.0),
		"kam_eczane": Vector3(11.8, 2.4, -2.0),
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
		"kopru": Vector3(20.5, 0, 6.0),
		"havuz": Vector3(25.5, 0, 6.0),
		"cesme_yani": Vector3(30.0, 0, 11.5),
		"kameriye": Vector3(29.5, 0, 1.0),
		"bufe": Vector3(18.5, 0, 14.5),
		"bufe_ici": Vector3(18.5, 0, 12.0),
		"yuruyus": Vector3(25.5, 0, 10.0),
		"kam_havuz": Vector3(21.0, 2.5, 12.5),
		"kam_cesme": Vector3(26.5, 2.5, 13.5),
		"kam_kameriye": Vector3(24.5, 2.6, 0.5),
		"kam_bufe": Vector3(21.5, 2.0, 15.5),
		"kam_park_genel": Vector3(17.0, 10.0, 24.0),
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
	"market": {
		"giris": Vector3(3.0, 0, 12.0),
		"dis": Vector3(3.0, 0, 16.0),
		"kasa_on": Vector3(5.0, 0, 9.0),
		"kasa_arka": Vector3(5.0, 0, 11.5),
		"kasa_2_arka": Vector3(9.0, 0, 11.5),
		"reyon_1": Vector3(4.5, 0, 5.5),
		"reyon_2": Vector3(7.5, 0, 5.5),
		"meyve": Vector3(2.0, 0, 5.0),
		"icecek": Vector3(10.0, 0, 5.5),
		"depo": Vector3(4.5, 0, -1.0),
		"kam_ic": Vector3(10.5, 2.6, 12.0),
		"kam_kasa": Vector3(7.0, 2.2, 9.4),
		"kam_reyon": Vector3(5.0, 2.2, 9.0),
		"kam_depo": Vector3(10.5, 2.2, 0.0),
		"kam_dis": Vector3(6.0, 5.0, 21.0),
	},
	"lokanta": {
		"giris": Vector3(7.5, 0, 1.5),
		"dis": Vector3(7.5, 0, -2.0),
		"masa_1": Vector3(4.5, 0, 3.5),
		"masa_2": Vector3(8.5, 0, 6.5),
		"masa_3": Vector3(12.5, 0, 3.5),
		"tezgah_on": Vector3(4.5, 0, 7.4),
		"tezgah_arka": Vector3(4.5, 0, 9.5),
		"mutfak": Vector3(8.0, 0, 10.0),
		"kam_ic": Vector3(12.5, 2.6, 1.5),
		"kam_mutfak": Vector3(11.5, 2.4, 10.5),
		"kam_dis": Vector3(7.5, 4.0, -7.0),
	},
	"pastane": {
		"giris": Vector3(3.5, 0, 1.5),
		"dis": Vector3(3.5, 0, -2.0),
		"vitrin_on": Vector3(2.5, 0, 4.0),
		"vitrin_arka": Vector3(2.5, 0, 6.5),
		"masa": Vector3(3.5, 0, 2.5),
		"kam_ic": Vector3(6.2, 2.4, 1.2),
		"kam_vitrin": Vector3(2.5, 2.0, 2.0),
		"kam_dis": Vector3(3.5, 3.5, -7.0),
	},
	"otopark": {
		"giris": Vector3(8.0, 0, 15.5),
		"gise": Vector3(12.5, 0, 16.5),
		"araba_yani": Vector3(3.5, 0, 5.5),
		"orta": Vector3(8.5, 0, 7.0),
		"kam_genel": Vector3(8.5, 7.0, 22.0),
		"kam_gise": Vector3(9.5, 2.0, 12.0),
	},
	"itfaiye": {
		"giris": Vector3(8.5, 0, 18.5),
		"garaj": Vector3(5.5, 0, 14.0),
		"arac_yani": Vector3(6.3, 0, 10.5),
		"direk": Vector3(7.5, 0, 5.8),
		"yatakhane": Vector3(4.5, 5, 10.0),
		"kam_genel": Vector3(-2.0, 6.0, 27.0),
		"kam_dis": Vector3(2.0, 3.0, 23.5),
		"kam_garaj": Vector3(6.5, 2.3, 15.0),
		"kam_yatakhane": Vector3(7.5, 7.3, 15.0),
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
	_build_market(SETS["market"])
	_build_restaurant(SETS["lokanta"])
	_build_bakery(SETS["pastane"])
	_build_parking(SETS["otopark"])
	for h: String in FAMILY_HOUSES:
		_build_family_house(SETS[h], FAMILY_HOUSES[h], FAMILY_SOFA[h])
	_family_extras()
	_build_fire_station(SETS["itfaiye"])
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


## Bloğa dönüşmeyen gerçek eşyalar: [ad, dünya köşesi (blok), taban (x, z blok)].
## Hücreleri yürünemez sayılır; görünüşü FilmProps kurar (GLB varsa o, yoksa köşeli yedek).
var props: Array = []
var _prop_cells := {}


func _prop(o: Vector3i, id: String, at: Vector3i, size: Vector2i, turn = null) -> void:
	props.append([id, o + at, size] if turn == null else [id, o + at, size, turn])
	var h := int(ceil(FilmProps.height(id)))
	for x in size.x:
		for z in size.y:
			for y in maxi(h, 1):
				_prop_cells[o + at + Vector3i(x, y, z)] = true


## Açılır kapılar: [menteşe tarafı alt köşe (dünya), y dönüşü]. film_studio yaklaşan
## oyuncuya göre açar/kapar; kapı boşluğu hava bloğudur, yürünebilir.
var doors: Array = []


## Süs: [ad, dünya konumu, y dönüşü]; hücre kapatmaz.
var decor: Array = []


func _decor(o: Vector3i, id: String, at: Vector3, turn: float) -> void:
	decor.append([id, Vector3(o) + at, turn])


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
	# Plan (zemin kat, iç ölçüler): ön blok x 0..8 z 0..6 = Emir'in odası + mutfak/yemek (iki katlı,
	# üstte anne-baba yatak odası); salon x 10..16 z 0..6 (tek kat, üstü teras); garaj x -8..-2 z 0..6;
	# arka kanat x -8..16 z -9..-2 (iki katlı): koridor z -3..-2, çamaşır odası, banyo, merdiven holü;
	# altında bodrum. Arsa x -10..25 z -11..22, çitle çevrili; doğuda yan bahçe.
	var F := Blocks.FACADE_CREAM
	var P := Blocks.PLASTER
	_fill(o, Vector3i(-9, -1, -10), Vector3i(17, -1, 7), Blocks.COBBLESTONE)
	_fill(o, Vector3i(0, -1, 0), Vector3i(8, -1, 6), Blocks.DARK_PLANKS)
	_fill(o, Vector3i(10, -1, 0), Vector3i(16, -1, 6), Blocks.PLANKS)
	_fill(o, Vector3i(-8, -1, -9), Vector3i(16, -1, -2), Blocks.DARK_PLANKS)
	_fill(o, Vector3i(-8, -1, 0), Vector3i(-2, -1, 6), Blocks.CONCRETE)
	_fill(o, Vector3i(0, -1, -9), Vector3i(4, -1, -5), Blocks.TILE_BATH)
	# Bodrum (merdivenden iner): taş duvar, beton zemin.
	_walls(o, Vector3i(-1, -5, -10), Vector3i(17, -2, -1), Blocks.STONE_BASE)
	_fill(o, Vector3i(0, -5, -9), Vector3i(16, -5, -2), Blocks.CONCRETE)
	_fill(o, Vector3i(0, -4, -9), Vector3i(16, -2, -2), Blocks.AIR)
	# Dış duvarlar: krem sıva, taş kaide, beyaz kat silmesi ve köşeler.
	_walls(o, Vector3i(-1, 0, -1), Vector3i(9, 7, 7), F)
	_walls(o, Vector3i(-9, 0, -10), Vector3i(17, 7, -1), F)
	_walls(o, Vector3i(9, 0, -1), Vector3i(17, 3, 7), F)
	_walls(o, Vector3i(-9, 0, -1), Vector3i(-1, 3, 7), F)
	for box in [[Vector3i(-1, 0, -1), Vector3i(9, 0, 7)], [Vector3i(-9, 0, -10), Vector3i(17, 0, -1)], [Vector3i(9, 0, -1), Vector3i(17, 0, 7)], [Vector3i(-9, 0, -1), Vector3i(-1, 0, 7)]]:
		_walls(o, box[0], box[1], Blocks.STONE_BASE)
	for box in [[Vector3i(-1, 4, -1), Vector3i(9, 4, 7)], [Vector3i(-9, 4, -10), Vector3i(17, 4, -1)], [Vector3i(9, 4, -1), Vector3i(17, 4, 7)], [Vector3i(-9, 4, -1), Vector3i(-1, 4, 7)]]:
		_walls(o, box[0], box[1], Blocks.TRIM_WHITE)
	for c in [Vector3i(-1, 0, 7), Vector3i(9, 0, 7), Vector3i(17, 0, 7), Vector3i(-9, 0, 7), Vector3i(-9, 0, -10), Vector3i(17, 0, -10)]:
		_fill(o, c + Vector3i(0, 1, 0), c + Vector3i(0, 3, 0), Blocks.TRIM_WHITE)
	for c in [Vector3i(-1, 5, 7), Vector3i(9, 5, 7), Vector3i(-9, 5, -10), Vector3i(17, 5, -10), Vector3i(-9, 5, -1), Vector3i(17, 5, -1)]:
		_fill(o, c, c + Vector3i(0, 2, 0), Blocks.TRIM_WHITE)
	# Kat döşemeleri ve tavanlar; garaj düz beton çatı; salonun üstü ahşap teras.
	_fill(o, Vector3i(0, 4, 0), Vector3i(8, 4, 6), Blocks.PLANKS)
	_fill(o, Vector3i(-8, 4, -9), Vector3i(16, 4, -2), Blocks.PLANKS)
	_fill(o, Vector3i(0, 8, 0), Vector3i(8, 8, 6), Blocks.PLANKS)
	_fill(o, Vector3i(-8, 8, -9), Vector3i(16, 8, -2), Blocks.PLANKS)
	_fill(o, Vector3i(-8, 4, 0), Vector3i(-2, 4, 6), Blocks.CONCRETE)
	_fill(o, Vector3i(10, 4, 0), Vector3i(16, 4, 6), Blocks.PLANKS)
	for z in range(-1, 8):
		_put(o + Vector3i(17, 5, z), Blocks.BALCONY_RAIL)
	for x in range(10, 17):
		_put(o + Vector3i(x, 5, 7), Blocks.BALCONY_RAIL)
	# İç duvarlar (sıva): koridor duvarı ve oda ayraçları.
	_fill(o, Vector3i(-8, 0, -4), Vector3i(16, 3, -4), P)
	_fill(o, Vector3i(-1, 0, -9), Vector3i(-1, 3, -5), P)
	_fill(o, Vector3i(5, 0, -9), Vector3i(5, 3, -5), P)
	# Kiremit çatılar: arka kanatta sırt x boyunca, ön blokta z boyunca (alınlık sokağa bakar).
	for s in 6:
		_fill(o, Vector3i(-10, 8 + s, -11 + s), Vector3i(18, 8 + s, 0 - s), Blocks.ROOF_TERRACOTTA)
		if s < 5:
			_fill(o, Vector3i(-9, 8 + s, -10 + s), Vector3i(-9, 8 + s, -1 - s), F)
			_fill(o, Vector3i(17, 8 + s, -10 + s), Vector3i(17, 8 + s, -1 - s), F)
	for s in 6:
		_fill(o, Vector3i(-2 + s, 8 + s, -1), Vector3i(10 - s, 8 + s, 8), Blocks.ROOF_TERRACOTTA)
		if s < 5:
			_fill(o, Vector3i(s, 8 + s, 7), Vector3i(8 - s, 8 + s, 7), F)
	_put(o + Vector3i(4, 9, 7), Blocks.WINDOW_BOTTOM)
	_put(o + Vector3i(4, 10, 7), Blocks.WINDOW_TOP)
	_fill(o, Vector3i(13, 9, -6), Vector3i(13, 15, -6), Blocks.BRICKS)
	# Pencereler (alt/üst yarı).
	var wins: Array = []
	for x in [1, 2, 6, 7]:
		wins.append([Vector3i(x, 1, 7)])
		wins.append([Vector3i(x, 5, 7)])
	for z in [2, 3]:
		wins.append([Vector3i(-1, 5, z)])
		wins.append([Vector3i(-9, 1, z)])
	wins.append([Vector3i(9, 5, 1)])
	for x in [-7, -6, 2, 3, 8, 9, 14, 15]:
		wins.append([Vector3i(x, 1, -10)])
		wins.append([Vector3i(x, 5, -10)])
	for z in [-7, -6]:
		for x in [-9, 17]:
			wins.append([Vector3i(x, 1, z)])
			wins.append([Vector3i(x, 5, z)])
	for x in [11, 12, 14, 15]:
		wins.append([Vector3i(x, 1, 7)])
	for z in [1, 2, 4, 5]:
		wins.append([Vector3i(17, 1, z)])
	for w: Array in wins:
		_put(o + w[0], Blocks.WINDOW_BOTTOM)
		_put(o + w[0] + Vector3i(0, 1, 0), Blocks.WINDOW_TOP)
	# Kapı aralıkları.
	for d in [Vector3i(5, 0, -1), Vector3i(9, 0, 4), Vector3i(9, 0, 5), Vector3i(13, 0, -1), Vector3i(-5, 0, -1),
			Vector3i(2, 0, -4), Vector3i(-5, 0, -4), Vector3i(9, 0, -4), Vector3i(10, 0, -4), Vector3i(-5, 0, -10)]:
		_fill(o, d, d + Vector3i(0, 2, 0), Blocks.AIR)
	for d in [Vector3i(5, 5, -1), Vector3i(9, 5, 3)]:
		_fill(o, d, d + Vector3i(0, 1, 0), Blocks.AIR)
	doors.append([Vector3(o) + Vector3(2, 0, -3.5), 0.0, true])  # banyo kapısı
	# Garaj: geniş açık kapı, üstünde beyaz lento; içinde araba.
	_fill(o, Vector3i(-7, 0, 7), Vector3i(-3, 2, 7), Blocks.AIR)
	_fill(o, Vector3i(-7, 3, 7), Vector3i(-3, 3, 7), Blocks.TRIM_WHITE)
	_car(o + Vector3i(-6, 0, 1), "araba", false, true)
	# Merdivenler: yukarı (x 7..11) ve bodruma (x 12..15), merdiven holünde.
	for k in 5:
		_fill(o, Vector3i(7 + k, 0, -9), Vector3i(7 + k, k, -8), Blocks.PLANKS)
	_fill(o, Vector3i(7, 4, -9), Vector3i(10, 4, -8), Blocks.AIR)
	for k in range(1, 5):
		_fill(o, Vector3i(11 + k, -k, -9), Vector3i(11 + k, -1, -8), Blocks.AIR)
		_fill(o, Vector3i(11 + k, -1 - k, -9), Vector3i(11 + k, -1 - k, -8), Blocks.PLANKS)
	# Giriş: açılan ahşap kapı (film_studio), beyaz kapı söveleri; üstünde balkon.
	_fill(o, Vector3i(4, 0, 7), Vector3i(4, 2, 7), Blocks.AIR)
	_fill(o, Vector3i(3, 0, 7), Vector3i(3, 3, 7), Blocks.TRIM_WHITE)
	_fill(o, Vector3i(5, 0, 7), Vector3i(5, 3, 7), Blocks.TRIM_WHITE)
	_put(o + Vector3i(4, 3, 7), Blocks.TRIM_WHITE)
	doors.append([Vector3(o) + Vector3(4, 0, 7.5), 0.0])
	for x in [3, 4, 5]:
		_put(o + Vector3i(x, 5, 7), Blocks.WINDOW_BOTTOM)
		_put(o + Vector3i(x, 6, 7), Blocks.WINDOW_TOP)
		_put(o + Vector3i(x, 4, 8), Blocks.TRIM_WHITE)
		_put(o + Vector3i(x, 5, 8), Blocks.BALCONY_RAIL)
	# Salon: koltuk, sehpa, televizyon, halı.
	_prop(o, "koltuk", Vector3i(11, 0, 0), Vector2i(3, 1))
	_prop(o, "sehpa", Vector3i(11, 0, 2), Vector2i(3, 1))
	_prop(o, "tv", Vector3i(11, 0, 6), Vector2i(3, 1))
	_fill(o, Vector3i(10, -1, 1), Vector3i(14, -1, 4), Blocks.RUG)
	_fill(o, Vector3i(16, 0, 0), Vector3i(16, 1, 1), Blocks.BOOKSHELF)
	# Banyo: küvet, lavabo, klozet.
	_prop(o, "kuvet", Vector3i(0, 0, -9), Vector2i(2, 1))
	_prop(o, "lavabo", Vector3i(3, 0, -9), Vector2i(1, 1))
	_prop(o, "klozet", Vector3i(4, 0, -9), Vector2i(1, 1))
	# Çamaşır odası: çamaşır ve kurutma makinesi, raf; arka bahçe kapısı.
	_prop(o, "camasir_makinesi", Vector3i(-8, 0, -9), Vector2i(1, 1))
	_prop(o, "camasir_makinesi", Vector3i(-7, 0, -9), Vector2i(1, 1))
	_fill(o, Vector3i(-3, 0, -9), Vector3i(-2, 1, -9), Blocks.BOOKSHELF)
	# Üst kat: anne-babanın yatak odası (ön blok), oyun köşesi (arka kanat).
	_prop(o, "cift_yatak", Vector3i(3, 5, 1), Vector2i(2, 2))
	_prop(o, "ayna", Vector3i(8, 5, 4), Vector2i(1, 1), -PI / 2)
	_decor(o, "tablo", Vector3(4.0, 7.2, 0.03), 0.0)
	_decor(o, "perde", Vector3(1.5, 6.55, 6.96), PI)
	_decor(o, "perde", Vector3(6.5, 6.55, 6.96), PI)
	_prop(o, "komodin", Vector3i(2, 5, 0), Vector2i(1, 1))
	_prop(o, "komodin", Vector3i(5, 5, 0), Vector2i(1, 1))
	_prop(o, "gardirop", Vector3i(0, 5, 4), Vector2i(1, 2))
	_fill(o, Vector3i(1, 4, 3), Vector3i(6, 4, 5), Blocks.RUG)
	_prop(o, "koltuk", Vector3i(-6, 5, -9), Vector2i(3, 1))
	_fill(o, Vector3i(0, 5, -9), Vector3i(3, 6, -9), Blocks.BOOKSHELF)
	# Teras: masa ve saksı çiçekler.
	_prop(o, "yemek_masasi", Vector3i(13, 5, 3), Vector2i(1, 1))
	_prop(o, "semsiye", Vector3i(13, 5, 3), Vector2i(1, 1))
	_prop(o, "sandalye", Vector3i(12, 5, 3), Vector2i(1, 1), PI / 2)
	_prop(o, "sandalye", Vector3i(14, 5, 3), Vector2i(1, 1), -PI / 2)
	for p in [Vector3i(10, 5, 6), Vector3i(16, 5, 6), Vector3i(16, 5, 0), Vector3i(10, 5, 0)]:
		_prop(o, "saksi", p, Vector2i(1, 1))
	# Bodrum: sandıklar ve raflar.
	_fill(o, Vector3i(0, -4, -9), Vector3i(2, -4, -9), Blocks.CHEST)
	_fill(o, Vector3i(4, -4, -9), Vector3i(8, -3, -9), Blocks.BOOKSHELF)
	_fill(o, Vector3i(0, -4, -3), Vector3i(1, -4, -2), Blocks.CHEST)
	_prop(o, "kiler_rafi", Vector3i(0, -4, -7), Vector2i(1, 2), PI / 2)
	_prop(o, "kiler_rafi", Vector3i(9, -4, -9), Vector2i(2, 1))
	for k in [Vector3i(2, -4, -3), Vector3i(3, -4, -2), Vector3i(6, -4, -2), Vector3i(4, -4, -7)]:
		_prop(o, "koli", k, Vector2i(1, 1))
	for l in [Vector3i(8, -2, -3), Vector3i(1, -2, -5), Vector3i(8, -2, -8)]:
		_put(o + l, Blocks.LANTERN)
	# Banyo: fayanslı duvarlar, duş, havluluk; salon: berjer, bitkiler, tablo; mutfak: üst dolap, sandalyeler.
	for w in [[Vector3i(-1, 0, -9), Vector3i(-1, 1, -5)], [Vector3i(5, 0, -9), Vector3i(5, 1, -5)], [Vector3i(0, 0, -4), Vector3i(4, 1, -4)]]:
		_fill(o, w[0], w[1], Blocks.TILE_BATH)
	_fill(o, Vector3i(2, 0, -4), Vector3i(2, 1, -4), Blocks.AIR)
	_prop(o, "dus", Vector3i(0, 0, -6), Vector2i(1, 2))
	_prop(o, "havluluk", Vector3i(4, 0, -6), Vector2i(1, 1), -PI / 2)
	_fill(o, Vector3i(1, -1, -7), Vector3i(3, -1, -6), Blocks.RUG)
	_prop(o, "berjer", Vector3i(16, 0, 3), Vector2i(1, 1), -PI / 2)
	_prop(o, "bitki", Vector3i(16, 0, 6), Vector2i(1, 1))
	_prop(o, "bitki", Vector3i(10, 0, 0), Vector2i(1, 1))
	_decor(o, "poster", Vector3(16.97, 1.6, 4.5), -PI / 2)
	# Salon takımı: vitrin, abajur, tablo, perdeler, saat.
	_prop(o, "vitrin", Vector3i(14, 0, 6), Vector2i(2, 1))
	_prop(o, "abajur", Vector3i(14, 0, 0), Vector2i(1, 1))
	_decor(o, "tablo_kucuk", Vector3(13.0, 2.4, 6.97), PI)
	_decor(o, "perde", Vector3(11.5, 1.55, 6.96), PI)
	_decor(o, "duvar_saati", Vector3(9.03, 2.7, 2.0), PI / 2)
	# Emir'in odası ve mutfak: perdeler, tablo.
	_decor(o, "perde", Vector3(1.5, 1.55, 6.96), PI)
	_decor(o, "perde", Vector3(6.5, 1.55, 6.96), PI)
	_decor(o, "tablo_kucuk", Vector3(8.97, 2.4, 3.0), -PI / 2)
	# Emir'in çalışma masasında bilgisayar; salonda pufler; banyoda ayna.
	_decor(o, "bilgisayar", Vector3(2.0, 0.8, 6.55), PI)
	_prop(o, "puf", Vector3i(14, 0, 3), Vector2i(1, 1))
	_prop(o, "puf", Vector3i(15, 0, 2), Vector2i(1, 1))
	_decor(o, "ayna_duvar", Vector3(3.5, 1.8, -8.97), 0.0)
	# Garaj: alet tezgâhı ve panosu, bisiklet, raf.
	_prop(o, "alet_tezgahi", Vector3i(-3, 0, 0), Vector2i(2, 1))
	_prop(o, "bisiklet", Vector3i(-8, 0, 2), Vector2i(1, 2))
	_prop(o, "kiler_rafi", Vector3i(-8, 0, 5), Vector2i(1, 2), PI / 2)
	# Teras: teleskop ve şezlong.
	_prop(o, "teleskop", Vector3i(15, 5, 1), Vector2i(1, 1), PI)
	_prop(o, "sezlong", Vector3i(11, 5, 4), Vector2i(1, 2), PI)
	# Bodrum: dağınık koliler, eski bisiklet.
	for k in [Vector3i(12, -4, -5), Vector3i(13, -4, -5), Vector3i(10, -4, -3), Vector3i(6, -4, -5)]:
		_prop(o, "koli", k, Vector2i(1, 1))
	_prop(o, "ust_dolap", Vector3i(6, 0, 0), Vector2i(3, 1))
	_prop(o, "sandalye", Vector3i(4, 0, 3), Vector2i(1, 1), PI / 2)
	_prop(o, "sandalye", Vector3i(6, 0, 3), Vector2i(1, 1), -PI / 2)
	# Işıklar.
	for l in [Vector3i(13, 3, 3), Vector3i(-1, 3, -3), Vector3i(9, 3, -3), Vector3i(2, 3, -7), Vector3i(-5, 3, -7),
			Vector3i(-5, 3, 3), Vector3i(14, 3, -7), Vector3i(4, -2, -6), Vector3i(12, -2, -3), Vector3i(4, 7, 3),
			Vector3i(-3, 7, -6), Vector3i(8, 7, -3)]:
		_put(o + l, Blocks.LANTERN)
	# Arsa: çit (yol ve garaj yolu açık), garaj yolu, yan bahçe (ağaçlar, çiçek tarhı, salıncak).
	for x in range(-10, 26):
		if x != 4 and (x < -7 or x > -3):
			_put(o + Vector3i(x, 0, 22), Blocks.FENCE_WHITE)
		if x != -5:
			_put(o + Vector3i(x, 0, -11), Blocks.FENCE_WHITE)
	for z in range(-11, 23):
		_put(o + Vector3i(-10, 0, z), Blocks.FENCE_WHITE)
		_put(o + Vector3i(25, 0, z), Blocks.FENCE_WHITE)
	_fill(o, Vector3i(-7, -1, 8), Vector3i(-3, -1, 22), Blocks.CONCRETE)
	for t in [Vector3i(21, 0, -7), Vector3i(23, 0, 3), Vector3i(20, 0, 17), Vector3i(-7, 0, 16)]:
		_tree(o + t)
	for z in range(0, 7):
		_put(o + Vector3i(18, 0, z), Blocks.FLOWERS)
	_fill(o, Vector3i(19, 0, 11), Vector3i(19, 3, 11), Blocks.LOG)
	_fill(o, Vector3i(22, 0, 11), Vector3i(22, 3, 11), Blocks.LOG)
	_fill(o, Vector3i(19, 4, 11), Vector3i(22, 4, 11), Blocks.PLANKS)
	_prop(o, "sehpa", Vector3i(20, 0, 11), Vector2i(2, 1))
	_prop(o, "yemek_masasi", Vector3i(21, 0, -2), Vector2i(1, 1))
	# Emir'in odası: yatak, kitaplık, sandık.
	_put(o + Vector3i(1, 0, 1), Blocks.BED)
	_put(o + Vector3i(1, 0, 2), Blocks.BED)
	_fill(o, Vector3i(2, 0, 0), Vector3i(3, 1, 0), Blocks.BOOKSHELF)
	# Minecraft sandık/çalışma masası yerine gerçek ev eşyaları (bkz. PROPS, film_props.gd).
	_prop(o, "gardirop", Vector3i(0, 0, 5), Vector2i(1, 2))
	_prop(o, "calisma_masasi", Vector3i(1, 0, 6), Vector2i(2, 1))
	_prop(o, "komodin", Vector3i(1, 0, 0), Vector2i(1, 1))
	_prop(o, "oyuncak_kutusu", Vector3i(0, 0, 3), Vector2i(1, 1))
	# Duvar ve zemin süsleri (yürümeyi engellemez): poster, saat, top, oda halısı.
	_decor(o, "poster", Vector3(0.02, 1.5, 3.6), PI / 2)
	_decor(o, "duvar_saati", Vector3(2.0, 2.5, 0.02), 0.0)
	_decor(o, "futbol_topu", Vector3(3.3, 0, 3.6), 0.0)
	_decor(o, "oda_halisi", Vector3(1.2, 0, 3.0), 0.0)
	# Mutfak: tezgah, ocak, buzdolabı.
	_prop(o, "mutfak_tezgahi", Vector3i(6, 0, 0), Vector2i(2, 1))
	_prop(o, "ocak", Vector3i(8, 0, 0), Vector2i(1, 1))
	_prop(o, "buzdolabi", Vector3i(8, 0, 1), Vector2i(1, 1))
	# Oturma alanı: yemek masası ve kırmızı halı.
	_prop(o, "yemek_masasi", Vector3i(5, 0, 3), Vector2i(1, 1))
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
	# Market rafları (gerçek raf, Minecraft sandığı değil).
	_prop(o, "market_rafi", Vector3i(0, 0, 1), Vector2i(1, 7))
	for z in range(4, 7):
		_put(o + Vector3i(10, 0, z), Blocks.GLASS)
		_put(o + Vector3i(10, 1, z), Blocks.TOY_BRICK_BLUE)
	_put(o + Vector3i(5, 2, 0), Blocks.LANTERN)
	_put(o + Vector3i(0, 2, 8), Blocks.LANTERN)
	for z in range(10, 14):
		_put(o + Vector3i(5, -1, z), Blocks.GRAVEL)
	# Arka duvarda renkli ürün rafları, kapıda paspas, önde saksı çiçekleri.
	_prop(o, "market_rafi", Vector3i(1, 0, 0), Vector2i(9, 1), 0.0)
	_put(o + Vector3i(5, -1, 8), Blocks.RUG)
	for x in [2, 3, 7, 8]:
		_put(o + Vector3i(x, 0, 11), Blocks.FLOWERS)
	# İçecek dolabı, kasa, meyve reyonu, koliler, duvarda saat.
	_prop(o, "icecek_dolabi", Vector3i(10, 0, 1), Vector2i(1, 2))
	_prop(o, "kasa", Vector3i(7, 0, 2), Vector2i(1, 1), PI)
	_prop(o, "meyve_reyonu", Vector3i(7, 0, 7), Vector2i(2, 1), 0.0)
	_prop(o, "koli", Vector3i(9, 0, 1), Vector2i(1, 1))
	_prop(o, "bitki", Vector3i(1, 0, 8), Vector2i(1, 1))
	_decor(o, "duvar_saati", Vector3(5.0, 2.6, 0.03), 0.0)


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
	# Yerin altı da oyulmuşsa (bodrum) havadır.
	var b: int = _blocks.get(cell, -1)
	return (b == Blocks.AIR or (b == -1 and cell.y > GROUND)) and not _prop_cells.has(cell)


## İki nokta arası bloklara çarpmadan görülebiliyor mu (kamera kadrajı için).
func clear_sight(a: Vector3, b: Vector3) -> bool:
	var n := int(ceil(a.distance_to(b) * 4.0))
	for i in range(1, n):
		if not is_air(Vector3i((a.lerp(b, float(i) / n)).floor())):
			return false
	return true


func is_free(cell: Vector3i) -> bool:
	return is_air(cell) and is_air(cell + Vector3i.UP)


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
const CAR_COLORS := ["araba", "araba_mavi", "araba_sari", "araba_beyaz", "araba_siyah", "araba_yesil"]
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
	_row(Vector2i(-40, 32), Vector2i(-20, 32), -1)  # batısında öğretmenin evi
	_bazaar(SETS["pazar"])
	# x 35..72: Ali'nin ve Zeynep'in evleri (karakter evleri).
	_playground(SETS["oyun"])
	# Güney sırası.
	_row(Vector2i(-62, -40), Vector2i(-20, -40), 1)
	_mosque(Vector3i(-6, Y0, -54))
	_row(Vector2i(14, -40), Vector2i(24, -40), 1)
	_row(Vector2i(35, -40), Vector2i(72, -40), 1)
	_row(Vector2i(83, -40), Vector2i(98, -40), 1)
	# Setlerin aralarındaki boş parseller.
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


## Araba (gerçek model, film_props): 2 blok geniş, 4 blok uzun. along_x: yol doğu-batı.
func _car(p: Vector3i, id: String, along_x: bool, back := false) -> void:
	var turn := (PI / 2 if along_x else 0.0) + (PI if back else 0.0)
	_prop(Vector3i.ZERO, id, p, Vector2i(4, 2) if along_x else Vector2i(2, 4), turn)


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


# ---------------------------------------------------------------------------
# Gerçekçi bina yardımcıları (okul, market, lokanta, pastane, hastane, otopark).

## Kat yüksekliği: 4 blok oda + 1 blok döşeme. Kat f'de zemin y = f * STOREY.
const STOREY := 5


## Bina kabuğu: dış duvarlar a..b (yerel x,z; duvar dahil), floors kat. Taş kaide, beyaz kat silmeleri
## ve köşeler, her 3 bloğun ikisinde pencere, kat döşemeleri, düz çatı ve korkuluk, tavanlarda fener.
func _shell(o: Vector3i, a: Vector2i, b: Vector2i, floors: int, wall: int, floor_block: int) -> void:
	var h := floors * STOREY
	_fill(o, Vector3i(a.x, -1, a.y), Vector3i(b.x, -1, b.y), Blocks.STONE_BASE)
	_fill(o, Vector3i(a.x + 1, -1, a.y + 1), Vector3i(b.x - 1, -1, b.y - 1), floor_block)
	_walls(o, Vector3i(a.x, 0, a.y), Vector3i(b.x, h - 1, b.y), wall)
	_walls(o, Vector3i(a.x, 0, a.y), Vector3i(b.x, 0, b.y), Blocks.STONE_BASE)
	for f in floors:
		var y0 := f * STOREY
		var slab := y0 + STOREY - 1
		_fill(o, Vector3i(a.x, slab, a.y), Vector3i(b.x, slab, b.y), Blocks.CONCRETE if f == floors - 1 else Blocks.PLANKS)
		_walls(o, Vector3i(a.x, slab, a.y), Vector3i(b.x, slab, b.y), Blocks.TRIM_WHITE)
		if f > 0:
			_fill(o, Vector3i(a.x + 1, y0 - 1, a.y + 1), Vector3i(b.x - 1, y0 - 1, b.y - 1), floor_block)
		for x in range(a.x + 1, b.x):
			if posmod(x - a.x, 3) != 0:
				_win(o, Vector3i(x, y0 + 1, a.y))
				_win(o, Vector3i(x, y0 + 1, b.y))
		for z in range(a.y + 1, b.y):
			if posmod(z - a.y, 3) != 0:
				_win(o, Vector3i(a.x, y0 + 1, z))
				_win(o, Vector3i(b.x, y0 + 1, z))
		for z in range(a.y + 1, b.y):
			for x in range(a.x + 1, b.x):
				if posmod(x - a.x, 4) == 2 and posmod(z - a.y, 4) == 2:
					_put(o + Vector3i(x, y0 + 3, z), Blocks.LANTERN)
	for c in [Vector2i(a.x, a.y), Vector2i(b.x, a.y), Vector2i(a.x, b.y), Vector2i(b.x, b.y)]:
		_fill(o, Vector3i(c.x, 1, c.y), Vector3i(c.x, h - 1, c.y), Blocks.TRIM_WHITE)
	_walls(o, Vector3i(a.x, h, a.y), Vector3i(b.x, h, b.y), Blocks.BALCONY_RAIL)


func _win(o: Vector3i, p: Vector3i) -> void:
	_put(o + p, Blocks.WINDOW_BOTTOM)
	_put(o + p + Vector3i(0, 1, 0), Blocks.WINDOW_TOP)


## İç duvar (sıva): from..to, bir kat yüksekliğinde (from.y'den 4 blok).
func _iwall(o: Vector3i, from: Vector3i, to: Vector3i, block := Blocks.PLASTER) -> void:
	_fill(o, from, Vector3i(to.x, from.y + STOREY - 2, to.z), block)


## Kapı: 3 blok yüksek boşluk ve açılır kapı. along_x: duvar x boyunca (z sabit).
## outer: bina giriş kapısı (ahşap); diğerleri iç kapı (beyaz, kapi_ic).
func _door(o: Vector3i, p: Vector3i, along_x: bool, swing := true, outer := false) -> void:
	_fill(o, p, p + Vector3i(0, 2, 0), Blocks.AIR)
	if swing:
		if along_x:
			doors.append([Vector3(o) + Vector3(p.x, p.y, p.z + 0.5), 0.0, not outer])
		else:
			doors.append([Vector3(o) + Vector3(p.x + 0.5, p.y, p.z), -PI / 2, not outer])


## Tente: x0..x1 boyunca, z'de, y yüksekliğinde iki renkli çizgili.
func _awning(o: Vector3i, x0: int, x1: int, y: int, z: int, color: int) -> void:
	for x in range(x0, x1 + 1):
		_put(o + Vector3i(x, y, z), color if posmod(x, 2) == 0 else Blocks.SNOW)


## Masa ve dört yanında sandalye (masa 2x1, x boyunca).
func _table4(o: Vector3i, at: Vector3i) -> void:
	_prop(o, "yemek_masasi", at, Vector2i(2, 1))
	for dx in 2:
		_prop(o, "sandalye", at + Vector3i(dx, 0, -1), Vector2i(1, 1))
		_prop(o, "sandalye", at + Vector3i(dx, 0, 1), Vector2i(1, 1), PI)


## Okul: iki katlı tuğla bina (dış x -1..25, z -9..11). Zemin: A sınıfı x0..14 z0..10, koridor x16..17
## (merdiven x17 z -8..-4), arka koridor z -3..-2, tuvalet x0..6 ve müdür odası x8..14 (z -8..-5),
## kantin x19..24 z0..10, öğretmenler odası x19..24 z -8..-2. Üst kat: B sınıfı, resim odası, kütüphane.
## Önde bahçe (bayrak, kaydırak, kum havuzu), batıda basketbol sahası; çevre çitli.
func _build_school(o: Vector3i) -> void:
	_shell(o, Vector2i(-1, -9), Vector2i(25, 11), 2, Blocks.BRICKS, Blocks.DARK_PLANKS)
	for f in 2:
		var y := f * STOREY
		_iwall(o, Vector3i(15, y, -1), Vector3i(15, y, 10))
		_iwall(o, Vector3i(18, y, -8), Vector3i(18, y, 10))
		_iwall(o, Vector3i(0, y, -1), Vector3i(14, y, -1))
	# Zemin kat odaları.
	_iwall(o, Vector3i(15, 0, -8), Vector3i(15, 0, -4))
	_iwall(o, Vector3i(0, 0, -4), Vector3i(14, 0, -4))
	_iwall(o, Vector3i(7, 0, -8), Vector3i(7, 0, -5))
	_iwall(o, Vector3i(19, 0, -1), Vector3i(24, 0, -1))
	_fill(o, Vector3i(0, -1, -8), Vector3i(6, -1, -5), Blocks.TILE_BATH)
	_fill(o, Vector3i(16, -1, -8), Vector3i(17, -1, 10), Blocks.SIDEWALK)
	_fill(o, Vector3i(0, -1, -3), Vector3i(14, -1, -2), Blocks.SIDEWALK)
	_door(o, Vector3i(15, 0, 5), false)
	_door(o, Vector3i(7, 0, 11), true, true, true)
	_door(o, Vector3i(16, 0, 11), true, true, true)
	_door(o, Vector3i(17, 0, 11), true, false)
	_door(o, Vector3i(3, 0, -4), true)
	_door(o, Vector3i(11, 0, -4), true)
	_door(o, Vector3i(18, 0, -5), false)
	_fill(o, Vector3i(18, 0, 2), Vector3i(18, 2, 3), Blocks.AIR)
	# Üst kat odaları.
	_iwall(o, Vector3i(15, 5, -8), Vector3i(15, 5, -2))
	_door(o, Vector3i(15, 5, 5), false)
	_door(o, Vector3i(15, 5, -5), false)
	_fill(o, Vector3i(18, 5, 2), Vector3i(18, 7, 3), Blocks.AIR)
	# Merdiven (x17, güneye doğru çıkar).
	for k in 5:
		_fill(o, Vector3i(17, 0, -4 - k), Vector3i(17, k, -4 - k), Blocks.PLANKS)
	_fill(o, Vector3i(17, 4, -7), Vector3i(17, 4, -4), Blocks.AIR)
	_fill(o, Vector3i(17, 5, -7), Vector3i(17, 7, -4), Blocks.AIR)
	# A sınıfı: kara tahta, öğretmen masası, sıralar, kitaplıklar, pano, saat.
	_fill(o, Vector3i(4, 1, -1), Vector3i(11, 2, -1), Blocks.BEDROCK)
	_prop(o, "ogretmen_masasi", Vector3i(7, 0, 2), Vector2i(2, 1))
	for at in [Vector3i(3, 0, 4), Vector3i(9, 0, 4), Vector3i(3, 0, 7), Vector3i(9, 0, 7)]:
		_prop(o, "sira", at, Vector2i(3, 1))
	_fill(o, Vector3i(0, 0, 1), Vector3i(0, 1, 3), Blocks.BOOKSHELF)
	_fill(o, Vector3i(14, 0, 1), Vector3i(14, 1, 3), Blocks.BOOKSHELF)
	_fill(o, Vector3i(1, 1, 10), Vector3i(4, 2, 10), Blocks.PLAYROOM_WALL)
	_decor(o, "duvar_saati", Vector3(7.5, 3.3, 0.02), 0.0)
	_decor(o, "poster", Vector3(0.02, 1.6, 7.5), PI / 2)
	# Kantin: tezgâh, buzdolabı, masalar.
	_prop(o, "mutfak_tezgahi", Vector3i(20, 0, 0), Vector2i(4, 1))
	_prop(o, "buzdolabi", Vector3i(24, 0, 1), Vector2i(1, 1))
	_prop(o, "icecek_dolabi", Vector3i(24, 0, 2), Vector2i(1, 1))
	_table4(o, Vector3i(20, 0, 5))
	_table4(o, Vector3i(20, 0, 8))
	_table4(o, Vector3i(23, 0, 5))
	# Öğretmenler odası: toplantı masası, kitaplık.
	_prop(o, "yemek_masasi", Vector3i(20, 0, -6), Vector2i(3, 2))
	for x in range(20, 23):
		_prop(o, "sandalye", Vector3i(x, 0, -7), Vector2i(1, 1))
		_prop(o, "sandalye", Vector3i(x, 0, -4), Vector2i(1, 1), PI)
	_fill(o, Vector3i(24, 0, -8), Vector3i(24, 1, -6), Blocks.BOOKSHELF)
	_prop(o, "bitki", Vector3i(24, 0, -2), Vector2i(1, 1))
	# Müdür odası.
	_prop(o, "ogretmen_masasi", Vector3i(10, 0, -7), Vector2i(2, 1))
	_prop(o, "koltuk", Vector3i(12, 0, -8), Vector2i(2, 1))
	_fill(o, Vector3i(14, 0, -8), Vector3i(14, 1, -6), Blocks.BOOKSHELF)
	_prop(o, "bitki", Vector3i(8, 0, -8), Vector2i(1, 1))
	_fill(o, Vector3i(9, -1, -6), Vector3i(13, -1, -5), Blocks.RUG)
	# Tuvaletler.
	_prop(o, "lavabo", Vector3i(1, 0, -8), Vector2i(1, 1))
	_prop(o, "lavabo", Vector3i(2, 0, -8), Vector2i(1, 1))
	_prop(o, "klozet", Vector3i(4, 0, -8), Vector2i(1, 1))
	_prop(o, "klozet", Vector3i(6, 0, -8), Vector2i(1, 1))
	_fill(o, Vector3i(5, 0, -8), Vector3i(5, 1, -7), Blocks.PLASTER)
	# B sınıfı (üst kat).
	_fill(o, Vector3i(4, 6, -1), Vector3i(11, 7, -1), Blocks.BEDROCK)
	_prop(o, "ogretmen_masasi", Vector3i(7, 5, 2), Vector2i(2, 1))
	for at in [Vector3i(3, 5, 4), Vector3i(9, 5, 4), Vector3i(3, 5, 7), Vector3i(9, 5, 7)]:
		_prop(o, "sira", at, Vector2i(3, 1))
	_decor(o, "duvar_saati", Vector3(7.5, 8.3, 0.02), 0.0)
	# Resim odası.
	_prop(o, "yemek_masasi", Vector3i(2, 5, -7), Vector2i(3, 2))
	_prop(o, "yemek_masasi", Vector3i(9, 5, -7), Vector2i(3, 2))
	_fill(o, Vector3i(1, 6, -9), Vector3i(13, 7, -9), Blocks.PLAYROOM_WALL)
	_prop(o, "oyuncak_kutusu", Vector3i(14, 5, -3), Vector2i(1, 1))
	# Kütüphane.
	_fill(o, Vector3i(24, 5, -8), Vector3i(24, 6, 10), Blocks.BOOKSHELF)
	_fill(o, Vector3i(22, 5, -7), Vector3i(22, 6, -3), Blocks.BOOKSHELF)
	_prop(o, "yemek_masasi", Vector3i(20, 5, 4), Vector2i(3, 2))
	for x in range(20, 23):
		_prop(o, "sandalye", Vector3i(x, 5, 3), Vector2i(1, 1))
		_prop(o, "sandalye", Vector3i(x, 5, 6), Vector2i(1, 1), PI)
	_fill(o, Vector3i(19, 4, 8), Vector3i(23, 4, 10), Blocks.RUG)
	# Bahçe: yollar, bayrak direği, kaydırak, kum havuzu, çiçekler, ağaçlar.
	_fill(o, Vector3i(16, -1, 12), Vector3i(17, -1, 22), Blocks.COBBLESTONE)
	_fill(o, Vector3i(7, -1, 12), Vector3i(7, -1, 22), Blocks.GRAVEL)
	_fill(o, Vector3i(12, 0, 15), Vector3i(12, 7, 15), Blocks.TRIM_WHITE)
	_fill(o, Vector3i(13, 5, 15), Vector3i(14, 7, 15), Blocks.TOY_BRICK_RED)
	for i in 4:
		_fill(o, Vector3i(20, 0, 16 + i), Vector3i(20, 3 - i, 16 + i), Blocks.TOY_BRICK_RED)
	_fill(o, Vector3i(21, 0, 16), Vector3i(21, 3, 16), Blocks.TOY_BRICK_BLUE)
	_fill(o, Vector3i(0, -1, 16), Vector3i(4, -1, 20), Blocks.SAND)
	for x in [0, 1, 2, 3, 4, 5, 9, 10, 11, 13, 14, 19, 20, 21, 22, 23]:
		_put(o + Vector3i(x, 0, 12), Blocks.FLOWERS)
	for tr in [Vector3i(24, 0, 20), Vector3i(10, 0, 20)]:
		_tree(o + tr)
	_prop(o, "bank", Vector3i(9, 0, 17), Vector2i(2, 1), PI)
	# Basketbol sahası (batı).
	_fill(o, Vector3i(-13, -1, -7), Vector3i(-3, -1, 10), Blocks.CONCRETE)
	_walls(o, Vector3i(-12, -1, -6), Vector3i(-4, -1, 9), Blocks.SNOW)
	_fill(o, Vector3i(-12, -1, 1), Vector3i(-4, -1, 2), Blocks.SNOW)
	_fill(o, Vector3i(-11, -1, -5), Vector3i(-5, -1, 0), Blocks.CONCRETE)
	_fill(o, Vector3i(-11, -1, 3), Vector3i(-5, -1, 8), Blocks.CONCRETE)
	_prop(o, "basket_potasi", Vector3i(-8, 0, -7), Vector2i(1, 1))
	_prop(o, "basket_potasi", Vector3i(-8, 0, 10), Vector2i(1, 1), PI)
	_prop(o, "bank", Vector3i(-2, 0, -2), Vector2i(1, 3), -PI / 2)
	# Çit (önde iki giriş).
	for x in range(-14, 26):
		if x != 7 and x != 16 and x != 17:
			_put(o + Vector3i(x, 0, 22), Blocks.FENCE_WHITE)
		_put(o + Vector3i(x, 0, -10), Blocks.FENCE_WHITE)
	for z in range(-10, 23):
		_put(o + Vector3i(-14, 0, z), Blocks.FENCE_WHITE)


## Süpermarket (dış x 0..12, z -3..13; ön cephe kuzeye, caddeye): camlı vitrin, otomatik kapı,
## reyonlar, meyve sebze, içecek dolapları, iki kasa, arkada depo.
func _build_market(o: Vector3i) -> void:
	_shell(o, Vector2i(0, -3), Vector2i(12, 13), 1, Blocks.FACADE_CREAM, Blocks.TILE_BATH)
	_fill(o, Vector3i(1, 0, 13), Vector3i(11, 2, 13), Blocks.GLASS)
	_fill(o, Vector3i(2, 0, 13), Vector3i(3, 2, 13), Blocks.AIR)
	_awning(o, 0, 12, 3, 14, Blocks.TOY_BRICK_BLUE)
	_fill(o, Vector3i(3, 4, 13), Vector3i(9, 4, 13), Blocks.TOY_BRICK_RED)  # tabela
	_iwall(o, Vector3i(1, 0, 1), Vector3i(11, 0, 1))
	_door(o, Vector3i(6, 0, 1), true)
	_fill(o, Vector3i(1, -1, -2), Vector3i(11, -1, 0), Blocks.CONCRETE)
	for x in range(3, 10, 3):
		_prop(o, "market_rafi", Vector3i(x, 0, 3), Vector2i(1, 6))
	_prop(o, "meyve_reyonu", Vector3i(1, 0, 3), Vector2i(1, 5))
	_prop(o, "icecek_dolabi", Vector3i(11, 0, 3), Vector2i(1, 6))
	_prop(o, "kasa", Vector3i(4, 0, 10), Vector2i(2, 1))
	_prop(o, "kasa", Vector3i(8, 0, 10), Vector2i(2, 1))
	# Depo: sandıklar ve koliler.
	_fill(o, Vector3i(1, 0, -2), Vector3i(3, 1, -2), Blocks.CHEST)
	for k in [Vector3i(8, 0, -2), Vector3i(9, 0, -2), Vector3i(10, 0, -2), Vector3i(10, 0, 0)]:
		_prop(o, "koli", k, Vector2i(1, 1))
	# Önde kaldırım ve saksılar.
	_fill(o, Vector3i(0, -1, 14), Vector3i(12, -1, 17), Blocks.SIDEWALK)
	_prop(o, "saksi", Vector3i(0, 0, 14), Vector2i(1, 1))
	_prop(o, "saksi", Vector3i(12, 0, 14), Vector2i(1, 1))


## Lokanta (dış x 0..14, z 0..12; kapı güneyde, caddeye): yemek salonu (masalar ve sandalyeler),
## servis penceresi, arkada mutfak (ocak, tezgâh, buzdolabı).
func _build_restaurant(o: Vector3i) -> void:
	_shell(o, Vector2i(0, 0), Vector2i(14, 12), 1, Blocks.BRICKS, Blocks.DARK_PLANKS)
	_door(o, Vector3i(7, 0, 0), true, true, true)
	_awning(o, 3, 11, 3, -1, Blocks.TOY_BRICK_RED)
	_fill(o, Vector3i(5, 4, 0), Vector3i(9, 4, 0), Blocks.TOY_BRICK_YELLOW)  # tabela
	_iwall(o, Vector3i(1, 0, 8), Vector3i(13, 0, 8))
	_fill(o, Vector3i(4, 1, 8), Vector3i(5, 2, 8), Blocks.AIR)
	_fill(o, Vector3i(4, 0, 8), Vector3i(5, 0, 8), Blocks.DARK_PLANKS)
	_door(o, Vector3i(11, 0, 8), true)
	_fill(o, Vector3i(1, -1, 9), Vector3i(13, -1, 11), Blocks.TILE_BATH)
	for x in [2, 6, 10]:
		_table4(o, Vector3i(x, 0, 3))
		_table4(o, Vector3i(x, 0, 6))
	_prop(o, "ocak", Vector3i(1, 0, 11), Vector2i(1, 1), PI)
	_prop(o, "mutfak_tezgahi", Vector3i(2, 0, 11), Vector2i(3, 1), PI)
	_prop(o, "ocak", Vector3i(5, 0, 11), Vector2i(1, 1), PI)
	_prop(o, "mutfak_tezgahi", Vector3i(6, 0, 11), Vector2i(3, 1), PI)
	_prop(o, "buzdolabi", Vector3i(13, 0, 10), Vector2i(1, 1))
	_prop(o, "icecek_dolabi", Vector3i(13, 0, 1), Vector2i(1, 1))
	_prop(o, "bitki", Vector3i(1, 0, 1), Vector2i(1, 1))
	_decor(o, "poster", Vector3(0.02, 1.6, 5.0), PI / 2)
	_decor(o, "duvar_saati", Vector3(7.0, 2.6, 7.98), PI)


## Pastane (dış x 0..7, z 0..9; kapı güneyde): pasta vitrini, kasa, fırın, ekmek rafları, iki masa.
func _build_bakery(o: Vector3i) -> void:
	_shell(o, Vector2i(0, 0), Vector2i(7, 9), 1, Blocks.FACADE_CREAM, Blocks.TILE_BATH)
	_door(o, Vector3i(3, 0, 0), true, true, true)
	_fill(o, Vector3i(5, 0, 0), Vector3i(6, 2, 0), Blocks.GLASS)
	_awning(o, 0, 7, 3, -1, Blocks.TOY_BRICK_RED)
	_fill(o, Vector3i(1, 0, 5), Vector3i(4, 0, 5), Blocks.GLASS)
	for x in range(1, 5):
		_put(o + Vector3i(x, -1, 5), [Blocks.TOY_BRICK_YELLOW, Blocks.TOY_BRICK_RED][x % 2])
	_prop(o, "kasa", Vector3i(5, 0, 5), Vector2i(1, 1))
	_fill(o, Vector3i(1, 0, 8), Vector3i(4, 1, 8), Blocks.BOOKSHELF)
	_prop(o, "ocak", Vector3i(6, 0, 8), Vector2i(1, 1), PI)
	_prop(o, "yemek_masasi", Vector3i(1, 0, 2), Vector2i(1, 1))
	_prop(o, "sandalye", Vector3i(1, 0, 1), Vector2i(1, 1))
	_prop(o, "sandalye", Vector3i(1, 0, 3), Vector2i(1, 1), PI)
	_prop(o, "yemek_masasi", Vector3i(5, 0, 2), Vector2i(1, 1))
	_prop(o, "sandalye", Vector3i(6, 0, 2), Vector2i(1, 1), -PI / 2)


## Hastane (dış x -1..13, z -7..9): girişte danışma ve bekleme, iki yataklı koğuş, arkada muayene
## odası ve eczane; önde ambulans.
func _build_hospital(o: Vector3i) -> void:
	_shell(o, Vector2i(-1, -7), Vector2i(13, 9), 1, Blocks.TRIM_WHITE, Blocks.TILE_BATH)
	_door(o, Vector3i(6, 0, 9), true, true, true)
	_fill(o, Vector3i(7, 0, 9), Vector3i(7, 2, 9), Blocks.GLASS)
	for c in [Vector3i(6, 4, 10), Vector3i(6, 5, 10), Vector3i(6, 6, 10), Vector3i(5, 5, 10), Vector3i(7, 5, 10)]:
		_put(o + c, Blocks.TOY_BRICK_RED)
	_iwall(o, Vector3i(0, 0, -1), Vector3i(12, 0, -1))
	_iwall(o, Vector3i(6, 0, -6), Vector3i(6, 0, -2))
	_door(o, Vector3i(3, 0, -1), true)
	_door(o, Vector3i(9, 0, -1), true)
	# Danışma, koğuş, bekleme.
	for x in range(5, 9):
		_put(o + Vector3i(x, 0, 5), Blocks.PLANKS)
	for b in [Vector3i(1, 0, 1), Vector3i(1, 0, 2), Vector3i(11, 0, 1), Vector3i(11, 0, 2)]:
		_put(o + b, Blocks.BED)
	_fill(o, Vector3i(3, 0, 0), Vector3i(3, 1, 1), Blocks.PLAYROOM_WALL)
	_fill(o, Vector3i(9, 0, 0), Vector3i(9, 1, 1), Blocks.PLAYROOM_WALL)
	for z in [5, 7]:
		_prop(o, "sandalye", Vector3i(0, 0, z), Vector2i(1, 1), PI / 2)
	_prop(o, "bitki", Vector3i(12, 0, 8), Vector2i(1, 1))
	# Koğuşta komodinler, bekleme salonunda televizyon, saksılar, tablo ve saat.
	_prop(o, "komodin", Vector3i(2, 0, 1), Vector2i(1, 1))
	_prop(o, "komodin", Vector3i(10, 0, 1), Vector2i(1, 1))
	_prop(o, "sandalye", Vector3i(0, 0, 6), Vector2i(1, 1), PI / 2)
	_prop(o, "sandalye", Vector3i(0, 0, 8), Vector2i(1, 1), PI / 2)
	_prop(o, "bitki", Vector3i(0, 0, 4), Vector2i(1, 1))
	_prop(o, "tv", Vector3i(3, 0, 8), Vector2i(2, 1), -PI / 2)
	_decor(o, "tablo", Vector3(6.5, 2.4, -0.03 + 0.06), 0.0)
	_decor(o, "duvar_saati", Vector3(12.97, 2.6, 6.0), -PI / 2)
	# Muayene odası.
	_prop(o, "ogretmen_masasi", Vector3i(1, 0, -5), Vector2i(2, 1))
	_put(o + Vector3i(5, 0, -6), Blocks.BED)
	_put(o + Vector3i(5, 0, -5), Blocks.BED)
	_prop(o, "lavabo", Vector3i(0, 0, -2), Vector2i(1, 1), PI / 2)
	# Eczane: ilaç rafları, tezgâh.
	_prop(o, "market_rafi", Vector3i(7, 0, -6), Vector2i(6, 1), 0.0)
	_prop(o, "komodin", Vector3i(3, 0, -6), Vector2i(1, 1))
	_prop(o, "bitki", Vector3i(0, 0, -6), Vector2i(1, 1))
	_decor(o, "tablo_kucuk", Vector3(3.0, 2.3, -6.97), 0.0)
	_prop(o, "bitki", Vector3i(12, 0, 4), Vector2i(1, 1))
	_prop(o, "mutfak_tezgahi", Vector3i(7, 0, -4), Vector2i(4, 1))
	_prop(o, "kasa", Vector3i(11, 0, -4), Vector2i(1, 1))
	# Bahçe yolu, çiçekler, ambulans.
	for z in range(10, 15):
		_put(o + Vector3i(6, -1, z), Blocks.GRAVEL)
	for x in [3, 4, 8]:
		_put(o + Vector3i(x, 0, 10), Blocks.FLOWERS)
	_fill(o, Vector3i(9, -1, 11), Vector3i(12, -1, 16), Blocks.ASPHALT)
	_prop(o, "ambulans", Vector3i(10, 0, 11), Vector2i(2, 4), PI)


## Otopark (yerel x 0..16, z -1..16; giriş kuzeyde): asfalt, beyaz park çizgileri, arabalar,
## bekçi kulübesi, bariyer, lambalar, alçak duvar.
func _build_parking(o: Vector3i) -> void:
	_fill(o, Vector3i(-1, -1, -2), Vector3i(17, -1, 17), Blocks.ASPHALT)
	for x in range(0, 17, 3):
		_fill(o, Vector3i(x, -1, -1), Vector3i(x, -1, 3), Blocks.ROAD_LINE)
		_fill(o, Vector3i(x, -1, 10), Vector3i(x, -1, 14), Blocks.ROAD_LINE)
	var cars := [[1, -1, "araba_mavi"], [4, -1, "araba"], [10, -1, "araba_beyaz"], [13, -1, "araba_siyah"],
			[4, 11, "araba_sari"], [7, 11, "araba_yesil"], [13, 11, "araba_mavi"]]
	for c: Array in cars:
		_car(o + Vector3i(c[0], 0, c[1]), c[2], false, c[1] > 5)
	for z in range(-2, 18):
		_put(o + Vector3i(-1, 0, z), Blocks.STONE_BASE)
		_put(o + Vector3i(17, 0, z), Blocks.STONE_BASE)
	for x in range(-1, 18):
		_put(o + Vector3i(x, 0, -2), Blocks.STONE_BASE)
	# Bekçi kulübesi ve bariyer.
	_walls(o, Vector3i(11, 0, 15), Vector3i(13, 2, 17), Blocks.TRIM_WHITE)
	_fill(o, Vector3i(11, 3, 15), Vector3i(13, 3, 17), Blocks.CONCRETE)
	_fill(o, Vector3i(12, 1, 17), Vector3i(12, 1, 17), Blocks.GLASS)
	_fill(o, Vector3i(11, 1, 16), Vector3i(11, 1, 16), Blocks.GLASS)
	_door(o, Vector3i(12, 0, 15), true, false)
	_put(o + Vector3i(12, 2, 16), Blocks.LANTERN)
	_fill(o, Vector3i(6, 0, 16), Vector3i(6, 1, 16), Blocks.STONE)
	for y in range(2, 6):
		_put(o + Vector3i(6, y, 16), Blocks.TOY_BRICK_RED if y % 2 == 0 else Blocks.SNOW)
	for l in [Vector3i(-1, 1, 6), Vector3i(17, 1, 6), Vector3i(8, 1, -2)]:
		_lamp(o + l)


## Park (yerel x 0..33, z -2..16): yürüyüş yolları, banklar, piknik örtüsü, ağaçlar, gölet ve köprü,
## fıskiyeli havuz, kameriye, dondurma büfesi, çiçek tarhları, lambalar.
func _build_park(o: Vector3i) -> void:
	for x in range(0, 33):
		_put(o + Vector3i(x, -1, 14), Blocks.GRAVEL)
	for z in range(-2, 17):
		_put(o + Vector3i(8, -1, z), Blocks.GRAVEL)
		_put(o + Vector3i(25, -1, z), Blocks.GRAVEL)
	_prop(o, "bank", Vector3i(3, 0, 5), Vector2i(4, 1))
	for z in range(8, 11):
		for x in range(9, 12):
			_put(o + Vector3i(x, -1, z), Blocks.TOY_BRICK_RED if (x + z) % 2 == 0 else Blocks.SNOW)
	_put(o + Vector3i(10, 0, 8), Blocks.CHEST)
	for tr in [Vector3i(2, 0, 11), Vector3i(14, 0, 3), Vector3i(1, 0, 1), Vector3i(31, 0, 15), Vector3i(17, 0, 0), Vector3i(31, 0, -2)]:
		_tree(o + tr)
	for b in [Vector3i(12, 0, 12), Vector3i(13, 0, 12), Vector3i(5, 0, 12), Vector3i(15, 0, 7)]:
		_put(o + b, Blocks.BERRY_BUSH)
	for l in [Vector3i(7, 0, 13), Vector3i(9, 0, 3), Vector3i(1, 0, 13), Vector3i(24, 0, 13), Vector3i(26, 0, 3)]:
		_lamp(o + l)
	for f in [Vector3i(12, 0, 1), Vector3i(13, 0, 1), Vector3i(0, 0, 7), Vector3i(0, 0, 8), Vector3i(15, 0, 13), Vector3i(16, 0, 13)]:
		_put(o + f, Blocks.FLOWERS)
	# Gölet: mavi su, taş kenar, çalı çit, ahşap köprü (z 6).
	_fill(o, Vector3i(17, -1, 2), Vector3i(24, -1, 10), Blocks.STONE_BASE)
	_fill(o, Vector3i(18, -1, 3), Vector3i(23, -1, 9), Blocks.TOY_BRICK_BLUE)
	_walls(o, Vector3i(17, 0, 2), Vector3i(24, 0, 10), Blocks.LEAVES)
	_fill(o, Vector3i(17, -1, 6), Vector3i(24, -1, 6), Blocks.PLANKS)
	_fill(o, Vector3i(17, 0, 6), Vector3i(24, 0, 6), Blocks.AIR)
	for x in range(18, 24):
		_put(o + Vector3i(x, 0, 5), Blocks.BALCONY_RAIL)
		_put(o + Vector3i(x, 0, 7), Blocks.BALCONY_RAIL)
	# Fıskiyeli havuz.
	_walls(o, Vector3i(28, 0, 6), Vector3i(32, 0, 10), Blocks.STONE)
	_fill(o, Vector3i(29, -1, 7), Vector3i(31, -1, 9), Blocks.TOY_BRICK_BLUE)
	_fill(o, Vector3i(30, 0, 8), Vector3i(30, 2, 8), Blocks.TRIM_WHITE)
	_put(o + Vector3i(30, 3, 8), Blocks.GLASS)
	_prop(o, "bank", Vector3i(28, 0, 12), Vector2i(2, 1), PI)
	_prop(o, "bank", Vector3i(31, 0, 12), Vector2i(2, 1), PI)
	# Kameriye: dört direk, kiremit çatı, ahşap zemin, içinde bank.
	_fill(o, Vector3i(27, -1, -1), Vector3i(31, -1, 3), Blocks.PLANKS)
	for c in [Vector3i(27, 0, -1), Vector3i(31, 0, -1), Vector3i(27, 0, 3), Vector3i(31, 0, 3)]:
		_fill(o, c, c + Vector3i(0, 2, 0), Blocks.LOG)
	_fill(o, Vector3i(26, 3, -2), Vector3i(32, 3, 4), Blocks.ROOF_TERRACOTTA)
	_fill(o, Vector3i(28, 4, -1), Vector3i(30, 4, 3), Blocks.ROOF_TERRACOTTA)
	_prop(o, "bank", Vector3i(28, 0, -1), Vector2i(3, 1))
	# Dondurma büfesi.
	_walls(o, Vector3i(17, 0, 11), Vector3i(19, 2, 13), Blocks.TRIM_WHITE)
	_fill(o, Vector3i(17, 3, 10), Vector3i(19, 3, 14), Blocks.TOY_BRICK_RED)
	_fill(o, Vector3i(18, 1, 13), Vector3i(18, 1, 13), Blocks.AIR)
	_door(o, Vector3i(18, 0, 11), true, false)
	_put(o + Vector3i(18, 2, 12), Blocks.LANTERN)
	# Çalı çit (kuzey dışında).
	for x in range(-1, 34):
		if x != 8 and x != 25:
			_put(o + Vector3i(x, 0, -3), Blocks.LEAVES)
	for z in range(-3, 17):
		_put(o + Vector3i(33, 0, z), Blocks.LEAVES)


## Karakter evi (Ali, Zeynep, öğretmen): iki katlı müstakil ev, önü caddeye (düşük z). Dış x 0..14 z 0..10.
## Zemin: salon x1..7, mutfak/yemek x9..13 (arka köşede merdiven). Üst kat: çocuk odası x1..6,
## anne-baba odası x8..13. Kiremit çatı, önde çitli bahçe, çakıl yol, çiçekler, ağaç.
func _build_family_house(o: Vector3i, wall: int, sofa: String) -> void:
	_shell(o, Vector2i(0, 0), Vector2i(14, 10), 2, wall, Blocks.PLANKS)
	# Giriş kapısı, söveler.
	_door(o, Vector3i(4, 0, 0), true, true, true)
	_fill(o, Vector3i(3, 0, 0), Vector3i(3, 3, 0), Blocks.TRIM_WHITE)
	_fill(o, Vector3i(5, 0, 0), Vector3i(5, 3, 0), Blocks.TRIM_WHITE)
	# Zemin kat: salon | mutfak duvarı ve kapısı.
	_iwall(o, Vector3i(8, 0, 1), Vector3i(8, 0, 9))
	_door(o, Vector3i(8, 0, 4), false)
	# Salon: L koltuk takımı, berjer, sehpa, halı, TV ünitesi, vitrin, abajur, tablolar, perdeler.
	_prop(o, "koltuk" + "@" + sofa, Vector3i(1, 0, 1), Vector2i(3, 1))
	_prop(o, "koltuk" + "@" + sofa, Vector3i(1, 0, 3), Vector2i(1, 3), PI / 2)
	_prop(o, "berjer" + "@" + sofa, Vector3i(6, 0, 4), Vector2i(1, 1), -PI / 2)
	_prop(o, "sehpa", Vector3i(3, 0, 4), Vector2i(2, 1))
	_prop(o, "abajur", Vector3i(6, 0, 1), Vector2i(1, 1))
	_prop(o, "tv", Vector3i(2, 0, 8), Vector2i(3, 1), PI)
	_prop(o, "vitrin", Vector3i(6, 0, 8), Vector2i(2, 1))
	_prop(o, "bitki", Vector3i(7, 0, 1), Vector2i(1, 1))
	_prop(o, "bitki", Vector3i(1, 0, 8), Vector2i(1, 1))
	_decor(o, "tablo_kucuk", Vector3(1.03, 2.4, 3.0), PI / 2)
	_decor(o, "tablo_kucuk", Vector3(3.0, 2.4, 9.97), PI)
	_decor(o, "perde", Vector3(1.5, 1.55, 1.04), 0.0)
	_decor(o, "perde", Vector3(5.5, 1.55, 1.04), 0.0)
	_decor(o, "duvar_saati", Vector3(7.97, 2.7, 2.5), -PI / 2)
	# Mutfak: tezgâh ve üst dolaplar, ocak, buzdolabı, kiler rafı, dört kişilik masa.
	_prop(o, "mutfak_tezgahi", Vector3i(9, 0, 1), Vector2i(2, 1))
	_prop(o, "ust_dolap", Vector3i(9, 0, 1), Vector2i(2, 1))
	_prop(o, "ocak", Vector3i(11, 0, 1), Vector2i(1, 1))
	_prop(o, "buzdolabi", Vector3i(12, 0, 1), Vector2i(1, 1))
	_prop(o, "kiler_rafi", Vector3i(13, 0, 5), Vector2i(1, 2), -PI / 2)
	_table4(o, Vector3i(10, 0, 4))
	_decor(o, "duvar_saati", Vector3(8.97 + 0.06, 2.7, 6.0), PI / 2)
	_decor(o, "tablo_kucuk", Vector3(13.97, 2.3, 3.0), -PI / 2)
	# Merdiven: mutfağın arkasında x 9..13 boyunca yukarı.
	for k in 5:
		_fill(o, Vector3i(9 + k, 0, 8), Vector3i(9 + k, k, 9), Blocks.PLANKS)
	_fill(o, Vector3i(9, 4, 8), Vector3i(12, 4, 9), Blocks.AIR)
	# Üst kat: çocuk odası (köşesinde banyo) | anne-baba odası.
	_iwall(o, Vector3i(7, 5, 1), Vector3i(7, 5, 9))
	_door(o, Vector3i(7, 5, 4), false)
	_put(o + Vector3i(1, 5, 1), Blocks.BED)
	_put(o + Vector3i(1, 5, 2), Blocks.BED)
	_prop(o, "komodin", Vector3i(2, 5, 1), Vector2i(1, 1))
	_prop(o, "gardirop", Vector3i(1, 5, 4), Vector2i(1, 2))
	_prop(o, "calisma_masasi", Vector3i(1, 5, 9), Vector2i(2, 1))
	_prop(o, "sandalye", Vector3i(1, 5, 8), Vector2i(1, 1), PI)
	_prop(o, "oyuncak_kutusu", Vector3i(5, 5, 1), Vector2i(1, 1))
	_fill(o, Vector3i(2, 4, 3), Vector3i(5, 4, 5), Blocks.RUG)
	_decor(o, "tablo_kucuk", Vector3(1.03, 7.0, 1.6), PI / 2)
	_decor(o, "perde", Vector3(1.5, 6.55, 1.04), 0.0)
	_prop(o, "kitaplik", Vector3i(6, 5, 2), Vector2i(1, 1), -PI / 2)
	_decor(o, "duvar_saati", Vector3(6.97, 7.4, 4.0), -PI / 2)
	# Banyo (x 4..6, z 7..9): klozet, lavabo ve ayna, duş, havluluk.
	_iwall(o, Vector3i(3, 5, 7), Vector3i(3, 5, 9))
	_iwall(o, Vector3i(3, 5, 6), Vector3i(6, 5, 6))
	_door(o, Vector3i(5, 5, 6), true)
	_fill(o, Vector3i(4, 4, 7), Vector3i(6, 4, 9), Blocks.TILE_BATH)
	_prop(o, "lavabo", Vector3i(4, 5, 9), Vector2i(1, 1), PI)
	_decor(o, "ayna_duvar", Vector3(4.5, 6.8, 9.97), PI)
	_prop(o, "klozet", Vector3i(6, 5, 9), Vector2i(1, 1), PI)
	_prop(o, "dus", Vector3i(6, 5, 7), Vector2i(1, 1), -PI / 2)
	_prop(o, "havluluk", Vector3i(4, 5, 7), Vector2i(1, 1), PI / 2)
	# Anne-baba odası: çift kişilik yatak, iki komodin ve abajur, gardırop, boy aynası, tablo.
	_prop(o, "cift_yatak", Vector3i(10, 5, 1), Vector2i(2, 2))
	_prop(o, "komodin", Vector3i(9, 5, 1), Vector2i(1, 1))
	_prop(o, "komodin", Vector3i(12, 5, 1), Vector2i(1, 1))
	_prop(o, "gardirop", Vector3i(13, 5, 4), Vector2i(1, 2))
	_prop(o, "ayna", Vector3i(8, 5, 6), Vector2i(1, 1), PI / 2)
	_decor(o, "tablo", Vector3(8.03, 7.3, 2.5), PI / 2)
	_decor(o, "oda_halisi", Vector3(10.8, 5, 4.6), 0.0)
	_decor(o, "perde", Vector3(8.5 + 0.5, 6.55, 1.04), 0.0)
	# Kiremit çatı: sırt x boyunca, alınlıklar yanlarda.
	for st in 6:
		_fill(o, Vector3i(-1, 10 + st, -1 + st), Vector3i(15, 10 + st, 11 - st), Blocks.ROOF_TERRACOTTA)
		if st < 5:
			_fill(o, Vector3i(0, 10 + st, st), Vector3i(0, 10 + st, 10 - st), wall)
			_fill(o, Vector3i(14, 10 + st, st), Vector3i(14, 10 + st, 10 - st), wall)
	_fill(o, Vector3i(11, 11, 6), Vector3i(11, 16, 6), Blocks.BRICKS)  # baca
	# Ön bahçe: çit, çakıl yol, çiçek sırası, ağaç.
	_fill(o, Vector3i(-1, 0, -5), Vector3i(15, 0, -5), Blocks.FENCE_WHITE)
	_fill(o, Vector3i(-1, 0, -5), Vector3i(-1, 0, 11), Blocks.FENCE_WHITE)
	_fill(o, Vector3i(15, 0, -5), Vector3i(15, 0, 11), Blocks.FENCE_WHITE)
	_fill(o, Vector3i(4, -1, -6), Vector3i(4, -1, -1), Blocks.GRAVEL)
	_put(o + Vector3i(4, 0, -5), Blocks.AIR)
	for x in range(0, 15):
		if x != 4 and x != 13:
			_put(o + Vector3i(x, 0, -1), Blocks.FLOWERS)
	_tree(o + Vector3i(13, 0, -3))


## İtfaiye (dış x 0..9, z 0..16; garaj kapısı güneyde caddeye): zeminde itfaiye aracı, kayma direği,
## ekipman dolapları; üst katta yatakhane. Arka köşede hortum kulesi, önde beton apron ve yangın musluğu.
func _build_fire_station(o: Vector3i) -> void:
	_shell(o, Vector2i(0, 0), Vector2i(9, 16), 2, Blocks.BRICKS, Blocks.CONCRETE)
	# Garaj kapısı (5 geniş, 3 yüksek) ve üstünde kırmızı-beyaz şerit; yanda giriş kapısı.
	_fill(o, Vector3i(2, 0, 16), Vector3i(6, 2, 16), Blocks.AIR)
	_awning(o, 1, 7, 3, 16, Blocks.TOY_BRICK_RED)
	_door(o, Vector3i(8, 0, 16), true, true, true)
	_prop(o, "itfaiye_araci", Vector3i(3, 0, 8), Vector2i(2, 5))
	_prop(o, "itfaiye_diregi", Vector3i(7, 0, 4), Vector2i(1, 1))
	_put(o + Vector3i(7, 4, 4), Blocks.AIR)
	_prop(o, "gardirop", Vector3i(8, 0, 7), Vector2i(1, 2))
	_prop(o, "gardirop", Vector3i(8, 0, 10), Vector2i(1, 2))
	_prop(o, "koli", Vector3i(1, 0, 14), Vector2i(1, 1))
	_fill(o, Vector3i(1, -1, 5), Vector3i(1, -1, 15), Blocks.TOY_BRICK_YELLOW)  # sarı güvenlik çizgisi
	# Merdiven: arka duvar boyunca x 1..5.
	for k in 5:
		_fill(o, Vector3i(1 + k, 0, 1), Vector3i(1 + k, k, 2), Blocks.PLANKS)
	_fill(o, Vector3i(1, 4, 1), Vector3i(4, 4, 2), Blocks.AIR)
	# Üst kat yatakhane: üç yatak, masa.
	for x in [2, 4, 6]:
		_put(o + Vector3i(x, 5, 14), Blocks.BED)
		_put(o + Vector3i(x, 5, 15), Blocks.BED)
	_table4(o, Vector3i(2, 5, 7))
	_prop(o, "gardirop", Vector3i(8, 5, 9), Vector2i(1, 2))
	# Hortum kulesi (arka sol köşe) ve tepesinde kırmızı siren.
	_walls(o, Vector3i(0, 10, 0), Vector3i(2, 15, 2), Blocks.BRICKS)
	_put(o + Vector3i(1, 13, 0), Blocks.GLASS)
	_fill(o, Vector3i(0, 16, 0), Vector3i(2, 16, 2), Blocks.CONCRETE)
	_put(o + Vector3i(1, 17, 1), Blocks.TOY_BRICK_RED)
	# Apron, yangın musluğu, lamba.
	_fill(o, Vector3i(0, -1, 17), Vector3i(9, -1, 20), Blocks.CONCRETE)
	_put(o + Vector3i(0, 0, 19), Blocks.TOY_BRICK_RED)
	_put(o + Vector3i(9, 2, 17), Blocks.LANTERN)


## Karakter evlerini birbirinden ayıran eşyalar: Ali'de top ve spor posteri, Zeynep'te oyuncaklar ve
## resim köşesi, öğretmende kitaplıklar.
func _family_extras() -> void:
	var a: Vector3i = SETS["ali_ev"]
	_decor(a, "salon_halisi", Vector3(4.0, 0, 4.5), 0.0)
	_decor(a, "futbol_topu", Vector3(4.5, 5, 2.5), 0.0)
	_decor(a, "poster", Vector3(6.97, 6.8, 2.5), -PI / 2)
	var z: Vector3i = SETS["zeynep_ev"]
	_decor(z, "oda_halisi", Vector3(4.0, 0, 4.5), PI / 2)
	_prop(z, "oyuncak_kutusu", Vector3i(6, 5, 1), Vector2i(1, 1))
	_decor(z, "tablo_kucuk", Vector3(6.97, 6.8, 2.5), -PI / 2)
	_decor(z, "oda_halisi", Vector3(4.0, 5, 3.8), 0.0)
	_decor(z, "tablo_kucuk", Vector3(2.0, 7.0, 9.97), PI)
	_prop(z, "bitki", Vector3i(13, 5, 7), Vector2i(1, 1))
	var t: Vector3i = SETS["ogretmen_ev"]
	_fill(t, Vector3i(2, -1, 3), Vector3i(5, -1, 6), Blocks.RUG)
	_prop(t, "kitaplik", Vector3i(8, 5, 8), Vector2i(1, 2), PI / 2)
	_prop(t, "kitaplik", Vector3i(7, 0, 6), Vector2i(1, 2), -PI / 2)
	_decor(t, "tablo", Vector3(1.03, 7.2, 4.5), PI / 2)
