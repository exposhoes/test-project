class_name Mob
extends CharacterBody3D
## Kutulardan kurulan basit yaratık: dolaşır, düşmanca olanlar oyuncuyu kovalayıp vurur.
## Nötr olanlar vurulunca kızar, barışçıllar kaçar. Dost (ALLY) olanlara demir verilince evcilleşir:
## oyuncuyu takip eder, yakındaki düşmanlarla savaşır. Özel yetenekler sonraki adımlarda eklenecek.

signal died
## Evcil Tüylüpaşa düşmanı fark edip öttü.
signal warned

const GRAVITY := 24.0
const JUMP_VELOCITY := 7.5
const CHASE_RANGE := 14.0
const ATTACK_RANGE := 1.4
const ATTACK_COOLDOWN := 1.0
const FLEE_TIME := 4.0
const DEFAULT_HEALTH := 10
const DEFAULT_DAMAGE := 2
const FACE_DIR := "res://assets/textures/mobs/"
## Evcil dost: bu mesafeden uzaksa sahibine yürür, çok uzaksa yanına ışınlanır.
const FOLLOW_DISTANCE := 3.5
const TELEPORT_DISTANCE := 24.0
## Evcil dostun sahibinin çevresinde düşman aradığı mesafe.
const GUARD_RANGE := 12.0
## Evcil dost bu kadar saniyede bir 1 can yeniler.
const REGEN_INTERVAL := 4.0
## Yetenek ayarları (mob_data.gd "ability").
const HOP_VELOCITY := 5.5
const HOP_INTERVAL := 0.7
const STARE_SPEEDUP := 1.8
const HEAR_MEMORY := 3.0        # duyduktan sonra bu kadar saniye kovalar
const HEAR_CLOSE := 2.5         # bu kadar yakında sessiz yürüyüş de duyulur
const AMBUSH_RANGE := 4.0
const GAS_TIME := 4.0
const TOSS_VELOCITY := 13.0
const STUN_TIME := 2.0
const SHOCKWAVE_RADIUS := 3.5
const LIGHT_FEAR_RANGE := 6.0
const WARN_COOLDOWN := 12.0

var mob_id: String
var data: Dictionary
var target: Node3D
var health := DEFAULT_HEALTH
## Evcilleşmiş dost mu; sahibi owner.
var tamed := false
var owner_node: Node3D

var _foe: Mob
var _fallback_target: Node3D
var _regen_timer := 0.0
var _stun_timer := 0.0
var _hop_timer := 0.0
var _heard_timer := 0.0
var _awake := false
var _warn_timer := 0.0

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


func max_health() -> int:
	return data.get("health", DEFAULT_HEALTH)


func is_ally() -> bool:
	return data["behavior"] == MobData.Behavior.ALLY


## Bu yaratığı evcilleştiren eşya; evcilleşmiyorsa -1. Dostlar demirle, Tüylüpaşa elmayla.
func tame_item() -> int:
	if data.has("tame_item"):
		return data["tame_item"]
	return Items.IRON if is_ally() else -1


## Dost yaratığı oyuncuya bağlar.
func tame(owner: Node3D) -> void:
	tamed = true
	owner_node = owner
	_angry = false
	_flee_timer = 0.0
	add_to_group("allies")


## Düşman yaratıklar evcil dostlara da vurabilsin diye (oyuncudaki hurt ile aynı imza).
func hurt(amount: int, from: Vector3) -> void:
	take_damage(amount, from)


func center_height() -> float:
	return data["height"] / 2.0


func take_damage(amount: int, from: Vector3) -> void:
	health -= amount
	var away := global_position - from
	away.y = 0
	_knockback = away.normalized() * 7.0
	velocity.y = 4.0
	_flash(true)
	if tamed:
		pass
	elif data["behavior"] == MobData.Behavior.PASSIVE:
		_flee_timer = FLEE_TIME
	elif data["behavior"] == MobData.Behavior.NEUTRAL:
		_angry = true
	if health <= 0:
		died.emit()
		queue_free()


func ability() -> String:
	return data.get("ability", "")


## Kısa süre donar: yürümez, vurmaz (Ekran Adam'ın yeteneği).
func stun(seconds: float) -> void:
	_stun_timer = maxf(_stun_timer, seconds)


func is_stunned() -> bool:
	return _stun_timer > 0.0


func _is_aggressive() -> bool:
	if tamed:
		return false
	if ability() == "night_hostile" and _is_night():
		return true
	return data["behavior"] == MobData.Behavior.HOSTILE or _angry


func _is_night() -> bool:
	var main := get_parent()
	return main != null and main.has_method("is_night") and main.is_night()


## Sırıtkan: yakında fener varsa ya da hedef elinde fener tutuyorsa korkar.
func _afraid_of_light() -> bool:
	if ability() != "fears_light":
		return false
	var main := get_parent()
	var world = main.get("world") if main else null
	if world and world.near_light(global_position, LIGHT_FEAR_RANGE):
		return true
	return target.has_method("held_item") and Blocks.is_light(target.held_item()) \
		and target.global_position.distance_to(global_position) < LIGHT_FEAR_RANGE


## Kovalanacak hedefi algılıyor mu. "hears" koşanı duyar, "stare" bakılınca durur, "ambush" uyanınca kovalar.
func _senses(dist: float) -> bool:
	match ability():
		"hears":
			if dist < HEAR_CLOSE or (target.has_method("is_loud") and target.is_loud()):
				_heard_timer = HEAR_MEMORY
			return _heard_timer > 0.0
		"stare":
			return not _is_watched()
		"ambush":
			if not _awake and dist < AMBUSH_RANGE:
				_awake = true
				velocity.y = JUMP_VELOCITY
			return _awake
	return true


func _is_watched() -> bool:
	return target.has_method("is_looking_at") and target.is_looking_at(global_position + Vector3.UP * center_height())


## Oyuncuya (ya da dosta) vurunca yeteneğe göre ek etki.
func _on_hit(victim: Node3D) -> void:
	match ability():
		"teleport":
			if victim.has_method("teleport_nearby") and victim.teleport_nearby():
				if victim.get("hud"):
					victim.hud.toast("Balon Kafa seni başka yere attı!")
		"gas":
			if victim.has_method("apply_sleep_gas"):
				victim.apply_sleep_gas(GAS_TIME)
		"toss":
			victim.velocity.y = TOSS_VELOCITY


## Evcil dostun bu kare yürüyeceği yön: düşman varsa ona saldırır, yoksa sahibini izler.
func _ally_direction(delta: float) -> Vector3:
	_regen_timer += delta
	if _regen_timer >= REGEN_INTERVAL:
		_regen_timer = 0.0
		health = mini(health + 1, max_health())
	if not is_instance_valid(owner_node):
		return Vector3.ZERO
	# Barışçıl evcil (Tüylüpaşa) savaşmaz; düşman yaklaşınca öter.
	if data["behavior"] == MobData.Behavior.PASSIVE:
		_warn_timer = maxf(_warn_timer - delta, 0.0)
		if ability() == "warn" and _warn_timer <= 0.0 and _find_foe():
			_warn_timer = WARN_COOLDOWN
			if owner_node.get("hud"):
				owner_node.hud.toast("%s ötüyor: düşman yakında!" % data["name"])
			warned.emit()
		_foe = null
	elif not _is_valid_foe(_foe):
		_foe = _find_foe()
	if _foe:
		var to_foe := _foe.global_position - global_position
		to_foe.y = 0
		if to_foe.length() < ATTACK_RANGE + (data["width"] + _foe.data["width"]) / 2.0:
			if _attack_timer <= 0.0:
				_attack_timer = ATTACK_COOLDOWN
				# Vurulan düşman artık dosta döner; dost ölünce yine oyuncuya.
				if _foe.target != self:
					_foe._fallback_target = _foe.target
					_foe.target = self
				_foe.take_damage(data.get("damage", DEFAULT_DAMAGE), global_position)
				_ally_power()
			return Vector3.ZERO
		return to_foe.normalized()
	var to_owner := owner_node.global_position - global_position
	var flat := Vector3(to_owner.x, 0, to_owner.z)
	if to_owner.length() > TELEPORT_DISTANCE:
		global_position = owner_node.global_position + owner_node.global_transform.basis.z * 1.5 + Vector3.UP * 0.2
		velocity = Vector3.ZERO
		return Vector3.ZERO
	return flat.normalized() if flat.length() > FOLLOW_DISTANCE else Vector3.ZERO


## Dost yeteneği: Bas Bekçi'nin ses dalgası çevredeki tüm düşmanları iter, Ekran Adam vurduğunu dondurur.
func _ally_power() -> void:
	match ability():
		"shockwave":
			for node in get_tree().get_nodes_in_group("mobs"):
				var m := node as Mob
				if m != self and _is_valid_foe(m) and m.global_position.distance_to(global_position) < SHOCKWAVE_RADIUS:
					if m != _foe:
						m.take_damage(1, global_position)
					m._knockback *= 2.0
		"stun":
			if is_instance_valid(_foe):
				_foe.stun(STUN_TIME)


func _is_valid_foe(m) -> bool:
	return is_instance_valid(m) and m is Mob and m.health > 0 and m._is_aggressive() \
		and m.global_position.distance_to(owner_node.global_position) < GUARD_RANGE


## Sahibinin çevresindeki en yakın düşman yaratık.
func _find_foe() -> Mob:
	var best: Mob = null
	var best_dist := GUARD_RANGE
	for node in get_tree().get_nodes_in_group("mobs"):
		var m := node as Mob
		if m == self or not _is_valid_foe(m):
			continue
		var d := m.global_position.distance_to(global_position)
		if d < best_dist:
			best = m
			best_dist = d
	return best


func _physics_process(delta: float) -> void:
	var dir := _wander(delta)
	var speed: float = data["speed"]
	_attack_timer = maxf(_attack_timer - delta, 0.0)
	if _flash_timer > 0.0:
		_flash_timer -= delta
		if _flash_timer <= 0.0:
			_flash(false)

	if not is_instance_valid(target) and is_instance_valid(_fallback_target):
		target = _fallback_target
		_fallback_target = null

	_hop_timer = maxf(_hop_timer - delta, 0.0)
	_heard_timer = maxf(_heard_timer - delta, 0.0)
	if _stun_timer > 0.0:
		_stun_timer -= delta
		dir = Vector3.ZERO
	elif ability() == "ambush" and not _awake and not tamed:
		dir = Vector3.ZERO
		if is_instance_valid(target) and target.global_position.distance_to(global_position) < AMBUSH_RANGE:
			_senses(0.0)
	elif tamed:
		dir = _ally_direction(delta)
	elif is_instance_valid(target):
		var to_target := target.global_position - global_position
		to_target.y = 0
		var dist := to_target.length()
		if _flee_timer > 0.0:
			_flee_timer -= delta
			dir = -to_target.normalized()
		elif _is_aggressive() and dist < CHASE_RANGE and _afraid_of_light():
			dir = -to_target.normalized()
		elif ability() == "stare" and _is_aggressive() and dist < CHASE_RANGE and _is_watched():
			# Bakılırken olduğu yerde donar.
			dir = Vector3.ZERO
		elif _is_aggressive() and dist < CHASE_RANGE and _senses(dist):
			dir = to_target.normalized()
			if ability() == "stare":
				speed *= STARE_SPEEDUP
			if dist < ATTACK_RANGE + data["width"] / 2.0 + data.get("reach", 0.0) and _attack_timer <= 0.0 and target.has_method("hurt"):
				_attack_timer = ATTACK_COOLDOWN
				target.hurt(data.get("damage", DEFAULT_DAMAGE), global_position)
				_on_hit(target)
		else:
			speed *= 0.5

	velocity.x = dir.x * speed + _knockback.x
	velocity.z = dir.z * speed + _knockback.z
	_knockback = _knockback.move_toward(Vector3.ZERO, 20.0 * delta)
	if is_on_floor():
		if is_on_wall() and dir != Vector3.ZERO:
			velocity.y = JUMP_VELOCITY
		elif ability() == "hop" and dir != Vector3.ZERO and _hop_timer <= 0.0:
			velocity.y = HOP_VELOCITY
			_hop_timer = HOP_INTERVAL
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
