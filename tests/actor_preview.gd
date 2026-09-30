extends SceneTree
## Karakteri film setinde önden, yandan ve arkadan gösterir (görüntü sürücüsü gerekir):
##   godot --path . --script res://tests/actor_preview.gd -- cikti.png emir

func _initialize() -> void:
	var args := OS.get_cmdline_user_args()
	var out: String = args[0] if args.size() > 0 else "user://actor_preview.png"
	var id: String = args[1] if args.size() > 1 else "emir"
	var studio: FilmStudio = load("res://scenes/film.tscn").instantiate()
	root.add_child(studio)
	await process_frame
	studio._panel.visible = false
	studio.set_time(0.3)
	var base := FilmSets.point("ev.yatak") + Vector3(3.5, -0.42, 2.8)
	for i in 3:
		var a := Actor.create(id)
		studio.world.add_child(a)
		a.position = base + Vector3((i - 1) * 1.15, 0, 0)
		a.rotation.y = [PI, -PI / 2.0, 0.0][i]
	var cam := base + Vector3(0, 1.1, 2.5)
	studio._move_camera(cam, base + Vector3(0, 0.95, 0), 0)
	while not studio.world.is_meshed_at(base):
		await process_frame
	for i in 50:
		await process_frame
	if args.has("yuru"):  # "yuru": yürüme anı (kol/bacak sallanır) ve gözler kapalı
		for a in studio.world.get_children():
			if a is Actor:
				a._moving = true
				a._walk_phase = 1.3
				a._blink_timer = 0.11
		for i in 3:
			await process_frame
		for a in studio.world.get_children():
			if a is Actor:
				a.set_process(false)
				for lid in a._lids:
					lid.visible = true  # göz kırpma anı
	else:
		for i in 10:
			await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(out)
	print("saved ", out)
	quit()
