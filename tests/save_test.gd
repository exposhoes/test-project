extends SceneTree
## Kayıt testi: dünyayı değiştirip kaydeder, oyunu yeniden açıp her şeyin geri geldiğini dener.
##   godot --headless --path . --script res://tests/save_test.gd

const PATH := "user://test_world.save"

var _failures := 0


func _initialize() -> void:
	DirAccess.remove_absolute(ProjectSettings.globalize_path(PATH))
	var main := await _start()
	var player: Player = main.player
	var cell := Vector3i(player.global_position.floor()) + Vector3i(3, 2, 0)
	main.world.set_block(cell, Blocks.BRICKS)
	var dug := Vector3i(player.global_position.floor()) + Vector3i(-2, -1, 0)
	main.world.set_block(dug, Blocks.AIR)
	player.inventory.add(Items.IRON_PICKAXE)
	player.inventory.add(Blocks.PLANKS, 17)
	player.inventory.wear(0, 5)
	player.inventory.fuel = 3
	main.spawn_ally("basbekci", 7)
	player.survival.hunger = 11
	player.global_position += Vector3(0.3, 0, 0.2)
	var pos := player.global_position
	main.time_of_day = 0.8
	var chest_cell := cell + Vector3i(0, 1, 0)
	main.world.set_block(chest_cell, Blocks.CHEST)
	main.world.chest_at(chest_cell).add(Items.RUBY, 3)
	var bed := Vector3(cell) + Vector3(0.5, 1, 0.5)
	player.bed_position = bed
	_check(main.save_game(), "kayıt yazılmalı")
	main.free()

	main = await _start()
	player = main.player
	_check(main.world.get_block(cell) == Blocks.BRICKS, "konan blok geri gelmeli")
	_check(main.world.get_block(dug) == Blocks.AIR, "kazılan blok boş kalmalı")
	_check(main.world.chest_at(chest_cell).count_of(Items.RUBY) == 3, "sandık içeriği geri gelmeli")
	_check(player.bed_position == bed, "yatak doğma noktası geri gelmeli")
	_check(player.inventory.count_of(Items.IRON_PICKAXE) == 1 and player.inventory.count_of(Blocks.PLANKS) == 17, "envanter geri gelmeli")
	_check(player.inventory.uses_at(0) == Items.max_uses(Items.IRON_PICKAXE) - 5 and player.inventory.fuel == 3, "alet hakkı ve yakıt geri gelmeli")
	_check(player.survival.hunger == 11, "açlık geri gelmeli")
	_check(player.global_position.distance_to(pos) < 0.2, "oyuncu kaldığı yerde doğmalı (%s / %s)" % [player.global_position, pos])
	_check(is_equal_approx(main.time_of_day, 0.8) or main.time_of_day > 0.8, "gün saati geri gelmeli")
	for i in 3:
		await process_frame
	var allies := get_nodes_in_group("allies")
	_check(allies.size() == 1 and allies[0].mob_id == "basbekci" and allies[0].health == 7 and allies[0].tamed, "evcil dost geri gelmeli")
	main.free()
	# Koridordayken kaydedilirse orada açılmalı.
	main = await _start()
	main.travel()
	while not main.player.is_spawned():
		await process_frame
	var hall_cell := HallsGenerator.EXIT_PORTAL + Vector3i(0, 1, 0)
	main.world.set_block(hall_cell, Blocks.BRICKS)
	_check(main.save_game(), "koridorda kayıt yazılmalı")
	main.free()
	main = await _start()
	_check(main.dimension == Dimension.HALLS and main.world.get_block(hall_cell) == Blocks.BRICKS, "koridorda açılmalı ve değişiklik kalmalı")
	_check(main.dim_edits.has(Dimension.OVERWORLD) and not main.dim_edits[Dimension.OVERWORLD].is_empty(), "yeryüzü değişiklikleri de saklanmalı")
	main.free()
	DirAccess.remove_absolute(ProjectSettings.globalize_path(PATH))
	print("SAVE TEST: ", "BAŞARILI" if _failures == 0 else "%d HATA" % _failures)
	quit(1 if _failures > 0 else 0)


func _start() -> Node:
	var main: Node = load("res://scenes/main.tscn").instantiate()
	main.save_path = PATH
	root.add_child(main)
	var frames := 0
	while not main.player.is_spawned() and frames < 600:
		await process_frame
		frames += 1
	return main


func _check(ok: bool, message: String) -> void:
	if ok:
		print("  ok  ", message)
	else:
		_failures += 1
		printerr("  FAIL ", message)
