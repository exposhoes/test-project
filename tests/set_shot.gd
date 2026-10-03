extends SceneTree
## Bir set noktasından ekran görüntüsü: godot --path . --script res://tests/set_shot.gd -- cikti.png bakkal.kam_ic bakkal.tezgah_on [mood] [saat]

func _initialize() -> void:
	var args := OS.get_cmdline_user_args()
	var studio: FilmStudio = load("res://scenes/film.tscn").instantiate()
	root.add_child(studio)
	await process_frame
	studio._panel.visible = false
	studio.set_time(float(args[4]) if args.size() > 4 else 0.4)
	if args.size() > 3 and args[3] != "":
		studio.set_mood(args[3])
	if args.size() > 5 and args[5] == "sandik":
		studio._spawn_prop({"spawn": "sandik", "prop": "sandik", "at": "orman.sandik", "light": [Color("ff8a1f"), 2.4, 6.0]})
		studio._spawn_prop({"spawn": "iksir", "prop": "iksir", "decor": true, "at": "orman.masa_iksir"})
	var cam := FilmSets.point(args[1])
	var look := FilmSets.point(args[2]) + Vector3(0, 1.0, 0)
	studio._move_camera(cam, look, 0)
	studio.world.update_center(cam)
	while not studio.world.is_meshed_at(cam):
		await process_frame
	for i in 90:
		await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(args[0])
	quit()
