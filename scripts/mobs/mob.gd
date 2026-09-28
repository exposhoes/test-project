class_name Mob
extends CharacterBody3D
## Kutulardan kurulan basit yaratık: dolaşır, düşmanca olanlar oyuncuyu kovalayıp vurur.
## Nötr olanlar vurulunca kızar, barışçıllar kaçar. Özel yetenekler sonraki adımlarda eklenecek.

const GRAVITY := 24.0
const JUMP_VELOCITY := 7.5
const CHASE_RANGE := 14.0
const ATTACK_RANGE := 1.4
const ATTACK_COOLDOWN := 1.0
const FLEE_TIME := 4.0
const DEFAULT_HEALTH := 10
const DEFAULT_DAMAGE := 2
const FACE_DIR := "res://assets/textures/mobs/"

var mob_id: String
var data: Dictionary
var target: Node3D
var health := DEFAULT_HEALTH

var _angry := false
var _flee_timer := 0.0
var _attack_timer := 0.0
var _knockback := Vector3.ZERO
var _flash_timer := 0.0
var _materials: Array[StandardMaterial3D] = []

var _wander_dir := Vector3.ZERO
var _wander_timer := 0.0


static func create(id: String) -> Mob:
	var mob := Mob.new()
	mob.mob_id = id
	mob.data = MobData.MOBS[id]
	mob.name = "Mob_" + id
	return mob


func _ready() -> void:
	add_to_group("mobs")
	health = data.get("health", DEFAULT_HEALTH)
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
	if data.has("parts"):
		for part in data["parts"]:
			_box(part[0], part[1], part[2], part[3] if part.size() > 3 else "")
		var edge = data["face"][0]
		_add_face(edge if edge is Vector2 else Vector2(edge, edge), data["face"][1])
		return
	var legs := h * 0.35
	var torso := h * 0.4
	var head := minf(h * 0.25, w * 1.1)
	_box(Vector3(w * 0.4, legs, w * 0.45), Vector3(-w * 0.22, legs / 2.0, 0), data["secondary"])
	_box(Vector3(w * 0.4, legs, w * 0.45), Vector3(w * 0.22, legs / 2.0, 0), data["secondary"])
	_box(Vector3(w, torso, w * 0.55), Vector3(0, legs + torso / 2.0, 0), data["primary"])
	_box(Vector3(head, head, head), Vector3(0, legs + torso + head / 2.0, 0), data["primary"].lightened(0.1))
	_add_face(Vector2(head, head), Vector3(0, legs + torso + head / 2.0, -head / 2.0))


## Yüz dokusunu verilen noktadaki (ön yüzeyin merkezi) dikdörtgene giydirir.
## "face_glow" olan yaratıkların yüzü (ekran, hoparlör, parlayan göz) karanlıkta da görünür.
func _add_face(size: Vector2, center: Vector3) -> void:
	var face := MeshInstance3D.new()
	var quad := QuadMesh.new()
	quad.size = size * 0.98
	var mat := StandardMaterial3D.new()
	if data.get("face_glow", false):
		mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA_SCISSOR
	mat.albedo_texture = _face_texture()
	quad.material = mat
	face.mesh = quad
	# Model -Z yönüne bakar; QuadMesh varsayılan olarak +Z'ye baktığı için çevrilir.
	face.rotation.y = PI
	face.position = center + Vector3(0, 0, -0.005)
	add_child(face)


## texture_name verilirse assets/textures/mobs/<ad>.png her yüzeye yarım blokta bir tekrarlanarak giydirilir.
func _box(size: Vector3, pos: Vector3, color: Color, texture_name := "") -> void:
	var mi := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = size
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	var tex_path := FACE_DIR + texture_name + ".png"
	if texture_name != "" and ResourceLoader.exists(tex_path):
		mat.albedo_color = Color.WHITE
		mat.albedo_texture = load(tex_path)
		mat.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
		mat.uv1_triplanar = true
		mat.uv1_scale = Vector3.ONE * 2.0
	mesh.material = mat
	_materials.append(mat)
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


func center_height() -> float:
	return data["height"] / 2.0


func take_damage(amount: int, from: Vector3) -> void:
	health -= amount
	var away := global_position - from
	away.y = 0
	_knockback = away.normalized() * 7.0
	velocity.y = 4.0
	_flash(true)
	if data["behavior"] == MobData.Behavior.PASSIVE:
		_flee_timer = FLEE_TIME
	elif data["behavior"] == MobData.Behavior.NEUTRAL:
		_angry = true
	if health <= 0:
		queue_free()


func _is_aggressive() -> bool:
	return data["behavior"] == MobData.Behavior.HOSTILE or _angry


func _physics_process(delta: float) -> void:
	var dir := _wander(delta)
	var speed: float = data["speed"]
	_attack_timer = maxf(_attack_timer - delta, 0.0)
	if _flash_timer > 0.0:
		_flash_timer -= delta
		if _flash_timer <= 0.0:
			_flash(false)

	if target and is_instance_valid(target):
		var to_target := target.global_position - global_position
		to_target.y = 0
		var dist := to_target.length()
		if _flee_timer > 0.0:
			_flee_timer -= delta
			dir = -to_target.normalized()
		elif _is_aggressive() and dist < CHASE_RANGE:
			dir = to_target.normalized()
			if dist < ATTACK_RANGE + data["width"] / 2.0 and _attack_timer <= 0.0 and target.has_method("hurt"):
				_attack_timer = ATTACK_COOLDOWN
				target.hurt(data.get("damage", DEFAULT_DAMAGE), global_position)
		else:
			speed *= 0.5

	velocity.x = dir.x * speed + _knockback.x
	velocity.z = dir.z * speed + _knockback.z
	_knockback = _knockback.move_toward(Vector3.ZERO, 20.0 * delta)
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
			_wander_dir = Vector3(sin(a), 0, cos(a))
	return _wander_dir


## Vurulunca kısa süre kırmızı yanıp söner.
func _flash(on: bool) -> void:
	_flash_timer = 0.15 if on else 0.0
	for mat in _materials:
		mat.emission_enabled = on
		mat.emission = Color(0.8, 0.0, 0.0)
