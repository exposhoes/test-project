class_name MenuPanel
extends Control
## Ortada başlık ve alt alta büyük düğmeler çizen basit menü.
## Dokunmatik ve fare aynı şekilde çalışır (dokunulan noktadaki düğmenin işlevi çağrılır).

const BUTTON_SIZE := Vector2(380, 76)
const GAP := 18.0

var title := ""
var subtitle := ""
## Karartılmış arka plan (oyun içi menüde); ana menüde arkadaki 3B sahne görünsün diye kapalı.
var dim := true
## Menünün yatay merkezi (ekran genişliğine oran); ana menüde sola alınır ki yaratıklar görünsün.
var center_ratio := 0.5
var _buttons: Array[Dictionary] = []  # {"label", "action": Callable, "rect", "style"}


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	resized.connect(queue_redraw)


func set_buttons(buttons: Array) -> void:
	_buttons.clear()
	for b: Dictionary in buttons:
		_buttons.append(b.duplicate())
	queue_redraw()


func _draw() -> void:
	var font := get_theme_default_font()
	if dim:
		draw_rect(Rect2(Vector2.ZERO, size), Color(0.03, 0.03, 0.06, 0.75))
	var total_h := _buttons.size() * (BUTTON_SIZE.y + GAP) - GAP
	var y := size.y / 2.0 - total_h / 2.0 + 60.0
	var cx := size.x * center_ratio
	_centered(font, title, 72, y - 140, Color.WHITE, 10)
	if subtitle != "":
		_centered(font, subtitle, 22, y - 90, Color(1, 1, 1, 0.8), 5)
	for b in _buttons:
		var r := Rect2(Vector2(cx - BUTTON_SIZE.x / 2.0, y), BUTTON_SIZE)
		b["rect"] = r
		var danger: bool = b.get("style", "") == "danger"
		draw_rect(r, Color(0.55, 0.15, 0.15, 0.85) if danger else Color(0.2, 0.45, 0.25, 0.9))
		draw_rect(r, Color(1, 1, 1, 0.7), false, 3.0)
		_centered(font, b["label"], 30, r.position.y + r.size.y / 2.0 + 11, Color.WHITE, 4)
		y += BUTTON_SIZE.y + GAP


func _centered(font: Font, text: String, font_size: int, baseline: float, color: Color, outline: int) -> void:
	var w := font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x
	var p := Vector2(size.x * center_ratio - w / 2.0, baseline)
	draw_string_outline(font, p, text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, outline, Color(0, 0, 0, 0.8))
	draw_string(font, p, text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, color)


func _input(event: InputEvent) -> void:
	if not is_visible_in_tree():
		return
	var pos := Vector2.INF
	if event is InputEventScreenTouch and event.pressed:
		pos = event.position
	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		pos = event.position
	if pos == Vector2.INF:
		return
	get_viewport().set_input_as_handled()
	tap(pos)


func tap(pos: Vector2) -> void:
	for b in _buttons:
		if b.has("rect") and b["rect"].has_point(pos):
			(b["action"] as Callable).call()
			return
