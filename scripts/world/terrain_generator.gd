class_name TerrainGenerator
extends RefCounted
## Gürültü tabanlı arazi: tepeler, kumsallar, karlı zirveler, madenler ve ağaçlar.

const BASE_HEIGHT := 22
const BEACH_HEIGHT := 19
const SNOW_HEIGHT := 40

var world_seed: int
var _hills := FastNoiseLite.new()
var _detail := FastNoiseLite.new()


func _init(p_seed: int) -> void:
	world_seed = p_seed
	_hills.seed = p_seed
	_hills.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
	_hills.frequency = 0.008
	_hills.fractal_octaves = 3
	_detail.seed = p_seed + 1
	_detail.frequency = 0.05


func height_at(x: int, z: int) -> int:
	var h := BASE_HEIGHT + _hills.get_noise_2d(x, z) * 16.0 + _detail.get_noise_2d(x, z) * 2.0
	return clampi(int(h), 2, Chunk.HEIGHT - 10)


func generate(chunk: Chunk) -> void:
	var base := chunk.origin()
	for z in Chunk.SIZE:
		for x in Chunk.SIZE:
			var gx := base.x + x
			var gz := base.z + z
			var h := height_at(gx, gz)
			for y in h + 1:
				chunk.set_local(x, y, z, _block_for(gx, y, gz, h))
			if _tree_here(gx, gz, h) and x >= 2 and x <= Chunk.SIZE - 3 and z >= 2 and z <= Chunk.SIZE - 3:
				_place_tree(chunk, x, h + 1, z)
			elif _bush_here(gx, gz, h) and chunk.get_local(x, h + 1, z) == Blocks.AIR:
				chunk.set_local(x, h + 1, z, Blocks.BERRY_BUSH)


func _block_for(x: int, y: int, z: int, surface: int) -> int:
	if y == 0:
		return Blocks.BEDROCK
	if y == surface:
		if surface <= BEACH_HEIGHT:
			return Blocks.SAND
		return Blocks.SNOW if surface >= SNOW_HEIGHT else Blocks.GRASS
	if y > surface - 4:
		return Blocks.SAND if surface <= BEACH_HEIGHT else Blocks.DIRT
	var roll := _roll(x, y, z)
	if roll < 12:
		return Blocks.COAL_ORE
	if roll < 18:
		return Blocks.IRON_ORE
	if y < 16 and roll < 21:
		return Blocks.GOLD_ORE
	if y < 10 and roll < 23:
		return Blocks.RUBY_ORE
	if y < 8 and roll < 24:
		return Blocks.CRYSTAL_ORE
	if roll < 30:
		return Blocks.GRAVEL
	return Blocks.STONE


func _tree_here(x: int, z: int, surface: int) -> bool:
	return surface > BEACH_HEIGHT and surface < SNOW_HEIGHT and _roll(x, -1, z) < 8


## Çimenlikte seyrek çilek çalıları (yiyecek).
func _bush_here(x: int, z: int, surface: int) -> bool:
	return surface > BEACH_HEIGHT and surface < SNOW_HEIGHT and _roll(x, -3, z) < 5


func _place_tree(chunk: Chunk, x: int, y: int, z: int) -> void:
	var trunk := 4 + _roll(x, -2, z) % 2
	for dy in range(trunk - 2, trunk + 2):
		var radius := 1 if dy >= trunk else 2
		for dz in range(-radius, radius + 1):
			for dx in range(-radius, radius + 1):
				if absi(dx) == radius and absi(dz) == radius and dy >= trunk:
					continue
				chunk.set_local(x + dx, y + dy, z + dz, Blocks.LEAVES)
	for dy in trunk:
		chunk.set_local(x, y + dy, z, Blocks.LOG)


## Konuma bağlı, tekrarlanabilir 0..999 arası sayı.
func _roll(x: int, y: int, z: int) -> int:
	return posmod(hash(Vector4i(x, y, z, world_seed)), 1000)
