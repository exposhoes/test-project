extends SceneTree
## Başsız duman testi:
##   godot --headless --path . --script res://tests/smoke_test.gd
## Ana sahneyi açar, oyuncunun doğmasını bekler, blok kırma/koyma ve ışın izlemeyi dener.

const MAX_FRAMES := 600

var _failures := 0


func _initialize() -> void:
	var main: Node = load("res://scenes/main.tscn").instantiate()
	root.add_child(main)
	var player: Player = main.player
	var world: World = main.world

	var frames := 0
	while not player.is_spawned() and frames < MAX_FRAMES:
		await process_frame
		frames += 1
	_check(player.is_spawned(), "oyuncu %d karede doğmalı" % frames)

	for i in 30:
		await physics_frame
	_check(player.is_on_floor(), "oyuncu zemine basmalı (y=%.2f)" % player.global_position.y)

	var below := Vector3i(player.global_position.floor()) + Vector3i(0, -1, 0)
	_check(Blocks.is_solid(world.get_block(below)), "oyuncunun altında katı blok olmalı")

	var test_pos := Vector3i(3, 60, 3)
	world.set_block(test_pos, Blocks.BRICKS)
	_check(world.get_block(test_pos) == Blocks.BRICKS, "set_block/get_block tutarlı olmalı")
	world.set_block(test_pos, Blocks.AIR)

	player.camera.rotation.x = deg_to_rad(-89)
	var hit := player.raycast_block()
	_check(not hit.is_empty() and hit["hit"] == below, "aşağı bakınca ayak altındaki blok seçilmeli: %s" % [hit])

	var mob := Mob.create("tokmak")
	root.add_child(mob)
	_check(mob.get_child_count() > 0, "yaratık modeli kurulmalı")
	_check(MobData.MOBS.size() == 20, "20 yaratık tanımlı olmalı")

	print("SMOKE TEST: ", "BAŞARILI" if _failures == 0 else "%d HATA" % _failures)
	quit(1 if _failures > 0 else 0)


func _check(ok: bool, message: String) -> void:
	if ok:
		print("  ok  ", message)
	else:
		_failures += 1
		printerr("  FAIL ", message)
