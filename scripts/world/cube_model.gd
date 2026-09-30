class_name CubeModel
## Kutu biçimli model blokları (kitaplık, sandık) Mehmet'in Roblox tarzı görsellerinden yüksek
## çözünürlükle çizilir. Doku üç kare yan yana: ön yüz | yan yüz | üst yüz.
## Blok yüzleri yerine çizilir (Blocks.DEFS[..]["model"]); çarpışma tam bloktur.

## Blok -> doku, boyut (1 = tam blok) ve ön yüz kuralı ("all": boşluğa bakan her yan, "one": ilk boş yan).
const DEFS := {
	Blocks.BOOKSHELF: {"texture": "res://assets/textures/models/bookshelf.png", "size": 1.0, "front": "all"},
	Blocks.CHEST: {"texture": "res://assets/textures/models/chest.png", "size": 0.88, "front": "one"},
	Blocks.FURNACE: {"texture": "res://assets/textures/models/furnace.png", "size": 1.0, "front": "one"},
	# Altı açık masa: siyah arka plan şeffaf ("cutout"), alt yüz yok, blok yüksekliğinin %80'i.
	Blocks.CRAFTING_TABLE: {"texture": "res://assets/textures/models/crafting_table.png", "size": 1.0,
		"front": "one", "cutout": true, "height": 0.8},
}
## Yatay yan yönleri, bit sırası: +X, -X, +Z, -Z.
## Dokudaki kare boyutu ve çevresindeki dolgu (tools/art/pack_model_texture.py ile aynı).
const CELL := 512.0
const PAD := 32.0
const SIDES := [Vector3i(1, 0, 0), Vector3i(-1, 0, 0), Vector3i(0, 0, 1), Vector3i(0, 0, -1)]

static var _materials := {}  # blok -> malzeme
static var _meshes := {}  # [blok, ön yüz maskesi] -> ArrayMesh


static func has(id: int) -> bool:
	return DEFS.has(id)


## pos'taki bloğun modeli. is_open: Callable(Vector3i) -> bool, o komşu boş/şeffaf mı.
static func create(id: int, pos: Vector3i, is_open: Callable) -> Node3D:
	var mask := 0
	var one: bool = DEFS[id]["front"] == "one"
	# Tek ön yüzde tercih sırası: +Z, +X, -X, -Z (setlerde kamera genelde +Z tarafında).
	for i: int in ([2, 0, 1, 3] if one else [0, 1, 2, 3]):
		if is_open.call(pos + SIDES[i]):
			mask |= 1 << i
			if one:
				break
	if mask == 0 and DEFS[id]["front"] == "one":
		mask = 1 << 2  # her yan kapalıysa +Z
	var mi := MeshInstance3D.new()
	mi.name = "Model"
	mi.mesh = _mesh(id, mask)
	mi.scale.y = DEFS[id].get("height", 1.0)
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	return mi


static func _mesh(id: int, mask: int) -> ArrayMesh:
	var key := [id, mask]
	if _meshes.has(key):
		return _meshes[key]
	if not _materials.has(id):
		var m := StandardMaterial3D.new()
		var tex: String = DEFS[id]["texture"]
		if ResourceLoader.exists(tex):
			m.albedo_texture = load(tex)
		else:
			m.albedo_color = Color("8a5a32")
		m.roughness = 0.55
		m.texture_repeat = false
		if DEFS[id].get("cutout", false):
			m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA_SCISSOR
			m.alpha_scissor_threshold = 0.5
			m.cull_mode = BaseMaterial3D.CULL_DISABLED
		_materials[id] = m
	var size: float = DEFS[id]["size"]
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	# Model bloğun köşesinden (0,0,0) başlar; tabanda ortalanır.
	for i in 4:
		var d: Vector3i = SIDES[i]
		_face(st, Vector3(d), 0 if (mask >> i) & 1 == 1 else 1, size)
	_face(st, Vector3.UP, 2, size)
	if not DEFS[id].get("cutout", false):
		_face(st, Vector3.DOWN, 1, size)
	var mesh := st.commit()
	mesh.surface_set_material(0, _materials[id])
	_meshes[key] = mesh
	return mesh


## n yönüne bakan yüz; region 0 ön, 1 yan, 2 üst (dokudaki üç kareden biri).
static func _face(st: SurfaceTool, n: Vector3, region: int, size: float) -> void:
	var up := Vector3.UP if absf(n.y) < 0.5 else Vector3(0, 0, -1)
	var right := up.cross(n)  # dışarıdan bakınca sağ
	var h := size * 0.5
	var c := Vector3(0.5, h, 0.5) + n * h
	var w := CELL + 2.0 * PAD
	var u0 := (region * w + PAD) / (3.0 * w)
	var u1 := (region * w + PAD + CELL) / (3.0 * w)
	var v0 := PAD / w
	var v1 := (PAD + CELL) / w
	var corners := [
		[c - right * h + up * h, Vector2(u0, v0)],
		[c + right * h + up * h, Vector2(u1, v0)],
		[c + right * h - up * h, Vector2(u1, v1)],
		[c - right * h - up * h, Vector2(u0, v1)],
	]
	for k: int in [0, 1, 2, 0, 2, 3]:
		st.set_normal(n)
		st.set_uv(corners[k][1])
		st.add_vertex(corners[k][0])
