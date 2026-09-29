class_name Inventory
extends RefCounted
## Oyuncunun eşyaları: ilk 9 yuva hızlı erişim çubuğu, kalan 27 yuva çanta.

signal changed

const HOTBAR := 9
const SIZE := 36

## Her yuva {"id": int, "count": int} ya da boşsa {}. Aletlerde "uses": kalan kullanım hakkı.
var slots: Array[Dictionary] = []
## Fırında yanmış, henüz harcanmamış yakıt (kaç eritmeye yeteceği).
var fuel := 0


## size: oyuncu için 36, sandık için 27. slots verilirse o dizi kullanılır (sandık içeriği dünyada saklanır).
func _init(size := SIZE, p_slots = null) -> void:
	if p_slots != null:
		slots = p_slots
		return
	for i in size:
		slots.append({})


## Eşyaları önce aynı türden yığınlara, sonra boş yuvalara koyar (çubuk önce dolar).
## Sığmayan miktarı döner.
func add(id: int, count := 1) -> int:
	var limit := Items.max_stack(id)
	for pass_empty in [false, true]:
		for slot in slots:
			if count == 0:
				break
			if pass_empty and slot.is_empty():
				slot["id"] = id
				slot["count"] = 0
				if Items.max_uses(id) > 0:
					slot["uses"] = Items.max_uses(id)
			if not slot.is_empty() and slot["id"] == id and slot["count"] < limit:
				var n := mini(count, limit - slot["count"])
				slot["count"] += n
				count -= n
	changed.emit()
	return count


## Hepsi sığar mı (eklemeden sınar).
func can_fit(id: int, count: int) -> bool:
	var limit := Items.max_stack(id)
	var room := 0
	for slot in slots:
		if slot.is_empty():
			room += limit
		elif slot["id"] == id:
			room += limit - slot["count"]
	return room >= count


## Verilen türden count tane çıkarır (önce çantadan). Yetmezse hiçbir şey çıkarmaz.
func remove(id: int, count: int) -> bool:
	if count_of(id) < count:
		return false
	for i in range(slots.size() - 1, -1, -1):
		if count == 0:
			break
		if not slots[i].is_empty() and slots[i]["id"] == id:
			var n := mini(count, slots[i]["count"])
			slots[i]["count"] -= n
			count -= n
			if slots[i]["count"] == 0:
				slots[i] = {}
	changed.emit()
	return true


func swap(a: int, b: int) -> void:
	var tmp := slots[a]
	slots[a] = slots[b]
	slots[b] = tmp
	changed.emit()


func item_at(i: int) -> int:
	return slots[i]["id"] if not slots[i].is_empty() else Blocks.AIR


func count_at(i: int) -> int:
	return slots[i]["count"] if not slots[i].is_empty() else 0


## Aletin kalan kullanım hakkı; alet değilse 0.
func uses_at(i: int) -> int:
	if slots[i].is_empty():
		return 0
	return slots[i].get("uses", Items.max_uses(slots[i]["id"]))


## Yuvadaki aleti bir kez kullanır. Alet bu kullanımla kırıldıysa true döner.
func wear(i: int, amount := 1) -> bool:
	if slots[i].is_empty() or Items.max_uses(slots[i]["id"]) == 0:
		return false
	slots[i]["uses"] = uses_at(i) - amount
	var broke: bool = slots[i]["uses"] <= 0
	if broke:
		slots[i] = {}
	changed.emit()
	return broke


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


## Tarif yapılabilir mi (masa şartı hariç).
func has_ingredients(recipe: Dictionary) -> bool:
	for id in recipe["in"]:
		if count_of(id) < recipe["in"][id]:
			return false
	return true


## Malzemeleri harcayıp ürünü ekler. Malzeme yoksa ya da ürün sığmıyorsa false.
func craft(recipe: Dictionary) -> bool:
	if not has_ingredients(recipe):
		return false
	for id in recipe["in"]:
		remove(id, recipe["in"][id])
	var left := add(recipe["out"], recipe["count"])
	if left > 0:
		# Sığmadıysa geri al.
		remove(recipe["out"], recipe["count"] - left)
		for id in recipe["in"]:
			add(id, recipe["in"][id])
		return false
	return true


## Fırında eritilebilir mi: malzeme, yer ve yakıt (yanmış ya da yakılabilir eşya) var mı.
func can_smelt(recipe: Dictionary) -> bool:
	return has_ingredients(recipe) and can_fit(recipe["out"], recipe["count"]) and (fuel > 0 or _fuel_to_burn(recipe) != -1)


## Gerekirse yakıt yakar, sonra eritir. Yapılamıyorsa hiçbir şey harcamaz.
func smelt(recipe: Dictionary) -> bool:
	if not can_smelt(recipe):
		return false
	if fuel == 0:
		var id := _fuel_to_burn(recipe)
		remove(id, 1)
		fuel += Items.FUEL[id]
	if not craft(recipe):
		return false
	fuel -= 1
	return true


## Yakılacak eşya: eritilecek malzemeyi tüketmeyen ilk yakıt; yoksa -1.
func _fuel_to_burn(recipe: Dictionary) -> int:
	for id in Items.FUEL:
		if count_of(id) >= recipe["in"].get(id, 0) + 1:
			return id
	return -1
