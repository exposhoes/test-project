class_name Player
extends CharacterBody3D
## Birinci şahıs oyuncu: yürüme, zıplama, bakma, blok kırma/koyma, yaratıklara vurma.

const WALK_SPEED := 4.5
const JUMP_VELOCITY := 7.8
const GRAVITY := 24.0
const REACH := 6.0
const EYE_HEIGHT := 1.6
const HALF_WIDTH := 0.3
const BODY_HEIGHT := 1.8
const MOUSE_SENSITIVITY := 0.003
const TOUCH_SENSITIVITY := 0.005
## Bu kadar bloktan fazla düşünce her fazla blok için yarım kalp hasar.
const SAFE_FALL := 3.0
const ATTACK_REACH := 3.5
const ATTACK_DAMAGE := 4
const APPLE_CHANCE := 0.2
## Uyku gazındayken yürüme hızı çarpanı.
const GAS_SLOW := 0.45
## Bu hızın üstünde yürümek sesle avlanan yaratıklara duyulur (joystick'i az itmek sessiz yürür).
const LOUD_SPEED := 3.0

signal tamed_mob(mob: Mob)
## Koridor Kapısı kullanıldı (boyut değiştirme main.gd'de).
signal used_portal(portal_block: int)

var world: World
var hud: Hud
var camera := Camera3D.new()
var survival := Survival.new()
var inventory := Inventory.new()

var _pitch := 0.0
var _gas_timer := 0.0
var _target := {}
var _highlight := MeshInstance3D.new()
var _spawned := false
var _fall_peak := 0.0
var _knockback := Vector3.ZERO
var _highlight_mat := StandardMaterial3D.new()
## Basılı tutarak kırma: hangi blok, ne kadar ilerledi (0..1).
var _break_cell := Vector3i.MAX
var _break_progress := 0.0
## Kayıttan yüklenen konum; boşsa dünyanın başlangıç noktasında doğar.
var saved_position := Vector3.INF
## Yeryüzünde son yatılan yatağın üstü; ölünce orada doğulur (yatak kırılmışsa başlangıçta).
var bed_position := Vector3.INF
const BED_SAFE_RANGE := 8.0


func _ready() -> void:
	add_to_group("player")
	var shape := BoxShape3D.new()
	shape.size = Vector3(HALF_WIDTH * 2.0, BODY_HEIGHT, HALF_WIDTH * 2.0)
	var col := CollisionShape3D.new()
	col.shape = shape
	col.position.y = BODY_HEIGHT / 2.0
	add_child(col)

	camera.position.y = EYE_HEIGHT
	camera.fov = 75.0
	camera.far = 200.0
	add_child(camera)

	var box := BoxMesh.new()
	box.size = Vector3.ONE * 1.02
	var mat := _highlight_mat
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.albedo_color = Color(1, 1, 1, 0.18)
	box.material = mat
	_highlight.mesh = box
	_highlight.top_level = true
	_highlight.visible = false
	add_child(_highlight)

	survival.name = "Survival"
	add_child(survival)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		_look(event.relative * MOUSE_SENSITIVITY * Settings.look_speed)
	elif event is InputEventMouseButton and event.pressed and Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
		if not DisplayServer.is_touchscreen_available():
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
			get_viewport().set_input_as_handled()
	elif event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func _physics_process(delta: float) -> void:
	if not _spawned:
		_try_spawn()
		return
	if survival.dead:
		velocity = Vector3.ZERO
		return

	var menu := hud != null and hud.is_menu_open()
	if hud and not menu:
		_look(hud.touch.consume_look_delta() * TOUCH_SENSITIVITY * Settings.look_speed)

	var input := Vector2.ZERO
	if not menu:
		input = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
		if hud:
			input += hud.touch.move_vector
	input = input.limit_length(1.0)
	var dir := (transform.basis * Vector3(input.x, 0, input.y))
	var speed := WALK_SPEED
	if _gas_timer > 0.0:
		_gas_timer -= delta
		speed *= GAS_SLOW
	velocity.x = dir.x * speed + _knockback.x
	velocity.z = dir.z * speed + _knockback.z
	_knockback = _knockback.move_toward(Vector3.ZERO, 20.0 * delta)

	var was_on_floor := is_on_floor()
	if is_on_floor():
		if Input.is_action_pressed("jump") and not menu:
			velocity.y = JUMP_VELOCITY
	else:
		velocity.y -= GRAVITY * delta

	move_and_slide()
	world.update_center(global_position)
	_check_fall(was_on_floor)

	if global_position.y < -20.0:
		survival.take_damage(Survival.MAX_HEALTH)


func _process(delta: float) -> void:
	if not _spawned or survival.dead or (hud and hud.is_menu_open()):
		_highlight.visible = false
		_break_progress = 0.0
		return
	_target = raycast_block()
	_highlight.visible = not _target.is_empty()
	if _highlight.visible:
		_highlight.global_position = Vector3(_target["hit"]) + Vector3.ONE * 0.5

	# Kır'a basınca önce yaratığa vurmayı dener; basılı tutunca blok kırılır.
	if Input.is_action_just_pressed("break_block") and attack():
		_break_progress = 0.0
	elif Input.is_action_pressed("break_block") and not _target.is_empty():
		mine(delta)
	else:
		_break_progress = 0.0
	_highlight_mat.albedo_color = Color(1, 1, 1, 0.18).lerp(Color(0, 0, 0, 0.6), _break_progress)
	if Input.is_action_just_pressed("place_block"):
		use_selected()


func held_item() -> int:
	return inventory.item_at(hud.selected_slot() if hud else 0)


## Bakılan bloğu kırmaya delta kadar devam eder; süre dolunca kırar.
func mine(delta: float) -> void:
	var cell: Vector3i = _target["hit"]
	var id := world.get_block(cell)
	if not Blocks.is_breakable(id):
		_break_progress = 0.0
		return
	if cell != _break_cell:
		_break_cell = cell
		_break_progress = 0.0
	_break_progress += delta / Items.break_time(id, held_item())
	if _break_progress >= 1.0:
		_break_progress = 0.0
		break_target()


## Yakında (dist blok içinde) çalışma masası var mı.
func near_crafting_table(dist := 4) -> bool:
	return near_block(Blocks.CRAFTING_TABLE, dist)


## Yakında (dist blok içinde) verilen blok var mı.
func near_block(block_id: int, dist := 4) -> bool:
	var c := Vector3i(global_position.floor())
	for x in range(-dist, dist + 1):
		for y in range(-dist, dist + 2):
			for z in range(-dist, dist + 1):
				if world.get_block(c + Vector3i(x, y, z)) == block_id:
					return true
	return false


## Elde tutulan aleti bir kez kullanır; kırılırsa haber verir.
func wear_held() -> void:
	var slot := hud.selected_slot() if hud else 0
	var id := inventory.item_at(slot)
	if inventory.wear(slot) and hud:
		Sfx.play("tool_break")
		hud.toast("%s kırıldı!" % Items.display_name(id))


func break_target() -> void:
	if _target.is_empty():
		return
	var pos: Vector3i = _target["hit"]
	var id := world.get_block(pos)
	if Blocks.is_breakable(id):
		world.set_block(pos, Blocks.AIR)
		Sfx.play("break")
		var center := Vector3(pos) + Vector3.ONE * 0.5
		var drop := Items.drop_for_block(id)
		if drop != -1 and Items.harvests(id, held_item()):
			ItemDrop.spawn(get_parent(), center, drop)
		if id == Blocks.LEAVES and randf() < APPLE_CHANCE:
			ItemDrop.spawn(get_parent(), center, Items.APPLE)
		wear_held()


## Koy düğmesi: kapıya bakıyorsan geçer; seçili eşya yiyecekse yenir, blok ise baktığın yere konur.
func use_selected() -> void:
	if not _target.is_empty() and Dimension.is_portal(world.get_block(_target["hit"])):
		used_portal.emit(world.get_block(_target["hit"]))
		return
	if not _target.is_empty() and world.get_block(_target["hit"]) == Blocks.BED:
		use_bed(_target["hit"])
		return
	var slot := hud.selected_slot() if hud else 0
	var id := inventory.item_at(slot)
	if id == Blocks.AIR:
		return
	if try_tame():
		return
	var food := Items.food_value(id)
	if food > 0:
		if survival.hunger < Survival.MAX_HUNGER and inventory.take_one(slot):
			survival.eat(food)
			Sfx.play("eat")
		return
	if Items.is_block(id) and place_at_target(id):
		inventory.take_one(slot)


func can_pick_up(_id: int) -> bool:
	return _spawned and not survival.dead


## Yerdeki eşyayı envantere alır; sığmayan miktarı döner.
func pick_up(id: int, count: int) -> int:
	var left := inventory.add(id, count)
	if left < count:
		Sfx.play("pickup", 0.2)
	return left


## Önündeki en yakın yaratığa vurur. Vurduysa true döner (o zaman blok kırılmaz).
## Evcil dostlara vurulmaz.
func attack() -> bool:
	var best := aimed_mob(false)
	if best == null:
		return false
	best.take_damage(ATTACK_DAMAGE + Items.attack_bonus(held_item()), global_position)
	Sfx.play("hit")
	wear_held()
	return true


## Önünde, erişim mesafesindeki en yakın yaratık; include_tamed false ise evcil dostlar atlanır.
func aimed_mob(include_tamed := true) -> Mob:
	var eye := camera.global_position
	var forward := -camera.global_transform.basis.z
	var best: Mob = null
	var best_dist := ATTACK_REACH
	for node in get_tree().get_nodes_in_group("mobs"):
		var mob := node as Mob
		if mob.tamed and not include_tamed:
			continue
		var to_mob := mob.global_position + Vector3.UP * mob.center_height() - eye
		var dist := to_mob.length()
		# Uzaktakiler için dar bir koni; burnumuzun dibindekiler için yatayda geniş açı yeterli.
		var flat_angle := Vector2(forward.x, forward.z).angle_to(Vector2(to_mob.x, to_mob.z))
		var aimed := forward.angle_to(to_mob) < deg_to_rad(25) or (dist < 2.0 and absf(flat_angle) < deg_to_rad(50))
		if dist < best_dist and aimed:
			best = mob
			best_dist = dist
	return best


## Önündeki yaratığa elindekini verip onu evcilleştirir (dostlar demir, Tüylüpaşa elma). Olduysa true.
func try_tame() -> bool:
	var slot := hud.selected_slot() if hud else 0
	var mob := aimed_mob()
	if mob == null or mob.tamed or mob.tame_item() == -1 or inventory.item_at(slot) != mob.tame_item():
		return false
	inventory.take_one(slot)
	mob.tame(self)
	tamed_mob.emit(mob)
	if hud:
		hud.toast("%s artık dostun!" % mob.data["name"])
	return true


## Yaratık saldırısı gibi dış hasarlar: can düşer ve oyuncu geriye itilir.
func hurt(amount: int, from: Vector3) -> void:
	if survival.dead:
		return
	survival.take_damage(amount)
	Sfx.play("hurt")
	var away := global_position - from
	away.y = 0
	_knockback = away.normalized() * 8.0
	velocity.y = 4.0


## Başka bir boyuta/konuma geçer: dünya hazır olunca pos'ta (INF ise başlangıç noktasında) belirir.
func teleport(pos: Vector3) -> void:
	saved_position = pos
	_knockback = Vector3.ZERO
	velocity = Vector3.ZERO
	_break_progress = 0.0
	_target = {}
	_spawned = false


## Mışıl'ın uyku gazı: bir süre yavaşlar, ekran kararır.
func apply_sleep_gas(seconds: float) -> void:
	if _gas_timer <= 0.0:
		Sfx.play("gas")
	_gas_timer = maxf(_gas_timer, seconds)
	if hud:
		hud.show_gas(seconds)


func is_gassed() -> bool:
	return _gas_timer > 0.0


## Sesle avlanan yaratıklar duyar mı: koşarken evet, yavaş yürürken ya da dururken hayır.
func is_loud() -> bool:
	return Vector2(velocity.x, velocity.z).length() > LOUD_SPEED


## Kamera bu noktaya bakıyor mu (Boşluk Gölgesi bakılınca donar).
func is_looking_at(point: Vector3, max_angle_deg := 35.0) -> bool:
	var to := point - camera.global_position
	return (-camera.global_transform.basis.z).angle_to(to) < deg_to_rad(max_angle_deg)


## Balon Kafa yakalayınca: 8-16 blok ötede rastgele boş bir yere ışınlanır. Olduysa true.
func teleport_nearby(rng_seed := -1) -> bool:
	var rng := RandomNumberGenerator.new()
	if rng_seed >= 0:
		rng.seed = rng_seed
	for i in 24:
		var a := rng.randf() * TAU
		var d := rng.randf_range(8.0, 16.0)
		var x := floori(global_position.x + cos(a) * d)
		var z := floori(global_position.z + sin(a) * d)
		if not world.is_meshed_at(Vector3(x, 0, z)):
			continue
		var y := world.spawn_y(x, z)
		if y < 0:
			continue
		global_position = Vector3(x + 0.5, y + 0.05, z + 0.5)
		velocity = Vector3.ZERO
		_knockback = Vector3.ZERO
		_fall_peak = global_position.y
		return true
	return false


func respawn() -> void:
	_gas_timer = 0.0
	saved_position = bed_position if has_bed() else Vector3.INF
	survival.reset()
	_knockback = Vector3.ZERO
	_spawned = false


func _check_fall(was_on_floor: bool) -> void:
	if was_on_floor and not is_on_floor():
		_fall_peak = global_position.y
	elif not is_on_floor():
		_fall_peak = maxf(_fall_peak, global_position.y)
	elif not was_on_floor:
		var dist := _fall_peak - global_position.y
		if dist > SAFE_FALL:
			survival.take_damage(int(dist - SAFE_FALL))


## Bakılan bloğun önüne blok koyar. Konduysa true döner.
func place_at_target(id: int) -> bool:
	if _target.is_empty():
		return false
	var pos: Vector3i = _target["place"]
	if Blocks.is_solid(world.get_block(pos)) or _overlaps_body(pos):
		return false
	world.set_block(pos, id)
	Sfx.play("place")
	return true


## Voxel DDA ışın izleme. {"hit": bakılan blok, "place": önündeki boş hücre} ya da {}.
func raycast_block() -> Dictionary:
	var origin := camera.global_position
	var dir := -camera.global_transform.basis.z
	var cell := Vector3i(origin.floor())
	var step := Vector3i(dir.sign())
	var t_max := Vector3.INF
	var t_delta := Vector3.INF
	for a in 3:
		if dir[a] != 0.0:
			var boundary := cell[a] + (1 if step[a] > 0 else 0)
			t_max[a] = (boundary - origin[a]) / dir[a]
			t_delta[a] = absf(1.0 / dir[a])
	var prev := cell
	var t := 0.0
	while t <= REACH:
		if Blocks.is_solid(world.get_block(cell)):
			return {"hit": cell, "place": prev}
		prev = cell
		var axis := t_max.min_axis_index()
		cell[axis] += step[axis]
		t = t_max[axis]
		t_max[axis] += t_delta[axis]
	return {}


func _look(delta: Vector2) -> void:
	rotate_y(-delta.x)
	_pitch = clampf(_pitch - delta.y, deg_to_rad(-89), deg_to_rad(89))
	camera.rotation.x = _pitch


func _overlaps_body(cell: Vector3i) -> bool:
	var p := global_position
	var body := AABB(Vector3(p.x - HALF_WIDTH, p.y, p.z - HALF_WIDTH), Vector3(HALF_WIDTH * 2.0, BODY_HEIGHT, HALF_WIDTH * 2.0))
	return body.intersects(AABB(Vector3(cell), Vector3.ONE))


func _try_spawn() -> void:
	var start := world.start_position()
	var spawn := start if saved_position == Vector3.INF else saved_position
	world.update_center(spawn)
	if not world.is_meshed_at(spawn):
		return
	if saved_position == Vector3.INF:
		global_position = Vector3(spawn.x, world.spawn_y(floori(spawn.x), floori(spawn.z)) + 0.5, spawn.z)
	else:
		global_position = saved_position
		saved_position = Vector3.INF
	velocity = Vector3.ZERO
	_fall_peak = global_position.y
	_spawned = true


## Yatak hâlâ yerinde mi ve yeryüzünde miyiz.
func has_bed() -> bool:
	if bed_position == Vector3.INF or world == null or world.dimension != Dimension.OVERWORLD:
		return false
	return world.get_block(Vector3i((bed_position - Vector3(0.5, 1.0, 0.5)).round())) == Blocks.BED


## Yatağa Koy: doğma noktasını kaydeder; gece ve yakında düşman yoksa sabaha atlar.
func use_bed(cell: Vector3i) -> bool:
	var main := get_parent()
	if world.dimension != Dimension.OVERWORLD:
		_toast("Yatak burada çalışmaz")
		return false
	bed_position = Vector3(cell) + Vector3(0.5, 1.0, 0.5)
	if not (main and main.has_method("is_night") and main.is_night()):
		_toast("Doğma noktası kaydedildi. Uyumak için gece olmalı.")
		return false
	for m in get_tree().get_nodes_in_group("mobs"):
		if m._is_aggressive() and m.global_position.distance_to(global_position) < BED_SAFE_RANGE:
			_toast("Yakında düşman var, uyuyamazsın!")
			return false
	main.time_of_day = 0.26
	_toast("Günaydın!")
	return true


func _toast(text: String) -> void:
	if hud:
		hud.toast(text)


func is_spawned() -> bool:
	return _spawned
