class_name HallsGenerator
extends RefCounted
## Sarı Koridorlar: sonsuz, tek katlı, alçak tavanlı sarı duvar kağıtlı labirent.
## Zemin nemli halı, tavanda floresan paneller. Duvarların içinde ara sıra maden bulunur.
## Başlangıç odası (0,0 çevresi) hep boştur ve dönüş kapısı orada durur.

const FLOOR := 20          # oyuncunun bastığı ilk boş katman
const ROOM_HEIGHT := 4     # zeminle tavan arası
const CELL := 5            # labirent hücresi (duvar dahil)
const WALL_CHANCE := 450   # 1000 üzerinden: bir duvar parçasının dolu olma olasılığı
## Dönüş kapısının yeri (başlangıç odasında).
const EXIT_PORTAL := Vector3i(10, FLOOR, 8)
const SPAWN := Vector3(8.5, FLOOR, 8.5)
const START_ROOM := 16     # 0..START_ROOM arası duvarsız

var world_seed: int


func _init(p_seed: int) -> void:
	world_seed = p_seed


func generate(chunk: Chunk) -> void:
	var base := chunk.origin()
	var ceiling := FLOOR + ROOM_HEIGHT
	for z in Chunk.SIZE:
		for x in Chunk.SIZE:
			var gx := base.x + x
			var gz := base.z + z
			chunk.set_local(x, 0, z, Blocks.BEDROCK)
			for y in range(1, FLOOR - 1):
				chunk.set_local(x, y, z, _solid(gx, y, gz))
			chunk.set_local(x, FLOOR - 1, z, Blocks.DAMP_CARPET)
			var wall := is_wall(gx, gz)
			for y in range(FLOOR, ceiling):
				chunk.set_local(x, y, z, _solid(gx, y, gz) if wall else Blocks.AIR)
			chunk.set_local(x, ceiling, z, Blocks.CEILING_LIGHT if _is_light(gx, gz) else Blocks.CEILING_TILE)
			for y in range(ceiling + 1, ceiling + 3):
				chunk.set_local(x, y, z, Blocks.YELLOW_WALLPAPER)
			if Vector3i(gx, FLOOR, gz) == EXIT_PORTAL:
				chunk.set_local(x, FLOOR, z, Blocks.HALLS_PORTAL)


## Bu sütun duvar mı: hücre köşeleri hep dolu, kenarlar rastgele, başlangıç odası boş.
func is_wall(x: int, z: int) -> bool:
	if x >= -1 and x <= START_ROOM and z >= -1 and z <= START_ROOM:
		return false
	var on_x := posmod(x, CELL) == 0
	var on_z := posmod(z, CELL) == 0
	if on_x and on_z:
		return true
	if on_x:
		return _roll(floori(x / float(CELL)), floori(z / float(CELL)), 1) < WALL_CHANCE
	if on_z:
		return _roll(floori(x / float(CELL)), floori(z / float(CELL)), 2) < WALL_CHANCE
	return false


## Canlıların doğabileceği yükseklik; duvar içindeyse -1.
func spawn_y(x: int, z: int) -> int:
	return -1 if is_wall(x, z) else FLOOR


func _is_light(x: int, z: int) -> bool:
	return posmod(x, CELL) == 2 and posmod(z, CELL * 2) == 2


func _solid(x: int, y: int, z: int) -> int:
	var roll := posmod(hash(Vector4i(x, y, z, world_seed)), 1000)
	if roll < 6:
		return Blocks.GOLD_ORE
	if roll < 9:
		return Blocks.CRYSTAL_ORE
	return Blocks.YELLOW_WALLPAPER


func _roll(a: int, b: int, c: int) -> int:
	return posmod(hash(Vector4i(a, b, c, world_seed + 77)), 1000)
