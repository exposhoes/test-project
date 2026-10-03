extends SceneTree
## Ham bir .glb'yi (ölçeği değiştirmeden ya da verilen yükseklikte) ev setinde yandan gösterir ve mesh sınırlarını yazar:
##   godot --path . --script res://tests/prop_preview.gd -- cikti.png res://assets/models/x.glb [yukseklik]

func _initialize() -> void:
	var args := OS.get_cmdline_user_args()
	var out: String = args[0]
	var path: String = args[1]
	var height := float(args[2]) if args.size() > 2 else 0.0
	var studio: FilmStudio = load("res://scenes/film.tscn").instantiate()
	root.add_child(studio)
	await process_frame
	studio._panel.visible = false
	studio.set_time(0.3)
	var base := FilmSets.point("ev.yatak") + Vector3(3.5, -0.42, 2.8)
	var m: Node3D = load(path).instantiate()
	var holder := Node3D.new()
	holder.add_child(m)
	studio.world.add_child(holder)
	var box := AABB()
	var first := true
	for c in m.find_children("*", "MeshInstance3D", true, false):
		var mi := c as MeshInstance3D
		var t := Transform3D.IDENTITY
		var p: Node = mi
		while p != m.get_parent() and p is Node3D:
			t = (p as Node3D).transform * t
			p = p.get_parent()
		var b: AABB = t * mi.get_aabb()
		print(mi.name, " ", b.position, " ", b.size)
		box = b if first else box.merge(b)
		first = false
	print("TOPLAM ", box.position, " ", box.size)
	var k := height / box.size.y if height > 0.0 else 1.0
	m.scale = Vector3.ONE * k
	m.position = Vector3(-box.get_center().x * k, -box.position.y * k, -box.get_center().z * k)
	holder.position = base
	var sz := maxf(box.size.x, box.size.z) * k
	studio._move_camera(base + Vector3(sz * 0.6, sz * 0.4 + 0.7, sz * 1.3 + 0.8), base + Vector3(0, box.size.y * k * 0.4, 0), 0)
	while not studio.world.is_meshed_at(base):
		await process_frame
	for i in 60:
		await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(out)
	quit()
