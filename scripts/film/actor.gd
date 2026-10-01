class_name Actor
extends Node3D
## Film sahnelerindeki oyuncular (Emir, Anne...): kutulardan kurulu, yürüyebilen, konuşurken ağzı oynayan karakter.
## Yüz görseli assets/textures/actors/<kod>_face.png (ağız açık hali <kod>_face_talk.png) varsa o kullanılır,
## yoksa kodla basit bir yüz çizilir. Model -Z yönüne bakar.

const FACE_DIR := "res://assets/textures/actors/"
const SKIN := Color("f1c7a0")

## "parts": [boyut, merkez, renk] kutuları; "face": [kenar, merkez]; "hair"/"eyes": kodla çizilen yüzün renkleri.
const ACTORS := {
	# Figüranlar: sokakta yürüyen komşular (konuşmazlar).
	"komsu_adam": {"name": "Komşu", "color": Color("cccccc"),
		"parts": [
			[Vector3(0.24, 0.8, 0.26), Vector3(-0.14, 0.4, 0), Color("4a4a55")],
			[Vector3(0.24, 0.8, 0.26), Vector3(0.14, 0.4, 0), Color("4a4a55")],
			[Vector3(0.56, 0.7, 0.32), Vector3(0, 1.15, 0), Color("3f6fb0")],
			[Vector3(0.16, 0.64, 0.18), Vector3(-0.37, 1.17, 0), Color("3f6fb0")],
			[Vector3(0.16, 0.64, 0.18), Vector3(0.37, 1.17, 0), Color("3f6fb0")],
			[Vector3(0.5, 0.5, 0.5), Vector3(0, 1.75, 0), SKIN],
			[Vector3(0.54, 0.12, 0.54), Vector3(0, 2.02, 0.02), Color("2a2a2a")],
		],
		"face": [0.46, Vector3(0, 1.73, -0.25)], "hair": Color("2a2a2a"), "eyes": Color("2a1a10")},
	"komsu_kadin": {"name": "Komşu", "color": Color("cccccc"),
		"parts": [
			[Vector3(0.56, 0.9, 0.34), Vector3(0, 0.45, 0), Color("2f7a6a")],
			[Vector3(0.54, 0.6, 0.32), Vector3(0, 1.2, 0), Color("e8c05a")],
			[Vector3(0.16, 0.56, 0.18), Vector3(-0.36, 1.22, 0), Color("e8c05a")],
			[Vector3(0.16, 0.56, 0.18), Vector3(0.36, 1.22, 0), Color("e8c05a")],
			[Vector3(0.5, 0.5, 0.5), Vector3(0, 1.75, 0), SKIN],
			[Vector3(0.56, 0.12, 0.56), Vector3(0, 2.03, 0.02), Color("8a5a30")],
			[Vector3(0.56, 0.5, 0.3), Vector3(0, 1.78, 0.14), Color("8a5a30")],
		],
		"face": [0.46, Vector3(0, 1.73, -0.25)], "hair": Color("8a5a30"), "eyes": Color("2a1a10")},
	"komsu_cocuk": {"name": "Çocuk", "color": Color("cccccc"),
		"parts": [
			[Vector3(0.22, 0.6, 0.24), Vector3(-0.13, 0.3, 0), Color("c07030")],
			[Vector3(0.22, 0.6, 0.24), Vector3(0.13, 0.3, 0), Color("c07030")],
			[Vector3(0.52, 0.6, 0.3), Vector3(0, 0.9, 0), Color("9a4fd0")],
			[Vector3(0.16, 0.56, 0.18), Vector3(-0.35, 0.92, 0), Color("9a4fd0")],
			[Vector3(0.16, 0.56, 0.18), Vector3(0.35, 0.92, 0), Color("9a4fd0")],
			[Vector3(0.5, 0.5, 0.5), Vector3(0, 1.45, 0), SKIN],
			[Vector3(0.54, 0.14, 0.54), Vector3(0, 1.72, 0.02), Color("111111")],
		],
		"face": [0.46, Vector3(0, 1.43, -0.25)], "hair": Color("111111"), "eyes": Color("2a1a10")},
	"emir": {"name": "Emir", "color": Color("ffd23f"),
		"parts": [
			[Vector3(0.22, 0.6, 0.24), Vector3(-0.13, 0.3, 0), Color("2f4f8f")],   # kot pantolon
			[Vector3(0.22, 0.6, 0.24), Vector3(0.13, 0.3, 0), Color("2f4f8f")],
			[Vector3(0.52, 0.6, 0.3), Vector3(0, 0.9, 0), Color("e0472f")],        # kırmızı tişört
			[Vector3(0.16, 0.56, 0.18), Vector3(-0.35, 0.92, 0), Color("e0472f")],
			[Vector3(0.16, 0.56, 0.18), Vector3(0.35, 0.92, 0), Color("e0472f")],
			[Vector3(0.5, 0.5, 0.5), Vector3(0, 1.45, 0), SKIN],                     # kafa
			[Vector3(0.54, 0.14, 0.54), Vector3(0, 1.72, 0.02), Color("5a3620")],   # saç
		],
		"face": [0.46, Vector3(0, 1.43, -0.25)], "hair": Color("5a3620"), "eyes": Color("3a2a1a")},
	"anne": {"name": "Anne", "color": Color("ff8fc8"),
		"parts": [
			[Vector3(0.56, 0.9, 0.34), Vector3(0, 0.45, 0), Color("7b4fa0")],        # uzun etek
			[Vector3(0.54, 0.6, 0.32), Vector3(0, 1.2, 0), Color("f08a5d")],        # hırka
			[Vector3(0.16, 0.56, 0.18), Vector3(-0.36, 1.22, 0), Color("f08a5d")],
			[Vector3(0.16, 0.56, 0.18), Vector3(0.36, 1.22, 0), Color("f08a5d")],
			[Vector3(0.5, 0.5, 0.5), Vector3(0, 1.75, 0), SKIN],
			[Vector3(0.56, 0.62, 0.3), Vector3(0, 1.72, 0.14), Color("3b2414")],    # arkada uzun saç
			[Vector3(0.56, 0.12, 0.56), Vector3(0, 2.03, 0.02), Color("3b2414")],
		],
		"face": [0.46, Vector3(0, 1.73, -0.25)], "hair": Color("3b2414"), "eyes": Color("2a1a10")},
	"ali": {"name": "Ali", "color": Color("7fd4ff"),
		"parts": [
			[Vector3(0.22, 0.6, 0.24), Vector3(-0.13, 0.3, 0), Color("3a3a3a")],
			[Vector3(0.22, 0.6, 0.24), Vector3(0.13, 0.3, 0), Color("3a3a3a")],
			[Vector3(0.52, 0.6, 0.3), Vector3(0, 0.9, 0), Color("2f9e5a")],        # yeşil forma
			[Vector3(0.16, 0.56, 0.18), Vector3(-0.35, 0.92, 0), Color("2f9e5a")],
			[Vector3(0.16, 0.56, 0.18), Vector3(0.35, 0.92, 0), Color("2f9e5a")],
			[Vector3(0.5, 0.5, 0.5), Vector3(0, 1.45, 0), Color("d9a57a")],
			[Vector3(0.54, 0.1, 0.54), Vector3(0, 1.7, 0.02), Color("1e1e1e")],
			[Vector3(0.56, 0.08, 0.3), Vector3(0, 1.66, -0.3), Color("2a6fd6")],   # şapka siperi
		],
		"face": [0.46, Vector3(0, 1.43, -0.25)], "hair": Color("1e1e1e"), "eyes": Color("1e1e1e")},
	"zeynep": {"name": "Zeynep", "color": Color("c9a0ff"),
		"parts": [
			[Vector3(0.22, 0.5, 0.24), Vector3(-0.13, 0.25, 0), Color("f2f2f2")],
			[Vector3(0.22, 0.5, 0.24), Vector3(0.13, 0.25, 0), Color("f2f2f2")],
			[Vector3(0.56, 0.35, 0.34), Vector3(0, 0.62, 0), Color("e65a9c")],     # etek
			[Vector3(0.5, 0.5, 0.3), Vector3(0, 1.0, 0), Color("ffd23f")],
			[Vector3(0.15, 0.5, 0.18), Vector3(-0.33, 1.0, 0), Color("ffd23f")],
			[Vector3(0.15, 0.5, 0.18), Vector3(0.33, 1.0, 0), Color("ffd23f")],
			[Vector3(0.48, 0.48, 0.48), Vector3(0, 1.49, 0), SKIN],
			[Vector3(0.52, 0.12, 0.52), Vector3(0, 1.75, 0.02), Color("c26a2a")],
			[Vector3(0.14, 0.4, 0.14), Vector3(-0.3, 1.4, 0.15), Color("c26a2a")],   # örgüler
			[Vector3(0.14, 0.4, 0.14), Vector3(0.3, 1.4, 0.15), Color("c26a2a")],
		],
		"face": [0.44, Vector3(0, 1.47, -0.24)], "hair": Color("c26a2a"), "eyes": Color("2a6a3a")},
	"ogretmen": {"name": "Öğretmen", "color": Color("9fe870"),
		"parts": [
			[Vector3(0.24, 0.8, 0.26), Vector3(-0.14, 0.4, 0), Color("3b3b5a")],
			[Vector3(0.24, 0.8, 0.26), Vector3(0.14, 0.4, 0), Color("3b3b5a")],
			[Vector3(0.58, 0.7, 0.34), Vector3(0, 1.15, 0), Color("f4f4f4")],      # beyaz önlük
			[Vector3(0.17, 0.62, 0.2), Vector3(-0.38, 1.17, 0), Color("f4f4f4")],
			[Vector3(0.17, 0.62, 0.2), Vector3(0.38, 1.17, 0), Color("f4f4f4")],
			[Vector3(0.5, 0.5, 0.5), Vector3(0, 1.75, 0), SKIN],
			[Vector3(0.54, 0.12, 0.54), Vector3(0, 2.02, 0.02), Color("8a8a8a")],
			[Vector3(0.36, 0.06, 0.02), Vector3(0, 1.8, -0.26), Color("222222")],    # gözlük
		],
		"face": [0.46, Vector3(0, 1.73, -0.25)], "hair": Color("8a8a8a"), "eyes": Color("2a2a2a")},
	"doktor": {"name": "Doktor", "color": Color("6fe0d0"),
		"parts": [
			[Vector3(0.24, 0.8, 0.26), Vector3(-0.14, 0.4, 0), Color("4a8ab0")],
			[Vector3(0.24, 0.8, 0.26), Vector3(0.14, 0.4, 0), Color("4a8ab0")],
			[Vector3(0.6, 0.9, 0.36), Vector3(0, 1.1, 0), Color("fafafa")],       # uzun beyaz önlük
			[Vector3(0.17, 0.62, 0.2), Vector3(-0.39, 1.17, 0), Color("fafafa")],
			[Vector3(0.17, 0.62, 0.2), Vector3(0.39, 1.17, 0), Color("fafafa")],
			[Vector3(0.1, 0.3, 0.04), Vector3(0.12, 1.25, -0.19), Color("333333")],  # steteskop
			[Vector3(0.5, 0.5, 0.5), Vector3(0, 1.75, 0), Color("d9a57a")],
			[Vector3(0.54, 0.12, 0.54), Vector3(0, 2.02, 0.02), Color("222222")],
		],
		"face": [0.46, Vector3(0, 1.73, -0.25)], "hair": Color("222222"), "eyes": Color("222222")},
	"bakkal": {"name": "Bakkal Amca", "color": Color("ffb347"),
		"parts": [
			[Vector3(0.26, 0.8, 0.28), Vector3(-0.15, 0.4, 0), Color("5a4630")],
			[Vector3(0.26, 0.8, 0.28), Vector3(0.15, 0.4, 0), Color("5a4630")],
			[Vector3(0.66, 0.75, 0.4), Vector3(0, 1.17, 0), Color("8fb8e0")],       # gömlek
			[Vector3(0.62, 0.6, 0.06), Vector3(0, 1.05, -0.22), Color("e8e2cf")],   # önlük
			[Vector3(0.18, 0.62, 0.2), Vector3(-0.42, 1.2, 0), Color("8fb8e0")],
			[Vector3(0.18, 0.62, 0.2), Vector3(0.42, 1.2, 0), Color("8fb8e0")],
			[Vector3(0.52, 0.52, 0.52), Vector3(0, 1.8, 0), SKIN],
			[Vector3(0.4, 0.08, 0.04), Vector3(0, 1.68, -0.27), Color("6a6a6a")],   # bıyık
			[Vector3(0.56, 0.1, 0.56), Vector3(0, 2.08, 0.02), Color("9a9a9a")],
		],
		"face": [0.48, Vector3(0, 1.8, -0.26)], "hair": Color("9a9a9a"), "eyes": Color("2a2a2a")},
}

## Yürürken engel kontrolü: hücre boşsa true döner (film stüdyosu bağlar; yoksa düz yürür).
static var is_free: Callable
## Sahnedeki tüm oyuncular; yürürken birbirinin içinden geçmesinler diye.
static var everyone: Array[Actor] = []
var actor_id: String
var data: Dictionary
var talking := false
var _body := Node3D.new()
var _face_mat := StandardMaterial3D.new()
var _face_idle: Texture2D
var _face_talk: Texture2D
var _talk_timer := 0.0
var _walk_phase := 0.0
## Kaplamalı modellerde omuz/kalça pivotları (yürürken sallanır) ve kafa düğümü.
var _arms: Array[Node3D] = []
var _legs: Array[Node3D] = []
var _head_node: Node3D
## Göz kırpma: göz üstüne ten renginde kapaklar; kısa süre görünür.
var _lids: Array[MeshInstance3D] = []
var _blink_timer := 2.0
var _moving := false


static func create(id: String) -> Actor:
	var a := Actor.new()
	a.actor_id = id
	a.data = ACTORS[id]
	a.name = "Actor_" + id
	return a


func _ready() -> void:
	everyone.append(self)
	tree_exiting.connect(func() -> void: everyone.erase(self))
	add_child(_body)
	if _build_glb():
		return
	if _build_skin():
		return
	for part in data["parts"]:
		var mi := MeshInstance3D.new()
		var mesh := BoxMesh.new()
		mesh.size = part[0]
		var mat := StandardMaterial3D.new()
		mat.albedo_color = part[2]
		mesh.material = mat
		mi.mesh = mesh
		mi.position = part[1]
		_body.add_child(mi)
	_face_idle = _load_or_draw(false)
	_face_talk = _load_or_draw(true)
	var face := MeshInstance3D.new()
	var quad := QuadMesh.new()
	quad.size = Vector2.ONE * float(data["face"][0])
	_face_mat.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
	_face_mat.albedo_texture = _face_idle
	quad.material = _face_mat
	face.mesh = quad
	face.rotation.y = PI
	face.position = data["face"][1] + Vector3(0, 0, -0.005)
	_body.add_child(face)


## Tripo'dan gelen iskeletli, animasyonlu model (res://assets/models/<kod>.glb) varsa o kullanılır:
## ~1.8 birim boya ölçeklenir, -Z'ye bakar; "walk" yürürken, "idle" dururken oynar.
var _anim: AnimationPlayer

func _build_glb() -> bool:
	var path := "res://assets/models/" + actor_id + ".glb"
	if not ResourceLoader.exists(path):
		return false
	var model: Node3D = load(path).instantiate()
	_body.add_child(model)
	var box := AABB()
	var first := true
	for mi: MeshInstance3D in model.find_children("*", "MeshInstance3D", true, false):
		var b: AABB = mi.global_transform * mi.get_aabb() if mi.is_inside_tree() else mi.get_aabb()
		box = b if first else box.merge(b)
		first = false
	var k := float(data.get("height", 1.8)) / maxf(box.size.y, 0.001)
	model.scale = Vector3.ONE * k
	model.position = Vector3(-box.get_center().x * k, -box.position.y * k, -box.get_center().z * k)
	model.rotation.y = float(data.get("glb_turn", PI))
	var players := model.find_children("*", "AnimationPlayer", true, false)
	if not players.is_empty():
		_anim = players[0]
		# Blender kopyası adlar ("walk.001", Godot'da "walk_001") düz ada çevrilsin, yoksa yürürken kayar.
		for lib_name in _anim.get_animation_library_list():
			var lib := _anim.get_animation_library(lib_name)
			for n: StringName in lib.get_animation_list():
				var plain := String(n)
				var tail := plain.get_slice("_", plain.get_slice_count("_") - 1)
				if tail.length() == 3 and tail.is_valid_int():
					plain = plain.left(-4)
				if plain != String(n) and not lib.has_animation(plain):
					lib.rename_animation(n, plain)
		for n in ["walk", "idle"]:
			if _anim.has_animation(n):
				_anim.get_animation(n).loop_mode = Animation.LOOP_LINEAR
		_play("idle")
	_face_idle = null
	return true


func _play(name: String) -> void:
	if _anim and _anim.has_animation(name) and _anim.current_animation != name:
		_anim.play(name, 0.2)


## Mehmet'in Roblox tarzı görünüm sayfasından üretilen kaplama (<kod>_skin.png + .json) varsa
## kafa, gövde, kollar ve bacaklar ondan kurulur (tools/art/build_actor.py). Konuşurken ağız
## üstüne küçük bir koyu ağız açılır. Kaplama yoksa false döner, renkli kutular kullanılır.
func _build_skin() -> bool:
	var json_path := FACE_DIR + actor_id + "_skin.json"
	var tex_path := FACE_DIR + actor_id + "_skin.png"
	if not (FileAccess.file_exists(json_path) and ResourceLoader.exists(tex_path)):
		return false
	var info = JSON.parse_string(FileAccess.get_file_as_string(json_path))
	if typeof(info) != TYPE_DICTIONARY:
		return false
	var mat := StandardMaterial3D.new()
	mat.albedo_texture = load(tex_path)
	mat.roughness = 0.6
	mat.texture_repeat = false
	# Kafa yüzlerinde saçın dışı şeffaf (tools/art/build_actor.py).
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA_SCISSOR
	mat.alpha_scissor_threshold = 0.5
	var head: Dictionary = {}
	for p: Dictionary in info["parts"]:
		var size := Vector3(p["size"][0], p["size"][1], p["size"][2])
		var mi := MeshInstance3D.new()
		var head_res := FACE_DIR + actor_id + "_head.res"
		if p.has("mesh_res"):
			# Küp kafanın üstündeki 3D saç (tools/art/build_heads.py, küp modu).
			var hair := MeshInstance3D.new()
			hair.mesh = load(FACE_DIR + String(p["mesh_res"]))
			hair.position = Vector3(p["pos"][0], p["pos"][1], p["pos"][2])
			_head_pivot().add_child(hair)
			hair.position -= _head_pivot().position
			continue
		if p["name"] == "head" and p.has("mesh") and ResourceLoader.exists(head_res):
			# Görünüm sayfasının silüetlerinden oyulmuş gerçek kafa (tools/art/build_heads.py,
			# tools/bake_heads.gd ile .res'e çevrilir; .res Android paketine otomatik girer).
			mi.mesh = load(head_res)
			mi.position = Vector3(p["pos"][0], p["pos"][1], p["pos"][2])
			_body.add_child(mi)
			head = {"size": size, "pos": mi.position, "mouth": p.get("mouth", []), "eyes": p.get("eyes", []),
				"skin": p.get("skin", [])}
			continue
		if p["name"] in ["arm", "leg"]:
			# Omuzdan / kalçadan döner: pivot parçanın üst kenarında.
			var pivot := Node3D.new()
			pivot.position = Vector3(p["pos"][0], p["pos"][1] + size.y / 2.0, p["pos"][2])
			_body.add_child(pivot)
			mi.mesh = _skin_box(size, p["uv"], mat, 0.2 if not info.get("sharp", false) else 0.04)
			mi.position = Vector3(0, -size.y / 2.0, 0)
			pivot.add_child(mi)
			(_arms if p["name"] == "arm" else _legs).append(pivot)
			continue
		# Kafa belirgin yuvarlak, gövde/kol/bacak hafif yuvarlak köşeli (Roblox plastik oyuncak görünümü).
		var sharp: bool = info.get("sharp", false)
		mi.mesh = _skin_box(size, p["uv"], mat, (0.04 if sharp else (0.3 if p["name"] == "head" else 0.2)))
		if p["name"] == "head":
			_head_pivot().position = Vector3(p["pos"][0], p["pos"][1], p["pos"][2])
			_head_node.add_child(mi)
			head = {"size": size, "pos": _head_node.position, "mouth": p.get("mouth", []), "eyes": p.get("eyes", []),
				"skin": p.get("skin", [])}
			continue
		mi.position = Vector3(p["pos"][0], p["pos"][1], p["pos"][2])
		_body.add_child(mi)
	# Ağız: kafanın ön yüzünde, alt kısımda; boştayken görünmez.
	_face_idle = _mouth_texture(false)
	_face_talk = _mouth_texture(true)
	var mouth := MeshInstance3D.new()
	var quad := QuadMesh.new()
	quad.size = Vector2(0.1, 0.06)
	_face_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	_face_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	_face_mat.albedo_texture = _face_idle
	quad.material = _face_mat
	mouth.mesh = quad
	mouth.rotation.y = PI
	if not head.is_empty():
		var hs: Vector3 = head["size"]
		var m: Array = head.get("mouth", [])
		mouth.position = head["pos"] + (Vector3(m[0], m[1], m[2]) if m.size() == 3 else Vector3(0, -hs.y * float(data.get("mouth_y", 0.36)), -hs.z / 2.0 - 0.004))
	if _head_node and mouth.get_parent() == null:
		mouth.position -= _head_node.position
		_head_node.add_child(mouth)
	elif mouth.get_parent() == null:
		_body.add_child(mouth)
	_add_lids(head)
	return true


## Kafa düğümü (küp kafa, saç, ağız ve göz kapakları bunun çocuğu; ileride kafa çevirme için).
func _head_pivot() -> Node3D:
	if _head_node == null:
		_head_node = Node3D.new()
		_body.add_child(_head_node)
	return _head_node


## Gözlerin üstüne ten rengi kapaklar (build_heads.py "eyes": x, y, z, en, boy ve "skin").
func _add_lids(head: Dictionary) -> void:
	var eyes: Array = head.get("eyes", [])
	var skin: Array = head.get("skin", [])
	if eyes.is_empty() or skin.size() < 3:
		return
	var lid_mat := StandardMaterial3D.new()
	lid_mat.albedo_color = Color8(int(skin[0]), int(skin[1]), int(skin[2]))
	var parent: Node3D = _head_node if _head_node else _body
	var origin: Vector3 = Vector3.ZERO if _head_node else head["pos"]
	for e: Array in eyes:
		var lid := MeshInstance3D.new()
		var q := QuadMesh.new()
		q.size = Vector2(e[3], e[4])
		q.material = lid_mat
		lid.mesh = q
		lid.rotation.y = PI
		lid.position = origin + Vector3(e[0], e[1], e[2] - 0.001)
		lid.visible = false
		parent.add_child(lid)
		_lids.append(lid)


## Yüzleri ayrı UV bölgesi olan, köşeleri yuvarlatılmış kutu: ön -Z (model -Z'ye bakar), arka +Z,
## "left" -X, "right" +X. round: köşe yuvarlaklığı (0 keskin kutu, 1'e yakın neredeyse küre).
## Her yüz ızgaraya bölünür, köşe noktaları iç kutudan dışarı doğru yuvarlanır ve normaller
## yumuşak olduğu için gölge kenarlarda kırılmaz.
static func _skin_box(size: Vector3, uv: Dictionary, mat: Material, round := 0.2) -> ArrayMesh:
	const N := 10
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var faces := {"front": Vector3.FORWARD, "back": Vector3.BACK, "left": Vector3.LEFT,
		"right": Vector3.RIGHT, "top": Vector3.UP, "bottom": Vector3.DOWN}
	var h := size / 2.0
	var r := clampf(round, 0.0, 0.95)
	var inner := Vector3.ONE * (1.0 - r)
	for f: String in faces:
		var n: Vector3 = faces[f]
		var up := Vector3.UP if absf(n.y) < 0.5 else (Vector3.FORWARD if n.y > 0 else Vector3.BACK)
		var right := up.cross(n)
		var rect: Array = uv[f]
		var verts := []
		for j in N + 1:
			for i in N + 1:
				var a := float(i) / N * 2.0 - 1.0
				var b := float(j) / N * 2.0 - 1.0
				var p := n + right * a - up * b  # birim küp yüzeyi
				var c := p.clamp(-inner, inner)
				var d := p - c
				var nn := d.normalized() if d.length() > 0.0001 else n
				var q := c + nn * r
				var normal := (nn / h).normalized()  # ölçeklenmiş kutuda doğru yön
				var uvp := Vector2(lerpf(rect[0], rect[2], float(i) / N), lerpf(rect[1], rect[3], float(j) / N))
				verts.append([q * h, normal, uvp])
		for j in N:
			for i in N:
				var k := j * (N + 1) + i
				for idx: int in [k, k + 1, k + N + 2, k, k + N + 2, k + N + 1]:
					st.set_normal(verts[idx][1])
					st.set_uv(verts[idx][2])
					st.add_vertex(verts[idx][0])
	var mesh := st.commit()
	mesh.surface_set_material(0, mat)
	return mesh


## build_heads.py çıktısı: float32 köşe sayısı, sonra köşe başına konum, normal, uv (8 float).
static func _load_head(bin_path: String, tex_path: String) -> ArrayMesh:
	var data := FileAccess.get_file_as_bytes(bin_path).to_float32_array()
	var n := int(data[0])
	var pos := PackedVector3Array()
	var nor := PackedVector3Array()
	var uvs := PackedVector2Array()
	pos.resize(n)
	nor.resize(n)
	uvs.resize(n)
	for i in n:
		var k := 1 + i * 8
		pos[i] = Vector3(data[k], data[k + 1], data[k + 2])
		nor[i] = Vector3(data[k + 3], data[k + 4], data[k + 5])
		uvs[i] = Vector2(data[k + 6], data[k + 7])
	var arrays := []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = pos
	arrays[Mesh.ARRAY_NORMAL] = nor
	arrays[Mesh.ARRAY_TEX_UV] = uvs
	var mesh := ArrayMesh.new()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	var mat := StandardMaterial3D.new()
	mat.albedo_texture = load(tex_path)
	mat.roughness = 0.55
	mat.texture_repeat = false
	mesh.surface_set_material(0, mat)
	return mesh


static func _mouth_texture(open: bool) -> Texture2D:
	var img := Image.create(20, 12, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	if open:
		for y in 12:
			for x in 20:
				var d := pow((x - 9.5) / 9.5, 2) + pow((y - 5.5) / 5.5, 2)
				if d <= 1.0:
					img.set_pixel(x, y, Color("5a1e1e") if d > 0.35 or y < 7 else Color("c9575a"))
	return ImageTexture.create_from_image(img)


func display_name() -> String:
	return data["name"]


## Yatağa uzanmış (true) ya da ayakta.
func set_lying(lying: bool) -> void:
	_body.rotation.x = -PI / 2.0 if lying else 0.0
	_body.position = Vector3(0, 0.3, 0.8) if lying else Vector3.ZERO


## Bir noktaya yürür; varınca biter (await ile beklenebilir). speed 0: anında ışınlanır.
func walk_to(target: Vector3, speed := 2.2) -> void:
	var flat := Vector3(target.x, position.y, target.z)
	if flat.distance_to(position) > 0.05:
		face_towards(flat)
	if speed <= 0.0:
		position = target
		return
	target = _stop_before_others(target)
	_moving = true
	for p in _path_to(target):
		var f := Vector3(p.x, position.y, p.z)
		if f.distance_to(position) > 0.05:
			face_towards(f)
		var tw := create_tween()
		tw.tween_property(self, "position", p, position.distance_to(p) / speed)
		await tw.finished
	_moving = false
	_body.position.y = 0.0


## Hedefte başka biri duruyorsa onun önünde (yaklaşık bir adım geride) durur.
func _stop_before_others(target: Vector3) -> Vector3:
	for o in everyone:
		if o == self or not o.visible or not is_instance_valid(o):
			continue
		var d := Vector2(target.x - o.position.x, target.z - o.position.z)
		if d.length() < 0.7:
			var back := Vector2(position.x - o.position.x, position.z - o.position.z)
			if back.length() < 0.01:
				back = Vector2(1, 0)
			back = back.normalized() * 0.8
			return Vector3(o.position.x + back.x, target.y, o.position.z + back.y)
	return target


## Bloklar ve diğer oyuncular arasından ızgara üzerinde yol bulur (köşeleri atlayan
## basit bir A*). Yol yoksa ya da engel kontrolü bağlı değilse düz çizgi döner.
func _path_to(target: Vector3) -> Array[Vector3]:
	var straight: Array[Vector3] = [target]
	if not is_free.is_valid():
		return straight
	var y := int(floor(position.y + 0.1))
	var a := Vector2i(floori(position.x), floori(position.z))
	var b := Vector2i(floori(target.x), floori(target.z))
	if a == b:
		return straight
	var lo := Vector2i(mini(a.x, b.x) - 6, mini(a.y, b.y) - 6)
	var hi := Vector2i(maxi(a.x, b.x) + 7, maxi(a.y, b.y) + 7)
	var grid := AStarGrid2D.new()
	grid.region = Rect2i(lo, hi - lo)
	grid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_ONLY_IF_NO_OBSTACLES
	grid.update()
	var taken := {}
	for o in everyone:
		if o != self and o.visible and is_instance_valid(o):
			taken[Vector2i(floori(o.position.x), floori(o.position.z))] = true
	for x in range(lo.x, hi.x):
		for z in range(lo.y, hi.y):
			var c := Vector2i(x, z)
			var free: bool = is_free.call(Vector3i(x, y, z)) and is_free.call(Vector3i(x, y + 1, z))
			if (not free or taken.has(c)) and c != a and c != b:
				grid.set_point_solid(c)
	var cells := grid.get_id_path(a, b)
	if cells.size() < 2:
		return straight
	# Düz giden ara hücreleri at, sadece dönüş noktalarını yürü.
	var out: Array[Vector3] = []
	for i in range(1, cells.size() - 1):
		var d1 := cells[i] - cells[i - 1]
		var d2 := cells[i + 1] - cells[i]
		if d1 != d2:
			out.append(Vector3(cells[i].x + 0.5, position.y, cells[i].y + 0.5))
	out.append(target)
	return out


## Yüzünü bir noktaya çevirir (model -Z'ye bakar).
func face_towards(point: Vector3) -> void:
	var d := point - position
	if Vector2(d.x, d.z).length() > 0.01:
		rotation.y = atan2(-d.x, -d.z)


func _process(delta: float) -> void:
	if _anim:
		_play("walk" if _moving else "idle")
		return
	if talking:
		_talk_timer += delta
		_face_mat.albedo_texture = _face_talk if int(_talk_timer * 8.0) % 2 == 0 else _face_idle
	elif _face_mat.albedo_texture != _face_idle:
		_face_mat.albedo_texture = _face_idle
	if _moving:
		_walk_phase += delta * 12.0
		_body.position.y = absf(sin(_walk_phase)) * 0.06
	# Kol ve bacaklar yürürken zıt yönde sallanır, dururken yavaşça düzelir.
	var swing := sin(_walk_phase) * 0.7 if _moving else 0.0
	for i in _arms.size():
		_arms[i].rotation.x = lerpf(_arms[i].rotation.x, swing * (1.0 if i % 2 == 0 else -1.0), minf(1.0, delta * 12.0))
	for i in _legs.size():
		_legs[i].rotation.x = lerpf(_legs[i].rotation.x, swing * (-1.0 if i % 2 == 0 else 1.0), minf(1.0, delta * 12.0))
	# Göz kırpma: 2-5 saniyede bir, 0.12 saniye.
	if not _lids.is_empty():
		_blink_timer -= delta
		var closed := _blink_timer < 0.12
		for lid in _lids:
			lid.visible = closed
		if _blink_timer < 0.0:
			_blink_timer = randf_range(2.0, 5.0)


func _load_or_draw(talk: bool) -> Texture2D:
	var path := FACE_DIR + actor_id + ("_face_talk.png" if talk else "_face.png")
	if ResourceLoader.exists(path):
		return load(path)
	if talk and ResourceLoader.exists(FACE_DIR + actor_id + "_face.png"):
		return load(FACE_DIR + actor_id + "_face.png")
	return ImageTexture.create_from_image(draw_face(data, talk))


## Görsel gelene kadar kullanılan 16x16 piksel yüz: saç çizgisi, gözler, ağız.
static func draw_face(d: Dictionary, talk: bool) -> Image:
	var img := Image.create(16, 16, false, Image.FORMAT_RGBA8)
	img.fill(SKIN)
	img.fill_rect(Rect2i(0, 0, 16, 3), d["hair"])
	for x in [4, 11]:
		img.fill_rect(Rect2i(x - 1, 6, 2, 3), Color.WHITE)
		img.fill_rect(Rect2i(x, 6, 1, 3), d["eyes"])
	img.fill_rect(Rect2i(3, 10, 2, 1), Color("f0a08a"))
	img.fill_rect(Rect2i(11, 10, 2, 1), Color("f0a08a"))
	if talk:
		img.fill_rect(Rect2i(6, 11, 4, 3), Color("7a2a2a"))
	else:
		img.fill_rect(Rect2i(6, 12, 4, 1), Color("7a2a2a"))
		img.set_pixel(5, 11, Color("7a2a2a"))
		img.set_pixel(10, 11, Color("7a2a2a"))
	return img
