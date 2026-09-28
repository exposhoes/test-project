extends SceneTree
## Başsız duman testi:
##   godot --headless --path . --script res://tests/smoke_test.gd
## Ana sahneyi açar, oyuncunun doğmasını bekler; blok, ışın izleme ve hayatta kalma sistemini dener.

const MAX_FRAMES := 600

var _failures := 0


func _initialize() -> void:
	var main: Node = load("res://scenes/main.tscn").instantiate()
	Settings.path = ""
	main.save_path = ""
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

	# Envanter: kırılan blok yere düşer, oyuncu toplar, koyunca bir tane harcanır.
	var inv := player.inventory
	_check(inv.item_at(0) == Blocks.AIR, "oyun boş envanterle başlamalı")
	var broken_id := world.get_block(below)
	var expected := Items.drop_for_block(broken_id)
	player._target = hit
	player.break_target()
	_check(world.get_block(below) == Blocks.AIR, "kırılan blok yok olmalı")
	_check(get_nodes_in_group("item_drops").size() == 1, "kırılan bloktan eşya düşmeli")
	for i in 90:
		await physics_frame
	_check(inv.count_of(expected) == 1 and get_nodes_in_group("item_drops").is_empty(),
		"düşen eşya toplanmalı (%s: %d)" % [Items.display_name(expected), inv.count_of(expected)])
	for i in 30:
		await physics_frame
	var place_pos := Vector3i(player.global_position.floor()) + Vector3i(2, 3, 0)
	player._target = {"hit": place_pos + Vector3i.DOWN, "place": place_pos}
	player.use_selected()
	_check(world.get_block(place_pos) == expected and inv.count_of(expected) == 0, "koyunca envanterden bir blok harcanmalı")
	world.set_block(place_pos, Blocks.AIR)
	inv.add(Blocks.STONE, 70)
	_check(inv.count_at(0) == 64 and inv.count_at(1) == 6, "yığınlar 64'te dolup sonraki yuvaya geçmeli")
	inv.add(Items.APPLE, 1)
	player.survival.hunger = 10
	player.hud._select(2)
	player.use_selected()
	_check(player.survival.hunger == 14 and inv.count_of(Items.APPLE) == 0, "elma yenince açlık dolmalı")

	# Üretim ve aletler: taş kazmasız bir şey bırakmaz, kütükten tahta, masada kazma.
	for i in Inventory.SIZE:
		inv.slots[i] = {}
	player.hud.select_slot(0)
	_check(not Items.harvests(Blocks.STONE, Blocks.AIR) and Items.harvests(Blocks.STONE, Items.WOOD_PICKAXE), "taş için kazma gerekmeli")
	_check(Items.break_time(Blocks.STONE, Items.STONE_PICKAXE) < Items.break_time(Blocks.STONE, Blocks.AIR), "kazma taşı daha hızlı kırmalı")
	_check(not Items.harvests(Blocks.IRON_ORE, Items.WOOD_PICKAXE) and Items.harvests(Blocks.IRON_ORE, Items.STONE_PICKAXE), "demir madeni taş kazma istemeli")
	inv.add(Blocks.LOG, 3)
	var recipes := {}
	for r in Items.RECIPES:
		recipes[r["out"]] = r
	_check(inv.craft(recipes[Blocks.PLANKS]) and inv.count_of(Blocks.PLANKS) == 4, "1 kütükten 4 tahta çıkmalı")
	inv.craft(recipes[Blocks.PLANKS])
	inv.craft(recipes[Blocks.PLANKS])
	_check(inv.craft(recipes[Items.STICK]) and inv.count_of(Items.STICK) == 4, "2 tahtadan 4 çubuk çıkmalı")
	_check(inv.craft(recipes[Blocks.CRAFTING_TABLE]), "4 tahtadan çalışma masası çıkmalı")
	_check(inv.craft(recipes[Items.WOOD_PICKAXE]) and inv.count_of(Items.WOOD_PICKAXE) == 1 and inv.count_of(Blocks.PLANKS) == 3,
		"kazma üretilmeli ve malzemeler harcanmalı (tahta=%d)" % inv.count_of(Blocks.PLANKS))
	inv.remove(Blocks.PLANKS, 1)
	_check(not inv.craft(recipes[Items.WOOD_PICKAXE]) and inv.count_of(Blocks.PLANKS) == 2, "malzeme yetmeyince üretilmemeli")
	_check(not player.near_crafting_table(), "başta yakında masa olmamalı")
	var table_pos := Vector3i(player.global_position.floor()) + Vector3i(2, 0, 0)
	world.set_block(table_pos, Blocks.CRAFTING_TABLE)
	_check(player.near_crafting_table(), "masa koyunca yakında algılanmalı")
	world.set_block(table_pos, Blocks.AIR)
	var pick_slot := -1
	for i in Inventory.SIZE:
		if inv.item_at(i) == Items.WOOD_PICKAXE:
			pick_slot = i
	inv.swap(pick_slot, 0)
	_check(player.held_item() == Items.WOOD_PICKAXE, "seçili yuvadaki kazma elde olmalı")
	player.hud.open_inventory()
	_check(player.hud.is_menu_open(), "çanta açılmalı")
	player.hud.close_inventory()

	# Dayanıklılık: her kullanım bir hak götürür, hak bitince alet kırılır.
	var full := Items.max_uses(Items.WOOD_PICKAXE)
	_check(inv.uses_at(0) == full, "yeni kazmanın hakkı dolu olmalı")
	player.wear_held()
	_check(inv.uses_at(0) == full - 1, "kullanınca hak azalmalı")
	inv.slots[0]["uses"] = 1
	player.wear_held()
	_check(inv.item_at(0) == Blocks.AIR, "hakkı biten kazma kırılmalı")
	_check(not inv.wear(1), "alet olmayan eşya aşınmamalı")

	# Fırın: ham demir yakıtla demire dönüşür; kömür 8 eritmeye yeter.
	for i in Inventory.SIZE:
		inv.slots[i] = {}
	_check(Items.drop_for_block(Blocks.IRON_ORE) == Items.RAW_IRON, "demir madeni ham demir bırakmalı")
	var smelt := {}
	for r in Items.SMELTING:
		smelt[r["out"]] = r
	inv.add(Items.RAW_IRON, 2)
	_check(not inv.can_smelt(smelt[Items.IRON]), "yakıtsız eritilmemeli")
	inv.add(Items.COAL, 1)
	_check(inv.smelt(smelt[Items.IRON]) and inv.count_of(Items.IRON) == 1 and inv.count_of(Items.COAL) == 0 and inv.fuel == 7,
		"kömür yakılıp demir çıkmalı (yakıt=%d)" % inv.fuel)
	_check(inv.smelt(smelt[Items.IRON]) and inv.count_of(Items.IRON) == 2 and inv.fuel == 6, "kalan yakıtla eritmeli")
	inv.fuel = 0
	inv.add(Blocks.LOG, 1)
	_check(not inv.can_smelt(smelt[Items.COAL]), "tek kütük hem yakıt hem malzeme olamamalı")
	inv.add(Blocks.LOG, 1)
	_check(inv.smelt(smelt[Items.COAL]) and inv.count_of(Blocks.LOG) == 0 and inv.fuel == 2, "kütükten kömür eritilmeli")
	_check(not player.near_block(Blocks.FURNACE), "başta yakında fırın olmamalı")
	world.set_block(table_pos, Blocks.FURNACE)
	_check(player.near_block(Blocks.FURNACE), "fırın koyunca algılanmalı")
	player.hud.open_inventory()
	_check(player.hud._inventory_screen.tab == 1, "fırın yanında çanta Fırın sekmesiyle açılmalı")
	player.hud.close_inventory()
	world.set_block(table_pos, Blocks.AIR)
	inv.fuel = 0
	for i in Inventory.SIZE:
		inv.slots[i] = {}

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

	# Dostlar: demir verilen Mercek evcilleşir, oyuncuya vurulmaz, düşmana saldırır.
	for m in get_nodes_in_group("mobs"):
		m.free()
	var ally := Mob.create("mercek")
	main.add_child(ally)
	player.camera.rotation.x = 0.0
	ally.global_position = player.global_position - player.global_transform.basis.z * 1.5
	ally.set_physics_process(false)
	player.hud.select_slot(0)
	inv.add(Items.IRON, 1)
	player.look_at(Vector3(ally.global_position.x, player.global_position.y, ally.global_position.z))
	_check(player.try_tame(), "dosta demir verilebilmeli")
	_check(ally.tamed and ally.is_in_group("allies") and inv.count_of(Items.IRON) == 0, "demir verilen Mercek evcilleşmeli")
	_check(not player.attack(), "evcil dosta vurulmamalı")
	var enemy := Mob.create("lavabo")
	main.add_child(enemy)
	enemy.global_position = ally.global_position + Vector3(0.8, 0, 0)
	enemy.set_physics_process(false)
	ally.set_physics_process(true)
	var enemy_health := enemy.health
	for i in 30:
		await physics_frame
	_check(not is_instance_valid(enemy) or enemy.health < enemy_health, "evcil dost yakındaki düşmana saldırmalı")
	if is_instance_valid(enemy):
		_check(enemy.target == ally, "vurulan düşman dosta dönmeli")
		enemy.free()
	ally.global_position = player.global_position + Vector3(40, 0, 0)
	await physics_frame
	await physics_frame
	_check(ally.global_position.distance_to(player.global_position) < 5.0, "çok uzaklaşan dost oyuncunun yanına gelmeli")
	ally.free()

	# Sarı Koridorlar: kapıya Koy ile geçilir, dönüşte kapının önüne gelinir.
	var portal_pos := Vector3i(player.global_position.floor()) + Vector3i(0, 0, -2)
	player.rotation = Vector3.ZERO
	player.camera.rotation.x = deg_to_rad(-15)
	world.set_block(portal_pos, Blocks.HALLS_PORTAL)
	world.set_block(portal_pos + Vector3i(0, 1, 0), Blocks.HALLS_PORTAL)
	await physics_frame
	await process_frame
	await process_frame
	player._target = player.raycast_block()
	var went := [false]
	player.used_portal.connect(func() -> void: went[0] = true, CONNECT_ONE_SHOT)
	player.used_portal.disconnect(main.travel)
	player.use_selected()
	player.used_portal.connect(main.travel)
	_check(went[0], "kapıya bakıp Koy'a basınca geçiş olmalı")
	var before_pos := player.global_position
	main.travel()
	var frames3 := 0
	while not player.is_spawned() and frames3 < MAX_FRAMES:
		await process_frame
		frames3 += 1
	world = main.world
	_check(main.dimension == Dimension.HALLS and world.dimension == Dimension.HALLS, "Sarı Koridorlar'a geçilmeli")
	_check(player.is_spawned() and absf(player.global_position.y - HallsGenerator.FLOOR) < 1.0, "koridor zemininde doğmalı (y=%.1f)" % player.global_position.y)
	_check(world.get_block(HallsGenerator.EXIT_PORTAL) == Blocks.HALLS_PORTAL, "başlangıç odasında dönüş kapısı olmalı")
	_check(MobData.ids_for(MobData.Habitat.YELLOW_HALLS, true).size() >= 3, "koridorlarda yaratık olmalı")
	main.travel()
	frames3 = 0
	while not player.is_spawned() and frames3 < MAX_FRAMES:
		await process_frame
		frames3 += 1
	world = main.world
	_check(main.dimension == Dimension.OVERWORLD and player.global_position.distance_to(before_pos) < 1.0, "yeryüzünde kapının önüne dönülmeli")
	_check(world.get_block(portal_pos) == Blocks.HALLS_PORTAL, "yeryüzündeki kapı yerinde kalmalı")

	# Duraklatma ve ana menü.
	player.hud.open_pause()
	_check(paused and player.hud.is_menu_open(), "duraklatınca oyun durmalı")
	player.hud._show_settings()
	var settings_buttons := player.hud._pause_menu._buttons
	_check(settings_buttons.size() == 3, "ayarlar menüsünde 3 düğme olmalı")
	var speed := Settings.look_speed
	settings_buttons[0]["action"].call()
	_check(Settings.look_speed != speed, "bakış hızı değişmeli")
	settings_buttons = player.hud._pause_menu._buttons
	settings_buttons[1]["action"].call()
	_check(world.render_distance == Settings.view_distance and Settings.view_distance == 6, "görüş mesafesi dünyaya uygulanmalı (%d)" % world.render_distance)
	Settings.view_distance = Settings.BASE_VIEW
	main.apply_settings()
	player.hud._pause_menu._buttons[2]["action"].call()
	_check(player.hud._pause_menu.title == "Duraklatıldı", "Geri ile duraklatma menüsüne dönülmeli")
	player.hud.close_pause()
	_check(not paused, "devam edince oyun sürmeli")
	var menu: Node = load("res://scenes/menu.tscn").instantiate()
	root.add_child(menu)
	await process_frame
	_check(menu._panel._buttons.size() >= 1, "ana menüde düğme olmalı")
	menu.free()

	print("SMOKE TEST: ", "BAŞARILI" if _failures == 0 else "%d HATA" % _failures)
	quit(1 if _failures > 0 else 0)


func _check(ok: bool, message: String) -> void:
	if ok:
		print("  ok  ", message)
	else:
		_failures += 1
		printerr("  FAIL ", message)
