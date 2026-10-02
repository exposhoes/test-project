class_name Hud
extends CanvasLayer
## Nişangah, can/açlık göstergesi, hızlı erişim çubuğu, bildirimler, ölüm ekranı ve dokunmatik kontroller.

const SLOT_SIZE := 56
const HOTBAR_WIDTH := SLOT_SIZE * 9 + 4 * 8
## Ölünce yanlışlıkla hemen yeniden doğmamak için bekleme.
const RESPAWN_DELAY := 1.0

var touch := TouchControls.new()
var atlas: BlockAtlas
var player: Player

var _selected := 0
var _slots: Array[Panel] = []
var _hotbar := HBoxContainer.new()
var _name_label := Label.new()
var _status := StatusBar.new()
var _quest_label := Label.new()
var _boss_bar := ProgressBar.new()
var _boss_name := Label.new()
var _toast := Label.new()
var _toast_timer := 0.0
var _damage_flash := ColorRect.new()
var _gas_overlay := ColorRect.new()
var _gas_time := 0.0
var _death_screen := ColorRect.new()
var _death_time := 0.0
var _inventory_screen := InventoryScreen.new()
var _pause_menu := MenuPanel.new()
## Şehri Gez modu: can/açlık, eşya çubuğu ve görev gizli; duraklat menüsünde hızlı geçiş.
var explore := false
const GEZI_YERLERI := [
	["Emir'in Evi", "ev.kapi_disi"], ["Okul", "okul.sinif_kapi"], ["Hastane", "hastane.dis"],
	["Pazar", "pazar.giris"], ["Park", "park.bank_yani"], ["Sahil", "sahil.kordon"],
	["Metro", "metro.peron"], ["Havalimanı", "havalimani.giris"],
]


func _ready() -> void:
	var root := Control.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(root)

	var crosshair := Label.new()
	crosshair.text = "+"
	crosshair.add_theme_font_size_override("font_size", 32)
	crosshair.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	crosshair.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	crosshair.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	root.add_child(crosshair)

	_hotbar.add_theme_constant_override("separation", 4)
	_hotbar.set_anchors_and_offsets_preset(Control.PRESET_CENTER_BOTTOM)
	_hotbar.grow_horizontal = Control.GROW_DIRECTION_BOTH
	_hotbar.position.y -= SLOT_SIZE + 12
	root.add_child(_hotbar)
	for i in Inventory.HOTBAR:
		var slot := Panel.new()
		slot.custom_minimum_size = Vector2(SLOT_SIZE, SLOT_SIZE)
		slot.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var icon := TextureRect.new()
		icon.name = "Icon"
		icon.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT, Control.PRESET_MODE_MINSIZE, 8)
		slot.add_child(icon)
		var count := Label.new()
		count.name = "Count"
		count.add_theme_font_size_override("font_size", 18)
		count.add_theme_color_override("font_outline_color", Color.BLACK)
		count.add_theme_constant_override("outline_size", 5)
		count.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		count.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
		count.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT, Control.PRESET_MODE_MINSIZE, 3)
		slot.add_child(count)
		var wear := ColorRect.new()
		wear.name = "Wear"
		wear.mouse_filter = Control.MOUSE_FILTER_IGNORE
		wear.position = Vector2(6, SLOT_SIZE - 8)
		wear.size = Vector2(SLOT_SIZE - 12, 4)
		slot.add_child(wear)
		_hotbar.add_child(slot)
		_slots.append(slot)
	player.inventory.changed.connect(_refresh_hotbar)
	_refresh_hotbar()

	_name_label.set_anchors_and_offsets_preset(Control.PRESET_CENTER_BOTTOM)
	_name_label.grow_horizontal = Control.GROW_DIRECTION_BOTH
	_name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_name_label.position.y -= SLOT_SIZE + 70
	root.add_child(_name_label)

	_status.survival = player.survival
	_status.inventory = player.inventory
	root.add_child(_status)
	_status.set_anchors_and_offsets_preset(Control.PRESET_CENTER_BOTTOM)
	_status.grow_horizontal = Control.GROW_DIRECTION_BOTH
	_status.position.y -= SLOT_SIZE + 40

	_quest_label.position = Vector2(16, 12)
	_quest_label.add_theme_font_size_override("font_size", 18)
	_quest_label.add_theme_color_override("font_outline_color", Color.BLACK)
	_quest_label.add_theme_constant_override("outline_size", 5)
	_quest_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(_quest_label)

	# Boss can çubuğu: üstte ortada, boss yakındayken görünür.
	_boss_bar.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP)
	_boss_bar.custom_minimum_size = Vector2(420, 18)
	_boss_bar.position = Vector2(-210, 44)
	_boss_bar.size = Vector2(420, 18)
	_boss_bar.show_percentage = false
	_boss_bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var fill := StyleBoxFlat.new()
	fill.bg_color = Color("d9343a")
	_boss_bar.add_theme_stylebox_override("fill", fill)
	var bg := StyleBoxFlat.new()
	bg.bg_color = Color(0, 0, 0, 0.6)
	_boss_bar.add_theme_stylebox_override("background", bg)
	_boss_bar.visible = false
	root.add_child(_boss_bar)
	_boss_name.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP)
	_boss_name.grow_horizontal = Control.GROW_DIRECTION_BOTH
	_boss_name.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_boss_name.position.y = 14
	_boss_name.add_theme_font_size_override("font_size", 20)
	_boss_name.add_theme_color_override("font_outline_color", Color.BLACK)
	_boss_name.add_theme_constant_override("outline_size", 5)
	_boss_name.visible = false
	root.add_child(_boss_name)

	_toast.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP)
	_toast.grow_horizontal = Control.GROW_DIRECTION_BOTH
	_toast.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_toast.position.y += 60
	_toast.add_theme_font_size_override("font_size", 26)
	_toast.add_theme_color_override("font_outline_color", Color.BLACK)
	_toast.add_theme_constant_override("outline_size", 6)
	root.add_child(_toast)

	_damage_flash.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_damage_flash.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_damage_flash.color = Color(0.8, 0, 0, 0)
	root.add_child(_damage_flash)
	_gas_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_gas_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_gas_overlay.color = Color(0.35, 0.2, 0.5, 0)
	root.add_child(_gas_overlay)
	player.survival.damaged.connect(func(_amount: int) -> void: _damage_flash.color.a = 0.35)

	_death_screen.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_death_screen.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_death_screen.color = Color(0.45, 0, 0, 0.6)
	_death_screen.visible = false
	var death_label := Label.new()
	death_label.text = "Öldün!\n\nYeniden doğmak için ekrana dokun"
	death_label.add_theme_font_size_override("font_size", 36)
	death_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	death_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	death_label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_death_screen.add_child(death_label)
	root.add_child(_death_screen)
	player.survival.died.connect(_on_died)

	_inventory_screen.hud = self
	root.add_child(_inventory_screen)
	root.move_child(_toast, -1)
	player.inventory.changed.connect(_inventory_screen.queue_redraw)

	_pause_menu.visible = false
	_show_pause_buttons()
	root.add_child(_pause_menu)
	# Oyun duraklatılınca arayüz çalışmaya devam etsin.
	process_mode = Node.PROCESS_MODE_ALWAYS

	touch.hud = self
	root.add_child(touch)
	_select(0)


func selected_slot() -> int:
	return _selected


func _refresh_hotbar() -> void:
	var inv := player.inventory
	for i in _slots.size():
		var id := inv.item_at(i)
		(_slots[i].get_node("Icon") as TextureRect).texture = item_texture(id) if id != Blocks.AIR else null
		var n := inv.count_at(i)
		(_slots[i].get_node("Count") as Label).text = str(n) if n > 1 else ""
		var wear := _slots[i].get_node("Wear") as ColorRect
		var frac := wear_fraction(inv, i)
		wear.visible = frac < 1.0
		wear.size.x = (SLOT_SIZE - 12) * frac
		wear.color = wear_color(frac)
	_name_label.text = Items.display_name(inv.item_at(_selected))


## Aletin kalan hakkı 0..1; alet değilse ya da hiç kullanılmadıysa 1.
static func wear_fraction(inv: Inventory, i: int) -> float:
	var full := Items.max_uses(inv.item_at(i))
	return 1.0 if full == 0 else float(inv.uses_at(i)) / full


## Dayanıklılık çubuğu rengi: yeşilden kırmızıya.
static func wear_color(frac: float) -> Color:
	return Color.RED.lerp(Color.GREEN, frac)


## Uyku gazı: ekran mora çalıp kararır, süre bitince açılır.
func show_gas(seconds: float) -> void:
	_gas_time = maxf(_gas_time, seconds)
	toast("Uyku gazı! Yavaşladın.")


func item_texture(id: int) -> Texture2D:
	return atlas.icon(id) if Items.is_block(id) else Items.item_icon(id)


func select_slot(i: int) -> void:
	_select(i)


func is_menu_open() -> bool:
	return _inventory_screen.visible or _death_screen.visible or _pause_menu.visible


## Gezi modunu açar: göstergeleri gizler.
func set_explore() -> void:
	explore = true
	_status.visible = false
	_hotbar.visible = false
	_name_label.visible = false
	_quest_label.visible = false
	_show_pause_buttons()


func _show_places() -> void:
	_pause_menu.title = "Nereye gidelim?"
	var buttons := []
	for pl: Array in GEZI_YERLERI:
		var target: String = pl[1]
		buttons.append({"label": pl[0], "action": func() -> void:
			close_pause()
			player.teleport(FilmSets.point(target) + Vector3(0, 0.1, 0))})
	buttons.append({"label": "Geri", "action": _show_pause_buttons})
	_pause_menu.set_buttons(buttons)


func _show_pause_buttons() -> void:
	_pause_menu.title = "Duraklatıldı"
	if explore:
		_pause_menu.set_buttons([
			{"label": "Oyuna Dön", "action": close_pause},
			{"label": "Yere Git", "action": _show_places},
			{"label": "Ana Menü", "action": func() -> void: get_parent().quit_to_menu()},
		])
		return
	_pause_menu.set_buttons([
		{"label": "Oyuna Dön", "action": close_pause},
		{"label": "Ayarlar", "action": _show_settings},
		{"label": "Kaydet ve Ana Menü", "action": func() -> void: get_parent().quit_to_menu()},
	])


func _show_settings() -> void:
	_pause_menu.title = "Ayarlar"
	_pause_menu.set_buttons(Settings.menu_buttons(func() -> void:
		get_parent().apply_settings()
		_show_settings(), _show_pause_buttons))


func open_pause() -> void:
	close_inventory()
	touch.release_all()
	touch.visible = false
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	_pause_menu.visible = true
	get_tree().paused = true


func close_pause() -> void:
	_pause_menu.visible = false
	_show_pause_buttons()
	get_tree().paused = false
	touch.visible = DisplayServer.is_touchscreen_available() or OS.has_feature("mobile")


## chest verilirse sağda tarifler yerine sandığın yuvaları gösterilir.
func open_inventory(chest: Inventory = null) -> void:
	touch.release_all()
	touch.visible = false
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	_inventory_screen.open(chest)


func close_inventory() -> void:
	_inventory_screen.close()
	touch.visible = DisplayServer.is_touchscreen_available() or OS.has_feature("mobile")


## Dokunulan nokta bir yuvanın üstündeyse onu seçer.
func select_slot_at(pos: Vector2) -> bool:
	for i in _slots.size():
		if _slots[i].get_global_rect().has_point(pos):
			_select(i)
			return true
	return false


## Ekranın üstünde birkaç saniye görünen kısa mesaj.
## Boss yakındayken adını ve canını gösterir; null gizler.
func show_boss_bar(b: Mob) -> void:
	_boss_bar.visible = b != null
	_boss_name.visible = b != null
	if b:
		_boss_bar.max_value = b.max_health()
		_boss_bar.value = maxi(b.health, 0)
		_boss_name.text = b.data["name"]


## Sol üstte sıradaki görev ve ilerleme.
func show_quest(q: Quests) -> void:
	var next := q.current()
	var total := Quests.LIST.size()
	_quest_label.text = "Görev %d/%d: %s" % [q.count_done() + 1, total, next] if next != "" else "Bütün görevler tamam! (%d/%d)" % [total, total]


func toast(text: String) -> void:
	_toast.text = text
	_toast_timer = 2.5


func _process(delta: float) -> void:
	_toast_timer = maxf(_toast_timer - delta, 0.0)
	_toast.modulate.a = clampf(_toast_timer, 0.0, 1.0)
	_damage_flash.color.a = move_toward(_damage_flash.color.a, 0.0, delta)
	_gas_time = maxf(_gas_time - delta, 0.0)
	_gas_overlay.color.a = minf(_gas_time, 1.0) * 0.55
	if Input.is_action_just_pressed("pause") and not _death_screen.visible:
		if _pause_menu.visible:
			close_pause()
		else:
			open_pause()
	elif Input.is_action_just_pressed("inventory") and not _death_screen.visible and not _pause_menu.visible:
		if _inventory_screen.visible:
			close_inventory()
		else:
			open_inventory()


func _on_died() -> void:
	close_inventory()
	touch.release_all()
	_death_screen.visible = true
	_death_time = Time.get_ticks_msec() / 1000.0
	touch.visible = false


func _input(event: InputEvent) -> void:
	if not _death_screen.visible or Time.get_ticks_msec() / 1000.0 - _death_time < RESPAWN_DELAY:
		return
	var tapped: bool = (event is InputEventScreenTouch or event is InputEventMouseButton or event is InputEventKey) and event.pressed
	if tapped:
		_death_screen.visible = false
		touch.visible = DisplayServer.is_touchscreen_available() or OS.has_feature("mobile")
		player.respawn()
		get_viewport().set_input_as_handled()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.keycode >= KEY_1 and event.keycode <= KEY_9:
		_select(event.keycode - KEY_1)
	elif event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			_select(posmod(_selected - 1, _slots.size()))
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			_select(posmod(_selected + 1, _slots.size()))


func _select(i: int) -> void:
	if i < 0 or i >= _slots.size():
		return
	_selected = i
	for j in _slots.size():
		_slots[j].self_modulate = Color(1.6, 1.6, 1.6) if j == i else Color(1, 1, 1, 0.7)
	_name_label.text = Items.display_name(player.inventory.item_at(i))
