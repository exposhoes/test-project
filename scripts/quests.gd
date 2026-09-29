class_name Quests
extends RefCounted
## Oyuncuya yol gösteren görev listesi. Sırayla gösterilir ama her biri ne zaman yapılırsa yapılsın sayılır.
## "item": çantada o eşya olunca, "event": main'den gelen olay adıyla tamamlanır.

signal completed(text: String)

const LIST := [
	{"id": "log", "text": "Bir ağaç kes", "item": Blocks.LOG},
	{"id": "table", "text": "Çalışma masası yap", "item": Blocks.CRAFTING_TABLE},
	{"id": "wood_pickaxe", "text": "Tahta kazma yap", "item": Items.WOOD_PICKAXE},
	{"id": "stone_pickaxe", "text": "Taş kazma yap", "item": Items.STONE_PICKAXE},
	{"id": "furnace", "text": "Fırın yap", "item": Blocks.FURNACE},
	{"id": "iron", "text": "Fırında demir erit", "item": Items.IRON},
	{"id": "bed", "text": "Yatak yap", "item": Blocks.BED},
	{"id": "iron_pickaxe", "text": "Demir kazma yap", "item": Items.IRON_PICKAXE},
	{"id": "tame", "text": "Bir yaratığı evcilleştir", "event": "tame"},
	{"id": "lantern", "text": "Fener yap", "item": Blocks.LANTERN},
	{"id": "halls", "text": "Sarı Koridorlar'a gir", "event": "dimension_%d" % Dimension.HALLS},
	{"id": "iron_armor", "text": "Demir zırh yap", "item": Items.IRON_ARMOR},
	{"id": "factory", "text": "Oyuncak Fabrikası'na gir", "event": "dimension_%d" % Dimension.FACTORY},
	{"id": "ruby_sword", "text": "Yakut kılıç yap", "item": Items.RUBY_SWORD},
	{"id": "boss", "text": "Fabrika Patronu'nu yen", "event": "boss"},
	{"id": "ruby_armor", "text": "Yakut zırh yap", "item": Items.RUBY_ARMOR},
	{"id": "crystal_pickaxe", "text": "Kristal kazma yap", "item": Items.CRYSTAL_PICKAXE},
]

## Tamamlanan görev kimlikleri -> true (kayıtta saklanır).
var done := {}


func check_inventory(inv: Inventory) -> void:
	for q: Dictionary in LIST:
		if q.has("item") and not done.has(q["id"]) and inv.count_of(q["item"]) > 0:
			_complete(q)


func event(name: String) -> void:
	for q: Dictionary in LIST:
		if q.get("event", "") == name and not done.has(q["id"]):
			_complete(q)


## Sıradaki görevin metni; hepsi bittiyse boş.
func current() -> String:
	for q: Dictionary in LIST:
		if not done.has(q["id"]):
			return q["text"]
	return ""


func count_done() -> int:
	return done.size()


func _complete(q: Dictionary) -> void:
	done[q["id"]] = true
	completed.emit(q["text"])
