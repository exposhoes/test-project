class_name Actor
extends Node3D
## Film sahnelerindeki oyuncular (Emir, Anne...): kutulardan kurulu, yürüyebilen, konuşurken ağzı oynayan karakter.
## Yüz görseli assets/textures/actors/<kod>_face.png (ağız açık hali <kod>_face_talk.png) varsa o kullanılır,
## yoksa kodla basit bir yüz çizilir. Model -Z yönüne bakar.

const FACE_DIR := "res://assets/textures/actors/"
const SKIN := Color("f1c7a0")

## "parts": [boyut, merkez, renk] kutuları; "face": [kenar, merkez]; "hair"/"eyes": kodla çizilen yüzün renkleri.
const ACTORS := {
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

var actor_id: String
var data: Dictionary
var talking := false
var _body := Node3D.new()
var _face_mat := StandardMaterial3D.new()
var _face_idle: Texture2D
var _face_talk: Texture2D
var _talk_timer := 0.0
var _walk_phase := 0.0
var _moving := false


static func create(id: String) -> Actor:
	var a := Actor.new()
	a.actor_id = id
	a.data = ACTORS[id]
	a.name = "Actor_" + id
	return a


func _ready() -> void:
	add_child(_body)
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
	var tw := create_tween()
	tw.tween_property(self, "position", target, position.distance_to(target) / speed)
	_moving = true
	await tw.finished
	_moving = false
	_body.position.y = 0.0


## Yüzünü bir noktaya çevirir (model -Z'ye bakar).
func face_towards(point: Vector3) -> void:
	var d := point - position
	if Vector2(d.x, d.z).length() > 0.01:
		rotation.y = atan2(-d.x, -d.z)


func _process(delta: float) -> void:
	if talking:
		_talk_timer += delta
		_face_mat.albedo_texture = _face_talk if int(_talk_timer * 8.0) % 2 == 0 else _face_idle
	elif _face_mat.albedo_texture != _face_idle:
		_face_mat.albedo_texture = _face_idle
	if _moving:
		_walk_phase += delta * 12.0
		_body.position.y = absf(sin(_walk_phase)) * 0.06


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
