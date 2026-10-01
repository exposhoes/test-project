class_name BedModel
## Yatak bloğunun 3D modeli (Mehmet'in Roblox tarzı yatak görseline göre): ahşap çerçeve, başlık,
## ayak tahtası, ayaklar, beyaz şilte, mavi şerit ve yastık. Yan yana iki yatak bloğu tek uzun yatak olur;
## model baş bloğunda kurulur ve ayak bloğuna uzanır. Tek blok yatak kısa, tam bir yataktır.
## Blok yüzleri çizilmez (Blocks.DEFS[BED]["model"]); çarpışma şilte yüksekliğinde kalır (Chunk).

const HEIGHT := 0.5625  # şilte üstü, çarpışma yüksekliği
const WOOD_TEXTURE := "res://assets/textures/models/bed_wood.png"

static var _wood: StandardMaterial3D
static var _sheet: StandardMaterial3D
static var _stripe: StandardMaterial3D


## pos'taki yatak bloğu için model kurulacaksa {"dir": uzama yönü, "length": 1 ya da 2} döner,
## ayak bloğuysa boş döner. get_block: Callable(Vector3i) -> int.
static func layout(pos: Vector3i, get_block: Callable) -> Dictionary:
	# Çift yatakta baş, eksen boyunca küçük koordinattaki bloktur (setlerde başlık duvar tarafında).
	for axis: Vector3i in [Vector3i(0, 0, 1), Vector3i(1, 0, 0)]:
		if get_block.call(pos - axis) == Blocks.BED and get_block.call(pos - axis * 2) != Blocks.BED:
			return {}  # ayak bloğu: model baş bloğunda kurulur
	for axis: Vector3i in [Vector3i(0, 0, 1), Vector3i(1, 0, 0)]:
		if get_block.call(pos + axis) == Blocks.BED and get_block.call(pos - axis) != Blocks.BED:
			return {"dir": axis, "length": 2}
	return {"dir": Vector3i(0, 0, 1), "length": 1}


static func _materials() -> void:
	if _wood:
		return
	_wood = StandardMaterial3D.new()
	if ResourceLoader.exists(WOOD_TEXTURE):
		_wood.albedo_texture = load(WOOD_TEXTURE)
		_wood.uv1_triplanar = true
		_wood.uv1_scale = Vector3(1.6, 1.6, 1.6)
	else:
		_wood.albedo_color = Color("b87338")
	_wood.roughness = 0.45
	_sheet = StandardMaterial3D.new()
	_sheet.albedo_color = Color("eef1f4")
	_sheet.roughness = 0.55
	_stripe = StandardMaterial3D.new()
	_stripe.albedo_color = Color("2b8ae6")
	_stripe.roughness = 0.4


## Yerel düzlemde yatak +Z yönüne uzanır, başlık z=0'da; x 0..1.
static func create(dir: Vector3i, length: int) -> Node3D:
	_materials()
	var root := Node3D.new()
	root.name = "Yatak"
	var body := Node3D.new()
	root.add_child(body)
	var l := float(length)
	# Bloğun merkezinde döndür, sonra yönüne çevir.
	body.position = Vector3(-0.5, 0, -0.5)
	root.rotation.y = atan2(float(dir.x), float(dir.z))
	var short := length == 1
	var head_h := 0.95 if not short else 0.8
	# Ayaklar
	for x: float in [0.08, 0.92]:
		for z: float in [0.08, l - 0.08]:
			_box(body, Vector3(0.12, 0.14, 0.12), Vector3(x, 0.07, z), _wood)
	# Alt çerçeve (yan kirişler)
	_box(body, Vector3(0.92, 0.18, l - 0.16), Vector3(0.5, 0.22, l / 2.0), _wood)
	# Başlık: ana tahta, üst başlık kapağı, iki dikme
	_box(body, Vector3(1.0, head_h, 0.1), Vector3(0.5, head_h / 2.0, 0.05), _wood)
	_box(body, Vector3(1.04, 0.07, 0.14), Vector3(0.5, head_h - 0.02, 0.05), _wood)
	_box(body, Vector3(0.78, head_h * 0.5, 0.02), Vector3(0.5, head_h * 0.55, 0.105), _wood)  # panel
	# Ayak tahtası
	var foot_h := 0.6 if not short else 0.5
	_box(body, Vector3(1.0, foot_h, 0.1), Vector3(0.5, foot_h / 2.0, l - 0.05), _wood)
	_box(body, Vector3(1.04, 0.06, 0.13), Vector3(0.5, foot_h - 0.01, l - 0.05), _wood)
	# Şilte ve yorgan
	var m_len := l - 0.2
	_box(body, Vector3(0.86, 0.26, m_len), Vector3(0.5, 0.31 + 0.13, l / 2.0), _sheet)
	# Mavi şerit (yorganın kıvrımı)
	var stripe_z := 0.62 if not short else 0.45
	_box(body, Vector3(0.9, 0.285, 0.2 if not short else 0.14), Vector3(0.5, 0.31 + 0.1425, stripe_z), _stripe)
	# Yastık: yumuşak görünsün diye basık küre
	var pillow := MeshInstance3D.new()
	var s := SphereMesh.new()
	s.radius = 0.5
	s.height = 1.0
	s.radial_segments = 16
	s.rings = 8
	pillow.mesh = s
	pillow.material_override = _sheet
	pillow.scale = Vector3(0.56, 0.13, 0.26 if not short else 0.2)
	pillow.position = Vector3(0.5, HEIGHT + 0.03, 0.27 if not short else 0.22)
	body.add_child(pillow)
	return root


static func _box(parent: Node3D, size: Vector3, center: Vector3, mat: Material) -> void:
	var mi := MeshInstance3D.new()
	var b := BoxMesh.new()
	b.size = size
	mi.mesh = b
	mi.material_override = mat
	mi.position = center
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	parent.add_child(mi)
