extends SceneTree
## Bir .glb modelini film setinde önden, yandan ve arkadan gösterir:
##   godot --path . --script res://tests/model_preview.gd -- cikti.png res://assets/models/emir.glb

func _initialize() -> void:
	var args := OS.get_cmdline_user_args()
	var out: String = args[0]
	var path: String = args[1]
	var studio: FilmStudio = load("res://scenes/film.tscn").instantiate()
	root.add_child(studio)
	await process_frame
	studio._panel.visible = false
	studio.set_time(0.3)
	var base := FilmSets.point("ev.yatak") + Vector3(3.5, -0.42, 2.8)
	for i in 3:
		var m: Node3D = load(path).instantiate()
		var holder := Node3D.new()
		holder.add_child(m)
		studio.world.add_child(holder)
		# ~1.8 birim boy
		var aabb := _aabb(m)
		var k := 1.8 / maxf(aabb.size.y, 0.001)
		m.scale = Vector3.ONE * k
		m.position = Vector3(-aabb.get_center().x * k, -aabb.position.y * k, -aabb.get_center().z * k)
		holder.position = base + Vector3((i - 1) * 1.15, 0, 0)
		holder.rotation.y = [0.0, -PI / 2.0, PI][i]
	studio._move_camera(base + Vector3(0, 1.1, 2.5), base + Vector3(0, 0.95, 0), 0)
	while not studio.world.is_meshed_at(base):
		await process_frame
	for i in 60:
		await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(out)
	print("saved ", out)
	quit()


func _aabb(n: Node) -> AABB:
	var box := AABB()
	var first := true
	for c in n.find_children("*", "MeshInstance3D", true, false):
		var mi := c as MeshInstance3D
		var b: AABB = mi.transform * mi.get_aabb()
		box = b if first else box.merge(b)
		first = false
	return box
