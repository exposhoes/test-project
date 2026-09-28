class_name TouchControls
extends Control
## Çoklu dokunuş kontrolleri: sol tarafta sanal joystick, sağ tarafta sürükleyerek bakma,
## sağ altta Zıpla / Kır / Koy düğmeleri. Düğmeler normal giriş eylemlerini tetikler.

const JOYSTICK_RADIUS := 80.0
## Joystick boştayken sol alt köşede durduğu yer (sol ve alt kenardan uzaklık).
const JOYSTICK_HOME := Vector2(170, -170)
const BUTTONS := [
	{"action": "jump", "label": "Zıpla", "offset": Vector2(-110, -120), "radius": 58.0},
	{"action": "break_block", "label": "Kır", "offset": Vector2(-250, -110), "radius": 48.0},
	{"action": "place_block", "label": "Koy", "offset": Vector2(-120, -270), "radius": 48.0},
]

var move_vector := Vector2.ZERO
var hud: Hud

var _joy_finger := -1
var _joy_origin := Vector2.ZERO
var _joy_pos := Vector2.ZERO
var _look_finger := -1
var _look_delta := Vector2.ZERO
var _finger_actions := {}  # parmak -> eylem


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	# Bazı emülatörler dokunmatik ekran bildirmiyor; mobil sürümde düğmeler her zaman görünsün.
	visible = DisplayServer.is_touchscreen_available() or OS.has_feature("mobile")
	# Düğmeler ekran boyutuna göre konumlanır; boyut ilk çizimden sonra oturduğunda yeniden çiz.
	resized.connect(queue_redraw)


func consume_look_delta() -> Vector2:
	var d := _look_delta
	_look_delta = Vector2.ZERO
	return d


func _input(event: InputEvent) -> void:
	if not visible:
		return
	if event is InputEventScreenTouch:
		if event.pressed:
			_on_press(event.index, event.position)
		else:
			_on_release(event.index)
		queue_redraw()
	elif event is InputEventScreenDrag:
		if event.index == _joy_finger:
			_joy_pos = event.position
			move_vector = ((_joy_pos - _joy_origin) / JOYSTICK_RADIUS).limit_length(1.0)
			queue_redraw()
		elif event.index == _look_finger:
			_look_delta += event.relative


func _on_press(finger: int, pos: Vector2) -> void:
	for b in BUTTONS:
		if pos.distance_to(_button_center(b)) <= b["radius"]:
			_finger_actions[finger] = b["action"]
			Input.action_press(b["action"])
			return
	if hud and hud.select_slot_at(pos):
		return
	if pos.x < size.x * 0.4 and _joy_finger == -1:
		_joy_finger = finger
		_joy_origin = pos
		_joy_pos = pos
	elif _look_finger == -1:
		_look_finger = finger


func _on_release(finger: int) -> void:
	if _finger_actions.has(finger):
		Input.action_release(_finger_actions[finger])
		_finger_actions.erase(finger)
	if finger == _joy_finger:
		_joy_finger = -1
		move_vector = Vector2.ZERO
	if finger == _look_finger:
		_look_finger = -1


func _button_center(b: Dictionary) -> Vector2:
	return size + b["offset"]


func _draw() -> void:
	var font := get_theme_default_font()
	for b in BUTTONS:
		var pressed: bool = _finger_actions.values().has(b["action"])
		var center := _button_center(b)
		draw_circle(center, b["radius"], Color(1, 1, 1, 0.35 if pressed else 0.18))
		draw_arc(center, b["radius"], 0, TAU, 48, Color(1, 1, 1, 0.6), 2.0)
		var text_size := font.get_string_size(b["label"], HORIZONTAL_ALIGNMENT_CENTER, -1, 22)
		draw_string(font, center + Vector2(-text_size.x / 2.0, 8), b["label"], HORIZONTAL_ALIGNMENT_CENTER, -1, 22)
	# Joystick her zaman görünür; dokununca parmağın değdiği yere taşınır.
	var origin := _joy_origin if _joy_finger != -1 else Vector2(JOYSTICK_HOME.x, size.y + JOYSTICK_HOME.y)
	draw_circle(origin, JOYSTICK_RADIUS, Color(1, 1, 1, 0.18 if _joy_finger != -1 else 0.1))
	draw_arc(origin, JOYSTICK_RADIUS, 0, TAU, 48, Color(1, 1, 1, 0.5), 2.0)
	draw_circle(origin + move_vector * JOYSTICK_RADIUS, 32, Color(1, 1, 1, 0.45))
