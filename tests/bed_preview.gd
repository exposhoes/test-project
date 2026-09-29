extends SceneTree
## Yatak modelini film setinde gösterir (görüntü sürücüsü gerekir):
##   godot --path . --script res://tests/bed_preview.gd -- cikti.png

func _initialize() -> void:
	var out := "user://bed_preview.png"
	var args := OS.get_cmdline_user_args()
	if not args.is_empty():
		out = args[0]
	var studio: FilmStudio = load("res://scenes/film.tscn").instantiate()
	root.add_child(studio)
	await process_frame
	studio._panel.visible = false
	studio.set_time(0.3)
	if not args.has("bos"):  # "bos": yatağı karaktersiz göster
		var emir := studio._actor("emir")
		emir.position = FilmSets.point("ev.yatak")
		emir.set_lying(true)
		emir.face_towards(FilmSets.point("ev.yatak") + Vector3(0, 0, -1))
	var cam_pos := FilmSets.point("ev.yatak") + Vector3(2.4, 1.6, 2.2)
	var look := FilmSets.point("ev.yatak") + Vector3(0, 0.1, 0)
	if args.has("oda"):  # "oda": sandıkları da gören geniş açı
		cam_pos = FilmSets.point("ev.yatak") + Vector3(3.2, 1.9, 4.6)
		look = FilmSets.point("ev.yatak") + Vector3(0.6, 0, 0.6)
	studio._move_camera(cam_pos, look, 0)
	while not studio.world.is_meshed_at(FilmSets.point("ev.yatak")):
		await process_frame
	for i in 60:
		await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(out)
	print("saved ", out)
	quit()
