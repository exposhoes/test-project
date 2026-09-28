class_name Inventory
extends RefCounted
## Oyuncunun eşyaları. Şimdilik yalnızca 9 yuvalı hızlı erişim çubuğu var;
## tam envanter ekranı üretimle birlikte gelecek.

signal changed

const SIZE := 9

## Her yuva {"id": int, "count": int} ya da boşsa {}.
var slots: Array[Dictionary] = []


func _init() -> void:
	for i in SIZE:
		slots.append({})


## Eşyaları önce aynı türden yığınlara, sonra boş yuvalara koyar. Sığmayan miktarı döner.
func add(id: int, count := 1) -> int:
	for pass_empty in [false, true]:
		for slot in slots:
			if count == 0:
				break
			if pass_empty and slot.is_empty():
				slot["id"] = id
				slot["count"] = 0
			if not slot.is_empty() and slot["id"] == id and slot["count"] < Items.MAX_STACK:
				var n := mini(count, Items.MAX_STACK - slot["count"])
				slot["count"] += n
				count -= n
	changed.emit()
	return count


func item_at(i: int) -> int:
	return slots[i]["id"] if not slots[i].is_empty() else Blocks.AIR


func count_at(i: int) -> int:
	return slots[i]["count"] if not slots[i].is_empty() else 0


func count_of(id: int) -> int:
	var total := 0
	for slot in slots:
		if not slot.is_empty() and slot["id"] == id:
			total += slot["count"]
	return total


## Yuvadan bir tane eksiltir. Yuva boşsa false döner.
func take_one(i: int) -> bool:
	if slots[i].is_empty():
		return false
	slots[i]["count"] -= 1
	if slots[i]["count"] <= 0:
		slots[i] = {}
	changed.emit()
	return true
