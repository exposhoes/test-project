class_name SaveGame
extends RefCounted
## Oyunun cihaza kaydı: dünya tohumu ve değişiklikleri, gün saati, oyuncunun konumu,
## can/açlık ve envanteri. Tek dosya, Godot'un store_var biçimiyle.

## Biçim değişirse artır; eski kayıtlar yüklenmez, yeni dünya başlar.
const VERSION := 1
const DEFAULT_PATH := "user://world.save"


static func save(path: String, main: Node) -> bool:
	var player: Player = main.player
	var world: World = main.world
	var dead := player.survival.dead
	main.dim_edits[main.dimension] = world.edits
	main.dim_chests[main.dimension] = world.chests
	var pos := player.global_position if player.is_spawned() else player.saved_position
	var data := {
		"version": VERSION,
		"seed": world.world_seed,
		"time_of_day": main.time_of_day,
		"dimension": main.dimension,
		"dim_edits": main.dim_edits,
		"dim_chests": main.dim_chests,
		"return_positions": main.return_positions,
		"player": {
			# Ölüyken kaydedilirse bir sonraki açılışta başlangıç noktasında dolu canla doğar.
			"position": Vector3.INF if dead else pos,
			"yaw": player.rotation.y,
			"pitch": player._pitch,
			"health": Survival.MAX_HEALTH if dead else player.survival.health,
			"hunger": Survival.MAX_HUNGER if dead else player.survival.hunger,
			"inventory": player.inventory.slots,
			"fuel": player.inventory.fuel,
			"bed": player.bed_position,
		},
		"allies": _allies(main),
		"quests": main.quests.done,
		"boss_defeated": main.boss_defeated,
	}
	# Önce geçici dosyaya yazılır; yazarken uygulama kapanırsa eski kayıt bozulmaz.
	var tmp := path + ".tmp"
	var f := FileAccess.open(tmp, FileAccess.WRITE)
	if f == null:
		push_warning("Kayıt yazılamadı: %s" % error_string(FileAccess.get_open_error()))
		return false
	f.store_var(data)
	f.close()
	return DirAccess.rename_absolute(tmp, path) == OK


static func _allies(main: Node) -> Array:
	var list: Array = main.pending_allies.duplicate()
	for node in main.get_tree().get_nodes_in_group("allies"):
		var mob := node as Mob
		if mob.health > 0 and not mob.is_queued_for_deletion():
			list.append({"id": mob.mob_id, "health": mob.health})
	return list


static func delete(path: String) -> void:
	if FileAccess.file_exists(path):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(path))


## Kaydı okur; yoksa ya da uyumsuzsa boş sözlük döner.
static func read(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {}
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		return {}
	var data = f.get_var()
	if not data is Dictionary or data.get("version", 0) != VERSION:
		return {}
	return data


## Dünya sahneye eklenmeden önce çağrılır (tohum ve değişiklikler üretimden önce gerekli).
static func apply_world(data: Dictionary, main: Node) -> void:
	main.world.world_seed = data["seed"]
	# İlk sürüm kayıtlarında yalnızca yeryüzü değişiklikleri "edits" altındaydı.
	main.dim_edits = data.get("dim_edits", {Dimension.OVERWORLD: data.get("edits", {})})
	main.dimension = data.get("dimension", Dimension.OVERWORLD)
	main.return_positions = data.get("return_positions", {})
	if not main.dim_edits.has(main.dimension):
		main.dim_edits[main.dimension] = {}
	main.world.dimension = main.dimension
	main.world.edits = main.dim_edits[main.dimension]
	# Sandık dizileri yazılı (Array[Dictionary]) olmalı; kayıttan gelen düz diziler dönüştürülür.
	main.dim_chests = {}
	var saved: Dictionary = data.get("dim_chests", {})
	for dim in saved:
		var chests := {}
		for pos in saved[dim]:
			var slots: Array[Dictionary] = []
			for slot in saved[dim][pos]:
				slots.append(slot)
			chests[pos] = slots
		main.dim_chests[dim] = chests
	main.world.chests = main.dim_chests.get(main.dimension, {})
	main.time_of_day = data["time_of_day"]
	main.quests.done = data.get("quests", {})
	main.boss_defeated = data.get("boss_defeated", false)


## Oyuncu sahneye eklendikten sonra çağrılır.
static func apply_player(data: Dictionary, player: Player) -> void:
	var p: Dictionary = data["player"]
	if p["position"] != Vector3.INF:
		player.saved_position = p["position"]
	player.bed_position = p.get("bed", Vector3.INF)
	player.rotation.y = p["yaw"]
	player._pitch = p["pitch"]
	player.camera.rotation.x = p["pitch"]
	player.survival.health = p["health"]
	player.survival.hunger = p["hunger"]
	var slots: Array = p["inventory"]
	for i in mini(slots.size(), Inventory.SIZE):
		player.inventory.slots[i] = slots[i]
	player.inventory.fuel = p.get("fuel", 0)
	player.get_parent().pending_allies = data.get("allies", [])
	player.inventory.changed.emit()
	player.survival.changed.emit()
