class_name FilmProps
extends RefCounted
## Setlerdeki gerçek ev eşyaları (gardırop, çalışma masası, buzdolabı...).
## Mehmet'in GLB'si assets/models/esya_<ad>.glb varsa o yüklenir ve tabana sığdırılır;
## yoksa köşeli (blok tarzı) yedek kutulardan kurulur. İstemler: docs/gorsel-istemleri-esyalar.md

## Eşya yüksekliği (blok). Yürünemeyen hücreler ve GLB ölçeği buna göre.
const HEIGHTS := {
	"gardirop": 2.0, "calisma_masasi": 0.8, "mutfak_tezgahi": 0.9, "ocak": 0.9,
	"buzdolabi": 1.9, "yemek_masasi": 0.8, "canta": 0.4, "komodin": 0.6, "ogretmen_masasi": 0.8, "market_rafi": 2.0, "oyuncak_kutusu": 0.6, "kalemlik": 0.18, "defter": 0.03,
}
## Yedek kutular: [boyut, merkez (tabana göre, taban 0..size), renk]. Taban 1x1 için yazıldı,
## daha geniş tabanlarda x/z ölçeklenir.
const WOOD := Color("9a6a3f")
const DARK := Color("5b3a22")
const WHITE := Color("eceff1")
const STEEL := Color("9ea7ad")


static func height(id: String) -> float:
	return HEIGHTS.get(id, 1.0)


## Eşyanın ön yüzünün baktığı yön (y dönüşü). Model önü +Z'ye bakacak biçimde kurulur.
## 0: +Z, PI/2: +X, PI: -Z, -PI/2: -X. Setteki duvara göre odaya bakar.
const FACING := {
	"gardirop": PI / 2, "oyuncak_kutusu": PI / 2, "market_rafi": PI / 2,
	"calisma_masasi": PI, "buzdolabi": -PI / 2,
}


## Eşyayı kurar; köşesi (0,0,0), tabanı size.x × size.y blok. Eşyalar parça parça köşeli
## bloklardan kurulur (bacak, tabla, kapak, kulp); ana rengi Mehmet'in PNG'sinin ön görünüşünden alınır.
static func build(id: String, size: Vector2i) -> Node3D:
	var root := Node3D.new()
	root.name = "Esya_" + id
	var turn: float = FACING.get(id, 0.0)
	var side := absf(sin(turn)) > 0.5
	var foot := Vector3(size.y if side else size.x, height(id), size.x if side else size.y)
	var model := Node3D.new()
	var glb := _load_glb(id, foot)
	if glb:
		model.add_child(glb)
	else:
		_model(model, id, foot)
	model.position = Vector3(-foot.x / 2, 0, -foot.z / 2)
	var pivot := Node3D.new()
	pivot.add_child(model)
	pivot.rotation.y = turn
	pivot.position = Vector3(size.x / 2.0, 0, size.y / 2.0)
	root.add_child(pivot)
	if id == "calisma_masasi":
		# Emir'in okul eşyaları masanın üstünde: çanta, kalemlik, defter.
		var top := height(id)
		_place_small(model, "canta", Vector3(0.4, top, 0.45), Vector3(0.5, 0.4, 0.3), Color("2e6fd8"))
		_place_small(model, "defter", Vector3(1.1, top, 0.5), Vector3(0.32, 0.03, 0.42), Color("f2c14e"))
		_place_small(model, "kalemlik", Vector3(1.6, top, 0.6), Vector3(0.14, 0.18, 0.14), Color("d94b4b"))
	return root


## PNG'nin ön görünüşündeki baskın renk (eşyanın ana rengi); PNG yoksa verilen renk.
static var _tone_cache := {}


static func _tone(id: String, fallback: Color) -> Color:
	if _tone_cache.has(id):
		return _tone_cache[id]
	var c := fallback
	var views := _views(id)
	if views.size() >= 1:
		var img: Image = (views[0] as Texture2D).get_image()
		var buckets := {}
		var step := maxi(1, img.get_width() / 48)
		for y in range(0, img.get_height(), step):
			for x in range(0, img.get_width(), step):
				var px := img.get_pixel(x, y)
				if px.a < 0.9:
					continue
				var key := Vector3i(int(px.r * 8), int(px.g * 8), int(px.b * 8))
				buckets[key] = buckets.get(key, []) + [px]
		var best: Array = []
		for k in buckets:
			if buckets[k].size() > best.size():
				best = buckets[k]
		if best.size() > 0:
			var s := Color(0, 0, 0)
			for px: Color in best:
				s += px
			c = Color(s.r / best.size(), s.g / best.size(), s.b / best.size())
	_tone_cache[id] = c
	return c


static func _place_small(root: Node3D, id: String, at: Vector3, box: Vector3, color: Color) -> void:
	var n := Node3D.new()
	var c := _tone(id, color)
	match id:
		"canta":
			_box(n, Vector3(box.x, box.y, box.z), Vector3(0, box.y / 2, 0), c)
			_box(n, Vector3(box.x * 0.7, box.y * 0.45, 0.06), Vector3(0, box.y * 0.3, box.z / 2 + 0.03), c.darkened(0.15))
			_box(n, Vector3(0.2, 0.05, 0.04), Vector3(0, box.y + 0.03, 0), c.darkened(0.35))
			_box(n, Vector3(0.05, box.y * 0.8, 0.03), Vector3(-0.13, box.y / 2, -box.z / 2 - 0.015), c.darkened(0.35))
			_box(n, Vector3(0.05, box.y * 0.8, 0.03), Vector3(0.13, box.y / 2, -box.z / 2 - 0.015), c.darkened(0.35))
		"defter":
			_box(n, box, Vector3(0, box.y / 2, 0), c)
			_box(n, Vector3(0.03, box.y + 0.01, box.z - 0.04), Vector3(-box.x / 2 + 0.02, box.y / 2, 0), Color("b0b0b0"))
		"kalemlik":
			_box(n, box, Vector3(0, box.y / 2, 0), c)
			for i in 3:
				_box(n, Vector3(0.025, 0.16, 0.025), Vector3(-0.035 + i * 0.035, box.y + 0.03, -0.02 + (i % 2) * 0.03), [Color("ffd23f"), Color("3aa655"), Color("2e6fd8")][i])
		_:
			_box(n, box, Vector3(0, box.y / 2, 0), c)
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


## Köşeli eşya modeli. Yerel düzen: en x, derinlik z, ön yüz +Z (z = f.z), taban y = 0.
static func _model(r: Node3D, id: String, f: Vector3) -> void:
	var w := f.x
	var d := f.z
	var h := f.y
	match id:
		"gardirop":
			var c := _tone(id, Color("d9b383"))
			var dw := w - 0.08
			_box(r, Vector3(w - 0.06, 0.08, d - 0.3), Vector3(w / 2, 0.04, d / 2 - 0.12), c.darkened(0.45))  # kaide
			_box(r, Vector3(dw, h - 0.14, d - 0.25), Vector3(w / 2, 0.08 + (h - 0.14) / 2, d / 2 - 0.12), c)
			_box(r, Vector3(w, 0.06, d - 0.2), Vector3(w / 2, h - 0.03, d / 2 - 0.1), c.darkened(0.12))  # üst pervaz
			var fz := d - 0.25 + 0.01
			for k in 2:
				var cx := w / 2 + (k - 0.5) * dw / 2
				_box(r, Vector3(dw / 2 - 0.03, h - 0.24, 0.03), Vector3(cx, 0.08 + (h - 0.14) / 2, fz), c.lightened(0.06))
				_box(r, Vector3(dw / 2 - 0.2, h - 0.6, 0.02), Vector3(cx, 0.08 + (h - 0.14) / 2, fz + 0.02), c.darkened(0.05))
				_box(r, Vector3(0.06, 0.06, 0.05), Vector3(w / 2 + (k - 0.5) * 0.14, h * 0.5, fz + 0.04), c.darkened(0.5))
		"calisma_masasi", "yemek_masasi", "ogretmen_masasi":
			var c := _tone(id, WOOD)
			var leg := c.darkened(0.2)
			_box(r, Vector3(w - 0.04, 0.06, d - 0.06), Vector3(w / 2, h - 0.03, d / 2), c)  # tabla
			var lw := 0.07
			for p in [Vector2(0.08, 0.1), Vector2(w - 0.08, 0.1), Vector2(0.08, d - 0.1), Vector2(w - 0.08, d - 0.1)]:
				_box(r, Vector3(lw, h - 0.06, lw), Vector3(p.x, (h - 0.06) / 2, p.y), leg)
			_box(r, Vector3(w - 0.2, 0.09, 0.03), Vector3(w / 2, h - 0.11, d - 0.1), leg)  # kuşak ön
			_box(r, Vector3(w - 0.2, 0.09, 0.03), Vector3(w / 2, h - 0.11, 0.1), leg)
			_box(r, Vector3(0.03, 0.09, d - 0.24), Vector3(0.08, h - 0.11, d / 2), leg)
			_box(r, Vector3(0.03, 0.09, d - 0.24), Vector3(w - 0.08, h - 0.11, d / 2), leg)
			if id == "calisma_masasi":
				_box(r, Vector3(0.5, 0.12, 0.03), Vector3(w * 0.7, h - 0.13, d - 0.08), c.lightened(0.08))
				_box(r, Vector3(0.1, 0.03, 0.03), Vector3(w * 0.7, h - 0.13, d - 0.05), c.darkened(0.5))
			elif id == "ogretmen_masasi":
				_box(r, Vector3(w - 0.2, h - 0.25, 0.03), Vector3(w / 2, (h - 0.06) / 2 + 0.05, d - 0.1), c.darkened(0.08))  # ön panel
				_box(r, Vector3(0.45, h - 0.12, d - 0.25), Vector3(w - 0.32, (h - 0.06) / 2, d / 2), c.darkened(0.04))  # çekmece gövdesi
				for k in 2:
					_box(r, Vector3(0.1, 0.03, 0.03), Vector3(w - 0.32, h * (0.3 + 0.3 * k), 0.1), c.darkened(0.5))
				_box(r, Vector3(0.35, 0.06, 0.25), Vector3(0.45, h + 0.03, d / 2), Color("b23b3b"))  # kitaplar
				_box(r, Vector3(0.33, 0.05, 0.24), Vector3(0.46, h + 0.085, d / 2), Color("2e6fd8"))
		"mutfak_tezgahi":
			var c := _tone(id, WHITE)
			_box(r, Vector3(w - 0.06, 0.1, d - 0.12), Vector3(w / 2, 0.05, d / 2 - 0.06), Color("3a3a3a"))  # kaide
			_box(r, Vector3(w - 0.02, h - 0.15, d - 0.05), Vector3(w / 2, 0.1 + (h - 0.15) / 2, d / 2 - 0.02), c)
			_box(r, Vector3(w, 0.05, d), Vector3(w / 2, h - 0.025, d / 2), Color("7b7f84"))  # tezgâh taşı
			var doors := int(round(w / 0.5))
			for k in doors:
				var cx := (k + 0.5) * w / doors
				_box(r, Vector3(w / doors - 0.03, h - 0.24, 0.02), Vector3(cx, 0.1 + (h - 0.19) / 2, d - 0.06), c.lightened(0.04))
				_box(r, Vector3(0.12, 0.025, 0.03), Vector3(cx, h - 0.2, d - 0.035), STEEL)
			_box(r, Vector3(0.5, 0.012, 0.35), Vector3(w * 0.3, h + 0.001, d / 2), Color("5d6268"))  # evye
			_box(r, Vector3(0.03, 0.25, 0.03), Vector3(w * 0.3, h + 0.125, 0.15), STEEL)  # musluk
			_box(r, Vector3(0.03, 0.03, 0.15), Vector3(w * 0.3, h + 0.24, 0.22), STEEL)
		"ocak":
			var c := _tone(id, WHITE)
			_box(r, Vector3(w - 0.04, h, d - 0.06), Vector3(w / 2, h / 2, d / 2 - 0.02), c)
			_box(r, Vector3(w - 0.2, h * 0.5, 0.02), Vector3(w / 2, h * 0.35, d - 0.04), Color("202428"))  # fırın camı
			_box(r, Vector3(w - 0.3, 0.03, 0.04), Vector3(w / 2, h * 0.65, d - 0.02), STEEL)
			for k in 4:
				_box(r, Vector3(0.05, 0.05, 0.03), Vector3(0.2 + k * (w - 0.4) / 3, h * 0.85, d - 0.04), Color("333333"))
			for p in [Vector2(0.28, 0.3), Vector2(w - 0.28, 0.3), Vector2(0.28, d - 0.35), Vector2(w - 0.28, d - 0.35)]:
				_box(r, Vector3(0.22, 0.02, 0.22), Vector3(p.x, h + 0.01, p.y), Color("1f1f1f"))
		"buzdolabi":
			var c := _tone(id, WHITE)
			_box(r, Vector3(w - 0.08, h, d - 0.1), Vector3(w / 2, h / 2, d / 2 - 0.04), c)
			_box(r, Vector3(w - 0.1, 0.015, 0.03), Vector3(w / 2, h * 0.66, d - 0.08), c.darkened(0.25))  # kapı arası
			_box(r, Vector3(0.035, 0.35, 0.05), Vector3(w * 0.78, h * 0.8, d - 0.05), STEEL)
			_box(r, Vector3(0.035, 0.6, 0.05), Vector3(w * 0.78, h * 0.42, d - 0.05), STEEL)
		"komodin":
			var c := _tone(id, Color("f4f1ea"))
			_box(r, Vector3(0.6, h - 0.05, 0.55), Vector3(w / 2, (h - 0.05) / 2 + 0.05, d / 2), c)
			for p in [Vector2(-0.25, -0.22), Vector2(0.25, -0.22), Vector2(-0.25, 0.22), Vector2(0.25, 0.22)]:
				_box(r, Vector3(0.05, 0.05, 0.05), Vector3(w / 2 + p.x, 0.025, d / 2 + p.y), c.darkened(0.3))
			_box(r, Vector3(0.5, 0.18, 0.02), Vector3(w / 2, h * 0.65, d / 2 + 0.28), c.darkened(0.06))
			_box(r, Vector3(0.05, 0.05, 0.04), Vector3(w / 2, h * 0.65, d / 2 + 0.3), Color("8a8a8a"))
			_box(r, Vector3(0.14, 0.04, 0.14), Vector3(w / 2, h + 0.02, d / 2), Color("8a8a8a"))  # lamba
			_box(r, Vector3(0.03, 0.2, 0.03), Vector3(w / 2, h + 0.12, d / 2), Color("8a8a8a"))
			_box(r, Vector3(0.26, 0.18, 0.26), Vector3(w / 2, h + 0.3, d / 2), Color("ffe08a"))
		"oyuncak_kutusu":
			var c := _tone(id, Color("6fb8e6"))
			var bw := 0.75
			_box(r, Vector3(bw, 0.04, bw), Vector3(w / 2, 0.02, d / 2), c.darkened(0.1))
			for s in [Vector3(bw, h, 0.04), Vector3(0.04, h, bw)]:
				for sgn in [-1, 1]:
					var off := Vector3(0, 0, sgn * (bw / 2 - 0.02)) if s.x > 0.1 else Vector3(sgn * (bw / 2 - 0.02), 0, 0)
					_box(r, s, Vector3(w / 2, h / 2, d / 2) + off, c)
			_box(r, Vector3(0.25, 0.12, 0.15), Vector3(w / 2 - 0.12, h - 0.02, d / 2 + 0.1), Color("e84a4a"))  # araba
			_box(r, Vector3(0.14, 0.14, 0.14), Vector3(w / 2 + 0.16, h + 0.02, d / 2 - 0.12), Color("ffd23f"))  # ördek
			_box(r, Vector3(0.12, 0.12, 0.12), Vector3(w / 2 + 0.1, h - 0.04, d / 2 + 0.15), Color("3aa655"))
			_box(r, Vector3(0.12, 0.12, 0.12), Vector3(w / 2 - 0.15, h - 0.03, d / 2 - 0.15), Color("2e6fd8"))
		"market_rafi":
			var c := _tone(id, Color("eeeeee"))
			_box(r, Vector3(w - 0.05, h, 0.05), Vector3(w / 2, h / 2, 0.05), c)  # arka
			_box(r, Vector3(0.05, h, d - 0.1), Vector3(0.03, h / 2, d / 2), c.darkened(0.08))
			_box(r, Vector3(0.05, h, d - 0.1), Vector3(w - 0.03, h / 2, d / 2), c.darkened(0.08))
			var cols := [Color("e84a4a"), Color("ffd23f"), Color("3aa655"), Color("2e6fd8"), Color("ff8fc8"), Color("f08a24")]
			for i in 4:
				var sy := 0.08 + i * 0.5
				_box(r, Vector3(w - 0.1, 0.04, d - 0.12), Vector3(w / 2, sy, d / 2), c.darkened(0.15))
				var n := int((w - 0.2) / 0.3)
				for k in n:
					var hh := 0.2 + float((i * 7 + k * 3) % 3) * 0.06
					_box(r, Vector3(0.24, hh, d * 0.55), Vector3(0.2 + k * 0.3, sy + 0.02 + hh / 2, d / 2 + 0.05), cols[(i * 3 + k) % cols.size()])
		_:
			_box(r, f, f / 2, WOOD)


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
	if id != "futbol_topu":
		var flat := _flat_png(id, size)
		if flat:
			root.add_child(flat)
			return root
	var glb := _load_glb(id, size)
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
			var mi := MeshInstance3D.new()
			var sm := SphereMesh.new()
			sm.radius = size.x / 2
			sm.height = size.y
			var m := StandardMaterial3D.new()
			m.albedo_color = Color("f5f5f5")
			sm.material = m
			mi.mesh = sm
			mi.position = Vector3(0, size.y / 2, 0)
			root.add_child(mi)
			for p in [Vector3(0, 1, 0), Vector3(1, 0, 0), Vector3(-1, 0, 0), Vector3(0, 0, 1), Vector3(0, 0, -1), Vector3(0.6, 0.6, 0.5)]:
				_box(root, Vector3.ONE * size.x * 0.28, Vector3(0, size.y / 2, 0) + p.normalized() * size.x * 0.4, Color("222222"))
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


static func _views(id: String) -> Array:
	var path := "res://assets/textures/esya/%s.png" % id
	if not ResourceLoader.exists(path) and not FileAccess.file_exists(path):
		return []
	if not _png_cache.has(id):
		var img: Image = null
		var tex = load(path)
		if tex is Texture2D:
			img = (tex as Texture2D).get_image()
		else:
			img = Image.load_from_file(path)
		if img == null:
			return []
		if img.is_compressed():
			img.decompress()
		img.convert(Image.FORMAT_RGBA8)
		_png_cache[id] = _split_views(img)
	return _png_cache[id]


## Duvara asılı/yerde düz süs (poster, saat, halı): PNG'nin ön (halıda üst) görünüşü tek yüzeyde.
static func _flat_png(id: String, size: Vector3) -> Node3D:
	var views := _views(id)
	if views.size() < 3:
		return null
	var root := Node3D.new()
	var mi := MeshInstance3D.new()
	if id == "oda_halisi":
		var pm := PlaneMesh.new()
		pm.size = Vector2(size.x, size.z)
		pm.material = _mat(views[2])
		mi.mesh = pm
		mi.position = Vector3(0, 0.012, 0)
	else:
		_box(root, Vector3(size.x, size.y, 0.02), Vector3(0, 0, -0.005), Color("ffffff") if id == "duvar_saati" else Color("f0f0f0"))
		var q := QuadMesh.new()
		q.size = Vector2(size.x, size.y)
		q.material = _mat(views[0])
		mi.mesh = q
		mi.position = Vector3(0, 0, 0.012)
	root.add_child(mi)
	return root


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


const EDGE_TRIM := 3  # kenardan kırpılan piksel; üreticinin bıraktığı açık renkli kenar çizgisini siler


## Saydam kenara komşu açık renkli halkayı keser, sonra saydam piksellere komşu rengi taşır
## (doku filtrelenince kenarda beyaz/siyah çizgi oluşmasın diye).
static func _clean_edges(part: Image) -> void:
	var w := part.get_width()
	var h := part.get_height()
	for _i in EDGE_TRIM:
		var cut: Array[Vector2i] = []
		for py in h:
			for px in w:
				if part.get_pixel(px, py).a == 0.0:
					continue
				if px == 0 or py == 0 or px == w - 1 or py == h - 1 \
						or part.get_pixel(px - 1, py).a == 0.0 or part.get_pixel(px + 1, py).a == 0.0 \
						or part.get_pixel(px, py - 1).a == 0.0 or part.get_pixel(px, py + 1).a == 0.0:
					cut.append(Vector2i(px, py))
		for c in cut:
			part.set_pixelv(c, Color(0, 0, 0, 0))
	for _i in 4:
		var fill: Array = []
		for py in h:
			for px in w:
				if part.get_pixel(px, py).a > 0.0:
					continue
				for d: Vector2i in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
					var q := Vector2i(px, py) + d
					if q.x >= 0 and q.y >= 0 and q.x < w and q.y < h:
						var c := part.get_pixelv(q)
						if c.a > 0.0 or c.r + c.g + c.b > 0.0:
							fill.append([Vector2i(px, py), Color(c.r, c.g, c.b, 0.0)])
							break
		for f in fill:
			part.set_pixelv(f[0], f[1])


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
		_clean_edges(part)
		part.generate_mipmaps()
		out.append(ImageTexture.create_from_image(part))
	return out


## Açılır ahşap giriş kapısı: menteşe sol alt köşede (0,0,0), kapı +X yönüne 1 blok uzanır.
## Doku: assets/textures/esya/kapi_ahsap.png (kodla çizildi).
static func build_door() -> Node3D:
	var root := Node3D.new()
	root.name = "Kapi"
	var hinge := Node3D.new()
	root.add_child(hinge)
	var mi := MeshInstance3D.new()
	var bm := BoxMesh.new()
	bm.size = Vector3(0.96, 2.92, 0.08)
	var m := StandardMaterial3D.new()
	var path := "res://assets/textures/esya/kapi_ahsap.png"
	if ResourceLoader.exists(path) or FileAccess.file_exists(path):
		var tex = load(path)
		m.albedo_texture = tex if tex is Texture2D else ImageTexture.create_from_image(Image.load_from_file(path))
		m.uv1_scale = Vector3(3, 2, 1)  # BoxMesh UV: yüzler 3x2 ızgara; ön yüze tek doku
	else:
		m.albedo_color = Color("b8703a")
	m.roughness = 0.8
	bm.material = m
	mi.mesh = bm
	mi.position = Vector3(0.48, 1.46, 0)
	hinge.add_child(mi)
	return root
