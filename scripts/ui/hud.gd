class_name Hud
extends CanvasLayer
## Nişangah, hızlı erişim çubuğu ve dokunmatik kontroller.

const SLOT_SIZE := 56

var touch := TouchControls.new()
var atlas: BlockAtlas

var _selected := 0
var _slots: Array[Panel] = []
var _hotbar := HBoxContainer.new()
var _name_label := Label.new()


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
	for id in Blocks.HOTBAR:
		var slot := Panel.new()
		slot.custom_minimum_size = Vector2(SLOT_SIZE, SLOT_SIZE)
		slot.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var icon := TextureRect.new()
		icon.texture = atlas.icon(id)
		icon.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT, Control.PRESET_MODE_MINSIZE, 8)
		slot.add_child(icon)
		_hotbar.add_child(slot)
		_slots.append(slot)

	_name_label.set_anchors_and_offsets_preset(Control.PRESET_CENTER_BOTTOM)
	_name_label.grow_horizontal = Control.GROW_DIRECTION_BOTH
	_name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_name_label.position.y -= SLOT_SIZE + 44
	root.add_child(_name_label)

	touch.hud = self
	root.add_child(touch)
	_select(0)


func selected_block() -> int:
	return Blocks.HOTBAR[_selected]


## Dokunulan nokta bir yuvanın üstündeyse onu seçer.
func select_slot_at(pos: Vector2) -> bool:
	for i in _slots.size():
		if _slots[i].get_global_rect().has_point(pos):
			_select(i)
			return true
	return false


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
	_name_label.text = Blocks.display_name(selected_block())
