class_name Player
extends CharacterBody3D
## Birinci şahıs oyuncu: yürüme, zıplama, bakma, blok kırma ve koyma.

const WALK_SPEED := 4.5
const JUMP_VELOCITY := 7.8
const GRAVITY := 24.0
const REACH := 6.0
const EYE_HEIGHT := 1.6
const HALF_WIDTH := 0.3
const BODY_HEIGHT := 1.8
const MOUSE_SENSITIVITY := 0.003
const TOUCH_SENSITIVITY := 0.005

var world: World
var hud: Hud
var camera := Camera3D.new()

var _pitch := 0.0
var _target := {}
var _highlight := MeshInstance3D.new()
var _spawned := false


func _ready() -> void:
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
	var mat := StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.albedo_color = Color(1, 1, 1, 0.18)
	box.material = mat
	_highlight.mesh = box
	_highlight.top_level = true
	_highlight.visible = false
	add_child(_highlight)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		_look(event.relative * MOUSE_SENSITIVITY)
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

	if hud:
		_look(hud.touch.consume_look_delta() * TOUCH_SENSITIVITY)

	var input := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	if hud:
		input += hud.touch.move_vector
	input = input.limit_length(1.0)
	var dir := (transform.basis * Vector3(input.x, 0, input.y))
	velocity.x = dir.x * WALK_SPEED
	velocity.z = dir.z * WALK_SPEED

	if is_on_floor():
		if Input.is_action_pressed("jump"):
			velocity.y = JUMP_VELOCITY
	else:
		velocity.y -= GRAVITY * delta

	move_and_slide()
	world.update_center(global_position)

	if global_position.y < -20.0:
		_spawned = false


func _process(_delta: float) -> void:
	if not _spawned:
		return
	_target = raycast_block()
	_highlight.visible = not _target.is_empty()
	if _highlight.visible:
		_highlight.global_position = Vector3(_target["hit"]) + Vector3.ONE * 0.5

	if Input.is_action_just_pressed("break_block"):
		break_target()
	if Input.is_action_just_pressed("place_block"):
		place_at_target(hud.selected_block() if hud else Blocks.DIRT)


func break_target() -> void:
	if _target.is_empty():
		return
	var pos: Vector3i = _target["hit"]
	if Blocks.is_breakable(world.get_block(pos)):
		world.set_block(pos, Blocks.AIR)


func place_at_target(id: int) -> void:
	if _target.is_empty():
		return
	var pos: Vector3i = _target["place"]
	if Blocks.is_solid(world.get_block(pos)) or _overlaps_body(pos):
		return
	world.set_block(pos, id)


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
	var spawn := Vector3(8.5, 0, 8.5)
	world.update_center(spawn)
	if not world.is_meshed_at(spawn):
		return
	global_position = Vector3(spawn.x, world.surface_y(floori(spawn.x), floori(spawn.z)) + 0.5, spawn.z)
	velocity = Vector3.ZERO
	_spawned = true


func is_spawned() -> bool:
	return _spawned
