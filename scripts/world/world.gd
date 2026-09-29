class_name World
extends Node3D
## Oyuncunun çevresindeki chunk'ları üretir, mesh'ler ve uzaktakileri boşaltır.

signal block_changed(pos: Vector3i, id: int)

## Mobil cihazlarda performans için küçük tutuldu.
@export var render_distance := 4
@export var meshes_per_frame := 1
@export var world_seed := 1337
## 0: Yeryüzü, 1: Sarı Koridorlar.
@export var dimension := 0

var atlas: BlockAtlas
var material: StandardMaterial3D
var generator: RefCounted

var _chunks := {}  # Vector2i -> Chunk (verisi üretilmiş)
var _meshed := {}  # Vector2i -> true
var _pending: Array[Vector2i] = []
var _center := Vector2i(2147483647, 0)
## Oyuncunun yaptığı değişiklikler: chunk -> {yerel indeks: blok}. Chunk yeniden üretilince uygulanır
## ve kayıt dosyasına yazılır, böylece uzaklaşınca ya da oyunu kapatınca kaybolmaz.
var edits := {}
## Yüklü chunk'lardaki fenerlerin ışıkları: blok konumu -> OmniLight3D.
var _lights := {}
## Mesh'ler arka plan iş parçacıklarında hazırlanır; ana iş parçacığı yalnızca sonucu uygular.
## Kapatılırsa (ya da tek çekirdekte) eski eşzamanlı yol kullanılır.
var threaded := OS.get_processor_count() > 1
const MAX_JOBS := 3
var _jobs := {}  # Vector2i -> {"task": id, "out": {}, "version": int}
## Chunk her anında yeniden mesh'lendiğinde artar; eski iş parçacığı sonuçları böylece atılır.
var _versions := {}
const LIGHT_RANGE := 10.0


func _ready() -> void:
	atlas = BlockAtlas.new()
	if dimension == Dimension.HALLS:
		generator = HallsGenerator.new(world_seed)
	elif dimension == Dimension.FACTORY:
		generator = FactoryGenerator.new(world_seed)
	else:
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
	var old := chunk.get_local(lx, pos.y, lz)
	chunk.set_local(lx, pos.y, lz, id)
	if Blocks.is_light(old):
		_remove_light(pos)
	if Blocks.is_light(id):
		_add_light(pos)
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


## pos'un dist blok yakınında fener var mı (Sırıtkan ışıktan kaçar).
func near_light(pos: Vector3, dist: float) -> bool:
	for p: Vector3i in _lights:
		if (Vector3(p) + Vector3.ONE * 0.5).distance_to(pos) < dist:
			return true
	return false


func _add_light(pos: Vector3i) -> void:
	if _lights.has(pos):
		return
	var light := OmniLight3D.new()
	light.light_color = Color("ffc864")
	light.light_energy = 3.0
	light.omni_attenuation = 0.6
	light.omni_range = LIGHT_RANGE
	light.position = Vector3(pos) + Vector3.ONE * 0.5
	add_child(light)
	_lights[pos] = light


func _remove_light(pos: Vector3i) -> void:
	if _lights.has(pos):
		_lights[pos].queue_free()
		_lights.erase(pos)


func is_meshed_at(pos: Vector3) -> bool:
	return _meshed.has(chunk_coord(Vector3i(pos.floor())))


## Oyuncunun bu boyuta ilk girişte belirdiği nokta (y, spawn_y ile bulunur).
func start_position() -> Vector3:
	return generator.start_position() if generator.has_method("start_position") else Vector3(8.5, 0, 8.5)


## Canlıların (oyuncu, yaratık) bu sütunda duracağı yükseklik; uygun yer yoksa -1.
## Tavanlı boyutlarda en üst katı blok değil zemin kullanılır.
func spawn_y(x: int, z: int) -> int:
	if generator.has_method("spawn_y"):
		return generator.spawn_y(x, z)
	return surface_y(x, z)


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
	_collect_jobs()
	var budget := meshes_per_frame
	while budget > 0 and not _pending.is_empty():
		if threaded and _jobs.size() >= MAX_JOBS:
			break
		var c: Vector2i = _pending.pop_front()
		if _jobs.has(c):
			continue
		for n in [c, c + Vector2i(1, 0), c + Vector2i(-1, 0), c + Vector2i(0, 1), c + Vector2i(0, -1)]:
			_ensure_chunk(n)
		if threaded:
			_start_job(c)
		else:
			_chunks[c].rebuild(atlas, material)
			_meshed[c] = true
		budget -= 1


func _start_job(c: Vector2i) -> void:
	Chunk._prepare_tables(atlas)
	var snap: Array = _chunks[c].snapshot()
	var out := {}
	var task := WorkerThreadPool.add_task(func() -> void: out["data"] = Chunk.build_arrays(snap))
	_jobs[c] = {"task": task, "out": out, "version": _versions.get(c, 0)}


## Biten işlerin sonucunu uygular; bu arada boşaltılan ya da elle yeniden mesh'lenen chunk'ınkini atar.
func _collect_jobs() -> void:
	for c: Vector2i in _jobs.keys():
		var job: Dictionary = _jobs[c]
		if not WorkerThreadPool.is_task_completed(job["task"]):
			continue
		WorkerThreadPool.wait_for_task_completion(job["task"])
		_jobs.erase(c)
		if _chunks.has(c) and job["version"] == _versions.get(c, 0):
			_chunks[c].apply_arrays(job["out"]["data"], material)
			_meshed[c] = true


func _exit_tree() -> void:
	for c: Vector2i in _jobs:
		WorkerThreadPool.wait_for_task_completion(_jobs[c]["task"])
	_jobs.clear()


func _ensure_chunk(c: Vector2i) -> Chunk:
	if not _chunks.has(c):
		var chunk := Chunk.new(c, self)
		generator.generate(chunk)
		for i: int in edits.get(c, {}):
			chunk.blocks[i] = edits[c][i]
			if Blocks.is_light(edits[c][i]):
				_add_light(chunk.origin() + Chunk.position_of(i))
		_chunks[c] = chunk
		add_child(chunk)
	return _chunks[c]


func _remesh(c: Vector2i) -> void:
	if _meshed.has(c) or _jobs.has(c):
		_versions[c] = _versions.get(c, 0) + 1
		_chunks[c].rebuild(atlas, material)
		_meshed[c] = true


func _unload_far() -> void:
	var keep := render_distance + 2
	for c: Vector2i in _chunks.keys():
		if absi(c.x - _center.x) > keep or absi(c.y - _center.y) > keep:
			_chunks[c].queue_free()
			_chunks.erase(c)
			for p: Vector3i in _lights.keys():
				if chunk_coord(p) == c:
					_remove_light(p)
			_meshed.erase(c)
