class_name BookshelfModel
## Kitaplık bloğunun yüksek çözünürlüklü görünümü (Mehmet'in Roblox tarzı kitaplık görseli):
## boşluğa bakan yanlarda kitaplı ön yüz, diğer yüzlerde ceviz ahşap. Doku: sol yarı ön yüz, sağ yarı ahşap.
## Blok yüzleri yerine çizilir (Blocks.DEFS[BOOKSHELF]["model"]); çarpışma tam bloktur.

const TEXTURE := "res://assets/textures/models/bookshelf.png"
## Yatay yan yönleri, bit sırası: +X, -X, +Z, -Z.
const SIDES := [Vector3i(1, 0, 0), Vector3i(-1, 0, 0), Vector3i(0, 0, 1), Vector3i(0, 0, -1)]

static var _material: StandardMaterial3D
static var _meshes := {}  # açık yan maskesi -> ArrayMesh


## pos'taki kitaplığın modeli. is_open: Callable(Vector3i) -> bool, o komşu boş/şeffaf mı.
static func create(pos: Vector3i, is_open: Callable) -> Node3D:
	var mask := 0
	for i in 4:
		if is_open.call(pos + SIDES[i]):
			mask |= 1 << i
	var mi := MeshInstance3D.new()
	mi.name = "Kitaplik"
	mi.mesh = _mesh(mask)
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	return mi


static func _mesh(mask: int) -> ArrayMesh:
	if _meshes.has(mask):
		return _meshes[mask]
	if _material == null:
		_material = StandardMaterial3D.new()
		if ResourceLoader.exists(TEXTURE):
			_material.albedo_texture = load(TEXTURE)
		else:
			_material.albedo_color = Color("5a3a24")
		_material.roughness = 0.6
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	# Model bloğun köşesinden (0,0,0) başlar, 1x1x1.
	for i in 4:
		var d: Vector3i = SIDES[i]
		_face(st, Vector3(d), (mask >> i) & 1 == 1)
	_face(st, Vector3.UP, false)
	_face(st, Vector3.DOWN, false)
	var mesh := st.commit()
	mesh.surface_set_material(0, _material)
	_meshes[mask] = mesh
	return mesh


## n yönüne bakan birim yüz; books true ise dokunun sol yarısı (kitaplar), değilse sağ yarısı (ahşap).
static func _face(st: SurfaceTool, n: Vector3, books: bool) -> void:
	var up := Vector3.UP if absf(n.y) < 0.5 else Vector3(0, 0, -1)
	var right := up.cross(n)  # dışarıdan bakınca sağ
	var c := Vector3(0.5, 0.5, 0.5) + n * 0.5
	var u0 := 0.0 if books else 0.5
	var corners := [
		[c - right * 0.5 + up * 0.5, Vector2(u0, 0)],
		[c + right * 0.5 + up * 0.5, Vector2(u0 + 0.5, 0)],
		[c + right * 0.5 - up * 0.5, Vector2(u0 + 0.5, 1)],
		[c - right * 0.5 - up * 0.5, Vector2(u0, 1)],
	]
	for k: int in [0, 1, 2, 0, 2, 3]:
		st.set_normal(n)
		st.set_uv(corners[k][1])
		st.add_vertex(corners[k][0])
