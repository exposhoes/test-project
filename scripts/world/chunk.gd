class_name Chunk
extends StaticBody3D
## 16x64x16 blokluk dünya parçası: blok verisi, görünür mesh ve çarpışma şekli.

const SIZE := 16
const HEIGHT := 64

## Her yüz için: normal, dışarıdan bakınca saat yönünde köşeler (sol üst, sağ üst, sağ alt, sol alt), gölge.
## Godot ön yüzleri saat yönünde çizer.
const FACES := [
	{"dir": Vector3i(1, 0, 0), "verts": [Vector3(1, 1, 1), Vector3(1, 1, 0), Vector3(1, 0, 0), Vector3(1, 0, 1)], "shade": 0.8},
	{"dir": Vector3i(-1, 0, 0), "verts": [Vector3(0, 1, 0), Vector3(0, 1, 1), Vector3(0, 0, 1), Vector3(0, 0, 0)], "shade": 0.8},
	{"dir": Vector3i(0, 1, 0), "verts": [Vector3(0, 1, 0), Vector3(1, 1, 0), Vector3(1, 1, 1), Vector3(0, 1, 1)], "shade": 1.0},
	{"dir": Vector3i(0, -1, 0), "verts": [Vector3(0, 0, 1), Vector3(1, 0, 1), Vector3(1, 0, 0), Vector3(0, 0, 0)], "shade": 0.5},
	{"dir": Vector3i(0, 0, 1), "verts": [Vector3(0, 1, 1), Vector3(1, 1, 1), Vector3(1, 0, 1), Vector3(0, 0, 1)], "shade": 0.7},
	{"dir": Vector3i(0, 0, -1), "verts": [Vector3(1, 1, 0), Vector3(0, 1, 0), Vector3(0, 0, 0), Vector3(1, 0, 0)], "shade": 0.7},
]

var coord: Vector2i
var blocks := PackedByteArray()
var world: World

var _mesh_instance := MeshInstance3D.new()
var _collision := CollisionShape3D.new()


func _init(p_coord: Vector2i, p_world: World) -> void:
	coord = p_coord
	world = p_world
	name = "Chunk_%d_%d" % [coord.x, coord.y]
	position = Vector3(coord.x * SIZE, 0, coord.y * SIZE)
	blocks.resize(SIZE * SIZE * HEIGHT)
	add_child(_mesh_instance)
	add_child(_collision)


static func index(x: int, y: int, z: int) -> int:
	return x + z * SIZE + y * SIZE * SIZE


## index()'in tersi: yerel konum.
static func position_of(i: int) -> Vector3i:
	return Vector3i(i % SIZE, i / (SIZE * SIZE), (i / SIZE) % SIZE)


func get_local(x: int, y: int, z: int) -> int:
	return blocks[index(x, y, z)]


func set_local(x: int, y: int, z: int, id: int) -> void:
	blocks[index(x, y, z)] = id


func origin() -> Vector3i:
	return Vector3i(coord.x * SIZE, 0, coord.y * SIZE)


## Yüz tablosu düz dizilere açılır: iç döngüde sözlük ve dizi ayırma olmasın diye (telefonda asıl maliyet buydu).
static var _face_verts := PackedVector3Array()
static var _face_shade := PackedColorArray()
## Blok kimliğine göre şeffaflık ve atlas başına (kimlik*6+yüz)*4 köşe UV'si önbelleği.
static var _transparent := PackedByteArray()
static var _uv_atlas: BlockAtlas
static var _uv_cache := PackedVector2Array()


static func _prepare_tables(atlas: BlockAtlas) -> void:
	if _face_verts.is_empty():
		for f in 6:
			for v: Vector3 in FACES[f]["verts"]:
				_face_verts.append(v)
			var s: float = FACES[f]["shade"]
			_face_shade.append(Color(s, s, s))
		_transparent.resize(256)
		for id in 256:
			_transparent[id] = 1 if (id == Blocks.AIR or (Blocks.DEFS.has(id) and Blocks.is_transparent(id))) else 0
	if _uv_atlas != atlas:
		_uv_atlas = atlas
		_uv_cache.resize(256 * 6 * 4)
		for id in Blocks.DEFS:
			if id == Blocks.AIR:
				continue
			for f in 6:
				var uv := atlas.uv_rect(Blocks.texture_for(id, f))
				var k: int = (id * 6 + f) * 4
				_uv_cache[k] = uv.position
				_uv_cache[k + 1] = Vector2(uv.end.x, uv.position.y)
				_uv_cache[k + 2] = uv.end
				_uv_cache[k + 3] = Vector2(uv.position.x, uv.end.y)


## Komşu chunk'ın blokları (yoksa boş dizi: kenar yüzleri çizilir).
func _neighbor_blocks(dx: int, dz: int) -> PackedByteArray:
	var c = world._chunks.get(coord + Vector2i(dx, dz)) if world else null
	return c.blocks if c else PackedByteArray()


func rebuild(atlas: BlockAtlas, material: Material) -> void:
	_prepare_tables(atlas)
	var verts := PackedVector3Array()
	var normals := PackedVector3Array()
	var uvs := PackedVector2Array()
	var colors := PackedColorArray()
	var indices := PackedInt32Array()
	var east := _neighbor_blocks(1, 0)
	var west := _neighbor_blocks(-1, 0)
	var south := _neighbor_blocks(0, 1)
	var north := _neighbor_blocks(0, -1)
	const LAYER := SIZE * SIZE
	# Tamamen boş üst katmanları atla.
	var top := HEIGHT - 1
	while top >= 0:
		var empty := true
		for i in range(top * LAYER, (top + 1) * LAYER):
			if blocks[i] != 0:
				empty = false
				break
		if not empty:
			break
		top -= 1

	for y in top + 1:
		for z in SIZE:
			for x in SIZE:
				var i := x + z * SIZE + y * LAYER
				var id := blocks[i]
				if id == Blocks.AIR:
					continue
				for f in 6:
					var n: int
					match f:
						0: n = blocks[i + 1] if x < SIZE - 1 else (east[i - (SIZE - 1)] if not east.is_empty() else Blocks.AIR)
						1: n = blocks[i - 1] if x > 0 else (west[i + (SIZE - 1)] if not west.is_empty() else Blocks.AIR)
						2: n = blocks[i + LAYER] if y < HEIGHT - 1 else Blocks.AIR
						3: n = blocks[i - LAYER] if y > 0 else Blocks.BEDROCK
						4: n = blocks[i + SIZE] if z < SIZE - 1 else (south[i - (SIZE - 1) * SIZE] if not south.is_empty() else Blocks.AIR)
						_: n = blocks[i - SIZE] if z > 0 else (north[i + (SIZE - 1) * SIZE] if not north.is_empty() else Blocks.AIR)
					if _transparent[n] == 0 or n == id:
						continue
					var start := verts.size()
					var k := (id * 6 + f) * 4
					var p := Vector3(x, y, z)
					var normal := Vector3(FACES[f]["dir"])
					var shade := _face_shade[f]
					for v in 4:
						verts.append(p + _face_verts[f * 4 + v])
						normals.append(normal)
						uvs.append(_uv_cache[k + v])
						colors.append(shade)
					indices.append(start)
					indices.append(start + 1)
					indices.append(start + 2)
					indices.append(start)
					indices.append(start + 2)
					indices.append(start + 3)

	if verts.is_empty():
		_mesh_instance.mesh = null
		_collision.shape = null
		return

	var arrays := []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = verts
	arrays[Mesh.ARRAY_NORMAL] = normals
	arrays[Mesh.ARRAY_TEX_UV] = uvs
	arrays[Mesh.ARRAY_COLOR] = colors
	arrays[Mesh.ARRAY_INDEX] = indices
	var mesh := ArrayMesh.new()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	mesh.surface_set_material(0, material)
	_mesh_instance.mesh = mesh

	var collision_faces := PackedVector3Array()
	collision_faces.resize(indices.size())
	for j in indices.size():
		collision_faces[j] = verts[indices[j]]
	var shape := ConcavePolygonShape3D.new()
	shape.backface_collision = true
	shape.set_faces(collision_faces)
	_collision.shape = shape


func _block_at(x: int, y: int, z: int, base: Vector3i) -> int:
	if y < 0:
		return Blocks.BEDROCK
	if y >= HEIGHT:
		return Blocks.AIR
	if x >= 0 and x < SIZE and z >= 0 and z < SIZE:
		return get_local(x, y, z)
	return world.get_block(base + Vector3i(x, y, z))
