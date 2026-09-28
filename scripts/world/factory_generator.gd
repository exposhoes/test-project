class_name FactoryGenerator
extends RefCounted
## Oyuncak Fabrikası: yüksek tavanlı, renkli oyuncak bloklarından büyük salonlar.
## Salonlar kapı boşluklu duvarlarla ayrılır; içlerinde oyuncak blok yığınları durur.
## Duvarlarda ara sıra yakut ve kristal bulunur. Başlangıç salonunda dönüş kapısı vardır.

const FLOOR := 20
const ROOM_HEIGHT := 8
const CELL := 12            # salon boyu (duvar dahil)
const DOOR_WIDTH := 3       # duvar ortasındaki kapı boşluğu
const DOOR_HEIGHT := 4
const PILE_CHANCE := 18     # 1000 üzerinden: bir sütunda oyuncak yığını olma olasılığı
const EXIT_PORTAL := Vector3i(10, FLOOR, 8)
const SPAWN := Vector3(8.5, FLOOR, 8.5)
const TOYS := [Blocks.TOY_BRICK_RED, Blocks.TOY_BRICK_BLUE, Blocks.TOY_BRICK_YELLOW]

var world_seed: int


func _init(p_seed: int) -> void:
	world_seed = p_seed


func start_position() -> Vector3:
	return SPAWN


func generate(chunk: Chunk) -> void:
	var base := chunk.origin()
	var ceiling := FLOOR + ROOM_HEIGHT
	for z in Chunk.SIZE:
		for x in Chunk.SIZE:
			var gx := base.x + x
			var gz := base.z + z
			chunk.set_local(x, 0, z, Blocks.BEDROCK)
			for y in range(1, FLOOR - 1):
				chunk.set_local(x, y, z, Blocks.PLAYROOM_WALL)
			# Zemin: 2x2 karelik renkli dama.
			chunk.set_local(x, FLOOR - 1, z, TOYS[posmod(floori(gx / 2.0) + floori(gz / 2.0), 3)])
			for y in range(FLOOR, ceiling):
				chunk.set_local(x, y, z, block_at(gx, y, gz))
			var light := posmod(gx, 6) == 3 and posmod(gz, 6) == 3
			chunk.set_local(x, ceiling, z, Blocks.CEILING_LIGHT if light else Blocks.PLAYROOM_WALL)
			if Vector3i(gx, FLOOR, gz) == EXIT_PORTAL:
				chunk.set_local(x, FLOOR, z, Blocks.FACTORY_PORTAL)


## Zemin ile tavan arasındaki blok: salon duvarı, oyuncak yığını ya da hava.
func block_at(x: int, y: int, z: int) -> int:
	var h := y - FLOOR
	if _is_wall(x, z):
		if _is_door(x, z) and h < DOOR_HEIGHT:
			return Blocks.AIR
		# Alt kısım oyun odası duvarı, üstte renkli şerit.
		if h == 2 or h == 5:
			return TOYS[posmod(floori(x / float(CELL)) + floori(z / float(CELL)) + h, 3)]
		var roll := _roll(x, y, z)
		if roll < 5:
			return Blocks.RUBY_ORE
		if roll < 8:
			return Blocks.CRYSTAL_ORE
		return Blocks.PLAYROOM_WALL
	if not _in_start_room(x, z) and h < _pile_height(x, z):
		return TOYS[posmod(x * 7 + z * 13 + h, 3)]
	return Blocks.AIR


## Canlıların doğabileceği yükseklik; duvar ya da yığın üstüyse -1.
func spawn_y(x: int, z: int) -> int:
	return FLOOR if block_at(x, FLOOR, z) == Blocks.AIR else -1


func _is_wall(x: int, z: int) -> bool:
	if _in_start_room(x, z):
		return false
	return posmod(x, CELL) == 0 or posmod(z, CELL) == 0


## Duvarın ortasındaki kapı boşluğu (köşelerde değil).
func _is_door(x: int, z: int) -> bool:
	var mid := CELL / 2
	var on_x := posmod(x, CELL) == 0
	var on_z := posmod(z, CELL) == 0
	if on_x and on_z:
		return false
	var along := posmod(z, CELL) if on_x else posmod(x, CELL)
	return absi(along - mid) <= DOOR_WIDTH / 2


func _in_start_room(x: int, z: int) -> bool:
	return x >= -1 and x <= 16 and z >= -1 and z <= 16


## Oyuncak yığını yüksekliği (0 = yığın yok); kapı önleri boş kalır.
func _pile_height(x: int, z: int) -> int:
	var px := posmod(x, CELL)
	var pz := posmod(z, CELL)
	if px <= 2 or pz <= 2 or px >= CELL - 2 or pz >= CELL - 2:
		return 0
	var roll := _roll(x, -1, z)
	return 1 + roll % 3 if roll < PILE_CHANCE else 0


func _roll(x: int, y: int, z: int) -> int:
	return posmod(hash(Vector4i(x, y, z, world_seed + 313)), 1000)
