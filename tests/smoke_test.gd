extends SceneTree
## Başsız duman testi:
##   godot --headless --path . --script res://tests/smoke_test.gd
## Ana sahneyi açar, oyuncunun doğmasını bekler; blok, ışın izleme ve hayatta kalma sistemini dener.

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

	# Hayatta kalma: hasar, yaratık saldırısı, yaratığa vurma, ölüm ve yeniden doğma.
	var survival := player.survival
	player.hurt(3, player.global_position + Vector3(1, 0, 0))
	_check(survival.health == Survival.MAX_HEALTH - 3, "hurt canı düşürmeli (can=%d)" % survival.health)
	await create_timer(0.6).timeout

	var foe := Mob.create("lavabo")
	foe.target = player
	main.add_child(foe)
	foe.global_position = player.global_position + Vector3(0.9, 0.2, 0)
	var before := survival.health
	for i in 40:
		await physics_frame
	_check(survival.health < before, "düşman yaratık yakındaki oyuncuya vurmalı (%d -> %d)" % [before, survival.health])

	foe.set_physics_process(false)
	player.camera.rotation.x = 0.0
	player.look_at(Vector3(foe.global_position.x, player.global_position.y, foe.global_position.z))
	var foe_health := foe.health
	_check(player.attack(), "oyuncu önündeki yaratığa vurabilmeli")
	_check(foe.health == foe_health - Player.ATTACK_DAMAGE, "vurulan yaratığın canı düşmeli")
	while is_instance_valid(foe) and foe.health > 0:
		foe.take_damage(Player.ATTACK_DAMAGE, player.global_position)
	await process_frame
	_check(not is_instance_valid(foe), "canı biten yaratık yok olmalı")

	await create_timer(0.6).timeout
	survival.take_damage(Survival.MAX_HEALTH)
	_check(survival.dead, "can sıfırlanınca oyuncu ölmeli")
	player.respawn()
	var frames2 := 0
	while not player.is_spawned() and frames2 < MAX_FRAMES:
		await process_frame
		frames2 += 1
	_check(player.is_spawned() and survival.health == Survival.MAX_HEALTH and not survival.dead, "yeniden doğunca can dolu olmalı")

	print("SMOKE TEST: ", "BAŞARILI" if _failures == 0 else "%d HATA" % _failures)
	quit(1 if _failures > 0 else 0)


func _check(ok: bool, message: String) -> void:
	if ok:
		print("  ok  ", message)
	else:
		_failures += 1
		printerr("  FAIL ", message)
