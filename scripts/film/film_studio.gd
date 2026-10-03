class_name FilmStudio
extends Node3D
## Film Stüdyosu: kalıcı setlerde (film_sets.gd) senaryoları (episodes.gd) oynatır.
## Ekran kaydı için: bölüm seçilir, 3 saniye geri sayılır, oyun arayüzü olmadan sahne oynar.
## Diyalog kutusu altta, konuşan karakterin ağzı oynar. Bitince menü geri gelir.

const MENU_SCENE := "res://scenes/menu.tscn"
## Harf başına okunma süresi ve her replik için en az bekleme (çocuklar okuyabilsin).
const READ_PER_CHAR := 0.032
const READ_MIN := 0.8
const TYPE_SPEED := 70.0  # harf/sn
const LOOK_HEIGHT := 1.3
const BASE_FOV := 70.0
var _speaker: Actor
var _watch_t := 0.0
var _away_t := 0.0

var world := World.new()
var camera := Camera3D.new()
var actors := {}
var _doors: Array[Node3D] = []
var playing := false
## Testler için: true olursa bekleme süreleri kısalır.
var fast := false
## Movie Maker kaydında pencere boyutu sabit kalmalı.
var recording := false
## Eşyalara takılmadan yol bulunamayan yürüyüş sayısı (testler 0 bekler).
var route_failures := 0
var _extras: Array[Actor] = []
var voice := FilmVoice.new()
var _episode_id := ""
var _line := 0
var _loading := false
var _fov_tween: Tween
var _music := AudioStreamPlayer.new()
var _loading_at := Vector3.ZERO

var _sun := DirectionalLight3D.new()
var _env := Environment.new()
var _sky := ProceduralSkyMaterial.new()
var _panel := MenuPanel.new()
var _ui := Control.new()
## Videolarda altyazı kutusu gösterilsin mi.
const SHOW_SUBTITLES := false
## Replikte "keep_cam": true ise kamera konuşanı aramaz, sahnenin açısında kalır (ör. arkadan çekim).
var _hold_cam := false
var _box := PanelContainer.new()
var _name_label := Label.new()
var _text_label := Label.new()
var _title := Label.new()
## Başlıklarda yalnızca logo (bölüm adı yazılmaz). Logo görseli yoksa "EmirCRAFT" yazısı.
const LOGO_ONLY := true
const LOGO_PATH := "res://assets/textures/logo/emircraft_logo.png"
var _logo := TextureRect.new()
## Kapanış logosunun iki yanında zil ve beğen simgeleri (kanal tanıtımı, "icons": true).
const ICON_PATHS := ["res://assets/textures/logo/simge_begen.png", "res://assets/textures/logo/simge_zil.png"]
var _icons: Array[TextureRect] = []
var _bars: Array[ColorRect] = []
var _fade := ColorRect.new()  # sahne geçişinde yumuşak kararma
var _fade_pending := false
var _look := Vector3.ZERO
var _cam_tween: Tween
## Bölüm içinde eklenen/oynatılan sahne nesneleri (sandık, kazma...): anahtar -> Node3D.
var _dyn := {}
## Kamera yan yatması (Dutch angle), derece.
var _roll := 0.0


func _ready() -> void:
	get_tree().paused = false
	_setup_environment()
	add_child(world)
	add_child(voice)
	add_child(_music)
	world.render_distance = 4
	world.generator = FilmSets.new()
	# Gerçek ev eşyaları (gardırop, masa...) bloklara değil sahneye eklenir.
	var sets := world.generator as FilmSets
	for pr: Array in sets.props:
		var n := FilmProps.build(pr[0], pr[2], pr[3] if pr.size() > 3 else null)
		n.position = Vector3(pr[1])
		add_child(n)
	for dr: Array in sets.doors:
		var n := FilmProps.build_door(dr.size() > 2 and dr[2])
		n.position = dr[0]
		n.rotation.y = dr[1]
		add_child(n)
		_doors.append(n)
	for d: Array in sets.decor:
		var n := FilmProps.build_decor(d[0])
		n.position = d[1]
		n.rotation.y = d[2]
		add_child(n)
	camera.fov = 62.0
	camera.far = 200.0
	add_child(camera)
	_move_camera(FilmSets.point("ev.kam_dis"), FilmSets.point("ev.kapi_disi"), 0)
	_build_ui()
	_show_menu()
	# Otomatik kayıt: tools/kayit.ps1 Godot'yu "-- --bolum=<id>" ile Movie Maker modunda açar;
	# bölüm oynar, bitince oyun kapanır ve video klasöre yazılmış olur.
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--bolum="):
			recording = true
			# Kayıtta keskin görüntü: kenar yumuşatma ve uzaktaki dokularda netlik (telefonda kapalı, yavaşlatmasın).
			get_viewport().msaa_3d = Viewport.MSAA_4X
			await get_tree().process_frame
			await play(arg.trim_prefix("--bolum="))
			get_tree().quit()


func _process(delta: float) -> void:
	_swing_doors(delta)
	if not Actor.is_free.is_valid() and world and world.generator is FilmSets:
		Actor.is_free = (world.generator as FilmSets).is_air
	_watch_speaker(delta)
	_keep_distance(delta)
	# Yeni kamera noktası yüklenirken merkez oraya sabit kalsın; yoksa iki nokta arasında gidip gelir ve chunk hiç bitmez.
	world.update_center(_loading_at if _loading else camera.global_position)


## Kamera hiçbir karakterin yüzüne girmesin: biri ~2.6 bloktan yakına gelirse kamera
## yavaşça geri çekilir (duvara girmeden). Mehmet: "uzak açıdan çek, yüzüne girme".
const MIN_CAM_DIST := 2.6


func _keep_distance(delta: float) -> void:
	if fast or not playing or world == null or not (world.generator is FilmSets):
		return
	var sets := world.generator as FilmSets
	for a in Actor.everyone:
		if not is_instance_valid(a) or not a.visible:
			continue
		var head: Vector3 = a.head_position() if a._body.rotation.x != 0.0 else a.position + Vector3(0, 1.3, 0)
		var away := camera.global_position - head
		away.y = 0.0
		var d := away.length()
		if d >= MIN_CAM_DIST or d < 0.01:
			continue
		var step := away.normalized() * minf(MIN_CAM_DIST - d, delta * 3.0)
		var next := camera.global_position + step
		if sets.is_air(Vector3i(next.floor())):
			if _cam_tween and _cam_tween.is_running():
				_cam_tween.kill()
			camera.global_position = next
			camera.look_at(_look if _look != Vector3.ZERO else head)


## Bölümü baştan sona oynatır (await ile beklenebilir).
func play(id: String) -> void:
	var ep := Episodes.find(id)
	playing = true
	_episode_id = ep["id"]
	_line = 0
	voice.enabled = not fast
	_panel.visible = false
	set_portrait(ep.get("format", "short") == "short")
	_clear_actors()
	set_time(ep.get("time", 0.3))
	var first: Dictionary = ep["steps"][0]
	var set_id: String = ep["set"]
	_move_camera(FilmSets.point(set_id + "." + _establishing_cam(set_id)), FilmSets.point(first.get("at", "ev.yatak")), 0)
	_title.visible = false
	var start := FilmSets.point(set_id + "." + FilmSets.POINTS[set_id].keys()[0])
	_loading = true
	_loading_at = start
	while not world.is_meshed_at(start):
		await get_tree().process_frame
	_loading = false
	_set_bars(true)
	play_music(ep.get("music", "neseli"))
	_spawn_extras(set_id)
	for step: Dictionary in ep["steps"]:
		await _run(step)
	_hide_dialogue()
	_title.visible = false
	_set_bars(false)
	_music.stop()
	playing = false
	set_portrait(false)
	_show_menu(ep.get("format", "short"))


## Setin açılış kamerası: kam_dis / kam_bahce / kam_genel, yoksa ilk kam_ noktası.
func _establishing_cam(set_id: String) -> String:
	var pts: Dictionary = FilmSets.POINTS[set_id]
	for k in ["kam_dis", "kam_bahce", "kam_genel"]:
		if pts.has(k):
			return k
	for k: String in pts:
		if k.begins_with("kam_"):
			return k
	return pts.keys()[0]


func _run(s: Dictionary) -> void:
	if s.has("sfx"):
		play_sfx(s["sfx"])
		# Sahne geçiş sesi, ağır sahne değişiminden önce başlasın diye kısa bekleme
		# (yoksa kayıtta bazen hiç duyulmuyordu).
		# ve görüntü yumuşakça kararır; yeni çekimde yeniden açılır.
		if s["sfx"] == "vuup":
			_fade_pending = true
			if not fast:
				create_tween().tween_property(_fade, "color:a", 1.0, 0.35)
			await _wait(0.35)
	elif s.has("music"):
		play_music(s["music"], s.get("fallback", "neseli"))
	elif s.has("title"):
		_fade_in()
		play_sfx("baslik")
		_hide_dialogue()
		_show_title(s["title"])
		if s.get("icons", false):
			_show_icons()
		await _wait(s.get("t", 2.0))
		_title.visible = false
		_logo.visible = false
		for ic in _icons:
			ic.queue_free()
		_icons.clear()
	elif s.has("place"):
		var a := _actor(s["place"])
		a.visible = true
		a.position = _free_spot(a, FilmSets.point(s["at"]), s.get("lie", false))
		a.set_lying(s.get("lie", false))
		if s.has("look"):
			a.face_towards(FilmSets.point(s["look"]))
	elif s.has("cam"):
		# Replik bitti, sahne değişiyor: eski altyazı yeni çekimde kalıp replik tekrar ediyor gibi görünmesin.
		_hide_dialogue()
		# Başka sete geçerken oranın chunk'ları yüklenmeden kesme yapma.
		var to := FilmSets.point(s["cam"])
		_loading = true
		_loading_at = to
		world.update_center(to)
		while not world.is_meshed_at(to):
			await get_tree().process_frame
		_loading = false
		_move_camera(FilmSets.point(s["cam"]), FilmSets.point(s["look"]) + Vector3(0, s.get("dy", LOOK_HEIGHT), 0), s.get("t", 0.0))
		_fade_in()
		if s.get("t", 0.0) > 0:
			await _wait(s["t"])
	elif s.has("say"):
		_hold_cam = s.get("keep_cam", false) or s.has("cuts")
		if s.has("cuts"):
			_run_cuts(s["cuts"], s["text"])
		await _say(s["say"], s["text"])
		_hold_cam = false
	elif s.has("walk"):
		var a := _actor(s["walk"])
		var speed := 0.0 if fast else float(s.get("speed", 2.2))
		# Başka kattaki hedef (ör. üst kattaki oda ↔ mutfak): yol bulucu tek katta çalışır, sahne kesmesiyle geç.
		if absf(FilmSets.point(s["to"]).y - a.position.y) > 2.0:
			a.position = FilmSets.point(s["to"])
			return
		var path := (world.generator as FilmSets).route(a.position, FilmSets.point(s["to"]))
		if path.is_empty():
			route_failures += 1
			path = [FilmSets.point(s["to"])]
		if s.get("wait", true):
			await _walk_path(a, path, speed)
		else:
			_walk_path(a, path, speed)
	elif s.has("gesture"):
		_actor(s["gesture"]).gesture(s.get("kind", "evet"))
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
		play_sfx("bom")
		# Komik anda hızlı yakınlaşma vuruşu (Shorts tarzı), sonra geri.
		var tw := create_tween()
		tw.tween_property(camera, "fov", 38.0, 0.12)
		tw.tween_interval(maxf(0.1, s["zoom"]))
		tw.tween_property(camera, "fov", BASE_FOV, 0.2)
		if not fast:
			await tw.finished
	elif _run_extra(s):
		await _extra_wait
	elif s.has("shake"):
		play_sfx("saskin")
		var base := camera.position
		var tw := create_tween()
		for i in int(maxf(1.0, s["shake"] * 20.0)):
			tw.tween_property(camera, "position", base + Vector3(randf_range(-0.08, 0.08), randf_range(-0.08, 0.08), 0), 0.05)
		tw.tween_property(camera, "position", base, 0.05)
		if not fast:
			await tw.finished


# ---- Gölge Orman bölümüyle gelen sahne adımları ----------------------------------------------------
##   {"mood": "orman"|"bosluk"|"gun"}          ortam: mor sisli gece, simsiyah boşluk, normal gün
##   {"black": true|false, "t": sn}            ekranı tam karartır / açar
##   {"roll": derece}                          kamera yan yatar (Dutch angle); 0 düzeltir
##   {"spawn": anahtar, "prop": ad, "at": nokta, "size": [x, z], "yaw": rad, "y": yükseklik,
##    "decor": true, "light": [renk, güç, menzil]}   sahneye nesne koyar (decor: küçük süs nesnesi, ör. kazma)
##   {"move": anahtar, "to": nokta, "rot": Vector3(derece), "t": sn, "block": false}   nesneyi götürür / döndürür
##   {"open": anahtar, "deg": 70, "t": sn}     sandık kapağını ("Kapak" düğümü) açar
##   {"burst": nokta, "kind": "kiymik"|"altin"|"cam", "n": 24}   parçacık patlaması
##   {"carry": oyuncu, "key": anahtar, "prop": ad, "pos": Vector3, "rot": Vector3(derece)}   oyuncunun eline nesne verir
##   {"release": anahtar, "to": nokta, "rot": Vector3(derece), "t": sn}   eldeki nesneyi bırakır / düşürür
##   {"unspawn": anahtar}                      nesneyi kaldırır
##   {"anim": oyuncu, "name": ["afraid"], "hold": sn}   modelin animasyonunu oynatır
##   {"pop": oyuncu, "t": sn}                  oyuncu küçükten büyüğe fırlar
var _extra_wait: Signal


func _apply_roll() -> void:
	if _roll != 0.0:
		camera.rotate_object_local(Vector3.BACK, deg_to_rad(_roll))


func _reset_mood() -> void:
	_env.fog_enabled = false
	_sun.light_energy = 1.0
	_env.ambient_light_color = Color.WHITE
	_env.ambient_light_energy = 1.0


func set_mood(m: String) -> void:
	match m:
		"orman":
			# Mor sisli, aydınsız gece; sahneyi turuncu sandık ışığı aydınlatır.
			_sky.sky_top_color = Color("07060f")
			_sky.sky_horizon_color = Color("2d1c4a")
			_sky.ground_horizon_color = _sky.sky_horizon_color
			_sky.ground_bottom_color = _sky.sky_horizon_color
			_sun.light_color = Color("8f84ff")
			_sun.light_energy = 0.28
			_env.ambient_light_color = Color("6a58a8")
			_env.ambient_light_energy = 0.7
			_env.fog_enabled = true
			_env.fog_light_color = Color("3d2560")
			_env.fog_density = 0.028
		"bosluk":
			# Çevresi görünmeyen simsiyah boşluk: yakındaki sandık dışında her şey sisle yutulur.
			_sky.sky_top_color = Color.BLACK
			_sky.sky_horizon_color = Color.BLACK
			_sky.ground_horizon_color = Color.BLACK
			_sky.ground_bottom_color = Color.BLACK
			_sun.light_energy = 0.0
			_env.ambient_light_color = Color.BLACK
			_env.ambient_light_energy = 0.0
			_env.fog_enabled = true
			_env.fog_light_color = Color.BLACK
			_env.fog_density = 0.55
		_:
			set_time(0.4)


func _run_extra(s: Dictionary) -> bool:
	_extra_wait = get_tree().process_frame
	if s.has("mood"):
		set_mood(s["mood"])
	elif s.has("black"):
		var on: bool = s["black"]
		var t: float = s.get("t", 0.0)
		_fade_pending = false
		if fast or t <= 0.0:
			_fade.color.a = 1.0 if on else 0.0
		else:
			var tw := create_tween()
			tw.tween_property(_fade, "color:a", 1.0 if on else 0.0, t)
			_extra_wait = tw.finished
	elif s.has("roll"):
		_roll = float(s["roll"])
		_apply_roll()
	elif s.has("spawn"):
		_spawn_prop(s)
	elif s.has("unspawn"):
		if _dyn.has(s["unspawn"]):
			(_dyn[s["unspawn"]] as Node).queue_free()
			_dyn.erase(s["unspawn"])
	elif s.has("move"):
		var n: Node3D = _dyn.get(s["move"])
		if n:
			var t: float = 0.0 if fast else float(s.get("t", 0.5))
			var tw := create_tween().set_parallel().set_trans(Tween.TRANS_QUAD)
			if s.has("to"):
				var to: Vector3 = FilmSets.point(s["to"]) + (n.get_meta("off") as Vector3)
				tw.tween_property(n, "global_position", to, maxf(t, 0.001))
			if s.has("rot"):
				var r: Vector3 = s["rot"]
				tw.tween_property(n, "rotation", Vector3(deg_to_rad(r.x), deg_to_rad(r.y), deg_to_rad(r.z)), maxf(t, 0.001))
			if t > 0.0 and s.get("block", true):
				_extra_wait = tw.finished
	elif s.has("open"):
		var n: Node3D = _dyn.get(s["open"])
		var lid := n.find_child("Kapak", true, false) as Node3D if n else null
		if lid:
			var tw := create_tween()
			tw.tween_property(lid, "rotation:x", deg_to_rad(-float(s.get("deg", 70.0))), 0.001 if fast else float(s.get("t", 0.25)))
			_extra_wait = tw.finished
	elif s.has("burst"):
		_burst(FilmSets.point(s["burst"]), s.get("kind", "kiymik"), int(s.get("n", 24)))
	elif s.has("carry"):
		var a := _actor(s["carry"])
		var item := FilmProps.build_decor(s["prop"])
		item.position = s.get("pos", Vector3.ZERO)
		var r: Vector3 = s.get("rot", Vector3.ZERO)
		item.rotation = Vector3(deg_to_rad(r.x), deg_to_rad(r.y), deg_to_rad(r.z))
		a.hold_item(item, s.get("hand", "right") == "right")
		_dyn[s.get("key", s["prop"])] = item
		item.set_meta("off", Vector3.ZERO)
	elif s.has("release"):
		var n: Node3D = _dyn.get(s["release"])
		if n:
			var xf := n.global_transform
			n.get_parent().remove_child(n)
			add_child(n)
			n.global_transform = xf
			var t: float = 0.0 if fast else float(s.get("t", 0.4))
			var tw := create_tween().set_parallel().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
			if s.has("to"):
				tw.tween_property(n, "global_position", FilmSets.point(s["to"]), maxf(t, 0.001))
			if s.has("rot"):
				var r: Vector3 = s["rot"]
				tw.tween_property(n, "rotation", Vector3(deg_to_rad(r.x), deg_to_rad(r.y), deg_to_rad(r.z)), maxf(t, 0.001))
			if t > 0.0 and s.get("block", false):
				_extra_wait = tw.finished
	elif s.has("anim"):
		_actor(s["anim"]).play_anim(s.get("name", []), float(s.get("hold", 0.0)))
	elif s.has("pop"):
		var a := _actor(s["pop"])
		a.visible = true
		if fast:
			a.scale = Vector3.ONE
		else:
			a.scale = Vector3.ONE * 0.05
			var tw := create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
			tw.tween_property(a, "scale", Vector3.ONE, float(s.get("t", 0.3)))
			_extra_wait = tw.finished
	else:
		return false
	return true


func _spawn_prop(s: Dictionary) -> void:
	var key: String = s["spawn"]
	if _dyn.has(key):
		(_dyn[key] as Node).queue_free()
	var size: Array = s.get("size", [1, 1])
	var n: Node3D
	var off := Vector3.ZERO
	if s.get("decor", false):
		n = FilmProps.build_decor(s["prop"])
	else:
		n = FilmProps.build(s["prop"], Vector2i(size[0], size[1]))
		off = Vector3(-size[0] / 2.0, 0, -size[1] / 2.0)
	n.set_meta("off", off)
	add_child(n)
	n.position = FilmSets.point(s["at"]) + off + Vector3(0, float(s.get("y", 0.0)), 0)
	n.rotation.y = float(s.get("yaw", 0.0))
	if s.has("light"):
		var l: Array = s["light"]
		var lamp := OmniLight3D.new()
		lamp.light_color = l[0]
		lamp.light_energy = l[1]
		lamp.omni_range = l[2]
		lamp.position = Vector3(size[0] / 2.0, 0.7, size[1] / 2.0) if not s.get("decor", false) else Vector3(0, 0.4, 0)
		n.add_child(lamp)
	_dyn[key] = n


## Parçacık patlaması: kıymık (kahverengi), altın (parlak sarı), cam (yeşil); balistik düşüp kaybolur.
func _burst(center: Vector3, kind: String, count: int) -> void:
	if fast:
		return
	var colors := {"kiymik": [Color("8a5a2b"), Color("b07a3a"), Color("5a3a1a")], "altin": [Color("ffd23f"), Color("ffec8a")], "cam": [Color("3fd96b"), Color("1f8a42"), Color("b8ffd0")]}
	var pal: Array = colors.get(kind, colors["kiymik"])
	for i in count:
		var mi := MeshInstance3D.new()
		var bm := BoxMesh.new()
		var sz := randf_range(0.04, 0.13) if kind != "kiymik" else randf_range(0.05, 0.16)
		bm.size = Vector3(sz, sz * (3.0 if kind == "kiymik" else 1.0), sz)
		var mat := StandardMaterial3D.new()
		mat.albedo_color = pal[i % pal.size()]
		if kind == "altin":
			mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		bm.material = mat
		mi.mesh = bm
		add_child(mi)
		mi.position = center
		var v := Vector3(randf_range(-2.2, 2.2), randf_range(2.0, 4.8), randf_range(-2.2, 2.2))
		var spin := Vector3(randf_range(-9, 9), randf_range(-9, 9), randf_range(-9, 9))
		var tw := create_tween()
		tw.tween_method(func(t: float) -> void:
			mi.position = center + v * t + Vector3(0, -4.9 * t * t, 0)
			mi.rotation = spin * t, 0.0, 0.9, 0.9)
		tw.tween_callback(mi.queue_free)


## Replik sürerken anlatılan yerlere kesme: "cuts": [[oran, kamera, bakış], ...]; oran 0-1,
## repliğin sesinin o noktasında kamera o yere geçer (ör. "Tramvay, park, AVM" derken her birini göster).
func _run_cuts(cuts: Array, text: String) -> void:
	await get_tree().process_frame
	var total := voice.length()
	if total <= 0.0:
		total = maxf(READ_MIN, text.length() * READ_PER_CHAR)
	var done := 0.0
	for c: Array in cuts:
		var at := float(c[0]) * total
		var target := FilmSets.point(c[2])
		if not fast:
			await _wait(maxf(0.0, at - done))
		done = at
		world.update_center(target)
		while not fast and not world.is_meshed_at(target):
			await get_tree().process_frame
		_move_camera(FilmSets.point(c[1]), target + Vector3(0, LOOK_HEIGHT, 0), 0.0)


func _say(id: String, text: String) -> void:
	_fade_in()
	var a := _actor(id)
	_name_label.text = a.display_name()
	_name_label.add_theme_color_override("font_color", a.data["color"])
	_text_label.text = text
	_text_label.visible_characters = 0
	_box.visible = true
	a.talking = true
	_line += 1
	# İkili diyalog: konuşan ile bir önceki konuşan birbirine döner (Mehmet, 2026-10-02).
	if _speaker and is_instance_valid(_speaker) and _speaker != a and _speaker.visible and a.visible \
			and _speaker.position.distance_to(a.position) < 6.0 and not _speaker._moving and not a._moving:
		a.face_towards(_speaker.position)
		_speaker.face_towards(a.position)
	_speaker = a
	_frame_speaker(a)
	_auto_zoom(text)
	_auto_sfx(text, a)
	var voiced := voice.speak(id, text, _episode_id, _line)
	var total := text.length()
	var t := 0.0
	while _text_label.visible_characters < total:
		if fast:
			break
		t += get_process_delta_time()
		_text_label.visible_characters = mini(total, int(t * TYPE_SPEED))
		await get_tree().process_frame
	_text_label.visible_characters = -1
	# Ses sürdükçe ağız oynasın; ses bitince kısa bir nefes payı.
	var limit := t + 12.0
	while not fast and voice.speaking() and t < limit:
		t += get_process_delta_time()
		await get_tree().process_frame
	a.talking = false
	await _wait(maxf(READ_MIN, total * READ_PER_CHAR) - t if not voiced else 0.05)


## Replik boyunca konuşanı izler: yürürse kamera başını takip eder, kadrajdan çıkar
## ya da biri önünü kapatırsa yeni bir açıya keser. Boş ekran kalmasın.
func _watch_speaker(delta: float) -> void:
	if fast or _hold_cam or _speaker == null or not is_instance_valid(_speaker) or not _box.visible:
		return
	if _cam_tween and _cam_tween.is_running():
		return
	var down := _speaker._body.rotation.x != 0.0
	var aim := _speaker.head_position() if down else _speaker.position + Vector3(0, 1.3, 0)
	_look = _look.lerp(aim, minf(1.0, delta * 4.0))
	if camera.global_position.distance_to(_look) > 0.01:
		camera.look_at(_look)
	_watch_t += delta
	if _watch_t < 0.25:
		return
	_watch_t = 0.0
	var head := _speaker.head_position() if down else _speaker.position + Vector3(0, 1.45, 0)
	var facing := Vector3(-sin(_speaker.rotation.y), 0, -cos(_speaker.rotation.y))
	var away := _speaker._body.rotation.x == 0.0 and not _faces(facing, head, camera.global_position)
	_away_t = _away_t + 0.25 if away else 0.0
	# Sırtı dönükse karşı açıya geç; yürürken daha sabırlı (sürekli kesme olmasın).
	# Konuşan kameraya fazla yaklaştıysa (ör. yataktan kalkıp kameraya yürüdü) yüzün içine girmesin.
	var too_close := camera.global_position.distance_to(head) < 1.9
	if too_close or _away_t >= (1.25 if _speaker._moving else 0.75) or (_speaker._body.rotation.x == 0.0 and _too_steep(camera.global_position, head)) or not _shows(camera.global_position, head, _speaker):
		_away_t = 0.0
		var fov := camera.fov
		_frame_speaker(_speaker, true)
		camera.fov = fov


## Konuşan karşı yüzünü kadrajda göstersin: görünmüyorsa ya da sırtı dönükse,
## yüzünün önünde boş ve görüşü açık bir yere kamerayı keser.
func _frame_speaker(a: Actor, force := false) -> void:
	if fast or _hold_cam:
		return
	var lying := a._body.rotation.x != 0.0
	var head := a.head_position() if lying else a.position + Vector3(0, 1.45, 0)
	var facing := Vector3(-sin(a.rotation.y), 0, -cos(a.rotation.y))
	if not force and camera.global_position.distance_to(head) > MIN_CAM_DIST + 0.2 and (lying or not _too_steep(camera.global_position, head)) and _shows(camera.global_position, head, a) and (lying or _faces(facing, head, camera.global_position)):
		return
	var sets: FilmSets = world.generator
	# Dizi gibi: göz hizası (hafif yukarıdan), 3/4 açı, orta-yakın plan. Tepeden çekim yok.
	# Yatan karakterde ayakta duran birinin göz hizasından, odayı da gösteren geniş açı.
	var lifts := [1.1, 0.8] if lying else [0.0, 0.15, -0.1]
	# Geniş açı: karakter ve etrafı birlikte görünsün (Mehmet istedi); yakına ancak yer yoksa.
	var dists := [3.6, 4.2, 3.0, 2.7] if lying else [4.0, 4.8, 3.4, 2.8]
	var angs := [0.6, -0.6, 1.0, -1.0, 1.6, -1.6, 2.2, -2.2, 0.0, PI] if lying else [0.45, -0.45, 0.0, 0.8, -0.8, 1.2, -1.2]
	# Önce açı: yüzü önden gösteren açı, uzak mesafede yandan profile tercih edilir.
	for ang in angs:
		for lift in lifts:
			for dist in dists:
				if a._moving and dist < 1.9:
					continue  # yürüyenin yoluna kamera koyma, içinden geçer
				var pos: Vector3 = head + facing.rotated(Vector3.UP, ang) * dist + Vector3(0, lift, 0)
				if sets.is_air(Vector3i(pos.floor())) and _clear_of_actors(pos) and _shows(pos, head, a, false):
					_move_camera(pos, head - Vector3(0, 0.15, 0), 0)
					return


	# Hiç boş nokta yoksa en azından kafaya dön.
	_look = head
	camera.look_at(head)


## Aday kamera yeri hiçbir karakterin başına MIN_CAM_DIST'ten yakın değil mi
## (yakınsa _keep_distance geri iter, _watch_speaker yine oraya koyar: titreme).
func _clear_of_actors(pos: Vector3) -> bool:
	for o in Actor.everyone:
		if is_instance_valid(o) and o.visible and Vector2(pos.x - o.position.x, pos.z - o.position.z).length() < MIN_CAM_DIST + 0.2:
			return false
	return true


## Kamera başa çok yukarıdan ya da aşağıdan mı bakıyor (25 dereceden dik).
func _too_steep(cam: Vector3, head: Vector3) -> bool:
	var d := head - cam
	return absf(atan2(d.y, Vector2(d.x, d.z).length())) > deg_to_rad(25.0)


func _faces(facing: Vector3, head: Vector3, cam: Vector3) -> bool:
	var d := cam - head
	return facing.dot(Vector3(d.x, 0, d.z).normalized()) > 0.45  # yandan profil değil, yüz görünsün


## Kameradan konuşanın başı görünüyor mu: bloklar ve diğer oyuncular önünü kapatmıyor,
## (mevcut kamerada) baş kadrajın orta kısmında ve çok uzakta değil.
func _shows(cam: Vector3, head: Vector3, who: Actor, check_frame := true) -> bool:
	var sets: FilmSets = world.generator
	if cam.distance_to(head) > 9.0 or not sets.clear_sight(cam, head):
		return false
	for other: Actor in actors.values():
		if other == who or not other.visible:
			continue
		for hgt in [0.9, 1.5]:
			var c: Vector3 = other.position + Vector3(0, hgt, 0)
			var seg := head - cam
			var k := clampf((c - cam).dot(seg) / seg.length_squared(), 0.0, 1.0)
			if k < 0.95 and (cam + seg * k).distance_to(c) < 0.5:
				return false
	if check_frame:
		if camera.is_position_behind(head):
			return false
		var sp := camera.unproject_position(head)
		var vs := get_viewport().get_visible_rect().size
		if sp.x < vs.x * 0.15 or sp.x > vs.x * 0.85 or sp.y < vs.y * 0.08 or sp.y > vs.y * 0.7:
			return false
	return true


## Komik ve şaşırtıcı anlara kendiliğinden efekt: kahkahada gülme, "?!" ya da "Eyvah"ta şok sesi.
func _auto_sfx(text: String, a: Actor = null) -> void:
	var t := text.to_lower()
	var kind := ""
	if t.contains("haha") or t.contains("hihi") or t.contains("kıkır"):
		play_sfx("gulme")
		kind = "gul"
	elif text.contains("?!") or t.begins_with("eyvah") or t.begins_with("ne?") or t.contains("olamaz"):
		play_sfx("saskin")
		kind = "sok"
	elif t.contains("ağla") or t.contains("üzgün") or t.contains("hıçkır"):
		kind = "agla"
	elif t.contains("kızdım") or t.contains("yeter") or t.contains("hayır!"):
		kind = "kiz"
	elif t.begins_with("merhaba") or t.begins_with("günaydın") or t.contains("görüşürüz"):
		kind = "selam"
	elif t.begins_with("tamam") or t.begins_with("olur") or t.begins_with("evet") or t.contains("yaşasın"):
		kind = "evet"
	# Otomatik büyük jestler kapalı: Tripo hareketlerinde adım/eğilme var, sakin replikte
	# yerinde yürüyor ya da kızıyor gibi duruyordu (Mehmet). Jest sadece senaryoda
	# {"gesture": "<kişi>", "kind": "gul"} ile açıkça istenince oynar.
	if a and kind != "" and a.data.get("auto_gesture", false):
		a.gesture(kind)


## Shorts tarzı kamera: her replikte yavaş yakınlaşma, ünlemli replikte hızlı "vurma" zoom'u.
func _auto_zoom(text: String) -> void:
	if fast:
		return
	if _fov_tween:
		_fov_tween.kill()
	_fov_tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	# Zoom yalnızca şok anlarında ("?!", "!!", "Eyvah"); diğer repliklerde çok hafif yaklaşma.
	var t := text.to_lower()
	if text.contains("?!") or text.contains("!!") or t.begins_with("eyvah") or t.contains("olamaz"):
		_fov_tween.tween_property(camera, "fov", BASE_FOV - 18.0, 0.12)
		_fov_tween.tween_property(camera, "fov", BASE_FOV - 10.0, 1.2)
	else:
		_fov_tween.tween_property(camera, "fov", maxf(BASE_FOV - 4.0, camera.fov - 1.5), 3.0)


## assets/audio/<klasör>/<ad>.ogg|mp3|wav; dosya yoksa null (sessizce atlanır).
static func _audio(folder: String, name: String) -> AudioStream:
	for ext in ["ogg", "mp3", "wav"]:
		var path := "res://assets/audio/%s/%s.%s" % [folder, name, ext]
		if ResourceLoader.exists(path):
			return load(path)
	# Yeni eklenen mp3 henüz içe aktarılmadıysa dosyadan doğrudan okunur (bilgisayarda kayıt).
	var raw := "res://assets/audio/%s/%s.mp3" % [folder, name]
	if FileAccess.file_exists(raw):
		var mp3 := AudioStreamMP3.new()
		mp3.data = FileAccess.get_file_as_bytes(raw)
		return mp3
	return null


## Geçiş kararmasını açar (yeni çekim hazır).
func _fade_in() -> void:
	if not _fade_pending:
		return
	_fade_pending = false
	if fast:
		_fade.color.a = 0.0
		return
	create_tween().tween_property(_fade, "color:a", 0.0, 0.45)


## Efekt çalar ("bom", "baslik", "saskin", "gulme"...). Dosya yoksa bir şey olmaz.
func play_sfx(name: String) -> void:
	if fast:
		return
	var st := _audio("sfx", name)
	if st == null:
		return
	var p := AudioStreamPlayer.new()
	p.stream = st
	p.volume_db = -4.0
	add_child(p)
	p.finished.connect(p.queue_free)
	p.play()


## Arka plan müziği ("neseli", "gerilim", "duygusal"); "" müziği durdurur.
func play_music(name: String, fallback := "neseli") -> void:
	var st := _audio("music", name) if name != "" and not fast else null
	# Bölüme özel müzik henüz indirilmediyse yedek müzik çalsın (varsayılan neşeli).
	if st == null and name != "" and not fast:
		st = _audio("music", fallback)
	if st == null:
		_music.stop()
		return
	if _music.stream == st and _music.playing:
		return
	if "loop" in st:
		st.loop = true
	_music.stream = st
	_music.volume_db = -16.0
	_music.play()


func _wait(sec: float) -> void:
	if fast or sec <= 0.0:
		await get_tree().process_frame
		return
	await get_tree().create_timer(sec).timeout


## Noktada başka biri duruyorsa yanında boş bir yer bulur; iki karakter iç içe girmesin.
func _free_spot(a: Actor, p: Vector3, lie := false) -> Vector3:
	var sets: FilmSets = world.generator
	for off in [Vector3.ZERO, Vector3(1.1, 0, 0), Vector3(-1.1, 0, 0), Vector3(0, 0, 1.1), Vector3(0, 0, -1.1),
			Vector3(1.1, 0, 1.1), Vector3(-1.1, 0, 1.1), Vector3(1.1, 0, -1.1), Vector3(-1.1, 0, -1.1),
			Vector3(1.6, 0, 0), Vector3(-1.6, 0, 0), Vector3(0, 0, 1.6), Vector3(0, 0, -1.6)]:
		var q: Vector3 = p + off
		# Sıra, masa gibi bir bloğun içine konmasın (yatak hariç: yatma noktası).
		var cell := Vector3i(q.floor())
		if not (lie or (sets.is_air(cell) and sets.is_air(cell + Vector3i.UP))):
			continue
		var taken := false
		for o: Actor in Actor.everyone:
			if o != a and o.visible and Vector2(o.position.x - q.x, o.position.z - q.z).length() < 0.95:
				taken = true
				break
		if not taken:
			return q
	return p


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
	for e: Actor in _extras:
		e.queue_free()
	_extras.clear()


## Setin önündeki caddenin kaldırımlarında gidip gelen figüranlar: şehir canlı görünsün.
func _spawn_extras(set_id: String) -> void:
	if fast:
		return
	var corner := FilmSets.point(set_id + "." + FilmSets.POINTS[set_id].keys()[0])
	# Setlerin kapısı +z yönüne bakar: önündeki (z'si büyük olan en yakın) cadde.
	var az: int = FilmSets.AVENUES_Z[0]
	for z: int in FilmSets.AVENUES_Z:
		if z > corner.z and (az < corner.z or z < az):
			az = z
	var kinds := ["komsu_adam", "komsu_kadin", "komsu_cocuk", "komsu_adam", "komsu_kadin", "komsu_cocuk"]
	for k in kinds.size():
		var e := Actor.create(kinds[k])
		add_child(e)
		_extras.append(e)
		var side_z := az - 0.6 if k % 2 == 0 else az + 4.3
		var x0 := corner.x - 18.0 + k * 7.0
		e.position = Vector3(x0, FilmSets.GROUND + 1, side_z)
		_extra_loop(e, x0 - 12.0, x0 + 12.0, 1.1 + (k % 3) * 0.3)


func _extra_loop(e: Actor, x_min: float, x_max: float, speed: float) -> void:
	var going_right := true
	while is_instance_valid(e) and playing:
		var target := Vector3(x_max if going_right else x_min, e.position.y, e.position.z)
		await e.walk_to(target, speed)
		going_right = not going_right


func _move_camera(pos: Vector3, look: Vector3, t: float) -> void:
	if _cam_tween:
		_cam_tween.kill()
	if _fov_tween:
		_fov_tween.kill()
	camera.fov = BASE_FOV
	if t <= 0.0 or fast:
		_look = look
		camera.look_at_from_position(pos, look)
		_apply_roll()
		return
	_cam_tween = create_tween().set_parallel().set_trans(Tween.TRANS_SINE)
	_cam_tween.tween_property(camera, "position", pos, t)
	_cam_tween.tween_method(func(l: Vector3) -> void:
		_look = l
		if camera.position.distance_to(l) > 0.01:
			camera.look_at(l)
			_apply_roll(), _look, look, t)


## Günün saati (0.25 gündoğumu, 0.5 öğle, 0.75 günbatımı).
func set_time(t: float) -> void:
	_reset_mood()
	var elevation := sin((t - 0.25) * TAU)
	_sun.rotation = Vector3(-asin(clampf(elevation, 0.05, 1.0)), deg_to_rad(35), 0)
	var warm := clampf(1.0 - elevation * 2.0, 0.0, 1.0)
	_sun.light_color = Color.WHITE.lerp(Color("ffc58a"), warm)
	_sky.sky_top_color = Color("3f8fdc").lerp(Color("6a86c8"), warm)
	_sky.sky_horizon_color = Color("a8d4f5").lerp(Color("ffcf9e"), warm)
	# Gökyüzünün alt yarısı koyu kahverengiydi; dünyanın kenarında ufukta basamaklı koyu bant
	# görünüyordu (Mehmet, 2026-10-02). Alt yarı ufuk rengiyle aynı yapılır.
	_sky.ground_horizon_color = _sky.sky_horizon_color
	_sky.ground_bottom_color = _sky.sky_horizon_color


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
	_fade.color = Color(0, 0, 0, 0)
	_fade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_fade.set_anchors_preset(Control.PRESET_FULL_RECT)
	_ui.add_child(_fade)
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
	# Mehmet altyazı istemiyor: kutu görünmez kalır (konuşan takibi için visible bayrağı kullanılır).
	if not SHOW_SUBTITLES:
		_box.modulate.a = 0.0
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
	_logo.set_anchors_preset(Control.PRESET_CENTER)
	_logo.anchor_left = 0.1
	_logo.anchor_right = 0.9
	_logo.anchor_top = 0.06  # üst kısım: kapanışta karakterlerin yüzünü kapatmasın
	_logo.anchor_bottom = 0.3
	_logo.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_logo.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_logo.visible = false
	_ui.add_child(_logo)
	_panel.title = "Film Stüdyosu"
	_panel.subtitle = "Bir bölüm seç, ekran kaydını başlat"
	layer.add_child(_panel)


const PAGE_SIZE := 4

## format "": format seçimi; "short" / "long": o formattaki bölümler (sayfa sayfa, ekrana sığsın).
func _show_menu(format := "", page := 0) -> void:
	_panel.visible = true
	var buttons := []
	if format == "":
		_panel.subtitle = "Bir format seç"
		buttons.append({"label": "Shorts (dikey, 30-60 sn)", "action": func() -> void: _show_menu("short")})
		buttons.append({"label": "Uzun Bölüm (yatay, 5-10 dk)", "action": func() -> void: _show_menu("long")})
		buttons.append({"label": "Ana Menü", "action": func() -> void:
			get_tree().change_scene_to_file(MENU_SCENE)})
	else:
		var list := Episodes.of_format(format)
		var pages := maxi(1, ceili(list.size() / float(PAGE_SIZE)))
		page = posmod(page, pages)
		_panel.subtitle = "Bir bölüm seç, ekran kaydını başlat" + ("  (%d/%d)" % [page + 1, pages] if pages > 1 else "")
		for ep: Dictionary in list.slice(page * PAGE_SIZE, (page + 1) * PAGE_SIZE):
			var id: String = ep["id"]
			buttons.append({"label": ep["name"], "action": func() -> void: play(id)})
		if pages > 1:
			buttons.append({"label": "Diğer bölümler >", "action": func() -> void: _show_menu(format, page + 1)})
		buttons.append({"label": "Geri", "action": func() -> void: _show_menu()})
	_panel.set_buttons(buttons)


## Shorts dikey çekilir: telefonda ekran dik döner, bilgisayarda pencere 9:16 olur.
## Diyalog kutusu ve başlık dar ekrana göre ayarlanır.
func set_portrait(on: bool) -> void:
	if OS.has_feature("mobile"):
		DisplayServer.screen_set_orientation(DisplayServer.SCREEN_PORTRAIT if on else DisplayServer.SCREEN_SENSOR_LANDSCAPE)
	elif DisplayServer.get_name() != "headless" and not recording:
		DisplayServer.window_set_size(Vector2i(405, 720) if on else Vector2i(1280, 720))
	_box.anchor_left = 0.04 if on else 0.12
	_box.anchor_right = 0.96 if on else 0.88
	_box.offset_top = -330 if on else -210
	_box.offset_bottom = -90 if on else -64
	_title.add_theme_font_size_override("font_size", 44 if on else 64)
	_text_label.add_theme_font_size_override("font_size", 46 if on else 34)
	_name_label.add_theme_font_size_override("font_size", 38 if on else 30)
	_title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART if on else TextServer.AUTOWRAP_OFF


func _show_title(text: String) -> void:
	# Mehmet'in kararı (2026-10-02): videolar birçok dilde yükleneceği için görüntüde yazı yok;
	# başlık adımlarında yalnızca EmirCRAFT logosu görünür, bölüm adı YouTube başlığında durur.
	if LOGO_ONLY:
		if _logo.texture == null and ResourceLoader.exists(LOGO_PATH):
			_logo.texture = load(LOGO_PATH)
		if _logo.texture:
			_logo.visible = true
			_title.text = ""
			return
		text = "EmirCRAFT"
	_title.text = text
	_title.visible = true


## Logonun solunda beğen, sağında zil; küçükten büyüyerek gelir ve hafifçe sallanır.
func _show_icons() -> void:
	for i in ICON_PATHS.size():
		if not ResourceLoader.exists(ICON_PATHS[i]):
			continue
		var ic := TextureRect.new()
		ic.texture = load(ICON_PATHS[i])
		ic.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		ic.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		ic.anchor_left = 0.02 if i == 0 else 0.86
		ic.anchor_right = ic.anchor_left + 0.12
		ic.anchor_top = 0.08
		ic.anchor_bottom = 0.28
		_ui.add_child(ic)
		ic.resized.connect(func() -> void: ic.pivot_offset = ic.size / 2.0)
		ic.scale = Vector2.ZERO
		var tw := ic.create_tween()
		tw.tween_interval(0.25 * i)
		tw.tween_property(ic, "scale", Vector2.ONE, 0.35).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tw.tween_property(ic, "rotation", 0.15, 0.25)
		tw.tween_property(ic, "rotation", -0.15, 0.25)
		tw.tween_property(ic, "rotation", 0.0, 0.25)
		_icons.append(ic)


func _hide_dialogue() -> void:
	_box.visible = false


func _set_bars(on: bool) -> void:
	for b in _bars:
		b.visible = on


func _walk_path(a: Actor, path: Array, speed: float) -> void:
	for p: Vector3 in path:
		await a.walk_to(p, speed)


## Bir oyuncu kapıya yaklaşınca kapı içeri doğru açılır, uzaklaşınca kapanır.
func _swing_doors(delta: float) -> void:
	for d in _doors:
		var center := d.global_position + d.global_transform.basis.x * 0.5
		var near := false
		for a in actors.values():
			if (a as Node3D).global_position.distance_to(center) < 1.8:
				near = true
		var hinge := d.get_child(0) as Node3D
		hinge.rotation.y = move_toward(hinge.rotation.y, 1.7 if near else 0.0, delta * 3.0)
