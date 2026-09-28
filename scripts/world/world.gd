class_name World
extends Node3D
## Oyuncunun çevresindeki chunk'ları üretir, mesh'ler ve uzaktakileri boşaltır.

signal block_changed(pos: Vector3i, id: int)

## Mobil cihazlarda performans için küçük tutuldu.
@export var render_distance := 4
@export var meshes_per_frame := 1
@export var world_seed := 1337

var atlas: BlockAtlas
var material: StandardMaterial3D
var generator: TerrainGenerator

var _chunks := {}  # Vector2i -> Chunk (verisi üretilmiş)
var _meshed := {}  # Vector2i -> true
var _pending: Array[Vector2i] = []
var _center := Vector2i(2147483647, 0)
## Oyuncunun yaptığı değişiklikler: chunk -> {yerel indeks: blok}. Chunk yeniden üretilince uygulanır
## ve kayıt dosyasına yazılır, böylece uzaklaşınca ya da oyunu kapatınca kaybolmaz.
var edits := {}


func _ready() -> void:
	atlas = BlockAtlas.new()
	generator = TerrainGenerator.new(world_seed)
	material = StandardMaterial3D.new()
	material.albedo_texture = atlas.texture
	material.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
	material.vertex_color_use_as_albedo = true
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA_SCISSOR
	material.alpha_scissor_threshold = 0.5


static func chunk_coord(pos: Vector3i) -> Vector2i:
	return Vector2i(floori(pos.x / float(Chunk.SIZE)), floori(pos.z / float(Chunk.SIZE)))


func get_block(pos: Vector3i) -> int:
	if pos.y < 0 or pos.y >= Chunk.HEIGHT:
		return Blocks.AIR
	var chunk: Chunk = _chunks.get(chunk_coord(pos))
	if chunk == null:
		return Blocks.AIR
	return chunk.get_local(pos.x - chunk.coord.x * Chunk.SIZE, pos.y, pos.z - chunk.coord.y * Chunk.SIZE)


func set_block(pos: Vector3i, id: int) -> void:
	if pos.y < 0 or pos.y >= Chunk.HEIGHT:
		return
	var c := chunk_coord(pos)
	var chunk: Chunk = _chunks.get(c)
	if chunk == null:
		return
	var lx := pos.x - c.x * Chunk.SIZE
	var lz := pos.z - c.y * Chunk.SIZE
	chunk.set_local(lx, pos.y, lz, id)
	if not edits.has(c):
		edits[c] = {}
	edits[c][Chunk.index(lx, pos.y, lz)] = id
	_remesh(c)
	if lx == 0:
		_remesh(c + Vector2i(-1, 0))
	elif lx == Chunk.SIZE - 1:
		_remesh(c + Vector2i(1, 0))
	if lz == 0:
		_remesh(c + Vector2i(0, -1))
	elif lz == Chunk.SIZE - 1:
		_remesh(c + Vector2i(0, 1))
	block_changed.emit(pos, id)


func is_meshed_at(pos: Vector3) -> bool:
	return _meshed.has(chunk_coord(Vector3i(pos.floor())))


## Bir sütundaki en üstteki katı bloğun üstü.
func surface_y(x: int, z: int) -> int:
	for y in range(Chunk.HEIGHT - 1, -1, -1):
		if Blocks.is_solid(get_block(Vector3i(x, y, z))):
			return y + 1
	return Chunk.HEIGHT


## Oyuncu konumunu bildirir; chunk yükleme sırasını yeniler.
## Görüş mesafesini değiştirir; chunk'lar bir sonraki update_center'da yeniden seçilir.
func set_render_distance(d: int) -> void:
	render_distance = d
	_center = Vector2i(2147483647, 0)


func update_center(pos: Vector3) -> void:
	var c := chunk_coord(Vector3i(pos.floor()))
	if c == _center:
		return
	_center = c
	_unload_far()
	_pending.clear()
	for dz in range(-render_distance, render_distance + 1):
		for dx in range(-render_distance, render_distance + 1):
			var cc := c + Vector2i(dx, dz)
			if not _meshed.has(cc) and Vector2(dx, dz).length() <= render_distance + 0.5:
				_pending.append(cc)
	_pending.sort_custom(func(a: Vector2i, b: Vector2i) -> bool:
		return (a - c).length_squared() < (b - c).length_squared())


func _process(_delta: float) -> void:
	var budget := meshes_per_frame
	while budget > 0 and not _pending.is_empty():
		var c: Vector2i = _pending.pop_front()
		for n in [c, c + Vector2i(1, 0), c + Vector2i(-1, 0), c + Vector2i(0, 1), c + Vector2i(0, -1)]:
			_ensure_chunk(n)
		_chunks[c].rebuild(atlas, material)
		_meshed[c] = true
		budget -= 1


func _ensure_chunk(c: Vector2i) -> Chunk:
	if not _chunks.has(c):
		var chunk := Chunk.new(c, self)
		generator.generate(chunk)
		for i: int in edits.get(c, {}):
			chunk.blocks[i] = edits[c][i]
		_chunks[c] = chunk
		add_child(chunk)
	return _chunks[c]


func _remesh(c: Vector2i) -> void:
	if _meshed.has(c):
		_chunks[c].rebuild(atlas, material)


func _unload_far() -> void:
	var keep := render_distance + 2
	for c: Vector2i in _chunks.keys():
		if absi(c.x - _center.x) > keep or absi(c.y - _center.y) > keep:
			_chunks[c].queue_free()
			_chunks.erase(c)
			_meshed.erase(c)
