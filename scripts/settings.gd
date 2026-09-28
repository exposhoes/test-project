class_name Settings
extends RefCounted
## Oyuncu ayarları: bakış hızı ve görüş mesafesi. user://settings.cfg dosyasında saklanır.

const DEFAULT_PATH := "user://settings.cfg"
## Seçilebilir bakış hızı çarpanları.
const LOOK_SPEEDS := [0.5, 0.75, 1.0, 1.25, 1.5, 2.0]
## Seçilebilir görüş mesafeleri (chunk) ve adları. Uzak görüş eski telefonları yavaşlatabilir.
const VIEW_DISTANCES := [2, 3, 4, 6, 8]
const VIEW_NAMES := ["Çok yakın", "Yakın", "Orta", "Uzak", "Çok uzak"]
## Fog yoğunluğu bu mesafeye göre ayarlanır: uzak görüşte sis de uzaklaşır.
const BASE_FOG := 0.012
const BASE_VIEW := 4

## Boş yol kaydetmeyi kapatır (testler).
static var path := DEFAULT_PATH
static var look_speed := 1.0
static var view_distance := BASE_VIEW
static var _loaded := false


static func ensure_loaded() -> void:
	if _loaded:
		return
	_loaded = true
	if path == "":
		return
	var cfg := ConfigFile.new()
	if cfg.load(path) != OK:
		return
	look_speed = cfg.get_value("controls", "look_speed", look_speed)
	view_distance = cfg.get_value("graphics", "view_distance", view_distance)


static func save() -> void:
	if path == "":
		return
	var cfg := ConfigFile.new()
	cfg.set_value("controls", "look_speed", look_speed)
	cfg.set_value("graphics", "view_distance", view_distance)
	cfg.save(path)


## Sıradaki bakış hızına geçer (sondan başa döner) ve kaydeder.
static func cycle_look_speed() -> void:
	look_speed = _next(LOOK_SPEEDS, look_speed)
	save()


## Sıradaki görüş mesafesine geçer (sondan başa döner) ve kaydeder.
static func cycle_view_distance() -> void:
	view_distance = _next(VIEW_DISTANCES, view_distance)
	save()


static func view_name() -> String:
	var i := VIEW_DISTANCES.find(view_distance)
	return VIEW_NAMES[i] if i != -1 else "%d" % view_distance


static func fog_density() -> float:
	return BASE_FOG * BASE_VIEW / view_distance


## Ayarlar menüsünün düğmeleri. changed: bir ayar değişince (menüyü yenilemek için),
## back: Geri düğmesi.
static func menu_buttons(changed: Callable, back: Callable) -> Array:
	ensure_loaded()
	return [
		{"label": "Bakış hızı: %sx" % str(look_speed).replace(".", ","), "action": func() -> void:
			cycle_look_speed()
			changed.call()},
		{"label": "Görüş: %s" % view_name(), "action": func() -> void:
			cycle_view_distance()
			changed.call()},
		{"label": "Geri", "action": back},
	]


static func _next(values: Array, current) -> Variant:
	var i := values.find(current)
	return values[(i + 1) % values.size()]
