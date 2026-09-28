extends Node3D
## Oyunun giriş noktası: dünya, oyuncu, arayüz, gece-gündüz döngüsü ve yaratık doğurma.

const DAY_LENGTH := 600.0  # saniye
const MAX_MOBS := 8
const SPAWN_INTERVAL := 5.0
const DESPAWN_DISTANCE := 56.0

var world := World.new()
var player := Player.new()
var hud := Hud.new()

## 0 = gece yarısı, 0.25 = sabah, 0.5 = öğle, 0.75 = akşam
var time_of_day := 0.3

var _sun := DirectionalLight3D.new()
var _environment := Environment.new()
var _sky_material := ProceduralSkyMaterial.new()
var _mobs: Array[Mob] = []
var _spawn_timer := 0.0


func _ready() -> void:
	_setup_input()
	_setup_environment()

	world.name = "World"
	add_child(world)

	player.name = "Player"
	player.world = world
	player.hud = hud
	add_child(player)

	hud.atlas = world.atlas
	hud.player = player
	add_child(hud)


func is_night() -> bool:
	return time_of_day < 0.22 or time_of_day > 0.78


func _process(delta: float) -> void:
	time_of_day = fposmod(time_of_day + delta / DAY_LENGTH, 1.0)
	_update_sun()
	if player.is_spawned():
		_spawn_timer -= delta
		if _spawn_timer <= 0.0:
			_spawn_timer = SPAWN_INTERVAL
			_despawn_far_mobs()
			_try_spawn_mob()


func _update_sun() -> void:
	var angle := (time_of_day - 0.25) * TAU
	_sun.rotation = Vector3(-angle, deg_to_rad(30), 0)
	var daylight := clampf(sin(angle) * 2.0 + 0.2, 0.0, 1.0)
	_sun.light_energy = daylight
	_environment.ambient_light_energy = lerpf(0.15, 0.6, daylight)
	_sky_material.sky_top_color = Color("0b1026").lerp(Color("3f8fdc"), daylight)
	_sky_material.sky_horizon_color = Color("1c2340").lerp(Color("a8d4f5"), daylight)
	_sky_material.ground_horizon_color = _sky_material.sky_horizon_color
	_sky_material.ground_bottom_color = _sky_material.sky_horizon_color
	_environment.fog_light_color = _sky_material.sky_horizon_color


func _try_spawn_mob() -> void:
	if _mobs.size() >= MAX_MOBS:
		return
	var ids := MobData.ids_for(MobData.Habitat.OVERWORLD, is_night())
	if ids.is_empty():
		return
	var a := randf() * TAU
	var dist := randf_range(16.0, 28.0)
	var x := floori(player.global_position.x + cos(a) * dist)
	var z := floori(player.global_position.z + sin(a) * dist)
	if not world.is_meshed_at(Vector3(x, 0, z)):
		return
	var mob := Mob.create(ids[randi() % ids.size()])
	mob.target = player
	add_child(mob)
	mob.global_position = Vector3(x + 0.5, world.surface_y(x, z) + 0.1, z + 0.5)
	_mobs.append(mob)


func _despawn_far_mobs() -> void:
	for mob in _mobs.duplicate():
		if not is_instance_valid(mob):
			_mobs.erase(mob)
		elif mob.global_position.distance_to(player.global_position) > DESPAWN_DISTANCE:
			_mobs.erase(mob)
			mob.queue_free()


func _setup_environment() -> void:
	_sky_material.sky_curve = 0.15
	var sky := Sky.new()
	sky.sky_material = _sky_material
	_environment.background_mode = Environment.BG_SKY
	_environment.sky = sky
	_environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	_environment.ambient_light_color = Color.WHITE
	_environment.fog_enabled = true
	_environment.fog_density = 0.012
	_environment.fog_sky_affect = 0.0
	var we := WorldEnvironment.new()
	we.environment = _environment
	add_child(we)
	_sun.shadow_enabled = false
	add_child(_sun)
	_update_sun()


## Klavye/fare eşlemeleri. Dokunmatik düğmeler aynı eylemleri tetikler.
func _setup_input() -> void:
	var keys := {
		"move_forward": [KEY_W, KEY_UP],
		"move_back": [KEY_S, KEY_DOWN],
		"move_left": [KEY_A, KEY_LEFT],
		"move_right": [KEY_D, KEY_RIGHT],
		"jump": [KEY_SPACE],
		"inventory": [KEY_E],
	}
	for action in keys:
		_ensure_action(action)
		for key in keys[action]:
			var ev := InputEventKey.new()
			ev.physical_keycode = key
			InputMap.action_add_event(action, ev)
	var buttons := {"break_block": MOUSE_BUTTON_LEFT, "place_block": MOUSE_BUTTON_RIGHT}
	for action in buttons:
		_ensure_action(action)
		var ev := InputEventMouseButton.new()
		ev.button_index = buttons[action]
		InputMap.action_add_event(action, ev)


func _ensure_action(action: String) -> void:
	if not InputMap.has_action(action):
		InputMap.add_action(action)
