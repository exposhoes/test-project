extends Node3D
## Ana menü: arkada dönen kamerayla birkaç yaratık, önde Devam Et / Yeni Dünya.

const GAME_SCENE := "res://scenes/main.tscn"
const SHOWCASE := ["tokmak", "lavabo", "ekran", "mercek", "basbekci", "tuylupasa", "bosluk"]

var _panel := MenuPanel.new()
var _camera := Camera3D.new()
var _angle := 0.0
var _confirm_new := false


func _ready() -> void:
	get_tree().paused = false
	_build_scene()
	var layer := CanvasLayer.new()
	add_child(layer)
	_panel.dim = false
	_panel.center_ratio = 0.3
	_panel.title = "EmirCRAFT"
	layer.add_child(_panel)
	_refresh()


func _refresh() -> void:
	var has_save := FileAccess.file_exists(SaveGame.DEFAULT_PATH)
	var buttons := []
	if _confirm_new:
		_panel.subtitle = "Eski dünya silinecek. Emin misin?"
		buttons.append({"label": "Evet, yeni dünya", "action": _new_world, "style": "danger"})
		buttons.append({"label": "Vazgeç", "action": func() -> void:
			_confirm_new = false
			_refresh()})
	else:
		_panel.subtitle = "Blokla, üret, hayatta kal"
		if has_save:
			buttons.append({"label": "Devam Et", "action": _continue})
		buttons.append({"label": "Yeni Dünya", "action": _ask_new_world if has_save else _new_world})
	_panel.set_buttons(buttons)


func _continue() -> void:
	get_tree().change_scene_to_file(GAME_SCENE)


func _ask_new_world() -> void:
	_confirm_new = true
	_refresh()


func _new_world() -> void:
	SaveGame.delete(SaveGame.DEFAULT_PATH)
	get_tree().change_scene_to_file(GAME_SCENE)


func _process(delta: float) -> void:
	_angle += delta * 0.15
	_camera.look_at_from_position(Vector3(sin(_angle) * 7.5, 2.6, cos(_angle) * 7.5), Vector3(0, 1.3, 0))


func _build_scene() -> void:
	var env := WorldEnvironment.new()
	env.environment = Environment.new()
	var sky := ProceduralSkyMaterial.new()
	sky.sky_top_color = Color("3f8fdc")
	sky.sky_horizon_color = Color("a8d4f5")
	sky.ground_horizon_color = Color("a8d4f5")
	sky.ground_bottom_color = Color("5da83a")
	env.environment.background_mode = Environment.BG_SKY
	env.environment.sky = Sky.new()
	env.environment.sky.sky_material = sky
	env.environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.environment.ambient_light_color = Color.WHITE
	env.environment.ambient_light_energy = 0.6
	add_child(env)
	var sun := DirectionalLight3D.new()
	sun.rotation = Vector3(deg_to_rad(-50), deg_to_rad(30), 0)
	add_child(sun)

	var ground := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = Vector3(60, 1, 60)
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color("5da83a")
	box.material = mat
	ground.mesh = box
	ground.position.y = -0.5
	add_child(ground)

	for i in SHOWCASE.size():
		var mob := Mob.create(SHOWCASE[i])
		add_child(mob)
		# _ready işlemeyi yeniden açtığı için eklendikten sonra durdurulur (vitrinde dolaşmasınlar).
		mob.set_physics_process(false)
		var a := TAU * i / SHOWCASE.size()
		mob.position = Vector3(sin(a), 0, cos(a)) * 2.8
		# Model -Z yönüne bakar; yüzleri dışarı dönsün.
		mob.rotation.y = a + PI
	# Yaratıklar ekranın sağında, menünün yanında görünsün.
	_camera.h_offset = -3.2
	_camera.fov = 60.0
	add_child(_camera)
