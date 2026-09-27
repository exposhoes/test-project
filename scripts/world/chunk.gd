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


func get_local(x: int, y: int, z: int) -> int:
	return blocks[index(x, y, z)]


func set_local(x: int, y: int, z: int, id: int) -> void:
	blocks[index(x, y, z)] = id


func origin() -> Vector3i:
	return Vector3i(coord.x * SIZE, 0, coord.y * SIZE)


func rebuild(atlas: BlockAtlas, material: Material) -> void:
	var verts := PackedVector3Array()
	var normals := PackedVector3Array()
	var uvs := PackedVector2Array()
	var colors := PackedColorArray()
	var indices := PackedInt32Array()
	var collision_faces := PackedVector3Array()
	var base := origin()

	for y in HEIGHT:
		for z in SIZE:
			for x in SIZE:
				var id := get_local(x, y, z)
				if id == Blocks.AIR:
					continue
				for f in 6:
					var face: Dictionary = FACES[f]
					var dir: Vector3i = face["dir"]
					var neighbor := _block_at(x + dir.x, y + dir.y, z + dir.z, base)
					if not Blocks.is_transparent(neighbor) or neighbor == id:
						continue
					var uv := atlas.uv_rect(Blocks.texture_for(id, f))
					var corner_uvs := [uv.position, Vector2(uv.end.x, uv.position.y), uv.end, Vector2(uv.position.x, uv.end.y)]
					var shade := Color(face["shade"], face["shade"], face["shade"])
					var start := verts.size()
					var quad: Array = face["verts"]
					for i in 4:
						verts.append(Vector3(x, y, z) + quad[i])
						normals.append(Vector3(dir))
						uvs.append(corner_uvs[i])
						colors.append(shade)
					indices.append_array([start, start + 1, start + 2, start, start + 2, start + 3])
					for i in [0, 1, 2, 0, 2, 3]:
						collision_faces.append(Vector3(x, y, z) + quad[i])

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
