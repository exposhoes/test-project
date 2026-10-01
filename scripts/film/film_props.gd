class_name FilmProps
extends RefCounted
## Setlerdeki gerçek ev eşyaları (gardırop, çalışma masası, buzdolabı...).
## Mehmet'in GLB'si assets/models/esya_<ad>.glb varsa o yüklenir ve tabana sığdırılır;
## yoksa köşeli (blok tarzı) yedek kutulardan kurulur. İstemler: docs/gorsel-istemleri-esyalar.md

## Eşya yüksekliği (blok). Yürünemeyen hücreler ve GLB ölçeği buna göre.
const HEIGHTS := {
	"gardirop": 2.0, "calisma_masasi": 0.8, "mutfak_tezgahi": 0.9, "ocak": 0.9,
	"buzdolabi": 1.9, "yemek_masasi": 0.8, "canta": 0.4, "komodin": 0.6, "oyuncak_kutusu": 0.6, "kalemlik": 0.18, "defter": 0.03,
}
## Yedek kutular: [boyut, merkez (tabana göre, taban 0..size), renk]. Taban 1x1 için yazıldı,
## daha geniş tabanlarda x/z ölçeklenir.
const WOOD := Color("9a6a3f")
const DARK := Color("5b3a22")
const WHITE := Color("eceff1")
const STEEL := Color("9ea7ad")


static func height(id: String) -> float:
	return HEIGHTS.get(id, 1.0)


## Eşyayı kurar; köşesi (0,0,0), tabanı size.x × size.y blok.
static func build(id: String, size: Vector2i) -> Node3D:
	var root := Node3D.new()
	root.name = "Esya_" + id
	var foot := Vector3(size.x, height(id), size.y)
	var png := _load_png_box(id, foot)
	var glb := png if png else _load_glb(id, foot)
	if glb:
		root.add_child(glb)
	else:
		_fallback(root, id, foot)
	if id == "calisma_masasi":
		# Emir'in okul eşyaları masanın üstünde: çanta, kalemlik, defter.
		var top := height(id)
		_place_small(root, "canta", Vector3(0.45, top, 0.55), Vector3(0.5, 0.4, 0.3), Color("2e6fd8"))
		_place_small(root, "defter", Vector3(1.15, top, 0.5), Vector3(0.32, 0.03, 0.42), Color("f2c14e"))
		_place_small(root, "kalemlik", Vector3(1.6, top, 0.4), Vector3(0.14, 0.18, 0.14), Color("d94b4b"))
	return root


static func _place_small(root: Node3D, id: String, at: Vector3, box: Vector3, color: Color) -> void:
	var n := _load_png_box(id, box)
	if n:
		n.position = Vector3(-box.x / 2, 0, -box.z / 2)
		var h := Node3D.new()
		h.add_child(n)
		n = h
	else:
		n = _load_glb(id, box)
	if n == null:
		n = Node3D.new()
		_box(n, box, Vector3(0, box.y / 2, 0), color)
		if id == "kalemlik":
			for i in 3:
				_box(n, Vector3(0.025, 0.16, 0.025), Vector3(-0.03 + i * 0.03, 0.22, 0), [Color("ffd23f"), Color("3aa655"), Color("2e6fd8")][i])
		elif id == "canta":
			_box(n, Vector3(0.3, 0.06, 0.04), Vector3(0, 0.42, 0), Color("1d4d9e"))  # sap
	else:
		var holder := Node3D.new()
		holder.add_child(n)
		n.position = Vector3(-box.x / 2, 0, -box.z / 2)
		n = holder
	n.position = at
	root.add_child(n)


## GLB'yi tabana ortalar, en/boy/yüksekliğe sığacak biçimde ölçekler (pivot zeminde).
static func _load_glb(id: String, foot: Vector3) -> Node3D:
	var path := "res://assets/models/esya_%s.glb" % id
	if not ResourceLoader.exists(path):
		return null
	var model: Node3D = (load(path) as PackedScene).instantiate()
	var box := AABB()
	var first := true
	for m in model.find_children("*", "MeshInstance3D", true, false):
		var mi := m as MeshInstance3D
		var b := mi.get_aabb()
		var t := Transform3D.IDENTITY
		var p: Node = mi
		while p != model and p is Node3D:
			t = (p as Node3D).transform * t
			p = p.get_parent()
		b = t * b
		box = b if first else box.merge(b)
		first = false
	if first or box.size.y <= 0.0:
		return model
	var k := minf(minf(foot.x / maxf(box.size.x, 0.01), foot.z / maxf(box.size.z, 0.01)), foot.y / box.size.y)
	var holder := Node3D.new()
	holder.add_child(model)
	model.scale = Vector3.ONE * k
	var c := box.get_center() * k
	model.position = Vector3(foot.x / 2 - c.x, -box.position.y * k, foot.z / 2 - c.z)
	return holder


static func _fallback(root: Node3D, id: String, f: Vector3) -> void:
	match id:
		"gardirop":
			_box(root, Vector3(f.x - 0.04, f.y, f.z - 0.1), Vector3(f.x / 2, f.y / 2, f.z / 2 - 0.05), WOOD)
			# İki kapak, ortada çizgi ve kulplar (oda içine, +x yönüne bakar).
			_box(root, Vector3(0.02, f.y - 0.12, f.z / 2 - 0.08), Vector3(f.x - 0.01, f.y / 2, f.z * 0.25), Color("b07a48"))
			_box(root, Vector3(0.02, f.y - 0.12, f.z / 2 - 0.08), Vector3(f.x - 0.01, f.y / 2, f.z * 0.75 - 0.1), Color("b07a48"))
			_box(root, Vector3(0.04, 0.22, 0.04), Vector3(f.x + 0.01, f.y / 2, f.z / 2 - 0.13), DARK)
			_box(root, Vector3(0.04, 0.22, 0.04), Vector3(f.x + 0.01, f.y / 2, f.z / 2 + 0.03), DARK)
		"calisma_masasi", "yemek_masasi":
			_box(root, Vector3(f.x - 0.05, 0.06, f.z - 0.05), Vector3(f.x / 2, f.y - 0.03, f.z / 2), WOOD)
			for c in [Vector2(0.1, 0.1), Vector2(f.x - 0.1, 0.1), Vector2(0.1, f.z - 0.1), Vector2(f.x - 0.1, f.z - 0.1)]:
				_box(root, Vector3(0.07, f.y - 0.06, 0.07), Vector3(c.x, (f.y - 0.06) / 2, c.y), DARK)
		"mutfak_tezgahi":
			_box(root, Vector3(f.x - 0.02, f.y - 0.05, f.z - 0.08), Vector3(f.x / 2, (f.y - 0.05) / 2, f.z / 2), WHITE)
			_box(root, Vector3(f.x, 0.05, f.z), Vector3(f.x / 2, f.y - 0.025, f.z / 2), Color("6d6d6d"))
			for i in int(f.x):
				_box(root, Vector3(0.3, 0.03, 0.02), Vector3(i + 0.5, f.y - 0.2, f.z - 0.03), STEEL)
		"ocak":
			_box(root, Vector3(f.x - 0.04, f.y, f.z - 0.08), Vector3(f.x / 2, f.y / 2, f.z / 2), WHITE)
			_box(root, Vector3(0.6, 0.4, 0.02), Vector3(f.x / 2, 0.35, f.z - 0.03), Color("222222"))
			for c in [Vector2(0.3, 0.3), Vector2(0.7, 0.3), Vector2(0.3, 0.7), Vector2(0.7, 0.7)]:
				_box(root, Vector3(0.22, 0.02, 0.22), Vector3(c.x, f.y + 0.01, c.y), Color("333333"))
		"buzdolabi":
			_box(root, Vector3(f.x - 0.06, f.y, f.z - 0.08), Vector3(f.x / 2, f.y / 2, f.z / 2), WHITE)
			_box(root, Vector3(0.02, 0.02, f.z - 0.12), Vector3(0.0, f.y * 0.62, f.z / 2), STEEL)
			_box(root, Vector3(0.03, 0.4, 0.04), Vector3(0.0, f.y * 0.8, 0.15), STEEL)
		"komodin":
			_box(root, Vector3(0.7, f.y, 0.7), Vector3(0.5, f.y / 2, 0.5), Color("f4f1ea"))
			_box(root, Vector3(0.02, 0.2, 0.55), Vector3(0.86, f.y * 0.55, 0.5), Color("e2dccd"))
			# Gece lambası
			_box(root, Vector3(0.12, 0.25, 0.12), Vector3(0.5, f.y + 0.12, 0.5), Color("8a8a8a"))
			_box(root, Vector3(0.3, 0.2, 0.3), Vector3(0.5, f.y + 0.32, 0.5), Color("ffe9a8"))
		"oyuncak_kutusu":
			_box(root, Vector3(0.8, f.y, 0.8), Vector3(0.5, f.y / 2, 0.5), Color("3aa0d8"))
			_box(root, Vector3(0.18, 0.18, 0.18), Vector3(0.35, f.y + 0.06, 0.4), Color("e84a4a"))
			_box(root, Vector3(0.15, 0.25, 0.15), Vector3(0.65, f.y + 0.05, 0.6), Color("ffd23f"))
		_:
			_box(root, f, f / 2, WOOD)


static func _box(parent: Node3D, size: Vector3, center: Vector3, color: Color) -> void:
	var mi := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = size
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mat.roughness = 0.8
	mesh.material = mat
	mi.mesh = mesh
	mi.position = center
	parent.add_child(mi)


## Duvar/zemin süsleri: GLB varsa o (esya_<ad>.glb), yoksa köşeli yedek. Pivot: zemin ya da duvar yüzeyi.
const DECOR_SIZE := {
	"poster": Vector3(0.9, 1.2, 0.03), "duvar_saati": Vector3(0.5, 0.5, 0.06),
	"futbol_topu": Vector3(0.35, 0.35, 0.35), "oda_halisi": Vector3(2.2, 0.02, 1.6),
}


static func build_decor(id: String) -> Node3D:
	var size: Vector3 = DECOR_SIZE.get(id, Vector3.ONE * 0.5)
	var root := Node3D.new()
	root.name = "Sus_" + id
	var glb := _load_png_box(id, size)
	if glb == null:
		glb = _load_glb(id, size)
	if glb:
		glb.position = Vector3(-size.x / 2, 0, -size.z / 2)
		root.add_child(glb)
		return root
	match id:
		"poster":
			_box(root, size, Vector3(0, 0, 0), Color("1f3b73"))
			_box(root, Vector3(0.6, 0.5, 0.01), Vector3(0, 0.15, 0.02), Color("ffd23f"))
			_box(root, Vector3(0.7, 0.12, 0.01), Vector3(0, -0.4, 0.02), Color("ffffff"))
		"duvar_saati":
			_box(root, size, Vector3.ZERO, Color("ffffff"))
			_box(root, Vector3(0.03, 0.18, 0.01), Vector3(0, 0.07, 0.04), Color("222222"))
			_box(root, Vector3(0.13, 0.03, 0.01), Vector3(0.05, 0, 0.04), Color("222222"))
		"futbol_topu":
			_box(root, size, Vector3(0, size.y / 2, 0), Color("f5f5f5"))
			_box(root, Vector3(0.12, 0.12, 0.36), Vector3(0, size.y / 2, 0), Color("222222"))
		"oda_halisi":
			_box(root, size, Vector3(0, 0.01, 0), Color("6fb3e0"))
			_box(root, Vector3(1.6, 0.022, 1.0), Vector3(0, 0.012, 0), Color("a9d6f2"))
		_:
			_box(root, size, Vector3(0, size.y / 2, 0), WOOD)
	return root


## Mehmet'in eşya resmi: assets/textures/esya/<ad>.png — koyu arka plan üstünde soldan sağa
## ÖN, YAN ve ÜST görünüş. Üç parça otomatik ayrılır, arka plan saydam yapılır ve
## eşyanın kutusunun yüzlerine kaplanır (ön +Z, yanlar ±X, üst +Y; arka = ön).
static var _png_cache := {}


static func _load_png_box(id: String, foot: Vector3) -> Node3D:
	var path := "res://assets/textures/esya/%s.png" % id
	if not ResourceLoader.exists(path) and not FileAccess.file_exists(path):
		return null
	if not _png_cache.has(id):
		var img: Image = null
		var tex = load(path)
		if tex is Texture2D:
			img = (tex as Texture2D).get_image()
		else:
			img = Image.load_from_file(path)
		if img == null:
			return null
		if img.is_compressed():
			img.decompress()
		img.convert(Image.FORMAT_RGBA8)
		_png_cache[id] = _split_views(img)
	var views: Array = _png_cache[id]
	if views.size() < 3:
		return null
	var root := Node3D.new()
	var x := foot.x
	var y := foot.y
	var z := foot.z
	# ön (+Z) ve arka
	_quad(root, views[0], Vector3(x / 2, y / 2, z), Vector3(x, y, 0), 0.0)
	_quad(root, views[0], Vector3(x / 2, y / 2, 0), Vector3(x, y, 0), PI)
	# yanlar
	_quad(root, views[1], Vector3(x, y / 2, z / 2), Vector3(z, y, 0), PI / 2)
	_quad(root, views[1], Vector3(0, y / 2, z / 2), Vector3(z, y, 0), -PI / 2)
	# üst
	var top := MeshInstance3D.new()
	var pm := PlaneMesh.new()
	pm.size = Vector2(x, z)
	pm.material = _mat(views[2])
	top.mesh = pm
	top.position = Vector3(x / 2, y, z / 2)
	root.add_child(top)
	return root


static func _quad(root: Node3D, tex: Texture2D, center: Vector3, size: Vector3, turn: float) -> void:
	var mi := MeshInstance3D.new()
	var q := QuadMesh.new()
	q.size = Vector2(size.x, size.y)
	q.material = _mat(tex)
	mi.mesh = q
	mi.position = center
	mi.rotation.y = turn
	root.add_child(mi)


static func _mat(tex: Texture2D) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_texture = tex
	m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA_SCISSOR
	m.alpha_scissor_threshold = 0.5
	m.cull_mode = BaseMaterial3D.CULL_DISABLED
	m.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	m.roughness = 0.9
	return m


## Arka plan rengi (sol üst köşe) dışındaki sütun gruplarını bulur; en geniş 3 grubu
## soldan sağa ön/yan/üst olarak kırpıp saydam arka planlı dokuya çevirir.
static func _split_views(img: Image) -> Array:
	var w := img.get_width()
	var h := img.get_height()
	var bg := img.get_pixel(2, 2)
	var is_bg := func(c: Color) -> bool:
		return absf(c.r - bg.r) + absf(c.g - bg.g) + absf(c.b - bg.b) < 0.12 or c.a < 0.1
	var cols: Array[bool] = []
	for px in w:
		var hit := false
		for py in range(0, h, 2):
			if not is_bg.call(img.get_pixel(px, py)):
				hit = true
				break
		cols.append(hit)
	var runs: Array = []
	var start := -1
	for px in w + 1:
		var on := px < w and cols[px]
		if on and start < 0:
			start = px
		elif not on and start >= 0:
			if px - start > w / 40:
				runs.append(Vector2i(start, px))
			start = -1
	runs.sort_custom(func(a: Vector2i, b: Vector2i) -> bool: return (a.y - a.x) > (b.y - b.x))
	runs = runs.slice(0, 3)
	runs.sort_custom(func(a: Vector2i, b: Vector2i) -> bool: return a.x < b.x)
	var out: Array = []
	for r: Vector2i in runs:
		var top := h
		var bottom := 0
		for py in h:
			for px in range(r.x, r.y, 2):
				if not is_bg.call(img.get_pixel(px, py)):
					top = mini(top, py)
					bottom = maxi(bottom, py)
					break
		var part := img.get_region(Rect2i(r.x, top, r.y - r.x, bottom - top + 1))
		for py in part.get_height():
			for px in part.get_width():
				if is_bg.call(part.get_pixel(px, py)):
					part.set_pixel(px, py, Color(0, 0, 0, 0))
		part.generate_mipmaps()
		out.append(ImageTexture.create_from_image(part))
	return out
