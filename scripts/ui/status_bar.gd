class_name StatusBar
extends Control
## Hızlı erişim çubuğunun üstünde can (kalp) ve açlık (but) göstergesi.
## assets/textures/ui/ui_heart.png ve ui_drumstick.png varsa onları kullanır, yoksa piksel desen çizer.

const ICON := 20.0
const GAP := 2.0
const UI_DIR := "res://assets/textures/ui/"

## 7x6 piksel kalp ve but desenleri ("#" dolu piksel).
const HEART := ["_##_##_", "#######", "#######", "_#####_", "__###__", "___#___"]
const DRUMSTICK := ["___##__", "__####_", "_#####_", "_####__", "#_#____", "##_____"]

var survival: Survival
## Verilirse çantadaki en iyi zırh kalplerin üstünde küçük ikon ve aşınma çubuğuyla gösterilir.
var inventory: Inventory

var _heart_tex: Texture2D
var _food_tex: Texture2D


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	custom_minimum_size = Vector2(Hud.HOTBAR_WIDTH, ICON)
	if ResourceLoader.exists(UI_DIR + "ui_heart.png"):
		_heart_tex = load(UI_DIR + "ui_heart.png")
	if ResourceLoader.exists(UI_DIR + "ui_drumstick.png"):
		_food_tex = load(UI_DIR + "ui_drumstick.png")
	survival.changed.connect(queue_redraw)
	if inventory:
		inventory.changed.connect(queue_redraw)


func _draw() -> void:
	for i in 10:
		# Can soldan sağa, açlık sağdan sola dolar.
		var heart_pos := Vector2(i * (ICON + GAP), 0)
		var food_pos := Vector2(size.x - (i + 1) * (ICON + GAP), 0)
		_draw_icon(heart_pos, _heart_tex, HEART, Color("e0282e"), survival.health - i * 2)
		_draw_icon(food_pos, _food_tex, DRUMSTICK, Color("c07a3a"), survival.hunger - i * 2)
	var slot := inventory.best_armor_slot() if inventory else -1
	if slot >= 0:
		var id := inventory.item_at(slot)
		var r := Rect2(Vector2(0, -ICON * 1.4 - 4), Vector2(ICON * 1.4, ICON * 1.4))
		draw_texture_rect(Items.item_icon(id), r, false)
		var frac := float(inventory.uses_at(slot)) / Items.max_uses(id)
		draw_rect(Rect2(r.end.x + 4, r.position.y + r.size.y / 2.0 - 3, 60, 6), Color(0, 0, 0, 0.5))
		draw_rect(Rect2(r.end.x + 4, r.position.y + r.size.y / 2.0 - 3, 60 * frac, 6), Hud.wear_color(frac))


## fill: 2 dolu, 1 yarım, 0 ve altı boş.
func _draw_icon(pos: Vector2, tex: Texture2D, pattern: Array, color: Color, fill: int) -> void:
	var rect := Rect2(pos, Vector2(ICON, ICON))
	if tex:
		draw_texture_rect(tex, rect, false, Color(0.2, 0.2, 0.2, 0.6))
		if fill >= 2:
			draw_texture_rect(tex, rect, false)
		elif fill == 1:
			draw_texture_rect_region(tex, Rect2(pos, Vector2(ICON / 2.0, ICON)), Rect2(Vector2.ZERO, tex.get_size() * Vector2(0.5, 1)))
		return
	var px := ICON / 7.0
	for y in pattern.size():
		var row: String = pattern[y]
		for x in row.length():
			if row[x] != "#":
				continue
			var c := Color(0.15, 0.15, 0.15, 0.7)
			if fill >= 2 or (fill == 1 and x < 4):
				c = color
			draw_rect(Rect2(pos + Vector2(x * px, y * px + px / 2.0), Vector2(px, px)), c)
