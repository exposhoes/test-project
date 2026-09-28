extends SceneTree
## Dokunmatik kontrollerin yerleşimini masaüstünde görmek için ekran görüntüsü alır:
##   godot --path . --script res://tests/touch_preview.gd -- cikti.png

func _initialize() -> void:
	var args := OS.get_cmdline_user_args()
	var out := args[0] if not args.is_empty() else "user://touch_preview.png"
	var main: Node = load("res://scenes/main.tscn").instantiate()
	root.add_child(main)
	await process_frame
	main.hud.touch.visible = true
	while not main.player.is_spawned():
		await process_frame
	for i in 60:
		await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(out)
	quit()
