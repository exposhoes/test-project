class_name FilmStudio
extends Node3D
## Film Stüdyosu: kalıcı setlerde (film_sets.gd) senaryoları (episodes.gd) oynatır.
## Ekran kaydı için: bölüm seçilir, 3 saniye geri sayılır, oyun arayüzü olmadan sahne oynar.
## Diyalog kutusu altta, konuşan karakterin ağzı oynar. Bitince menü geri gelir.

const MENU_SCENE := "res://scenes/menu.tscn"
## Harf başına okunma süresi ve her replik için en az bekleme (çocuklar okuyabilsin).
const READ_PER_CHAR := 0.055
const READ_MIN := 1.6
const TYPE_SPEED := 45.0  # harf/sn
const LOOK_HEIGHT := 1.3

var world := World.new()
var camera := Camera3D.new()
var actors := {}
var playing := false
## Testler için: true olursa bekleme süreleri kısalır.
var fast := false

var _sun := DirectionalLight3D.new()
var _env := Environment.new()
var _sky := ProceduralSkyMaterial.new()
var _panel := MenuPanel.new()
var _ui := Control.new()
var _box := PanelContainer.new()
var _name_label := Label.new()
var _text_label := Label.new()
var _title := Label.new()
var _bars: Array[ColorRect] = []
var _look := Vector3.ZERO
var _cam_tween: Tween


func _ready() -> void:
	get_tree().paused = false
	_setup_environment()
	add_child(world)
	world.render_distance = 3
	world.generator = FilmSets.new()
	camera.fov = 62.0
	camera.far = 200.0
	add_child(camera)
	_move_camera(FilmSets.point("ev.kam_dis"), FilmSets.point("ev.kapi_disi"), 0)
	_build_ui()
	_show_menu()


func _process(_delta: float) -> void:
	world.update_center(camera.global_position)


## Bölümü baştan sona oynatır (await ile beklenebilir).
func play(id: String) -> void:
	var ep := Episodes.find(id)
	playing = true
	_panel.visible = false
	set_portrait(ep.get("format", "short") == "short")
	_clear_actors()
	set_time(ep.get("time", 0.3))
	var first: Dictionary = ep["steps"][0]
	var set_id: String = ep["set"]
	_move_camera(FilmSets.point(set_id + "." + ("kam_bahce" if set_id == "okul" else "kam_dis")), FilmSets.point(first.get("at", "ev.yatak")), 0)
	# Setin chunk'ları hazır olmadan başlama; bu sırada kayıt için geri say.
	for n in [3, 2, 1]:
		_show_title("Kayıt için hazırlan\n%d" % n)
		await _wait(1.0)
	_title.visible = false
	while not world.is_meshed_at(FilmSets.point(set_id + "." + FilmSets.POINTS[set_id].keys()[0])):
		await get_tree().process_frame
	_set_bars(true)
	for step: Dictionary in ep["steps"]:
		await _run(step)
	_hide_dialogue()
	_title.visible = false
	_set_bars(false)
	playing = false
	set_portrait(false)
	_show_menu(ep.get("format", "short"))


func _run(s: Dictionary) -> void:
	if s.has("title"):
		_hide_dialogue()
		_show_title(s["title"])
		await _wait(s.get("t", 2.0))
		_title.visible = false
	elif s.has("place"):
		var a := _actor(s["place"])
		a.visible = true
		a.position = FilmSets.point(s["at"])
		a.set_lying(s.get("lie", false))
		if s.has("look"):
			a.face_towards(FilmSets.point(s["look"]))
	elif s.has("cam"):
		# Başka sete geçerken oranın chunk'ları yüklenmeden kesme yapma.
		var to := FilmSets.point(s["cam"])
		world.update_center(to)
		while not world.is_meshed_at(to):
			await get_tree().process_frame
		_move_camera(FilmSets.point(s["cam"]), FilmSets.point(s["look"]) + Vector3(0, LOOK_HEIGHT, 0), s.get("t", 0.0))
		if s.get("t", 0.0) > 0:
			await _wait(s["t"])
	elif s.has("say"):
		await _say(s["say"], s["text"])
	elif s.has("walk"):
		var a := _actor(s["walk"])
		var speed := 0.0 if fast else 2.2
		if s.get("wait", true):
			await a.walk_to(FilmSets.point(s["to"]), speed)
		else:
			a.walk_to(FilmSets.point(s["to"]), speed)
	elif s.has("lie"):
		_actor(s["lie"]).set_lying(s["value"])
	elif s.has("turn"):
		_actor(s["turn"]).face_towards(FilmSets.point(s["to"]))
	elif s.has("hide"):
		_actor(s["hide"]).visible = false
	elif s.has("time"):
		set_time(s["time"])
	elif s.has("wait"):
		await _wait(s["wait"])
	elif s.has("zoom"):
		# Komik anda hızlı yakınlaşma vuruşu (Shorts tarzı), sonra geri.
		var tw := create_tween()
		tw.tween_property(camera, "fov", 38.0, 0.12)
		tw.tween_interval(maxf(0.1, s["zoom"]))
		tw.tween_property(camera, "fov", 62.0, 0.2)
		if not fast:
			await tw.finished
	elif s.has("shake"):
		var base := camera.position
		var tw := create_tween()
		for i in int(maxf(1.0, s["shake"] * 20.0)):
			tw.tween_property(camera, "position", base + Vector3(randf_range(-0.08, 0.08), randf_range(-0.08, 0.08), 0), 0.05)
		tw.tween_property(camera, "position", base, 0.05)
		if not fast:
			await tw.finished


func _say(id: String, text: String) -> void:
	var a := _actor(id)
	_name_label.text = a.display_name()
	_name_label.add_theme_color_override("font_color", a.data["color"])
	_text_label.text = text
	_text_label.visible_characters = 0
	_box.visible = true
	a.talking = true
	var total := text.length()
	var t := 0.0
	while _text_label.visible_characters < total:
		if fast:
			break
		t += get_process_delta_time()
		_text_label.visible_characters = mini(total, int(t * TYPE_SPEED))
		await get_tree().process_frame
	_text_label.visible_characters = -1
	a.talking = false
	await _wait(maxf(READ_MIN, total * READ_PER_CHAR) - t)


func _wait(sec: float) -> void:
	if fast or sec <= 0.0:
		await get_tree().process_frame
		return
	await get_tree().create_timer(sec).timeout


func _actor(id: String) -> Actor:
	if not actors.has(id):
		var a := Actor.create(id)
		add_child(a)
		actors[id] = a
	return actors[id]


func _clear_actors() -> void:
	for a: Actor in actors.values():
		a.queue_free()
	actors.clear()


func _move_camera(pos: Vector3, look: Vector3, t: float) -> void:
	if _cam_tween:
		_cam_tween.kill()
	if t <= 0.0 or fast:
		_look = look
		camera.look_at_from_position(pos, look)
		return
	_cam_tween = create_tween().set_parallel().set_trans(Tween.TRANS_SINE)
	_cam_tween.tween_property(camera, "position", pos, t)
	_cam_tween.tween_method(func(l: Vector3) -> void:
		_look = l
		if camera.position.distance_to(l) > 0.01:
			camera.look_at(l), _look, look, t)


## Günün saati (0.25 gündoğumu, 0.5 öğle, 0.75 günbatımı).
func set_time(t: float) -> void:
	var elevation := sin((t - 0.25) * TAU)
	_sun.rotation = Vector3(-asin(clampf(elevation, 0.05, 1.0)), deg_to_rad(35), 0)
	var warm := clampf(1.0 - elevation * 2.0, 0.0, 1.0)
	_sun.light_color = Color.WHITE.lerp(Color("ffc58a"), warm)
	_sky.sky_top_color = Color("3f8fdc").lerp(Color("6a86c8"), warm)
	_sky.sky_horizon_color = Color("a8d4f5").lerp(Color("ffcf9e"), warm)


func _setup_environment() -> void:
	var sky := Sky.new()
	sky.sky_material = _sky
	_env.background_mode = Environment.BG_SKY
	_env.sky = sky
	_env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	_env.ambient_light_color = Color.WHITE
	_env.ambient_light_energy = 1.0
	var we := WorldEnvironment.new()
	we.environment = _env
	add_child(we)
	add_child(_sun)
	set_time(0.3)


func _build_ui() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)
	_ui.set_anchors_preset(Control.PRESET_FULL_RECT)
	_ui.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(_ui)
	# Sinema şeritleri.
	for top in [true, false]:
		var bar := ColorRect.new()
		bar.color = Color.BLACK
		bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
		bar.anchor_right = 1.0
		if top:
			bar.offset_bottom = 48
		else:
			bar.anchor_top = 1.0
			bar.anchor_bottom = 1.0
			bar.offset_top = -48
		bar.visible = false
		_ui.add_child(bar)
		_bars.append(bar)
	# Diyalog kutusu.
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.05, 0.05, 0.1, 0.82)
	style.set_corner_radius_all(14)
	style.set_border_width_all(3)
	style.border_color = Color(1, 1, 1, 0.85)
	style.content_margin_left = 22
	style.content_margin_right = 22
	style.content_margin_top = 10
	style.content_margin_bottom = 14
	_box.add_theme_stylebox_override("panel", style)
	_box.anchor_left = 0.12
	_box.anchor_right = 0.88
	_box.anchor_top = 1.0
	_box.anchor_bottom = 1.0
	_box.offset_top = -210
	_box.offset_bottom = -64
	_box.visible = false
	var v := VBoxContainer.new()
	_box.add_child(v)
	_name_label.add_theme_font_size_override("font_size", 30)
	_name_label.add_theme_color_override("font_outline_color", Color.BLACK)
	_name_label.add_theme_constant_override("outline_size", 6)
	v.add_child(_name_label)
	_text_label.add_theme_font_size_override("font_size", 34)
	_text_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	v.add_child(_text_label)
	_ui.add_child(_box)
	# Bölüm başlığı.
	_title.set_anchors_preset(Control.PRESET_FULL_RECT)
	_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_title.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_title.add_theme_font_size_override("font_size", 64)
	_title.add_theme_color_override("font_color", Color("ffd23f"))
	_title.add_theme_color_override("font_outline_color", Color("3a1a00"))
	_title.add_theme_constant_override("outline_size", 16)
	_title.visible = false
	_ui.add_child(_title)
	_panel.title = "Film Stüdyosu"
	_panel.subtitle = "Bir bölüm seç, ekran kaydını başlat"
	layer.add_child(_panel)


## format "": format seçimi; "short" / "long": o formattaki bölümler.
func _show_menu(format := "") -> void:
	_panel.visible = true
	var buttons := []
	if format == "":
		_panel.subtitle = "Bir format seç"
		buttons.append({"label": "Shorts (dikey, 30-60 sn)", "action": func() -> void: _show_menu("short")})
		buttons.append({"label": "Uzun Bölüm (yatay, 5-10 dk)", "action": func() -> void: _show_menu("long")})
		buttons.append({"label": "Ana Menü", "action": func() -> void:
			get_tree().change_scene_to_file(MENU_SCENE)})
	else:
		_panel.subtitle = "Bir bölüm seç, ekran kaydını başlat"
		for ep: Dictionary in Episodes.of_format(format):
			var id: String = ep["id"]
			buttons.append({"label": ep["name"], "action": func() -> void: play(id)})
		buttons.append({"label": "Geri", "action": func() -> void: _show_menu()})
	_panel.set_buttons(buttons)


## Shorts dikey çekilir: telefonda ekran dik döner, bilgisayarda pencere 9:16 olur.
## Diyalog kutusu ve başlık dar ekrana göre ayarlanır.
func set_portrait(on: bool) -> void:
	if OS.has_feature("mobile"):
		DisplayServer.screen_set_orientation(DisplayServer.SCREEN_PORTRAIT if on else DisplayServer.SCREEN_SENSOR_LANDSCAPE)
	elif DisplayServer.get_name() != "headless":
		DisplayServer.window_set_size(Vector2i(405, 720) if on else Vector2i(1280, 720))
	_box.anchor_left = 0.04 if on else 0.12
	_box.anchor_right = 0.96 if on else 0.88
	_box.offset_top = -330 if on else -210
	_box.offset_bottom = -90 if on else -64
	_title.add_theme_font_size_override("font_size", 44 if on else 64)
	_title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART if on else TextServer.AUTOWRAP_OFF


func _show_title(text: String) -> void:
	_title.text = text
	_title.visible = true


func _hide_dialogue() -> void:
	_box.visible = false


func _set_bars(on: bool) -> void:
	for b in _bars:
		b.visible = on
