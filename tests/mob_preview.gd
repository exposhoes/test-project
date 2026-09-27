extends SceneTree
## Yaratık modellerini yakından görüntüler (görüntü sürücüsü gerekir):
##   godot --path . --script res://tests/mob_preview.gd -- cikti.png tokmak tuylupasa

func _initialize() -> void:
	var args := OS.get_cmdline_user_args()
	var out := args[0] if not args.is_empty() else "user://mob_preview.png"
	var ids := args.slice(1) if args.size() > 1 else PackedStringArray(MobData.MOBS.keys())
	var scene := Node3D.new()
	root.add_child(scene)
	var env := WorldEnvironment.new()
	env.environment = Environment.new()
	env.environment.background_mode = Environment.BG_COLOR
	env.environment.background_color = Color("a8d4f5")
	env.environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.environment.ambient_light_color = Color.WHITE
	env.environment.ambient_light_energy = 0.6
	scene.add_child(env)
	var sun := DirectionalLight3D.new()
	sun.rotation = Vector3(deg_to_rad(-50), deg_to_rad(20), 0)
	scene.add_child(sun)
	var spacing := 1.6
	for i in ids.size():
		var mob := Mob.create(ids[i])
		mob.set_physics_process(false)
		scene.add_child(mob)
		mob.position = Vector3((i - (ids.size() - 1) / 2.0) * spacing, 0, 0)
		mob.rotation.y = PI + deg_to_rad(20)
	var cam := Camera3D.new()
	scene.add_child(cam)
	await process_frame
	cam.look_at_from_position(Vector3(0, 1.4, 2.4 + ids.size() * 0.6), Vector3(0, 1.0, 0))
	for i in 5:
		await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(out)
	quit()
