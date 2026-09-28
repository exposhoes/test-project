extends SceneTree
## Ekran görüntüsü alır (görüntü sürücüsü gerekir, --headless ile çalışmaz):
##   godot --path . --script res://tests/screenshot.gd -- cikti.png

func _initialize() -> void:
	var out := "user://screenshot.png"
	var args := OS.get_cmdline_user_args()
	if not args.is_empty():
		out = args[0]
	var main: Node = load("res://scenes/main.tscn").instantiate()
	main.save_path = ""
	root.add_child(main)
	var player: Player = main.player
	while not player.is_spawned():
		await process_frame
	for i in 240:
		await process_frame
	player.rotate_y(deg_to_rad(35))
	player.camera.rotation.x = deg_to_rad(-12)
	var ahead := player.global_position - player.global_transform.basis.z * 6.0
	for i in 3:
		var mob := Mob.create(["tokmak", "mercek", "lavabo"][i])
		main.add_child(mob)
		var x := floori(ahead.x) + (i - 1) * 3
		var z := floori(ahead.z)
		mob.global_position = Vector3(x + 0.5, main.world.surface_y(x, z), z + 0.5)
		mob.rotation.y = player.rotation.y + PI
		mob.set_physics_process(false)
	for i in 10:
		await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(out)
	print("saved ", out)
	quit()
