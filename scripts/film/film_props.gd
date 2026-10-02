class_name FilmProps
extends RefCounted
## Setlerdeki gerçek ev eşyaları (gardırop, çalışma masası, buzdolabı...).
## Mehmet'in GLB'si assets/models/esya_<ad>.glb varsa o yüklenir ve tabana sığdırılır;
## yoksa köşeli (blok tarzı) yedek kutulardan kurulur. İstemler: docs/gorsel-istemleri-esyalar.md

## Eşya yüksekliği (blok). Yürünemeyen hücreler ve GLB ölçeği buna göre.
const HEIGHTS := {
	"gardirop": 2.0, "calisma_masasi": 0.8, "mutfak_tezgahi": 0.9, "ocak": 0.9,
	"buzdolabi": 1.9, "yemek_masasi": 0.8, "canta": 0.4, "komodin": 0.6, "ogretmen_masasi": 0.8, "market_rafi": 2.0, "oyuncak_kutusu": 0.6, "kalemlik": 0.18, "defter": 0.03,
	"koltuk": 0.9, "sehpa": 0.45, "tv": 1.4, "kuvet": 0.6, "lavabo": 0.9, "klozet": 0.8, "camasir_makinesi": 0.9,
	"sandalye": 1.0, "sira": 0.8, "kasa": 1.0, "bank": 0.9, "icecek_dolabi": 2.0, "meyve_reyonu": 0.9,
	"basket_potasi": 3.5, "araba": 1.5, "ambulans": 2.0, "itfaiye_araci": 2.3, "itfaiye_diregi": 5.0, "vitrin": 2.0, "cift_yatak": 0.9, "abajur": 1.5, "ayna": 1.8, "kitaplik": 2.0, "tv_unitesi": 0.6, "ayakkabilik": 1.0, "teleskop": 1.6, "trafik_isigi": 3.2, "otomat": 1.9, "trambolin": 0.8, "pompa": 1.8, "kafes": 1.0, "kopek": 0.7, "kedi": 0.45, "muayene_masasi": 0.9, "sezlong": 0.6, "bisiklet": 1.0, "puf": 0.45, "alet_tezgahi": 0.9, "saksi": 0.9, "semsiye": 2.4, "tramvay": 3.2, "metro": 3.0, "ucak": 4.2, "jet": 2.6, "helikopter": 3.0, "bagaj_bandi": 0.8, "tramvay_sari": 3.2, "tramvay_mavi": 3.2, "bilet_makinesi": 1.7, "tekne": 1.2, "yelkenli": 5.5, "surat_teknesi": 1.1, "havlu": 0.05, "dondurma_arabasi": 1.6, "dus": 2.2, "havluluk": 1.1,
	"ust_dolap": 0.7, "berjer": 0.9, "bitki": 1.3, "koli": 0.6, "kiler_rafi": 2.0, "tv_sehpasi": 1.4,
	"serum_askisi": 1.9, "ilac_dolabi": 2.0, "paravan": 1.8, "tarti": 1.3, "bekleme_koltugu": 0.9,
	"su_sebili": 1.4, "stant": 1.3, "sepetlik": 0.8,
	"pasta_vitrini": 1.3, "ekmek_rafi": 2.0, "ogrenci_dolabi": 1.9, "cop_kutusu": 0.7,
	"yangin_hortumu": 1.6, "kask_askisi": 1.9, "misir_makinesi": 1.7,
}
## Yedek kutular: [boyut, merkez (tabana göre, taban 0..size), renk]. Taban 1x1 için yazıldı,
## daha geniş tabanlarda x/z ölçeklenir.
const WOOD := Color("9a6a3f")
const DARK := Color("5b3a22")
const WHITE := Color("eceff1")
const STEEL := Color("9ea7ad")


static func height(id: String) -> float:
	id = id.get_slice("@", 0)
	if id.begins_with("araba_") or id == "polis_araci":
		return HEIGHTS["araba"]
	return HEIGHTS.get(id, 1.0)


## Araba renkleri (araba_<renk>).
const CAR_TONES := {
	"araba": Color("c62828"), "araba_mavi": Color("1e5bb8"), "araba_sari": Color("f2b705"),
	"araba_beyaz": Color("eeeeee"), "araba_siyah": Color("2b2b2b"), "araba_yesil": Color("2e7d4f"),
}


## Eşyanın ön yüzünün baktığı yön (y dönüşü). Model önü +Z'ye bakacak biçimde kurulur.
## 0: +Z, PI/2: +X, PI: -Z, -PI/2: -X. Setteki duvara göre odaya bakar.
const FACING := {
	"gardirop": PI / 2, "oyuncak_kutusu": PI / 2, "market_rafi": PI / 2,
	"calisma_masasi": PI, "buzdolabi": -PI / 2, "tv": PI,
	"icecek_dolabi": -PI / 2, "meyve_reyonu": PI / 2,
	"vitrin": PI, "kitaplik": PI, "cift_yatak": 0.0,
}


## Eşyayı kurar; köşesi (0,0,0), tabanı size.x × size.y blok. Eşyalar parça parça köşeli
## bloklardan kurulur (bacak, tabla, kapak, kulp); ana rengi Mehmet'in PNG'sinin ön görünüşünden alınır.
## id "koltuk@3a6ea5" gibi verilirse eşya o renge boyanır (evler birbirinden farklı görünsün).
static func build(id: String, size: Vector2i, turn_override = null) -> Node3D:
	var tint = null
	if "@" in id:
		tint = Color(id.get_slice("@", 1))
		id = id.get_slice("@", 0)
	var root := Node3D.new()
	root.name = "Esya_" + id
	var turn: float = FACING.get(id, 0.0) if turn_override == null else float(turn_override)
	var side := absf(sin(turn)) > 0.5
	var foot := Vector3(size.y if side else size.x, height(id), size.x if side else size.y)
	var model := Node3D.new()
	var glb := _load_glb(id, foot)
	if glb:
		model.add_child(glb)
	else:
		_begin_texture(id)
		_model(model, id, foot)
		_tex = null
	model.position = Vector3(-foot.x / 2, 0, -foot.z / 2)
	var pivot := Node3D.new()
	pivot.add_child(model)
	pivot.rotation.y = turn
	pivot.position = Vector3(size.x / 2.0, 0, size.y / 2.0)
	root.add_child(pivot)
	if tint != null:
		_paint(model, tint)
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
				if _face(r, Vector3(dw / 2 - 0.03, h - 0.24, 0.03), Vector3(cx, 0.08 + (h - 0.14) / 2, fz), "on_gardirop_kapagi", c.lightened(0.06)):
					continue
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
				if _face(r, Vector3(w / doors - 0.03, h - 0.24, 0.02), Vector3(cx, 0.1 + (h - 0.19) / 2, d - 0.06), "on_dolap_kapagi", c.lightened(0.04)):
					continue
				_box(r, Vector3(0.12, 0.025, 0.03), Vector3(cx, h - 0.2, d - 0.035), STEEL)
			_box(r, Vector3(0.5, 0.012, 0.35), Vector3(w * 0.3, h + 0.001, d / 2), Color("5d6268"))  # evye
			_box(r, Vector3(0.03, 0.25, 0.03), Vector3(w * 0.3, h + 0.125, 0.15), STEEL)  # musluk
			_box(r, Vector3(0.03, 0.03, 0.15), Vector3(w * 0.3, h + 0.24, 0.22), STEEL)
		"ocak":
			var c := _tone(id, WHITE)
			_box(r, Vector3(w - 0.04, h, d - 0.06), Vector3(w / 2, h / 2, d / 2 - 0.02), c)
			if not _face(r, Vector3(w - 0.08, h - 0.04, 0.02), Vector3(w / 2, h / 2, d - 0.04), "on_firin", c):
				_box(r, Vector3(w - 0.2, h * 0.5, 0.02), Vector3(w / 2, h * 0.35, d - 0.04), Color("202428"))  # fırın camı
				_box(r, Vector3(w - 0.3, 0.03, 0.04), Vector3(w / 2, h * 0.65, d - 0.02), STEEL)
				for k in 4:
					_box(r, Vector3(0.05, 0.05, 0.03), Vector3(0.2 + k * (w - 0.4) / 3, h * 0.85, d - 0.04), Color("333333"))
			if not _face(r, Vector3(w - 0.06, 0.01, d - 0.08), Vector3(w / 2, h + 0.003, d / 2 - 0.02), "ust_ocak", c, true):
				for p in [Vector2(0.28, 0.3), Vector2(w - 0.28, 0.3), Vector2(0.28, d - 0.35), Vector2(w - 0.28, d - 0.35)]:
					_box(r, Vector3(0.22, 0.02, 0.22), Vector3(p.x, h + 0.01, p.y), Color("1f1f1f"))
		"buzdolabi":
			var c := _tone(id, WHITE)
			_box(r, Vector3(w - 0.08, h, d - 0.1), Vector3(w / 2, h / 2, d / 2 - 0.04), c)
			if not _face(r, Vector3(w - 0.1, h - 0.04, 0.02), Vector3(w / 2, h / 2, d - 0.08), "on_buzdolabi", c):
				_box(r, Vector3(w - 0.1, 0.015, 0.03), Vector3(w / 2, h * 0.66, d - 0.08), c.darkened(0.25))  # kapı arası
				_box(r, Vector3(0.035, 0.35, 0.05), Vector3(w * 0.78, h * 0.8, d - 0.05), STEEL)
				_box(r, Vector3(0.035, 0.6, 0.05), Vector3(w * 0.78, h * 0.42, d - 0.05), STEEL)
		"komodin":
			var c := _tone(id, Color("f4f1ea"))
			_box(r, Vector3(0.6, h - 0.05, 0.55), Vector3(w / 2, (h - 0.05) / 2 + 0.05, d / 2), c)
			for p in [Vector2(-0.25, -0.22), Vector2(0.25, -0.22), Vector2(-0.25, 0.22), Vector2(0.25, 0.22)]:
				_box(r, Vector3(0.05, 0.05, 0.05), Vector3(w / 2 + p.x, 0.025, d / 2 + p.y), c.darkened(0.3))
			if not _face(r, Vector3(0.5, 0.18, 0.02), Vector3(w / 2, h * 0.65, d / 2 + 0.28), "on_cekmece", c.darkened(0.06)):
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
		"koltuk":
			var c := _tone(id, Color("8d939a"))
			_box(r, Vector3(w - 0.1, 0.25, d - 0.2), Vector3(w / 2, 0.2, d / 2 + 0.05), c.darkened(0.15))  # oturak tabanı
			_box(r, Vector3(w - 0.4, 0.15, d - 0.35), Vector3(w / 2, 0.4, d / 2 + 0.1), c.lightened(0.05))  # minder
			_box(r, Vector3(w - 0.1, 0.55, 0.22), Vector3(w / 2, 0.55, 0.16), c)  # sırt
			for sx in [0.1, w - 0.1]:
				_box(r, Vector3(0.18, 0.55, d - 0.2), Vector3(sx, 0.35, d / 2 + 0.05), c.darkened(0.08))  # kolçak
			for k in 2:
				_box(r, Vector3(0.45, 0.35, 0.12), Vector3(w * (0.3 + 0.4 * k), 0.62, 0.32), c.lightened(0.15))  # yastık
			for px in [0.15, w - 0.15]:
				_box(r, Vector3(0.06, 0.08, 0.06), Vector3(px, 0.04, d - 0.2), Color("3a2a1e"))
		"sehpa":
			var c := _tone(id, WOOD)
			_box(r, Vector3(w - 0.6, 0.05, d - 0.4), Vector3(w / 2, h - 0.025, d / 2), c)
			for p in [Vector2(0.35, 0.25), Vector2(w - 0.35, 0.25), Vector2(0.35, d - 0.25), Vector2(w - 0.35, d - 0.25)]:
				_box(r, Vector3(0.05, h - 0.05, 0.05), Vector3(p.x, (h - 0.05) / 2, p.y), c.darkened(0.25))
			_box(r, Vector3(0.3, 0.08, 0.2), Vector3(w / 2 - 0.3, h + 0.04, d / 2), Color("e84a4a"))  # kitap
			_box(r, Vector3(0.12, 0.15, 0.12), Vector3(w / 2 + 0.3, h + 0.075, d / 2), Color("f5f5f5"))  # fincan
		"tv":
			var c := _tone(id, WOOD)
			_box(r, Vector3(w - 0.2, 0.5, d - 0.4), Vector3(w / 2, 0.25, d / 2 - 0.1), c)  # sehpa
			for k in 2:
				_box(r, Vector3(w / 2 - 0.25, 0.3, 0.02), Vector3(w * (0.27 + 0.46 * k), 0.25, d - 0.3), c.lightened(0.06))
			_box(r, Vector3(0.3, 0.05, 0.2), Vector3(w / 2, 0.525, d / 2 - 0.1), Color("222222"))  # ayak
			_box(r, Vector3(1.7, 0.95, 0.06), Vector3(w / 2, 1.0, d / 2 - 0.1), Color("1b1d20"))  # ekran
			_face(r, Vector3(1.6, 0.85, 0.01), Vector3(w / 2, 1.0, d / 2 - 0.065), "on_tv", Color("2b4a6b"))
		"kuvet":
			_box(r, Vector3(w - 0.05, h, d - 0.1), Vector3(w / 2, h / 2, d / 2), Color("f7f7f7"))
			_box(r, Vector3(w - 0.3, 0.02, d - 0.35), Vector3(w / 2, h - 0.08, d / 2), Color("8fd3f0"))  # su
			_box(r, Vector3(0.05, 0.4, 0.05), Vector3(0.2, h + 0.2, 0.1), STEEL)  # musluk
		"lavabo":
			_box(r, Vector3(0.18, h - 0.15, 0.18), Vector3(w / 2, (h - 0.15) / 2, 0.3), Color("f2f2f2"))
			_box(r, Vector3(0.6, 0.15, 0.45), Vector3(w / 2, h - 0.075, 0.3), Color("fafafa"))
			_box(r, Vector3(0.4, 0.02, 0.28), Vector3(w / 2, h + 0.001, 0.3), Color("b9d7e3"))
			_box(r, Vector3(0.04, 0.2, 0.04), Vector3(w / 2, h + 0.1, 0.1), STEEL)
			_box(r, Vector3(0.55, 0.7, 0.03), Vector3(w / 2, 1.6, 0.03), Color("cfe7f2"))  # ayna
			_box(r, Vector3(0.6, 0.75, 0.02), Vector3(w / 2, 1.6, 0.015), Color("d9d9d9"))
		"klozet":
			_box(r, Vector3(0.35, 0.4, 0.45), Vector3(w / 2, 0.2, 0.45), Color("f7f7f7"))
			_box(r, Vector3(0.45, 0.06, 0.55), Vector3(w / 2, 0.43, 0.5), Color("ffffff"))  # kapak
			_box(r, Vector3(0.45, 0.4, 0.18), Vector3(w / 2, 0.6, 0.12), Color("f2f2f2"))  # rezervuar
			_box(r, Vector3(0.1, 0.03, 0.05), Vector3(w / 2, 0.82, 0.12), STEEL)
		"camasir_makinesi":
			_box(r, Vector3(w - 0.1, h, d - 0.15), Vector3(w / 2, h / 2, d / 2 - 0.05), Color("f4f4f4"))
			_box(r, Vector3(0.5, 0.5, 0.03), Vector3(w / 2, h * 0.45, d - 0.12), Color("9aa3aa"))  # kapak çerçevesi
			_box(r, Vector3(0.38, 0.38, 0.03), Vector3(w / 2, h * 0.45, d - 0.1), Color("2f3a45"))  # cam
			_box(r, Vector3(w - 0.2, 0.12, 0.02), Vector3(w / 2, h - 0.1, d - 0.12), Color("d0d4d8"))
		"sandalye":
			var c := _tone(id, WOOD)
			_box(r, Vector3(0.46, 0.06, 0.46), Vector3(w / 2, 0.45, d / 2), c)
			for p in [Vector2(-0.19, -0.19), Vector2(0.19, -0.19), Vector2(-0.19, 0.19), Vector2(0.19, 0.19)]:
				_box(r, Vector3(0.05, 0.43, 0.05), Vector3(w / 2 + p.x, 0.215, d / 2 + p.y), c.darkened(0.25))
			_box(r, Vector3(0.46, 0.5, 0.05), Vector3(w / 2, 0.72, d / 2 - 0.2), c.darkened(0.08))  # sırt
		"sira":
			_box(r, Vector3(w - 0.1, 0.05, 0.42), Vector3(w / 2, 0.75, 0.25), Color("c9a06a"))  # tabla
			_box(r, Vector3(w - 0.2, 0.03, 0.36), Vector3(w / 2, 0.55, 0.25), Color("7d8790"))  # kitap rafı
			_box(r, Vector3(w - 0.1, 0.05, 0.3), Vector3(w / 2, 0.45, 0.78), Color("c9a06a"))  # oturak
			for x in [0.1, w - 0.1]:
				_box(r, Vector3(0.05, 0.75, 0.05), Vector3(x, 0.375, 0.08), STEEL)
				_box(r, Vector3(0.05, 0.75, 0.05), Vector3(x, 0.375, 0.42), STEEL)
				_box(r, Vector3(0.05, 0.45, 0.05), Vector3(x, 0.225, 0.9), STEEL)
				_box(r, Vector3(0.05, 0.03, 0.85), Vector3(x, 0.05, 0.5), STEEL)
		"kasa":
			_box(r, Vector3(w - 0.08, 0.88, d - 0.2), Vector3(w / 2, 0.44, d / 2), Color("e9ecef"))
			_box(r, Vector3(w * 0.55, 0.03, d - 0.3), Vector3(w * 0.32, 0.9, d / 2), Color("222222"))  # bant
			_box(r, Vector3(0.4, 0.22, 0.32), Vector3(w * 0.8, 1.0, d / 2), Color("3a3f45"))  # yazar kasa
			_box(r, Vector3(0.3, 0.2, 0.03), Vector3(w * 0.8, 1.2, d / 2 - 0.1), Color("5fb0e0"))  # ekran
			_box(r, Vector3(w - 0.1, 0.12, 0.02), Vector3(w / 2, 0.75, d - 0.09), Color("d94b4b"))
		"bank":
			var c := _tone(id, Color("a8743f"))
			for k in 3:
				_box(r, Vector3(w - 0.1, 0.04, 0.12), Vector3(w / 2, 0.45, 0.4 + k * 0.14), c)
			for k in 2:
				_box(r, Vector3(w - 0.1, 0.1, 0.04), Vector3(w / 2, 0.65 + k * 0.16, 0.28), c)
			for x in [0.2, w - 0.2]:
				_box(r, Vector3(0.06, 0.45, 0.45), Vector3(x, 0.22, 0.55), Color("2d2d2d"))
				_box(r, Vector3(0.06, 0.45, 0.05), Vector3(x, 0.65, 0.3), Color("2d2d2d"))
		"icecek_dolabi":
			_box(r, Vector3(w - 0.05, h, d - 0.1), Vector3(w / 2, h / 2, d / 2 - 0.05), Color("d8dde2"))
			var cols := [Color("d94b4b"), Color("f2a33a"), Color("3aa655"), Color("2e6fd8"), Color("f5f5f5")]
			for i in 4:
				var sy := 0.25 + i * 0.42
				_box(r, Vector3(w - 0.2, 0.03, d - 0.3), Vector3(w / 2, sy, d / 2), Color("aab4bc"))
				var n := int(w / 0.18)
				for k in n:
					_box(r, Vector3(0.1, 0.28, 0.1), Vector3(0.15 + k * 0.18, sy + 0.16, d - 0.25), cols[(i + k) % cols.size()])
			_box(r, Vector3(w - 0.15, h - 0.25, 0.02), Vector3(w / 2, h / 2, d - 0.08), Color(0.7, 0.85, 0.95, 1))
			_box(r, Vector3(w - 0.1, 0.18, 0.04), Vector3(w / 2, h - 0.1, d - 0.08), Color("2e6fd8"))  # tepe tabelası
		"meyve_reyonu":
			_box(r, Vector3(w - 0.05, 0.6, d - 0.1), Vector3(w / 2, 0.3, d / 2), Color("8a5a30"))
			var fr := [Color("d93b3b"), Color("f28c28"), Color("8bc34a"), Color("ffd54f"), Color("7b3fa0")]
			var n := maxi(1, int(w / 0.9))
			for k in n:
				var cw := (w - 0.1) / n
				_box(r, Vector3(cw - 0.06, 0.12, d - 0.2), Vector3(0.05 + cw * (k + 0.5), 0.66, d / 2), Color("c49a63"))
				for b in 6:
					_box(r, Vector3(0.14, 0.14, 0.14), Vector3(0.05 + cw * k + 0.15 + (b % 3) * (cw - 0.3) / 2, 0.78, d / 2 - 0.2 + (b / 3) * 0.35), fr[k % fr.size()])
		"basket_potasi":
			_box(r, Vector3(0.6, 0.15, 0.6), Vector3(w / 2, 0.075, 0.3), Color("3a3a3a"))
			_box(r, Vector3(0.15, 3.0, 0.15), Vector3(w / 2, 1.5, 0.2), Color("6b7178"))
			_box(r, Vector3(1.3, 0.85, 0.06), Vector3(w / 2, 3.05, 0.35), Color("f5f5f5"))
			_box(r, Vector3(0.5, 0.35, 0.065), Vector3(w / 2, 2.9, 0.351), Color("d94b4b"))
			for s in [[Vector3(0.45, 0.04, 0.04), Vector3(0, 0, 0.25)], [Vector3(0.45, 0.04, 0.04), Vector3(0, 0, 0.7)], [Vector3(0.04, 0.04, 0.45), Vector3(-0.22, 0, 0.47)], [Vector3(0.04, 0.04, 0.45), Vector3(0.22, 0, 0.47)]]:
				_box(r, s[0], Vector3(w / 2, 2.7, 0.0) + s[1], Color("f27a1a"))
		"araba", "ambulans", "polis_araci", "araba_mavi", "araba_sari", "araba_beyaz", "araba_siyah", "araba_yesil":
			# Önü +Z. Gövde, kabin, camlar, tekerlekler, farlar, stoplar.
			var amb := id == "ambulans"
			var pol := id == "polis_araci"
			var c: Color = Color("f4f4f4") if amb or pol else _tone(id, CAR_TONES.get(id, Color("c62828")))
			_box(r, Vector3(w - 0.2, 0.55, d - 0.15), Vector3(w / 2, 0.55, d / 2), c)  # alt gövde
			var cab_l := d * (0.7 if amb else 0.5)
			var cab_z := d * (0.42 if amb else 0.45)
			_box(r, Vector3(w - 0.3, 0.6 if not amb else 0.95, cab_l), Vector3(w / 2, 1.1 if not amb else 1.27, cab_z), c)
			var gl := Color("27384a")
			_box(r, Vector3(w - 0.4, 0.42, 0.04), Vector3(w / 2, 1.12, cab_z + cab_l / 2 + 0.01), gl)  # ön cam
			_box(r, Vector3(w - 0.4, 0.38, 0.04), Vector3(w / 2, 1.12, cab_z - cab_l / 2 - 0.01), gl)
			for sx in [0.14, w - 0.14]:
				_box(r, Vector3(0.03, 0.38, cab_l - 0.3), Vector3(sx, 1.12, cab_z), gl)
			for p in [Vector2(0.18, d * 0.2), Vector2(w - 0.18, d * 0.2), Vector2(0.18, d * 0.8), Vector2(w - 0.18, d * 0.8)]:
				_box(r, Vector3(0.2, 0.5, 0.5), Vector3(p.x, 0.25, p.y), Color("1b1b1b"))
				_box(r, Vector3(0.21, 0.22, 0.22), Vector3(p.x, 0.25, p.y), Color("9e9e9e"))
			for sx in [0.35, w - 0.35]:
				_box(r, Vector3(0.3, 0.14, 0.04), Vector3(sx, 0.65, d - 0.07), Color("fff3b0"))  # far
				_box(r, Vector3(0.3, 0.12, 0.04), Vector3(sx, 0.65, 0.07), Color("d32f2f"))  # stop
			_box(r, Vector3(w - 0.5, 0.12, 0.04), Vector3(w / 2, 0.45, d - 0.07), Color("bdbdbd"))  # tampon
			if pol:
				for sx in [0.09, w - 0.09]:
					_box(r, Vector3(0.03, 0.2, d * 0.85), Vector3(sx, 0.65, d / 2), Color("1e4fa8"))
				_box(r, Vector3(0.3, 0.14, 0.25), Vector3(w / 2 - 0.17, 1.47, cab_z), Color("2e6fd8"))
				_box(r, Vector3(0.3, 0.14, 0.25), Vector3(w / 2 + 0.17, 1.47, cab_z), Color("d32f2f"))
			if amb:
				_box(r, Vector3(0.03, 0.15, d * 0.8), Vector3(0.09, 0.8, d / 2), Color("d32f2f"))
				_box(r, Vector3(0.03, 0.15, d * 0.8), Vector3(w - 0.09, 0.8, d / 2), Color("d32f2f"))
				for k in 2:
					_box(r, Vector3(0.03, [0.5, 0.15][k], [0.15, 0.5][k]), Vector3(-0.0 + 0.085, 1.3, d * 0.3), Color("d32f2f"))
					_box(r, Vector3(0.03, [0.5, 0.15][k], [0.15, 0.5][k]), Vector3(w - 0.085, 1.3, d * 0.3), Color("d32f2f"))
				_box(r, Vector3(0.5, 0.15, 0.25), Vector3(w / 2, 1.82, cab_z + cab_l / 2 - 0.2), Color("2e6fd8"))  # tepe lambası
		"itfaiye_araci":
			# Önü +Z. Kırmızı gövde, önde kabin, sırtta merdiven, beyaz şerit, tepe lambaları.
			var red := Color("c8231e")
			_box(r, Vector3(w - 0.15, 1.1, d - 0.2), Vector3(w / 2, 0.85, d * 0.42), red)  # arka gövde (dolaplar)
			_box(r, Vector3(w - 0.15, 1.35, d * 0.22), Vector3(w / 2, 0.98, d * 0.86), red)  # kabin
			_box(r, Vector3(w - 0.35, 0.5, 0.04), Vector3(w / 2, 1.3, d * 0.97 + 0.01), Color("27384a"))  # ön cam
			for sx in [0.07, w - 0.07]:
				_box(r, Vector3(0.03, 0.45, d * 0.16), Vector3(sx, 1.3, d * 0.86), Color("27384a"))
				_box(r, Vector3(0.03, 0.12, d * 0.8), Vector3(sx, 0.6, d / 2), Color("f5f5f5"))  # şerit
				for k in 3:
					_box(r, Vector3(0.03, 0.55, 0.04), Vector3(sx, 0.95, 0.4 + k * d * 0.2), Color("9ea7ad"))  # dolap kapakları
			for p in [Vector2(0.18, d * 0.15), Vector2(w - 0.18, d * 0.15), Vector2(0.18, d * 0.42), Vector2(w - 0.18, d * 0.42), Vector2(0.18, d * 0.85), Vector2(w - 0.18, d * 0.85)]:
				_box(r, Vector3(0.22, 0.56, 0.56), Vector3(p.x, 0.28, p.y), Color("1b1b1b"))
				_box(r, Vector3(0.23, 0.24, 0.24), Vector3(p.x, 0.28, p.y), Color("bdbdbd"))
			# Merdiven: iki ray ve basamaklar.
			for sx in [w / 2 - 0.3, w / 2 + 0.3]:
				_box(r, Vector3(0.07, 0.07, d * 0.85), Vector3(sx, 1.5, d * 0.4), Color("cfd4d8"))
			for k in int(d * 2.5):
				_box(r, Vector3(0.6, 0.05, 0.05), Vector3(w / 2, 1.5, 0.25 + k * 0.4), Color("cfd4d8"))
			_box(r, Vector3(w - 0.4, 0.15, 0.25), Vector3(w / 2, 1.73, d * 0.88), Color("2e6fd8"))  # tepe lambası
			_box(r, Vector3(0.3, 0.16, 0.26), Vector3(w / 2, 1.74, d * 0.88), Color("d32f2f"))
			for sx in [0.35, w - 0.35]:
				_box(r, Vector3(0.3, 0.14, 0.04), Vector3(sx, 0.6, d - 0.05), Color("fff3b0"))
			_box(r, Vector3(w - 0.4, 0.14, 0.05), Vector3(w / 2, 0.38, d - 0.04), Color("bdbdbd"))  # tampon
		"itfaiye_diregi":
			_box(r, Vector3(0.12, f.y, 0.12), Vector3(w / 2, f.y / 2, d / 2), Color("d9dde0"))
			_box(r, Vector3(0.9, 0.06, 0.9), Vector3(w / 2, 0.03, d / 2), Color("8a8f94"))  # yumuşak minder
		"vitrin":
			# Camlı vitrin: koyu ahşap gövde, cam kapaklar, içinde tabak ve fincanlar.
			var c := _tone(id, Color("6b4026"))
			_box(r, Vector3(w - 0.05, h, 0.45), Vector3(w / 2, h / 2, 0.25), c)
			_box(r, Vector3(w - 0.2, h * 0.55, 0.03), Vector3(w / 2, h * 0.66, 0.49), Color(0.78, 0.9, 0.95, 1))
			_box(r, Vector3(w - 0.2, h * 0.3, 0.03), Vector3(w / 2, h * 0.18, 0.49), c.darkened(0.15))
			for k in 3:
				_box(r, Vector3(w - 0.25, 0.03, 0.38), Vector3(w / 2, h * 0.42 + k * h * 0.17, 0.25), c.lightened(0.2))
				for j in int(maxf(2.0, w * 3)):
					_box(r, Vector3(0.14, 0.12, 0.14), Vector3(0.25 + j * (w - 0.5) / maxf(1.0, w * 3 - 1), h * 0.42 + k * h * 0.17 + 0.08, 0.3), [Color("f5f5f5"), Color("4a7fc1"), Color("e0b84a")][(j + k) % 3])
			_box(r, Vector3(0.03, h * 0.55, 0.04), Vector3(w / 2, h * 0.66, 0.5), c.darkened(0.2))
		"cift_yatak":
			# Önü (ayak ucu) +Z, başlık arkada. Çift kişilik: iki yastık.
			var c := _tone(id, Color("8a5a3b"))
			_box(r, Vector3(w - 0.05, 0.35, d - 0.05), Vector3(w / 2, 0.22, d / 2), c)
			_box(r, Vector3(w - 0.1, 0.9, 0.12), Vector3(w / 2, 0.45, 0.06), c.darkened(0.2))  # başlık
			_box(r, Vector3(w - 0.15, 0.2, d - 0.25), Vector3(w / 2, 0.48, d / 2 + 0.05), Color("f4f1ea"))  # yatak
			_box(r, Vector3(w - 0.1, 0.06, d * 0.6), Vector3(w / 2, 0.6, d * 0.65), Color("5b8fd6"))  # yorgan
			for px in [w * 0.27, w * 0.73]:
				_box(r, Vector3(w * 0.36, 0.14, 0.35), Vector3(px, 0.65, 0.35), Color("ffffff"))
		"abajur":
			_box(r, Vector3(0.3, 0.05, 0.3), Vector3(w / 2, 0.025, d / 2), Color("3a3a3a"))
			_box(r, Vector3(0.05, 1.1, 0.05), Vector3(w / 2, 0.6, d / 2), Color("3a3a3a"))
			_box(r, Vector3(0.45, 0.35, 0.45), Vector3(w / 2, 1.3, d / 2), Color("f3e1b5"))
		"ayna":
			_box(r, Vector3(w * 0.6, h, 0.08), Vector3(w / 2, h / 2, 0.08), Color("8a5a3b"))
			_box(r, Vector3(w * 0.5, h - 0.2, 0.02), Vector3(w / 2, h / 2, 0.13), Color("cfe3ea"))
		"kitaplik":
			var c := _tone(id, Color("8a5a3b"))
			_box(r, Vector3(w - 0.05, h, 0.4), Vector3(w / 2, h / 2, 0.2), c)
			var cols := [Color("c0392b"), Color("2e86c1"), Color("27ae60"), Color("f1c40f"), Color("8e44ad"), Color("e67e22")]
			for k in 4:
				_box(r, Vector3(w - 0.15, 0.03, 0.36), Vector3(w / 2, 0.1 + k * h / 4, 0.22), c.lightened(0.15))
				var n := int(w * 7)
				for j in n:
					_box(r, Vector3(0.1, 0.3 + (j % 3) * 0.04, 0.3), Vector3(0.12 + j * (w - 0.24) / maxf(1.0, n - 1), 0.28 + k * h / 4, 0.24), cols[(j + k * 2) % cols.size()])
		"tv_unitesi":
			var c := _tone(id, Color("efe8dc"))
			_box(r, Vector3(w - 0.05, h, d - 0.1), Vector3(w / 2, h / 2, d / 2), c)
			for k in 3:
				_box(r, Vector3(w / 3 - 0.08, h - 0.15, 0.02), Vector3(w / 6 + k * w / 3, h / 2, d - 0.04), c.darkened(0.1))
		"ayakkabilik":
			var c := _tone(id, Color("d9b383"))
			_box(r, Vector3(w - 0.05, h, d - 0.2), Vector3(w / 2, h / 2, d / 2 - 0.1), c)
			_box(r, Vector3(w - 0.15, 0.02, 0.02), Vector3(w / 2, h * 0.5, d - 0.19), c.darkened(0.3))
		"teleskop":
			for a in [0.0, TAU / 3, 2 * TAU / 3]:
				_box(r, Vector3(0.05, 1.0, 0.05), Vector3(w / 2 + cos(a) * 0.2, 0.5, d / 2 + sin(a) * 0.2), Color("3a3a3a"))
			var tube := Node3D.new()
			tube.position = Vector3(w / 2, 1.15, d / 2)
			tube.rotation = Vector3(-0.6, 0, 0)
			r.add_child(tube)
			_box(tube, Vector3(0.2, 0.2, 1.0), Vector3(0, 0, 0.1), Color("f5f5f5"))
			_box(tube, Vector3(0.24, 0.24, 0.12), Vector3(0, 0, 0.6), Color("2e6fd8"))
			_box(tube, Vector3(0.08, 0.08, 0.15), Vector3(0, 0.05, -0.45), Color("222222"))
		"sezlong":
			_box(r, Vector3(w - 0.3, 0.08, d - 0.2), Vector3(w / 2, 0.3, d / 2 + 0.1), Color("f5f5f5"))
			for k in 4:
				_box(r, Vector3(w - 0.32, 0.09, (d - 0.2) / 8), Vector3(w / 2, 0.31, 0.2 + k * (d - 0.2) / 4), Color("2e86c1"))
			var back := Node3D.new()
			back.position = Vector3(w / 2, 0.35, 0.2)
			back.rotation = Vector3(0.9, 0, 0)
			r.add_child(back)
			_box(back, Vector3(w - 0.3, 0.08, 0.7), Vector3(0, 0, -0.35), Color("2e86c1"))
			for p in [Vector2(0.2, 0.2), Vector2(w - 0.2, 0.2), Vector2(0.2, d - 0.1), Vector2(w - 0.2, d - 0.1)]:
				_box(r, Vector3(0.05, 0.3, 0.05), Vector3(p.x, 0.15, p.y), Color("cfd4d8"))
		"bisiklet":
			# Önü +Z: iki teker, kadro, sele, gidon.
			for z in [0.25, d - 0.25]:
				_box(r, Vector3(0.05, 0.6, 0.6), Vector3(w / 2, 0.3, z), Color("222222"))
				_box(r, Vector3(0.06, 0.4, 0.4), Vector3(w / 2, 0.3, z), Color("bdbdbd"))
			_box(r, Vector3(0.05, 0.05, d - 0.5), Vector3(w / 2, 0.6, d / 2), Color("d32f2f"))
			_box(r, Vector3(0.05, 0.4, 0.05), Vector3(w / 2, 0.45, d / 2 - 0.15), Color("d32f2f"))
			_box(r, Vector3(0.12, 0.05, 0.25), Vector3(w / 2, 0.75, d / 2 - 0.15), Color("222222"))
			_box(r, Vector3(0.45, 0.04, 0.04), Vector3(w / 2, 0.85, d - 0.3), Color("222222"))
			_box(r, Vector3(0.04, 0.3, 0.04), Vector3(w / 2, 0.7, d - 0.3), Color("d32f2f"))
		"puf":
			_box(r, Vector3(0.6, 0.42, 0.6), Vector3(w / 2, 0.21, d / 2), _tone(id, Color("e8a33d")))
		"alet_tezgahi":
			var c := _tone(id, Color("8a5a3b"))
			_box(r, Vector3(w - 0.05, 0.08, d - 0.1), Vector3(w / 2, 0.86, d / 2), c)
			for p in [Vector2(0.1, 0.1), Vector2(w - 0.1, 0.1), Vector2(0.1, d - 0.15), Vector2(w - 0.1, d - 0.15)]:
				_box(r, Vector3(0.08, 0.82, 0.08), Vector3(p.x, 0.41, p.y), c.darkened(0.3))
			_box(r, Vector3(w - 0.1, 0.9, 0.04), Vector3(w / 2, 1.5, 0.03), Color("6d6d6d"))  # alet panosu
			for k in int(w * 4):
				_box(r, Vector3(0.06, 0.3, 0.04), Vector3(0.2 + k * 0.25, 1.5, 0.07), [Color("d32f2f"), Color("f2b705"), Color("2e6fd8")][k % 3])
		"kafes":
			# Hayvan kafesleri: iki katlı, ızgaralı kapaklar.
			_box(r, Vector3(w - 0.05, h, d - 0.1), Vector3(w / 2, h / 2, d / 2 - 0.05), Color("dfe3e6"))
			for k in 2:
				var y := 0.25 + k * 0.5
				_box(r, Vector3(w - 0.15, 0.4, 0.02), Vector3(w / 2, y, d - 0.08), Color("4a4f55"))
				for j in int(w * 6):
					_box(r, Vector3(0.03, 0.38, 0.03), Vector3(0.1 + j * (w - 0.2) / maxf(1.0, w * 6 - 1), y, d - 0.06), Color("b0b6bb"))
		"kopek", "kedi":
			# Köşeli dost: gövde, baş, kulaklar, kuyruk, bacaklar. Önü +Z.
			var dog := id == "kopek"
			var c: Color = Color("c8935a") if dog else Color("8a8f94")
			var s := 1.0 if dog else 0.6
			_box(r, Vector3(0.35 * s, 0.3 * s, 0.7 * s), Vector3(w / 2, 0.45 * s, d / 2), c)
			_box(r, Vector3(0.3 * s, 0.3 * s, 0.3 * s), Vector3(w / 2, 0.68 * s, d / 2 + 0.42 * s), c)
			_box(r, Vector3(0.14 * s, 0.1 * s, 0.12 * s), Vector3(w / 2, 0.62 * s, d / 2 + 0.6 * s), c.lightened(0.2))
			_box(r, Vector3(0.05 * s, 0.05 * s, 0.02), Vector3(w / 2, 0.65 * s, d / 2 + 0.67 * s), Color("1b1b1b"))
			for ex in [-0.08, 0.08]:
				_box(r, Vector3(0.05 * s, 0.05 * s, 0.02), Vector3(w / 2 + ex * s, 0.75 * s, d / 2 + 0.57 * s + 0.01), Color("1b1b1b"))
				_box(r, Vector3(0.08 * s, (0.15 if dog else 0.12) * s, 0.06 * s), Vector3(w / 2 + ex * 1.4 * s, (0.86 if not dog else 0.8) * s, d / 2 + 0.4 * s), c.darkened(0.25 if dog else 0.0))
			for p in [Vector2(-0.12, -0.25), Vector2(0.12, -0.25), Vector2(-0.12, 0.25), Vector2(0.12, 0.25)]:
				_box(r, Vector3(0.08 * s, 0.3 * s, 0.08 * s), Vector3(w / 2 + p.x * s, 0.15 * s, d / 2 + p.y * s), c.darkened(0.1))
			_box(r, Vector3(0.06 * s, 0.06 * s, 0.3 * s), Vector3(w / 2, 0.6 * s, d / 2 - 0.45 * s), c)
		"muayene_masasi":
			_box(r, Vector3(w - 0.1, 0.1, d - 0.2), Vector3(w / 2, 0.85, d / 2), Color("c9d1d6"))
			_box(r, Vector3(0.1, 0.8, 0.1), Vector3(w / 2, 0.4, d / 2), Color("8a9298"))
			_box(r, Vector3(0.6, 0.05, 0.6), Vector3(w / 2, 0.03, d / 2), Color("8a9298"))
		"pompa":
			# Akaryakıt pompası: gövde, ekran, iki tabanca ve hortum. Önü +Z.
			_box(r, Vector3(w * 0.7, h - 0.1, d * 0.5), Vector3(w / 2, (h - 0.1) / 2, d / 2), Color("f4f4f4"))
			_box(r, Vector3(w * 0.72, 0.3, d * 0.52), Vector3(w / 2, h - 0.25, d / 2), Color("2e8b57"))
			_box(r, Vector3(w * 0.4, 0.25, 0.02), Vector3(w / 2, h * 0.65, d / 2 + d * 0.26), Color("1b1b1b"))
			_box(r, Vector3(w * 0.3, 0.12, 0.01), Vector3(w / 2, h * 0.66, d / 2 + d * 0.27), Color("7cff9a"))
			for sx in [w * 0.28, w * 0.72]:
				_box(r, Vector3(0.1, 0.25, 0.12), Vector3(sx, h * 0.4, d / 2 + d * 0.28), Color("d32f2f"))
				_box(r, Vector3(0.04, 0.5, 0.04), Vector3(sx, h * 0.18, d / 2 + d * 0.3), Color("1b1b1b"))
			_box(r, Vector3(w * 0.8, 0.1, d * 0.7), Vector3(w / 2, 0.05, d / 2), Color("9e9e9e"))
		"otomat":
			# Atıştırmalık otomatı: kırmızı gövde, camlı vitrin içinde renkli paketler, tuş paneli.
			_box(r, Vector3(w - 0.1, h, d - 0.2), Vector3(w / 2, h / 2, d / 2 - 0.05), Color("c62828"))
			_box(r, Vector3(w * 0.6, h * 0.65, 0.02), Vector3(w * 0.38, h * 0.6, d - 0.24), Color(0.8, 0.9, 0.95, 1))
			for k in 4:
				for j in 3:
					_box(r, Vector3(w * 0.14, 0.12, 0.06), Vector3(w * 0.18 + j * w * 0.2, h * 0.35 + k * h * 0.13, d - 0.3), [Color("ffd23f"), Color("2e86c1"), Color("27ae60"), Color("e67e22")][(j + k) % 4])
			_box(r, Vector3(w * 0.18, h * 0.3, 0.03), Vector3(w * 0.8, h * 0.6, d - 0.24), Color("2b2b2b"))
			_box(r, Vector3(w * 0.5, 0.15, 0.03), Vector3(w * 0.38, h * 0.12, d - 0.24), Color("1b1b1b"))
		"trambolin":
			for a in 8:
				var an := a * TAU / 8
				_box(r, Vector3(0.08, 0.6, 0.08), Vector3(w / 2 + cos(an) * w * 0.45, 0.3, d / 2 + sin(an) * d * 0.45), Color("9ea7ad"))
			_box(r, Vector3(w * 0.95, 0.1, d * 0.95), Vector3(w / 2, 0.62, d / 2), Color("2e6fd8"))
			_box(r, Vector3(w * 0.75, 0.11, d * 0.75), Vector3(w / 2, 0.63, d / 2), Color("1b1b1b"))
		"trafik_isigi":
			# Direk ve üç lambalı kutu (kırmızı, sarı, yeşil); önü +Z.
			_box(r, Vector3(0.14, 2.4, 0.14), Vector3(w / 2, 1.2, d / 2), Color("3a3a3a"))
			_box(r, Vector3(0.36, 0.95, 0.3), Vector3(w / 2, 2.85, d / 2), Color("1b1b1b"))
			var lc := [Color("ff3b30"), Color("ffcc00"), Color("34c759")]
			for k in 3:
				var on := k == 2
				var c: Color = lc[k] if on else lc[k].darkened(0.6)
				_box(r, Vector3(0.22, 0.22, 0.04), Vector3(w / 2, 3.15 - k * 0.3, d / 2 + 0.16), c)
		"saksi":
			_box(r, Vector3(0.45, 0.4, 0.45), Vector3(w / 2, 0.2, d / 2), Color("b5562f"))
			_box(r, Vector3(0.6, 0.45, 0.6), Vector3(w / 2, 0.65, d / 2), Color("3f8f3a"))
			_box(r, Vector3(0.12, 0.12, 0.12), Vector3(w / 2 + 0.15, 0.85, d / 2 + 0.25), Color("e84a8a"))
			_box(r, Vector3(0.12, 0.12, 0.12), Vector3(w / 2 - 0.2, 0.8, d / 2 - 0.1), Color("ffd23f"))
		"bitki":
			_box(r, Vector3(0.4, 0.35, 0.4), Vector3(w / 2, 0.175, d / 2), Color("e8e2d6"))
			_box(r, Vector3(0.06, 0.6, 0.06), Vector3(w / 2, 0.6, d / 2), Color("5b3a22"))
			for k in 5:
				var a := k * TAU / 5
				_box(r, Vector3(0.3, 0.08, 0.14), Vector3(w / 2 + cos(a) * 0.18, 0.75 + k * 0.1, d / 2 + sin(a) * 0.18), Color("2f7d32"))
			_box(r, Vector3(0.35, 0.3, 0.35), Vector3(w / 2, 1.1, d / 2), Color("3a9a3f"))
		"semsiye":
			_box(r, Vector3(0.06, 2.3, 0.06), Vector3(w / 2, 1.15, d / 2), Color("dddddd"))
			for k in 4:
				_box(r, Vector3(1.8 - k * 0.4, 0.08, 1.8 - k * 0.4), Vector3(w / 2, 2.2 + k * 0.07, d / 2), [Color("d94b4b"), Color("f5f5f5")][k % 2])
		"tekne":
			_box(r, Vector3(w - 0.3, 0.6, d - 0.2), Vector3(w / 2, 0.3, d / 2), Color("f4f1ea"))  # gövde
			_box(r, Vector3(w - 0.3, 0.12, d - 0.2), Vector3(w / 2, 0.66, d / 2), Color("1e5bb8"))
			_box(r, Vector3(w - 0.9, 0.5, d * 0.35), Vector3(w / 2, 0.95, d * 0.4), Color("e9e4d8"))  # kabin
			_box(r, Vector3(w - 1.0, 0.25, 0.04), Vector3(w / 2, 1.0, d * 0.22), Color(0.6, 0.8, 0.95, 1))
		"yelkenli":
			_box(r, Vector3(w - 0.3, 0.55, d - 0.2), Vector3(w / 2, 0.28, d / 2), Color("ffffff"))
			_box(r, Vector3(w - 0.3, 0.1, d - 0.2), Vector3(w / 2, 0.6, d / 2), Color("8a5a35"))
			_box(r, Vector3(0.1, 5.0, 0.1), Vector3(w / 2, 3.0, d * 0.45), Color("dddddd"))  # direk
			_box(r, Vector3(0.04, 3.8, d * 0.5), Vector3(w / 2, 2.8, d * 0.72), Color("fafafa"))  # yelken
		"surat_teknesi":
			_box(r, Vector3(w - 0.3, 0.5, d - 0.2), Vector3(w / 2, 0.25, d / 2), Color("d62828"))
			_box(r, Vector3(w - 0.3, 0.12, d - 0.2), Vector3(w / 2, 0.56, d / 2), Color("ffffff"))
			_box(r, Vector3(w - 0.5, 0.35, 0.05), Vector3(w / 2, 0.8, d * 0.35), Color(0.6, 0.8, 0.95, 1))  # ön cam
			_box(r, Vector3(0.5, 0.4, 0.5), Vector3(w / 2, 0.6, d * 0.65), Color("222222"))  # koltuk
		"havlu":
			_box(r, Vector3(w - 0.2, 0.04, d - 0.2), Vector3(w / 2, 0.02, d / 2), Color("4fa3d9"))
			_box(r, Vector3(w - 0.2, 0.045, 0.2), Vector3(w / 2, 0.025, d / 2), Color("ffd23f"))
		"dondurma_arabasi":
			_box(r, Vector3(w - 0.2, 0.9, d - 0.3), Vector3(w / 2, 0.65, d / 2), Color("f7c6d9"))
			_box(r, Vector3(w - 0.1, 0.06, d - 0.2), Vector3(w / 2, 1.13, d / 2), Color(0.8, 0.92, 1, 1))
			_box(r, Vector3(0.06, 1.4, 0.06), Vector3(w / 2, 1.8, d / 2), Color("dddddd"))
			_box(r, Vector3(1.6, 0.08, 1.6), Vector3(w / 2, 2.5, d / 2), Color("ffd23f"))
		"tramvay", "tramvay_sari", "tramvay_mavi":
			var col: Color = {"tramvay": Color("c62828"), "tramvay_sari": Color("f2b705"), "tramvay_mavi": Color("1e5bb8")}[id]
			_box(r, Vector3(w - 0.1, 2.4, d - 0.3), Vector3(w / 2, 1.55, d / 2), col)  # gövde
			_box(r, Vector3(w - 0.08, 0.35, d - 0.25), Vector3(w / 2, 0.55, d / 2), Color("2b2b2b"))  # alt etek
			_box(r, Vector3(w - 0.6, 0.9, d - 0.26), Vector3(w / 2, 2.05, d / 2), Color(0.55, 0.75, 0.9, 1))  # pencereler
			for k in int(w / 2.0):
				_box(r, Vector3(0.08, 0.95, d - 0.24), Vector3(1.0 + k * 2.0, 2.05, d / 2), col)
			_box(r, Vector3(w - 0.1, 0.12, d - 0.3), Vector3(w / 2, 2.8, d / 2), Color("f2f2f2"))  # çatı
			_box(r, Vector3(1.2, 0.08, 0.1), Vector3(w / 2, 3.1, d / 2), Color("333333"))  # pantograf
			_box(r, Vector3(0.06, 0.35, 0.06), Vector3(w / 2, 2.95, d / 2), Color("333333"))
			for e in [0.06, w - 0.06]:
				_box(r, Vector3(0.04, 1.0, d - 0.6), Vector3(e, 2.0, d / 2), Color(0.55, 0.75, 0.9, 1))  # ön cam
				_box(r, Vector3(0.05, 0.15, 0.25), Vector3(e, 0.95, 0.4), Color("fff4b0"))  # far
				_box(r, Vector3(0.05, 0.15, 0.25), Vector3(e, 0.95, d - 0.4), Color("fff4b0"))
		"bilet_makinesi":
			_box(r, Vector3(0.6, 1.6, 0.45), Vector3(w / 2, 0.8, d / 2), Color("ffd23f"))
			_box(r, Vector3(0.4, 0.3, 0.02), Vector3(w / 2, 1.25, d / 2 + 0.23), Color("1d2b3a"))  # ekran
			_box(r, Vector3(0.3, 0.06, 0.03), Vector3(w / 2, 0.85, d / 2 + 0.23), Color("333333"))  # bilet ağzı
			_box(r, Vector3(0.14, 0.14, 0.02), Vector3(w / 2, 1.5, d / 2 + 0.23), Color("2e7d32"))
		"metro":
			for car in int(d / 6.0):
				var cz := 3.0 + car * 6.0
				_box(r, Vector3(w - 0.2, 2.6, 5.8), Vector3(w / 2, 1.5, cz), Color("d9dde2"))  # gövde
				_box(r, Vector3(w - 0.18, 0.3, 5.82), Vector3(w / 2, 1.0, cz), Color("d62828"))  # kırmızı şerit
				_box(r, Vector3(w - 0.16, 0.8, 4.6), Vector3(w / 2, 1.95, cz), Color(0.35, 0.5, 0.62, 1))  # pencere
				for dz in [-1.6, 1.6]:
					_box(r, Vector3(w - 0.14, 1.9, 0.9), Vector3(w / 2, 1.15, cz + dz), Color("8f979e"))  # kapı
			for e in [0.04, d - 0.04]:
				_box(r, Vector3(w - 0.6, 0.9, 0.05), Vector3(w / 2, 2.0, e), Color(0.35, 0.5, 0.62, 1))
				_box(r, Vector3(0.25, 0.15, 0.06), Vector3(0.4, 0.8, e), Color("fff4b0"))
				_box(r, Vector3(0.25, 0.15, 0.06), Vector3(w - 0.4, 0.8, e), Color("fff4b0"))
		"ucak", "jet":
			var big := id == "ucak"
			var fw := 1.8 if big else 1.1
			_box(r, Vector3(fw, fw, d - 0.6), Vector3(w / 2, 1.2 + fw / 2, d / 2), Color("f4f6f8"))  # gövde
			_box(r, Vector3(fw * 0.7, fw * 0.6, 0.8), Vector3(w / 2, 1.2 + fw * 0.45, 0.6), Color("dfe3e7"))  # burun
			_box(r, Vector3(fw * 0.6, fw * 0.25, 0.3), Vector3(w / 2, 1.25 + fw * 0.8, 0.9), Color(0.25, 0.35, 0.45, 1))  # kokpit camı
			_box(r, Vector3(w - 0.2, 0.18, 2.2 if big else 1.6), Vector3(w / 2, 1.3 + fw * 0.3, d * 0.48), Color("e6e9ec"))  # kanat
			_box(r, Vector3(w * 0.4, 0.14, 1.0), Vector3(w / 2, 1.3 + fw * 0.7, d - 1.0), Color("e6e9ec"))  # kuyruk yatay
			_box(r, Vector3(0.18, 2.0 if big else 1.4, 1.4), Vector3(w / 2, 1.2 + fw + (1.0 if big else 0.7), d - 1.0), Color("1e5bb8"))  # dikey kuyruk
			_box(r, Vector3(fw + 0.02, 0.25, d - 1.6), Vector3(w / 2, 1.2 + fw * 0.55, d / 2), Color("1e5bb8"))  # mavi şerit
			if big:
				for ex in [w * 0.28, w * 0.72]:
					_box(r, Vector3(0.7, 0.7, 1.4), Vector3(ex, 1.15, d * 0.44), Color("9aa3ab"))  # motor
				for k in 10:
					_box(r, Vector3(fw + 0.03, 0.22, 0.25), Vector3(w / 2, 1.2 + fw * 0.72, 2.0 + k * (d - 4.5) / 10.0), Color(0.3, 0.4, 0.5, 1))
			for gz in [1.0, d * 0.5]:
				_box(r, Vector3(0.12, 1.2, 0.12), Vector3(w / 2, 0.6, gz), Color("444444"))
				_box(r, Vector3(0.6, 0.4, 0.4), Vector3(w / 2, 0.2, gz), Color("222222"))
		"helikopter":
			_box(r, Vector3(1.6, 1.5, 2.6), Vector3(w / 2, 1.05, d * 0.35), Color("d62828"))  # kabin
			_box(r, Vector3(1.4, 0.8, 1.0), Vector3(w / 2, 1.3, d * 0.35 - 1.1), Color(0.35, 0.5, 0.62, 1))  # cam burun
			_box(r, Vector3(0.35, 0.35, d * 0.5), Vector3(w / 2, 1.4, d * 0.75), Color("d62828"))  # kuyruk
			_box(r, Vector3(0.08, 0.9, 0.5), Vector3(w / 2 + 0.2, 1.6, d - 0.3), Color("333333"))  # kuyruk pervanesi
			_box(r, Vector3(5.5, 0.06, 0.25), Vector3(w / 2, 2.1, d * 0.35), Color("333333"))  # pervane
			_box(r, Vector3(0.25, 0.06, 5.5), Vector3(w / 2, 2.1, d * 0.35), Color("333333"))
			for sx in [w / 2 - 0.7, w / 2 + 0.7]:
				_box(r, Vector3(0.1, 0.1, 2.6), Vector3(sx, 0.05, d * 0.35), Color("444444"))  # kızak
		"bagaj_bandi":
			_box(r, Vector3(w - 0.1, 0.6, d - 0.1), Vector3(w / 2, 0.3, d / 2), Color("9aa3ab"))
			_box(r, Vector3(w - 0.2, 0.06, d - 0.3), Vector3(w / 2, 0.63, d / 2), Color("2b2b2b"))
			_box(r, Vector3(0.5, 0.35, 0.4), Vector3(w * 0.3, 0.83, d / 2), Color("d62828"))  # bavul
		"dus":
			_box(r, Vector3(w - 0.05, 0.1, d - 0.05), Vector3(w / 2, 0.05, d / 2), Color("f2f2f2"))  # tekne
			_box(r, Vector3(0.03, 2.0, d - 0.05), Vector3(w - 0.03, 1.1, d / 2), Color(0.75, 0.88, 0.95, 1))  # cam
			_box(r, Vector3(w - 0.05, 2.0, 0.03), Vector3(w / 2, 1.1, d - 0.03), Color(0.75, 0.88, 0.95, 1))
			_box(r, Vector3(0.04, 1.9, 0.04), Vector3(0.15, 1.05, 0.08), STEEL)
			_box(r, Vector3(0.25, 0.04, 0.25), Vector3(0.25, 2.0, 0.2), STEEL)  # duş başlığı
		"havluluk":
			_box(r, Vector3(0.05, 1.1, 0.05), Vector3(0.15, 0.55, d / 2), STEEL)
			_box(r, Vector3(0.05, 1.1, 0.05), Vector3(w - 0.15, 0.55, d / 2), STEEL)
			_box(r, Vector3(w - 0.3, 0.6, 0.06), Vector3(w / 2, 0.75, d / 2), Color("4fa3d9"))  # havlu
			_box(r, Vector3(w - 0.3, 0.12, 0.07), Vector3(w / 2, 0.6, d / 2), Color("ffffff"))
		"ust_dolap":
			_box(r, Vector3(w - 0.04, 0.6, 0.4), Vector3(w / 2, 1.75, 0.2), Color("f2efe9"))
			for k in int(maxf(1.0, w)):
				if not _face(r, Vector3(0.9, 0.52, 0.02), Vector3(0.5 + k, 1.75, 0.41), "on_ust_dolap", Color("e7e1d8")):
					_box(r, Vector3(0.1, 0.03, 0.03), Vector3(0.5 + k, 1.53, 0.43), STEEL)
		"berjer":
			var c := _tone(id, Color("6b8f71"))
			_box(r, Vector3(0.85, 0.3, 0.8), Vector3(w / 2, 0.25, d / 2 + 0.05), c.darkened(0.1))
			_box(r, Vector3(0.65, 0.12, 0.6), Vector3(w / 2, 0.45, d / 2 + 0.1), c.lightened(0.08))
			_box(r, Vector3(0.85, 0.6, 0.18), Vector3(w / 2, 0.6, 0.15), c)
			for sx in [-0.38, 0.38]:
				_box(r, Vector3(0.12, 0.5, 0.7), Vector3(w / 2 + sx, 0.4, d / 2 + 0.05), c.darkened(0.05))
		"tv_sehpasi":
			_box(r, Vector3(w - 0.1, 0.5, d - 0.4), Vector3(w / 2, 0.25, d / 2), Color("5b3a22"))
			_box(r, Vector3(1.7, 0.95, 0.06), Vector3(w / 2, 1.0, d / 2), Color("1b1d20"))
			_face(r, Vector3(1.6, 0.85, 0.01), Vector3(w / 2, 1.0, d / 2 + 0.035), "on_tv", Color("3a6a9b"))
		"koli":
			_box(r, Vector3(0.6, 0.45, 0.5), Vector3(w / 2 - 0.1, 0.225, d / 2), Color("c49a63"))
			_box(r, Vector3(0.45, 0.35, 0.4), Vector3(w / 2 + 0.15, 0.45 + 0.175 - 0.0, d / 2 - 0.05), Color("b98b55"))
			_box(r, Vector3(0.6, 0.02, 0.1), Vector3(w / 2 - 0.1, 0.455, d / 2), Color("8a6a3f"))
		"kiler_rafi":
			_box(r, Vector3(0.05, h, d - 0.1), Vector3(0.05, h / 2, d / 2), Color("8a8a8a"))
			_box(r, Vector3(0.05, h, d - 0.1), Vector3(w - 0.05, h / 2, d / 2), Color("8a8a8a"))
			var jc := [Color("e0a030"), Color("c0392b"), Color("6aa84f"), Color("d9c27a")]
			for i in 4:
				var sy := 0.1 + i * 0.5
				_box(r, Vector3(w - 0.05, 0.04, d - 0.1), Vector3(w / 2, sy, d / 2), Color("a0a0a0"))
				for k in int(w / 0.25):
					_box(r, Vector3(0.14, 0.22, 0.14), Vector3(0.18 + k * 0.25, sy + 0.13, d / 2), jc[(i + k) % jc.size()])
		"serum_askisi":
			# Tekerlekli ayak, direk, üstte askı ve serum torbası.
			_box(r, Vector3(0.5, 0.05, 0.08), Vector3(w / 2, 0.05, d / 2), STEEL)
			_box(r, Vector3(0.08, 0.05, 0.5), Vector3(w / 2, 0.05, d / 2), STEEL)
			_box(r, Vector3(0.04, 1.8, 0.04), Vector3(w / 2, 0.95, d / 2), STEEL)
			_box(r, Vector3(0.4, 0.03, 0.03), Vector3(w / 2, 1.85, d / 2), STEEL)
			_box(r, Vector3(0.16, 0.28, 0.06), Vector3(w / 2 + 0.15, 1.65, d / 2), Color("d8f0f7"))
			_box(r, Vector3(0.02, 0.5, 0.02), Vector3(w / 2 + 0.15, 1.25, d / 2), Color("cfd8dc"))
		"ilac_dolabi":
			# Beyaz dolap, camlı üst bölmede ilaç kutuları, kapakta kırmızı artı.
			_box(r, Vector3(w - 0.06, h, 0.45), Vector3(w / 2, h / 2, 0.24), Color("f4f6f7"))
			_box(r, Vector3(w - 0.16, 0.95, 0.02), Vector3(w / 2, 1.45, 0.475), Color("cfe3ea"))
			var ic := [Color("e53935"), Color("1e88e5"), Color("43a047"), Color("fdd835"), Color("fb8c00")]
			for k in 3:
				_box(r, Vector3(w - 0.18, 0.02, 0.03), Vector3(w / 2, 1.05 + k * 0.3, 0.49), Color("b0bec5"))
				for j in int((w - 0.2) / 0.18):
					_box(r, Vector3(0.12, 0.18, 0.03), Vector3(0.2 + j * 0.18, 1.16 + k * 0.3, 0.49), ic[(j + k * 2) % ic.size()])
			_box(r, Vector3(0.28, 0.08, 0.02), Vector3(w / 2, 0.55, 0.475), Color("e53935"))
			_box(r, Vector3(0.08, 0.28, 0.02), Vector3(w / 2, 0.55, 0.475), Color("e53935"))
		"paravan":
			# Üç kanatlı hasta paravanı: çelik çerçeve, açık mavi kumaş.
			for k in 3:
				var px := w / 6 + k * w / 3
				_box(r, Vector3(w / 3 - 0.04, 1.5, 0.03), Vector3(px, 0.95, d / 2 + (0.08 if k == 1 else -0.08)), Color("bfe3f2"))
				_box(r, Vector3(0.03, 1.75, 0.03), Vector3(px - w / 6 + 0.02, 0.875, d / 2), STEEL)
			_box(r, Vector3(0.03, 1.75, 0.03), Vector3(w - 0.02, 0.875, d / 2), STEEL)
		"tarti":
			# Boy ölçerli hasta tartısı.
			_box(r, Vector3(0.5, 0.08, 0.6), Vector3(w / 2, 0.04, d / 2 + 0.05), Color("eceff1"))
			_box(r, Vector3(0.4, 0.02, 0.45), Vector3(w / 2, 0.09, d / 2 + 0.08), Color("37474f"))
			_box(r, Vector3(0.06, 1.2, 0.06), Vector3(w / 2, 0.65, d / 2 - 0.22), STEEL)
			_box(r, Vector3(0.3, 0.2, 0.08), Vector3(w / 2, 1.2, d / 2 - 0.2), Color("eceff1"))
			_box(r, Vector3(0.2, 0.1, 0.02), Vector3(w / 2, 1.2, d / 2 - 0.15), Color("263238"))
		"bekleme_koltugu":
			# Bekleme salonu oturağı: çelik ayaklar üstünde yan yana mavi koltuklar (önü +Z).
			var n := int(maxf(1.0, w))
			_box(r, Vector3(w - 0.1, 0.06, 0.08), Vector3(w / 2, 0.3, d / 2), STEEL)
			for sx in [0.2, w - 0.2]:
				_box(r, Vector3(0.06, 0.3, 0.5), Vector3(sx, 0.15, d / 2), STEEL)
			for k in n:
				var cx := (k + 0.5) * w / n
				_box(r, Vector3(w / n - 0.12, 0.08, 0.5), Vector3(cx, 0.42, d / 2 + 0.05), Color("2f6fb5"))
				_box(r, Vector3(w / n - 0.12, 0.45, 0.08), Vector3(cx, 0.68, d / 2 - 0.22), Color("2f6fb5"))
		"su_sebili":
			_box(r, Vector3(0.4, 0.95, 0.4), Vector3(w / 2, 0.475, d / 2), Color("f4f6f7"))
			_box(r, Vector3(0.3, 0.4, 0.3), Vector3(w / 2, 1.17, d / 2), Color("6ec1ea"))
			_box(r, Vector3(0.06, 0.06, 0.06), Vector3(w / 2 - 0.08, 0.7, d / 2 + 0.22), Color("1e88e5"))
			_box(r, Vector3(0.06, 0.06, 0.06), Vector3(w / 2 + 0.08, 0.7, d / 2 + 0.22), Color("e53935"))
		"stant":
			# Dükkân ortası çift taraflı alçak raf: üç kat, iki yüzünde renkli ürün kutuları.
			_box(r, Vector3(w - 0.1, 0.1, d - 0.2), Vector3(w / 2, 0.05, d / 2), Color("b0b0b0"))
			_box(r, Vector3(w - 0.1, h - 0.1, 0.05), Vector3(w / 2, h / 2, d / 2), Color("d7d7d7"))
			var sc := [Color("e53935"), Color("fdd835"), Color("43a047"), Color("1e88e5"), Color("fb8c00"), Color("ec407a")]
			for k in 3:
				var sy := 0.12 + k * 0.38
				_box(r, Vector3(w - 0.1, 0.03, d - 0.25), Vector3(w / 2, sy, d / 2), Color("c8c8c8"))
				for j in int((w - 0.2) / 0.22):
					for side in [-1.0, 1.0]:
						_box(r, Vector3(0.17, 0.24, 0.17), Vector3(0.2 + j * 0.22, sy + 0.135, d / 2 + side * 0.22), sc[(j + k + (1 if side > 0 else 3)) % sc.size()])
		"sepetlik":
			# Üst üste alışveriş sepetleri.
			for k in 4:
				_box(r, Vector3(0.55 - k * 0.02, 0.16, 0.4 - k * 0.02), Vector3(w / 2, 0.1 + k * 0.17, d / 2), Color("d32f2f") if k % 2 == 0 else Color("b71c1c"))
			_box(r, Vector3(0.5, 0.03, 0.03), Vector3(w / 2, 0.78, d / 2), Color("263238"))
		"pasta_vitrini":
			# Camlı pasta dolabı: beyaz gövde, iki cam raf, üstünde dilim pastalar ve kurabiyeler.
			_box(r, Vector3(w - 0.05, 0.6, d - 0.15), Vector3(w / 2, 0.3, d / 2), Color("f4f1ea"))
			_box(r, Vector3(w - 0.05, 0.04, d - 0.15), Vector3(w / 2, 1.28, d / 2), Color("f4f1ea"))
			for sx in [0.04, w - 0.04]:
				_box(r, Vector3(0.04, 0.66, d - 0.15), Vector3(sx, 0.94, d / 2), Color("cfd4d8"))
			_box(r, Vector3(w - 0.1, 0.03, d - 0.25), Vector3(w / 2, 0.95, d / 2), Color("d6e8ee"))
			var kc := [Color("f48fb1"), Color("6d4c41"), Color("fff59d"), Color("ef5350"), Color("a5d6a7")]
			for j in int((w - 0.2) / 0.3):
				_box(r, Vector3(0.2, 0.14, 0.2), Vector3(0.2 + j * 0.3, 0.68, d / 2), kc[j % kc.size()])
				_box(r, Vector3(0.2, 0.03, 0.2), Vector3(0.2 + j * 0.3, 0.765, d / 2), Color("fafafa"))
				_box(r, Vector3(0.16, 0.1, 0.16), Vector3(0.2 + j * 0.3, 1.02, d / 2), kc[(j + 2) % kc.size()])
		"ekmek_rafi":
			# Ahşap fırın rafı: dört kat, somun ekmekler ve simitler.
			var c := _tone(id, Color("9a6a3f"))
			_box(r, Vector3(w - 0.05, h, 0.06), Vector3(w / 2, h / 2, 0.05), c.darkened(0.2))
			for sx in [0.04, w - 0.04]:
				_box(r, Vector3(0.06, h, 0.45), Vector3(sx, h / 2, 0.25), c.darkened(0.2))
			for k in 4:
				var sy := 0.2 + k * 0.45
				_box(r, Vector3(w - 0.1, 0.04, 0.45), Vector3(w / 2, sy, 0.25), c)
				for j in int((w - 0.2) / 0.34):
					_box(r, Vector3(0.26, 0.13, 0.16), Vector3(0.22 + j * 0.34, sy + 0.085, 0.27), Color("d9a35a") if (j + k) % 3 != 0 else Color("b97a3a"))
		"ogrenci_dolabi":
			# Koridor dolapları: yan yana renkli metal kapaklar, havalandırma çizgileri, küçük kulp.
			var lc := [Color("3f7fbf"), Color("e0a030"), Color("4f9f5f"), Color("c8504a")]
			var n := int(maxf(1.0, w * 2))
			_box(r, Vector3(w - 0.02, h, 0.42), Vector3(w / 2, h / 2, 0.22), Color("78838c"))
			for k in n:
				var cx := (k + 0.5) * w / n
				_box(r, Vector3(w / n - 0.04, h - 0.1, 0.02), Vector3(cx, h / 2, 0.44), lc[k % lc.size()])
				for v in 3:
					_box(r, Vector3(w / n - 0.2, 0.02, 0.01), Vector3(cx, h - 0.25 - v * 0.07, 0.455), Color("2b2b2b"))
				_box(r, Vector3(0.04, 0.1, 0.03), Vector3(cx + w / n * 0.3, h / 2, 0.46), STEEL)
		"cop_kutusu":
			_box(r, Vector3(0.4, 0.6, 0.4), Vector3(w / 2, 0.3, d / 2), _tone(id, Color("4f9f5f")))
			_box(r, Vector3(0.44, 0.06, 0.44), Vector3(w / 2, 0.63, d / 2), Color("37474f"))
		"yangin_hortumu":
			# Duvara dayalı kırmızı hortum dolabı: sarılı hortum makarası ve yanında yangın söndürücü.
			_box(r, Vector3(0.8, 0.9, 0.2), Vector3(w / 2, 1.1, 0.12), Color("c62828"))
			_box(r, Vector3(0.6, 0.6, 0.06), Vector3(w / 2, 1.1, 0.25), Color("f5f5f5"))
			_box(r, Vector3(0.42, 0.42, 0.06), Vector3(w / 2, 1.1, 0.29), Color("b0b0b0"))
			_box(r, Vector3(0.22, 0.22, 0.07), Vector3(w / 2, 1.1, 0.3), Color("c62828"))
			_box(r, Vector3(0.18, 0.5, 0.18), Vector3(w / 2 + 0.3, 0.25, 0.2), Color("d32f2f"))
			_box(r, Vector3(0.08, 0.1, 0.08), Vector3(w / 2 + 0.3, 0.55, 0.2), Color("263238"))
		"kask_askisi":
			# İtfaiyeci askılığı: üst rafta sarı kasklar, altında asılı ceketler, yerde çizmeler.
			_box(r, Vector3(w - 0.05, 0.05, 0.4), Vector3(w / 2, 1.6, 0.22), Color("8a8a8a"))
			_box(r, Vector3(w - 0.05, h, 0.04), Vector3(w / 2, h / 2, 0.03), Color("9e9e9e"))
			for k in int(maxf(1.0, w * 2)):
				var cx := 0.28 + k * 0.5
				_box(r, Vector3(0.3, 0.18, 0.32), Vector3(cx, 1.72, 0.22), Color("fbc02d"))
				_box(r, Vector3(0.36, 0.04, 0.38), Vector3(cx, 1.64, 0.22), Color("f9a825"))
				_box(r, Vector3(0.34, 0.75, 0.16), Vector3(cx, 1.12, 0.14), Color("3e2f23"))
				_box(r, Vector3(0.34, 0.06, 0.17), Vector3(cx, 0.95, 0.14), Color("fdd835"))
				_box(r, Vector3(0.24, 0.3, 0.26), Vector3(cx, 0.15, 0.2), Color("212121"))
		"misir_makinesi":
			# Patlamış mısır arabası: kırmızı gövde, camlı hazne, içinde sarı mısır, üstte kırmızı çatı.
			_box(r, Vector3(0.7, 0.8, 0.6), Vector3(w / 2, 0.4, d / 2), Color("c62828"))
			_box(r, Vector3(0.72, 0.06, 0.62), Vector3(w / 2, 0.78, d / 2), Color("fdd835"))
			_box(r, Vector3(0.62, 0.6, 0.52), Vector3(w / 2, 1.15, d / 2), Color("d6ecf3"))
			_box(r, Vector3(0.56, 0.3, 0.46), Vector3(w / 2, 1.0, d / 2), Color("ffe082"))
			_box(r, Vector3(0.76, 0.12, 0.66), Vector3(w / 2, 1.52, d / 2), Color("c62828"))
			_box(r, Vector3(0.5, 0.1, 0.4), Vector3(w / 2, 1.64, d / 2), Color("fdd835"))
		_:
			_box(r, f, f / 2, WOOD)


## Eşya dokuları (Mehmet'in gerçekçi görselleri, istemler: docs/gorsel-istemleri-esya-dokulari.md):
## assets/textures/esya/dokular/<ad>.png.
## Her eşyanın ana dokusu ve o dokunun yerini tuttuğu ana renk; ana renge yakın (açık/koyu tonları dahil)
## parçalar dokuyla kaplanır, diğer parçalar (kitap, ekran, düğme) kendi renginde kalır.
const TEXTURES := {
	"yemek_masasi": "ahsap_koyu", "sandalye": "ahsap_koyu", "sehpa": "ahsap_koyu", "komodin": "ahsap_acik",
	"tv_sehpasi": "ahsap_koyu", "ogretmen_masasi": "ahsap_koyu",
	"gardirop": "ahsap_acik", "calisma_masasi": "ahsap_acik", "bank": "ahsap_acik", "sira": "ahsap_acik",
	"oyuncak_kutusu": "ahsap_acik", "market_rafi": "ahsap_acik",
	"mutfak_tezgahi": "beyaz_lake", "ust_dolap": "beyaz_lake", "kasa": "beyaz_lake",
	"buzdolabi": "beyaz_lake", "camasir_makinesi": "beyaz_lake", "ocak": "beyaz_lake", "icecek_dolabi": "beyaz_lake",
	"koltuk": "kumas_gri", "berjer": "kumas_gri",
}
## Eşyanın kodda yazılı ana rengi PNG'den gelmiyorsa burada.
const TEXTURE_REF := {
	"sira": Color("c9a06a"), "kuvet": Color("f7f7f7"), "lavabo": Color("f7f7f7"), "klozet": Color("f7f7f7"),
	"dus": Color("f2f2f2"), "ust_dolap": Color("f2efe9"), "kasa": Color("e9ecef"), "camasir_makinesi": Color("f4f4f4"),
	"icecek_dolabi": Color("d8dde2"),
}
## Her eşyada geçerli ortak dokular: renk → doku (çelik kulplar, tezgâh taşı).
const COLOR_TEXTURES := {"9ea7ad": "metal_celik", "7b7f84": "tezgah_tas"}
static var _tex: Texture2D = null
static var _ref := Color.WHITE
static var _tex_cache := {}


static func _texture(name: String) -> Texture2D:
	if _tex_cache.has(name):
		return _tex_cache[name]
	var path := "res://assets/textures/esya/dokular/%s.png" % name
	var tex: Texture2D = null
	if ResourceLoader.exists(path):
		tex = load(path)
	elif FileAccess.file_exists(path):
		tex = ImageTexture.create_from_image(Image.load_from_file(path))
	# Uzaktan bakınca ince desen (ahşap damarı) titreşip parlamasın: küçültülmüş kopyalar (mipmap) üret.
	if tex and not tex.get_image().has_mipmaps():
		var img := tex.get_image()
		if img.is_compressed():
			img.decompress()
		img.generate_mipmaps()
		tex = ImageTexture.create_from_image(img)
	_tex_cache[name] = tex
	return tex


static func _begin_texture(id: String) -> void:
	_tex = _texture(TEXTURES[id]) if TEXTURES.has(id) else null
	if _tex:
		_ref = TEXTURE_REF.get(id, _tone(id, WOOD))


## Parça rengi ana renge yakınsa (aynı renk, açık/koyu) doku ve parlaklık oranı; değilse null.
static func _texture_tint(color: Color):
	var r := Vector3(color.r / maxf(_ref.r, 0.02), color.g / maxf(_ref.g, 0.02), color.b / maxf(_ref.b, 0.02))
	var lo := minf(r.x, minf(r.y, r.z))
	var hi := maxf(r.x, maxf(r.y, r.z))
	if lo <= 0.0 or hi / lo > 1.3:
		return null
	var k := clampf((r.x + r.y + r.z) / 3.0, 0.3, 1.0)
	return Color(k, k, k)


## Ön yüz görseli (on_dolap_kapagi, on_tv...): görsel varsa parçanın ön yüzüne (top=true ise üstüne)
## bir kez kaplanır ve true döner; yoksa parça düz renkte kurulur, false döner (kulp gibi süsler eklensin).
static func _face(parent: Node3D, size: Vector3, center: Vector3, name: String, color: Color, top := false) -> bool:
	var tex := _texture(name)
	var saved := _tex
	_tex = null
	_box(parent, size, center, color)
	_tex = saved
	if tex == null:
		return false
	var q := MeshInstance3D.new()
	var qm := QuadMesh.new()
	qm.size = Vector2(size.x, size.z if top else size.y)
	var m := StandardMaterial3D.new()
	m.albedo_texture = tex
	m.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS_ANISOTROPIC
	m.roughness = 0.9
	m.metallic_specular = 0.2
	qm.material = m
	q.mesh = qm
	if top:
		q.rotation.x = -PI / 2
		q.position = center + Vector3(0, size.y / 2 + 0.002, 0)
	else:
		q.position = center + Vector3(0, 0, size.z / 2 + 0.002)
	parent.add_child(q)
	return true


static func _box(parent: Node3D, size: Vector3, center: Vector3, color: Color) -> void:
	var mi := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = size
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	var tex: Texture2D = null
	var tint = null
	if COLOR_TEXTURES.has(color.to_html(false)):
		tex = _texture(COLOR_TEXTURES[color.to_html(false)])
		tint = Color.WHITE
	elif _tex:
		tint = _texture_tint(color)
		tex = _tex if tint != null else null
	if tex:
		mat.albedo_texture = tex
		mat.albedo_color = tint
		mat.uv1_triplanar = true
		mat.uv1_scale = Vector3(1.5, 1.5, 1.5)
		# İnce desenli dokular (ahşap damarı, kumaş) uzaktan ve eğik açıdan kıpır kıpır parlamasın.
		mat.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS_ANISOTROPIC
		mat.metallic_specular = 0.2  # mat yüzey; ışık lekesi yapmasın
	mat.roughness = 0.8 if tex == null else 0.95
	mesh.material = mat
	mi.mesh = mesh
	mi.position = center
	parent.add_child(mi)


## Duvar/zemin süsleri: GLB varsa o (esya_<ad>.glb), yoksa köşeli yedek. Pivot: zemin ya da duvar yüzeyi.
const DECOR_SIZE := {
	"poster": Vector3(0.9, 1.2, 0.03), "duvar_saati": Vector3(0.5, 0.5, 0.06),
	"futbol_topu": Vector3(0.35, 0.35, 0.35), "oda_halisi": Vector3(2.2, 0.02, 1.6),
	"ray": Vector3(8.0, 0.08, 1.2), "metro_m": Vector3(1.2, 1.2, 0.1), "havalimani_logo": Vector3(4.0, 1.6, 0.1), "tablo": Vector3(1.0, 0.75, 0.04), "tablo_kucuk": Vector3(0.55, 0.7, 0.04), "perde": Vector3(1.0, 2.1, 0.06),
	"salon_halisi": Vector3(3.0, 0.02, 2.2), "bilgisayar": Vector3(0.7, 0.5, 0.45), "buyuk_saat": Vector3(2.2, 2.2, 0.1), "ayna_duvar": Vector3(0.6, 0.9, 0.03),
	"pano": Vector3(1.8, 1.1, 0.04), "harita": Vector3(1.5, 1.0, 0.03), "sofra": Vector3(1.6, 0.12, 0.7),
	"ucus_tabelasi": Vector3(2.6, 1.5, 0.08),
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
		"tablo", "tablo_kucuk":
			# Yazısız manzara tablosu: çerçeve, gök, tepe, güneş.
			_box(root, size, Vector3.ZERO, Color("8a5a3b"))
			var iw := size.x - 0.12
			var ih := size.y - 0.12
			_box(root, Vector3(iw, ih * 0.55, 0.01), Vector3(0, ih * 0.22, 0.025), Color("8ec9ef"))
			_box(root, Vector3(iw, ih * 0.45, 0.01), Vector3(0, -ih * 0.27, 0.025), Color("5fae4a"))
			_box(root, Vector3(iw * 0.2, iw * 0.2, 0.012), Vector3(iw * 0.25, ih * 0.28, 0.027), Color("ffd23f"))
		"perde":
			for k in 2:
				var sx := (k - 0.5) * size.x * 0.75
				_box(root, Vector3(size.x * 0.3, size.y, size.z), Vector3(sx, 0, 0), Color("c98b6b"))
			_box(root, Vector3(size.x + 0.3, 0.05, 0.05), Vector3(0, size.y / 2, 0), Color("6b4026"))
		"metro_m":
			_box(root, size, Vector3.ZERO, Color("d62828"))
			for bx in [-0.35, 0.35]:
				_box(root, Vector3(0.14, 0.8, 0.02), Vector3(bx, 0, 0.06), Color("ffffff"))
			for bx in [-0.17, 0.17]:
				_box(root, Vector3(0.12, 0.45, 0.02), Vector3(bx, 0.12, 0.065), Color("ffffff"))
		"havalimani_logo":
			_box(root, size, Vector3.ZERO, Color("1e3d6b"))
			_box(root, Vector3(2.0, 0.22, 0.02), Vector3(0, 0, 0.06), Color("ffffff"))  # uçak gövdesi
			_box(root, Vector3(0.35, 1.1, 0.02), Vector3(0.1, 0, 0.065), Color("ffffff"))  # kanatlar
			_box(root, Vector3(0.2, 0.55, 0.02), Vector3(-0.9, 0, 0.065), Color("ffffff"))  # kuyruk
			_box(root, Vector3(0.9, 0.9, 0.02), Vector3(1.4, 0, 0.06), Color("ffd23f"))  # logo
			_box(root, Vector3(0.5, 0.5, 0.02), Vector3(1.4, 0, 0.065), Color("1e3d6b"))
		"ray":
			for k in 8:
				_box(root, Vector3(0.25, 0.04, 1.3), Vector3(-3.5 + k, 0.02, 0), Color("5b4636"))  # travers
			for zz in [-0.45, 0.45]:
				_box(root, Vector3(8.0, 0.07, 0.1), Vector3(0, 0.05, zz), Color("9aa3ab"))
		"salon_halisi":
			_box(root, size, Vector3(0, 0.01, 0), Color("9c3b3b"))
			_box(root, Vector3(size.x - 0.4, 0.022, size.z - 0.4), Vector3(0, 0.012, 0), Color("d8b46a"))
			_box(root, Vector3(size.x - 0.8, 0.024, size.z - 0.8), Vector3(0, 0.013, 0), Color("9c3b3b"))
		"ayna_duvar":
			_box(root, size, Vector3.ZERO, Color("c9a64a"))
			_box(root, Vector3(size.x - 0.08, size.y - 0.08, 0.01), Vector3(0, 0, 0.02), Color("d6e8ee"))
		"bilgisayar":
			# Masa üstü: monitör (+Z'ye bakar), ayak, klavye, fare.
			_box(root, Vector3(0.6, 0.38, 0.04), Vector3(0, 0.3, -0.12), Color("1b1b1b"))
			_box(root, Vector3(0.54, 0.32, 0.01), Vector3(0, 0.3, -0.095), Color("3d7fd6"))
			_box(root, Vector3(0.05, 0.12, 0.05), Vector3(0, 0.06, -0.14), Color("3a3a3a"))
			_box(root, Vector3(0.45, 0.02, 0.15), Vector3(0, 0.01, 0.1), Color("2b2b2b"))
			_box(root, Vector3(0.06, 0.02, 0.09), Vector3(0.3, 0.01, 0.1), Color("2b2b2b"))
		"buyuk_saat":
			_box(root, size, Vector3.ZERO, Color("c9a64a"))
			_box(root, Vector3(size.x - 0.25, size.y - 0.25, 0.02), Vector3(0, 0, 0.05), Color("fbf7ec"))
			for k in 12:
				var a := k * TAU / 12
				_box(root, Vector3(0.1, 0.1, 0.02), Vector3(cos(a) * 0.85, sin(a) * 0.85, 0.07), Color("2b2b2b"))
			_box(root, Vector3(0.08, 0.7, 0.02), Vector3(0, 0.3, 0.08), Color("2b2b2b"))
			_box(root, Vector3(0.5, 0.08, 0.02), Vector3(0.22, 0, 0.09), Color("2b2b2b"))
		"oda_halisi":
			_box(root, size, Vector3(0, 0.01, 0), Color("6fb3e0"))
			_box(root, Vector3(1.6, 0.022, 1.0), Vector3(0, 0.012, 0), Color("a9d6f2"))
		"pano":
			# Mantar pano: ahşap çerçeve, üstünde renkli kâğıtlar (yazısız).
			_box(root, size, Vector3.ZERO, Color("8a5a3b"))
			_box(root, Vector3(size.x - 0.12, size.y - 0.12, 0.01), Vector3(0, 0, 0.022), Color("c9a26b"))
			var pc := [Color("f5f5f5"), Color("ffd23f"), Color("7fd4ff"), Color("ff8fc8"), Color("9fe870"), Color("ffb347")]
			for k in 8:
				var px := -size.x / 2 + 0.25 + (k % 4) * (size.x - 0.5) / 3.0
				var py := 0.22 if k < 4 else -0.22
				_box(root, Vector3(0.28, 0.34, 0.01), Vector3(px, py, 0.03), pc[(k * 5 + 1) % pc.size()])
		"harita":
			# Yazısız dünya haritası: mavi deniz, yeşil kara parçaları.
			_box(root, size, Vector3.ZERO, Color("f2efe6"))
			_box(root, Vector3(size.x - 0.08, size.y - 0.08, 0.01), Vector3(0, 0, 0.018), Color("5aa9e6"))
			for b in [[-0.45, 0.15, 0.3, 0.35], [-0.38, -0.2, 0.16, 0.3], [0.05, 0.1, 0.25, 0.5], [0.4, 0.15, 0.45, 0.3], [0.5, -0.25, 0.2, 0.15]]:
				_box(root, Vector3(b[2], b[3], 0.01), Vector3(b[0], b[1], 0.026), Color("6dbb5a"))
		"sofra":
			# Masa üstü: iki tabak, iki bardak, ortada sürahi ve peçetelik.
			for sx in [-0.45, 0.45]:
				_box(root, Vector3(0.3, 0.02, 0.3), Vector3(sx, 0.01, 0.05), Color("fafafa"))
				_box(root, Vector3(0.18, 0.015, 0.18), Vector3(sx, 0.025, 0.05), Color("e8a33d"))
				_box(root, Vector3(0.08, 0.11, 0.08), Vector3(sx + 0.22, 0.055, -0.15), Color("bfe3f2"))
			_box(root, Vector3(0.12, 0.2, 0.12), Vector3(0, 0.1, -0.05), Color("7fc4e8"))
			_box(root, Vector3(0.1, 0.08, 0.06), Vector3(0, 0.04, 0.2), Color("d94b4b"))
		"ucus_tabelasi":
			# Yazısız uçuş bilgi ekranı: koyu pano, satır satır sarı/beyaz çizgiler ve yeşil/kırmızı durum ışıkları.
			_box(root, size, Vector3.ZERO, Color("20262b"))
			for k in 6:
				var ry := size.y / 2 - 0.2 - k * 0.22
				_box(root, Vector3(0.3, 0.1, 0.01), Vector3(-size.x / 2 + 0.3, ry, 0.045), Color("ffd23f"))
				_box(root, Vector3(1.1 - (k % 3) * 0.2, 0.1, 0.01), Vector3(-0.15 - (k % 3) * 0.1, ry, 0.045), Color("f5f5f5"))
				_box(root, Vector3(0.35, 0.1, 0.01), Vector3(size.x / 2 - 0.65, ry, 0.045), Color("f5f5f5"))
				_box(root, Vector3(0.12, 0.1, 0.01), Vector3(size.x / 2 - 0.2, ry, 0.045), Color("e53935") if k == 2 else Color("43a047"))
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
static func build_door(interior := false) -> Node3D:
	var root := Node3D.new()
	root.name = "Kapi"
	var hinge := Node3D.new()
	root.add_child(hinge)
	var mi := MeshInstance3D.new()
	var bm := BoxMesh.new()
	bm.size = Vector3(0.96, 2.92, 0.08)
	var m := StandardMaterial3D.new()
	var path := "res://assets/textures/esya/kapi_ahsap.png"
	if interior and (ResourceLoader.exists("res://assets/textures/esya/dokular/kapi_ic.png") or FileAccess.file_exists("res://assets/textures/esya/dokular/kapi_ic.png")):
		path = "res://assets/textures/esya/dokular/kapi_ic.png"
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


## Eşyanın ana renkli parçalarını boyar: açık ve doygun yüzeyler renge çekilir, siyah/metal parçalar kalır.
static func _paint(node: Node, tint: Color) -> void:
	for mi in node.find_children("*", "MeshInstance3D", true, false):
		var m: Material = (mi as MeshInstance3D).mesh.surface_get_material(0) if (mi as MeshInstance3D).mesh else null
		if m is StandardMaterial3D:
			var c: Color = (m as StandardMaterial3D).albedo_color
			if c.v < 0.25 or (c.s < 0.12 and c.v < 0.7):
				continue
			var n := (m as StandardMaterial3D).duplicate() as StandardMaterial3D
			n.albedo_color = Color(tint.r * (0.6 + 0.4 * c.v), tint.g * (0.6 + 0.4 * c.v), tint.b * (0.6 + 0.4 * c.v))
			if n.albedo_texture:
				n.albedo_color = n.albedo_color.lightened(0.25)
			(mi as MeshInstance3D).material_override = n
