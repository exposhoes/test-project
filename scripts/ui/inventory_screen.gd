class_name InventoryScreen
extends Control
## Çanta ve üretim ekranı. Solda çanta ve hızlı erişim çubuğu, sağda tarifler.
## Dokunmatik ve fare aynı şekilde çalışır: her şey dokunulan noktaya göre seçilir.

const SLOT := 56.0
const GAP := 6.0
const ROW_H := 58.0
const TABLE_RANGE := 4

var hud: Hud

var _slot_rects: Array[Rect2] = []  # yuva indeksine göre
var _recipe_rects: Array[Rect2] = []
var _close_rect := Rect2()
var _near_table := false


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	visible = false
	resized.connect(queue_redraw)


func open() -> void:
	_near_table = hud.player.near_crafting_table(TABLE_RANGE)
	visible = true
	queue_redraw()


func close() -> void:
	visible = false


func _layout() -> void:
	_slot_rects.resize(Inventory.SIZE)
	var origin := Vector2(40, 90)
	for i in range(Inventory.HOTBAR, Inventory.SIZE):
		var k := i - Inventory.HOTBAR
		_slot_rects[i] = Rect2(origin + Vector2(k % 9, k / 9) * (SLOT + GAP), Vector2(SLOT, SLOT))
	var hotbar_y := origin.y + 3 * (SLOT + GAP) + 24
	for i in Inventory.HOTBAR:
		_slot_rects[i] = Rect2(Vector2(origin.x + i * (SLOT + GAP), hotbar_y), Vector2(SLOT, SLOT))
	_recipe_rects.clear()
	var x0 := origin.x + 9 * (SLOT + GAP) + 30
	var col_w := (size.x - x0 - 30 - GAP) / 2.0
	var rows := ceili(Items.RECIPES.size() / 2.0)
	for r in Items.RECIPES.size():
		var col := r / rows
		var row := r % rows
		_recipe_rects.append(Rect2(Vector2(x0 + col * (col_w + GAP), origin.y + row * (ROW_H + GAP)), Vector2(col_w, ROW_H)))
	_close_rect = Rect2(Vector2(size.x - 84, 16), Vector2(64, 56))


func _draw() -> void:
	_layout()
	var font := get_theme_default_font()
	var inv := hud.player.inventory
	draw_rect(Rect2(Vector2.ZERO, size), Color(0.05, 0.05, 0.08, 0.85))
	draw_string(font, Vector2(40, 60), "Çanta", HORIZONTAL_ALIGNMENT_LEFT, -1, 30)
	draw_string(font, _recipe_rects[0].position + Vector2(0, -30), "Üretim", HORIZONTAL_ALIGNMENT_LEFT, -1, 30)
	_button(_close_rect, "X", font)

	for i in Inventory.SIZE:
		var r := _slot_rects[i]
		var selected := i == hud.selected_slot()
		draw_rect(r, Color(1, 1, 1, 0.28 if selected else 0.1))
		draw_rect(r, Color(1, 1, 1, 0.9 if selected else 0.3), false, 3.0 if selected else 1.0)
		_draw_item(r, inv.item_at(i), inv.count_at(i), font)
	var hint_y := _slot_rects[0].end.y + 36
	draw_string(font, Vector2(40, hint_y), "Çantadaki eşyaya dokun: seçili yuvayla yer değiştirir.", HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color(1, 1, 1, 0.7))
	var table_text := "Yakında çalışma masası var." if _near_table else "Aletler için çalışma masasının yanında olmalısın."
	draw_string(font, Vector2(40, hint_y + 26), table_text, HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color(0.6, 1, 0.6) if _near_table else Color(1, 0.8, 0.5))

	for r in Items.RECIPES.size():
		var recipe: Dictionary = Items.RECIPES[r]
		var rect := _recipe_rects[r]
		var ok := _can_craft(recipe)
		draw_rect(rect, Color(0.3, 0.55, 0.3, 0.45) if ok else Color(1, 1, 1, 0.07))
		var icon_rect := Rect2(rect.position + Vector2(8, 9), Vector2(40, 40))
		_draw_item(icon_rect, recipe["out"], recipe["count"], font)
		var alpha := 1.0 if ok else 0.5
		draw_string(font, rect.position + Vector2(58, 24), Items.display_name(recipe["out"]), HORIZONTAL_ALIGNMENT_LEFT, rect.size.x - 64, 18, Color(1, 1, 1, alpha))
		var parts := PackedStringArray()
		for id in recipe["in"]:
			parts.append("%d %s" % [recipe["in"][id], Items.display_name(id)])
		var needs := " + ".join(parts)
		if recipe.get("table", false):
			needs += "  (masa)"
		draw_string(font, rect.position + Vector2(58, 46), needs, HORIZONTAL_ALIGNMENT_LEFT, rect.size.x - 64, 13, Color(1, 1, 1, alpha * 0.8))


func _draw_item(r: Rect2, id: int, count: int, font: Font) -> void:
	if id == Blocks.AIR:
		return
	draw_texture_rect(hud.item_texture(id), r.grow(-6), false)
	if count > 1:
		var text := str(count)
		var w := font.get_string_size(text, HORIZONTAL_ALIGNMENT_RIGHT, -1, 16).x
		var p := r.end - Vector2(w + 4, 4)
		draw_string_outline(font, p, text, HORIZONTAL_ALIGNMENT_LEFT, -1, 16, 4, Color.BLACK)
		draw_string(font, p, text, HORIZONTAL_ALIGNMENT_LEFT, -1, 16)


func _button(r: Rect2, text: String, font: Font) -> void:
	draw_rect(r, Color(1, 1, 1, 0.15))
	draw_rect(r, Color(1, 1, 1, 0.6), false, 2.0)
	var w := font.get_string_size(text, HORIZONTAL_ALIGNMENT_CENTER, -1, 26).x
	draw_string(font, r.get_center() + Vector2(-w / 2.0, 9), text, HORIZONTAL_ALIGNMENT_LEFT, -1, 26)


func _can_craft(recipe: Dictionary) -> bool:
	var inv := hud.player.inventory
	return inv.has_ingredients(recipe) and (_near_table or not recipe.get("table", false)) and inv.can_fit(recipe["out"], recipe["count"])


func _input(event: InputEvent) -> void:
	if not visible:
		return
	var pos := Vector2.INF
	if event is InputEventScreenTouch and event.pressed:
		pos = event.position
	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		pos = event.position
	if pos != Vector2.INF:
		tap(pos)
		get_viewport().set_input_as_handled()


## Dokunulan noktadaki şeyi yapar: kapat, yuva seç/değiştir ya da üret.
func tap(pos: Vector2) -> void:
	if _close_rect.has_point(pos):
		hud.close_inventory()
		return
	var inv := hud.player.inventory
	for i in Inventory.SIZE:
		if _slot_rects[i].has_point(pos):
			if i < Inventory.HOTBAR:
				hud.select_slot(i)
			else:
				inv.swap(i, hud.selected_slot())
			queue_redraw()
			return
	for r in _recipe_rects.size():
		if _recipe_rects[r].has_point(pos):
			var recipe: Dictionary = Items.RECIPES[r]
			if _can_craft(recipe) and inv.craft(recipe):
				hud.toast("%s üretildi" % Items.display_name(recipe["out"]))
			queue_redraw()
			return
