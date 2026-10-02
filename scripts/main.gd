extends Node3D
## Oyunun giriş noktası: dünya, oyuncu, arayüz, gece-gündüz döngüsü, yaratık doğurma ve kayıt.

const DAY_LENGTH := 600.0  # saniye
const MAX_MOBS := 8
const SPAWN_INTERVAL := 5.0
const DESPAWN_DISTANCE := 56.0
const AUTOSAVE_INTERVAL := 20.0

## Kayıt dosyası; boş bırakılırsa (testlerde) kaydetmez ve yüklemez.
var save_path := SaveGame.DEFAULT_PATH

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
var _autosave_timer := 0.0
## Kayıttan gelen evcil dostlar: oyuncu doğunca yanına çıkarılır. [{"id", "health"}]
var pending_allies: Array = []
## Şu anki boyut, her boyutun blok değişiklikleri ve oyuncunun her boyuttan ayrıldığı yer.
var dimension := Dimension.OVERWORLD
var dim_edits := {}
var dim_chests := {}
var return_positions := {}
## Boyutun ortam sesi (koridor uğultusu, fabrika müzik kutusu).
var ambience := AudioStreamPlayer.new()
var quests := Quests.new()
## Yenilen boss'lar (kimlik -> true, kayıtta saklanır) ve şu an sahnedeki boss.
var boss_defeated := {}
var boss: Mob
var _loot_rng := RandomNumberGenerator.new()
const BOSS_BAR_RANGE := 32.0


## Şehri Gez modu: film setlerinin (mahalle, nehir, sahil, metro, havalimanı) içinde serbest dolaşma.
## Ana menü Engine meta "gezi" ile açar; kayıt yok, yaratık yok, açlık yok, hep gündüz.
var explore := false
var _doors: Array[Node3D] = []


func _ready() -> void:
	_setup_input()
	if Engine.has_meta("gezi"):
		explore = true
		Engine.remove_meta("gezi")
		save_path = ""
	var save := SaveGame.read(save_path) if save_path != "" else {}
	if not save.is_empty():
		SaveGame.apply_world(save, self)
	elif save_path != "":
		# Yeni dünya: her seferinde farklı arazi. Testler sabit tohumla çalışır.
		world.world_seed = randi()
	Settings.ensure_loaded()
	world.render_distance = Settings.view_distance
	_setup_environment()

	world.name = "World"
	add_child(world)
	if explore:
		world.generator = FilmSets.new()
		_build_film_props(world.generator as FilmSets)
		time_of_day = 0.4

	player.name = "Player"
	player.world = world
	player.hud = hud
	add_child(player)
	if explore:
		player.saved_position = FilmSets.point("ev.kapi_disi") + Vector3(0, 0.1, 0)
		player.survival.set_process(false)
	player.tamed_mob.connect(_on_tamed)
	player.used_portal.connect(travel)

	hud.atlas = world.atlas
	hud.player = player
	add_child(hud)
	if not save.is_empty():
		SaveGame.apply_player(save, player)
		hud.toast("Kaldığın yerden devam")
	quests.completed.connect(_on_quest_completed)
	player.inventory.changed.connect(func() -> void: quests.check_inventory(player.inventory))
	if not explore:
		hud.show_quest(quests)
	else:
		hud.toast("Şehri Gez: mahalle, nehir, sahil, metro, havalimanı")


func _on_quest_completed(text: String) -> void:
	hud.toast("Görev tamam: %s" % text)
	Sfx.play("craft")
	hud.show_quest(quests)


## Ayarlar menüsünde değişen görüş mesafesini ve sisi uygular.
func apply_settings() -> void:
	if world.render_distance != Settings.view_distance:
		world.set_render_distance(Settings.view_distance)
	if dimension == Dimension.OVERWORLD:
		_environment.fog_density = Settings.fog_density()


## Kaydedip ana menüye döner.
func quit_to_menu() -> void:
	save_game()
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/menu.tscn")


func save_game() -> bool:
	if save_path == "":
		return false
	return SaveGame.save(save_path, self)


func _notification(what: int) -> void:
	# Android'de uygulama arka plana atılınca ya da kapatılınca kaydet.
	if what in [NOTIFICATION_WM_CLOSE_REQUEST, NOTIFICATION_APPLICATION_PAUSED, NOTIFICATION_WM_GO_BACK_REQUEST, NOTIFICATION_APPLICATION_FOCUS_OUT]:
		if is_node_ready():
			save_game()


func is_night() -> bool:
	return time_of_day < 0.22 or time_of_day > 0.78


func _process(delta: float) -> void:
	if explore:
		_update_sun()
		_swing_doors(delta)
		return
	time_of_day = fposmod(time_of_day + delta / DAY_LENGTH, 1.0)
	_update_sun()
	_autosave_timer += delta
	if _autosave_timer >= AUTOSAVE_INTERVAL:
		_autosave_timer = 0.0
		save_game()
	if player.is_spawned():
		for ally in pending_allies:
			spawn_ally(ally["id"], ally["health"])
		pending_allies.clear()
		_update_boss()
		_spawn_timer -= delta
		if _spawn_timer <= 0.0:
			_spawn_timer = SPAWN_INTERVAL
			_despawn_far_mobs()
			_try_spawn_mob()


func _update_sun() -> void:
	if dimension != Dimension.OVERWORLD:
		return
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
	var indoor := dimension != Dimension.OVERWORLD
	var ids := MobData.ids_for(Dimension.DEFS[dimension]["habitat"], indoor or is_night())
	if ids.is_empty():
		return
	var a := randf() * TAU
	var dist := randf_range(16.0, 28.0)
	var x := floori(player.global_position.x + cos(a) * dist)
	var z := floori(player.global_position.z + sin(a) * dist)
	if not world.is_meshed_at(Vector3(x, 0, z)):
		return
	var y := world.spawn_y(x, z)
	if y < 0:
		return
	var mob := Mob.create(ids[randi() % ids.size()])
	mob.target = player
	add_child(mob)
	mob.died.connect(_on_mob_died.bind(mob))
	mob.global_position = Vector3(x + 0.5, y + 0.1, z + 0.5)
	_mobs.append(mob)


## Kapıdan geçiş: yeryüzünden kapının boyutuna, diğer boyutlardan yeryüzüne. Dünya yeniden kurulur,
## oyuncu o boyutta en son ayrıldığı yere (ilk seferde başlangıç odasına) döner.
func travel(portal_block := Blocks.HALLS_PORTAL) -> void:
	var target_dim := Dimension.destination(dimension, portal_block)
	if target_dim == -1:
		return
	dim_edits[dimension] = world.edits
	dim_chests[dimension] = world.chests
	return_positions[dimension] = player.global_position
	for node in get_tree().get_nodes_in_group("item_drops"):
		node.queue_free()
	for mob in _mobs:
		if is_instance_valid(mob):
			mob.queue_free()
	_mobs.clear()
	if is_instance_valid(boss):
		boss.queue_free()
	boss = null
	# Dostlar da gelir: oyuncu yeni dünyada belirince yanında doğarlar.
	for node in get_tree().get_nodes_in_group("allies"):
		var ally := node as Mob
		if ally.health > 0 and not ally.is_queued_for_deletion():
			pending_allies.append({"id": ally.mob_id, "health": ally.health})
		ally.remove_from_group("allies")
		ally.queue_free()
	var old := world
	remove_child(old)
	old.queue_free()
	dimension = target_dim
	world = _make_world(old.world_seed)
	add_child(world)
	player.world = world
	hud.atlas = world.atlas
	player.teleport(return_positions.get(dimension, Vector3.INF))
	Sfx.play("portal", 0.0)
	_apply_dimension_look()
	hud.toast(Dimension.display_name(dimension))
	quests.event("dimension_%d" % dimension)


func _make_world(p_seed: int) -> World:
	var w := World.new()
	w.name = "World"
	w.world_seed = p_seed
	w.dimension = dimension
	if not dim_edits.has(dimension):
		dim_edits[dimension] = {}
	w.edits = dim_edits[dimension]
	w.chests = dim_chests.get(dimension, {})
	w.render_distance = Settings.view_distance
	return w


## Boyutun boss'u yoksa ve yenilmediyse salonuna koyar; yakındayken can çubuğunu gösterir.
func _update_boss() -> void:
	var def: Dictionary = Dimension.DEFS[dimension].get("boss", {})
	if not def.is_empty() and not boss_defeated.has(def["id"]) and not is_instance_valid(boss):
		if world.is_meshed_at(def["spawn"]):
			spawn_boss(def["spawn"], def["id"])
	var near := is_instance_valid(boss) and boss.global_position.distance_to(player.global_position) < BOSS_BAR_RANGE
	hud.show_boss_bar(boss if near else null)


func spawn_boss(at: Vector3, id := "patron") -> Mob:
	boss = Mob.create(id)
	boss.target = player
	add_child(boss)
	# Yer duvarın içine düşerse en yakın boş hücre aranır.
	var spot := at
	var y := world.spawn_y(floori(at.x), floori(at.z))
	for r in range(1, 8):
		if y >= 0:
			break
		for d: Vector3 in [Vector3(r, 0, 0), Vector3(-r, 0, 0), Vector3(0, 0, r), Vector3(0, 0, -r)]:
			var yy := world.spawn_y(floori(at.x + d.x), floori(at.z + d.z))
			if yy >= 0:
				spot = at + d
				y = yy
				break
	boss.global_position = Vector3(spot.x, maxi(y, 0) + 0.1, spot.z)
	boss.died.connect(_on_boss_died.bind(boss))
	return boss


## Yenilen yaratık yaşadığı yere göre eşya bırakır (evcil dostlar bırakmaz).
func _on_mob_died(mob: Mob) -> void:
	if mob.tamed:
		return
	var loot := MobData.roll_loot(mob.mob_id, _loot_rng)
	for id in loot:
		ItemDrop.spawn(self, mob.global_position + Vector3(0, 0.5, 0), id, loot[id])


func _on_boss_died(b: Mob) -> void:
	boss_defeated[b.mob_id] = true
	var at := b.global_position + Vector3(0, 1, 0)
	var loot: Dictionary = b.data.get("loot", {})
	for id in loot:
		ItemDrop.spawn(self, at, id, loot[id])
	hud.toast("%s yenildi!" % b.data["name"])
	Sfx.play("portal")
	quests.event("boss_" + b.mob_id)


## Evcil bir dostu oyuncunun yanında doğurur.
func spawn_ally(id: String, health := -1) -> Mob:
	var mob := Mob.create(id)
	add_child(mob)
	var p := player.global_position + player.global_transform.basis.z * 1.5
	var y := world.spawn_y(floori(p.x), floori(p.z))
	if y < 0:
		p = player.global_position
		y = int(p.y)
	mob.global_position = Vector3(p.x, y + 0.1, p.z)
	if health > 0:
		mob.health = health
	mob.tame(player)
	_on_tamed(mob)
	return mob


## Evcil dostlar uzaklaşınca silinmez ve yaratık sınırına sayılmaz.
func _on_tamed(mob: Mob) -> void:
	_mobs.erase(mob)
	quests.event("tame")
	mob.died.connect(func() -> void: hud.toast("%s öldü" % mob.data["name"]))


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
	_environment.fog_density = Settings.fog_density()
	_environment.fog_sky_affect = 0.0
	var we := WorldEnvironment.new()
	we.environment = _environment
	add_child(we)
	_sun.shadow_enabled = false
	add_child(_sun)
	add_child(ambience)
	_apply_dimension_look()


## Yeryüzünde gökyüzü ve güneş; kapalı boyutlarda gökyüzü yok, ışık ve sis boyutun renginde.
func _apply_dimension_look() -> void:
	var sound: String = Dimension.DEFS[dimension].get("ambience", "")
	if sound == "":
		ambience.stop()
	else:
		ambience.stream = Sfx.stream(sound)
		ambience.volume_db = -6.0
		ambience.play()
	var indoor: Dictionary = Dimension.DEFS[dimension].get("indoor", {})
	_sun.visible = indoor.is_empty()
	if not indoor.is_empty():
		_environment.background_mode = Environment.BG_COLOR
		_environment.background_color = indoor["background"]
		_environment.ambient_light_color = indoor["ambient"]
		_environment.ambient_light_energy = indoor["energy"]
		_environment.fog_light_color = indoor["fog"]
		_environment.fog_density = indoor["fog_density"]
	else:
		_environment.background_mode = Environment.BG_SKY
		_environment.ambient_light_color = Color.WHITE
		_environment.fog_density = Settings.fog_density()
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
		"pause": [KEY_ESCAPE, KEY_P],
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


## Gezi modu: setlerin gerçek eşyaları, kapıları ve süsleri sahneye eklenir (film_studio ile aynı).
func _build_film_props(sets: FilmSets) -> void:
	for pr: Array in sets.props:
		var n := FilmProps.build(pr[0], pr[2], pr[3] if pr.size() > 3 else null)
		n.position = Vector3(pr[1])
		add_child(n)
		# Eşyaya çarpılsın: tabanı kadar kutu çarpıştırıcı (çok alçak olanlar hariç).
		var h := FilmProps.height(pr[0])
		if h >= 0.3:
			var size: Vector2i = pr[2]
			var body := StaticBody3D.new()
			var shape := CollisionShape3D.new()
			var box := BoxShape3D.new()
			box.size = Vector3(size.x - 0.1, minf(h, 3.0), size.y - 0.1)
			shape.shape = box
			shape.position = Vector3(size.x / 2.0, minf(h, 3.0) / 2.0, size.y / 2.0)
			body.add_child(shape)
			body.position = Vector3(pr[1])
			add_child(body)
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


## Oyuncu yaklaşınca kapılar açılır.
func _swing_doors(delta: float) -> void:
	for d in _doors:
		var center := d.global_position + d.global_transform.basis.x * 0.5
		var near := player.global_position.distance_to(center) < 2.2
		var hinge := d.get_child(0) as Node3D
		hinge.rotation.y = move_toward(hinge.rotation.y, 1.7 if near else 0.0, delta * 3.0)
