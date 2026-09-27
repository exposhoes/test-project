class_name Mob
extends CharacterBody3D
## Kutulardan kurulan basit yaratık: dolaşır, düşmanca olanlar oyuncuyu kovalar.
## Saldırı, can ve özel yetenekler sonraki adımlarda eklenecek.

const GRAVITY := 24.0
const JUMP_VELOCITY := 7.5
const CHASE_RANGE := 14.0
const FACE_DIR := "res://assets/textures/mobs/"

var mob_id: String
var data: Dictionary
var target: Node3D

var _wander_dir := Vector3.ZERO
var _wander_timer := 0.0


static func create(id: String) -> Mob:
	var mob := Mob.new()
	mob.mob_id = id
	mob.data = MobData.MOBS[id]
	mob.name = "Mob_" + id
	return mob


func _ready() -> void:
	var h: float = data["height"]
	var w: float = data["width"]
	var shape := BoxShape3D.new()
	shape.size = Vector3(w, h, w)
	var col := CollisionShape3D.new()
	col.shape = shape
	col.position.y = h / 2.0
	add_child(col)
	_build_model(h, w)


func _build_model(h: float, w: float) -> void:
	var legs := h * 0.35
	var torso := h * 0.4
	var head := minf(h * 0.25, w * 1.1)
	_box(Vector3(w * 0.4, legs, w * 0.45), Vector3(-w * 0.22, legs / 2.0, 0), data["secondary"])
	_box(Vector3(w * 0.4, legs, w * 0.45), Vector3(w * 0.22, legs / 2.0, 0), data["secondary"])
	_box(Vector3(w, torso, w * 0.55), Vector3(0, legs + torso / 2.0, 0), data["primary"])
	_box(Vector3(head, head, head), Vector3(0, legs + torso + head / 2.0, 0), data["primary"].lightened(0.1))

	var face := MeshInstance3D.new()
	var quad := QuadMesh.new()
	quad.size = Vector2(head, head) * 0.98
	var mat := StandardMaterial3D.new()
	mat.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA_SCISSOR
	mat.albedo_texture = _face_texture()
	quad.material = mat
	face.mesh = quad
	# Model -Z yönüne bakar; QuadMesh varsayılan olarak +Z'ye baktığı için çevrilir.
	face.rotation.y = PI
	face.position = Vector3(0, legs + torso + head / 2.0, -head / 2.0 - 0.005)
	add_child(face)


func _box(size: Vector3, pos: Vector3, color: Color) -> void:
	var mi := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = size
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mesh.material = mat
	mi.mesh = mesh
	mi.position = pos
	add_child(mi)


func _face_texture() -> Texture2D:
	var path := FACE_DIR + "mob_%s_face.png" % mob_id
	if ResourceLoader.exists(path):
		return load(path)
	# Geçici yüz: iki göz ve bir ağız.
	var img := Image.create(8, 8, false, Image.FORMAT_RGBA8)
	img.fill(Color.TRANSPARENT)
	for p in [Vector2i(2, 3), Vector2i(5, 3)]:
		img.set_pixelv(p, Color.WHITE)
	for x in range(2, 6):
		img.set_pixel(x, 6, Color(0.1, 0.1, 0.1))
	return ImageTexture.create_from_image(img)


func _physics_process(delta: float) -> void:
	var dir := _wander(delta)
	if data["behavior"] == MobData.Behavior.HOSTILE and target:
		var to_target := target.global_position - global_position
		to_target.y = 0
		if to_target.length() < CHASE_RANGE:
			dir = to_target.normalized()

	var speed: float = data["speed"]
	velocity.x = dir.x * speed
	velocity.z = dir.z * speed
	if is_on_floor():
		if is_on_wall() and dir != Vector3.ZERO:
			velocity.y = JUMP_VELOCITY
	else:
		velocity.y -= GRAVITY * delta
	if dir != Vector3.ZERO:
		rotation.y = atan2(-dir.x, -dir.z)
	move_and_slide()


func _wander(delta: float) -> Vector3:
	_wander_timer -= delta
	if _wander_timer <= 0.0:
		_wander_timer = randf_range(2.0, 5.0)
		if randf() < 0.4:
			_wander_dir = Vector3.ZERO
		else:
			var a := randf() * TAU
			_wander_dir = Vector3(sin(a), 0, cos(a)) * 0.5
	return _wander_dir
