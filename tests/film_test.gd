extends SceneTree
## Film Stüdyosu: tüm bölümler hızlı modda baştan sona hatasız oynuyor mu, noktalar set içinde mi.

func _init() -> void:
	var studio: FilmStudio = load("res://scenes/film.tscn").instantiate()
	studio.fast = true
	root.add_child(studio)
	await process_frame
	var fails := 0
	for set_id in FilmSets.POINTS:
		for p in FilmSets.POINTS[set_id]:
			var pos := FilmSets.point(set_id + "." + p)
			if pos.y < FilmSets.GROUND:
				fails += 1
				print("FAIL nokta yerin altında: ", set_id, ".", p)
	for ep: Dictionary in Episodes.LIST:
		await studio.play(ep["id"])
		if studio.playing:
			fails += 1
			print("FAIL bitmedi: ", ep["id"])
		for step: Dictionary in ep["steps"]:
			for key in ["say", "place", "walk", "turn", "lie"]:
				if step.has(key) and step[key] is String and not Actor.ACTORS.has(step[key]):
					fails += 1
					print("FAIL bilinmeyen karakter: ", step[key])
		print("ok ", ep["id"])
	# Yatak seti gerçekten evde mi?
	if studio.world.get_block(Vector3i(FilmSets.SETS["ev"]) + Vector3i(1, 0, 1)) != Blocks.BED:
		fails += 1
		print("FAIL evde yatak yok")
	print("FILM TEST ", "PASS" if fails == 0 else "FAIL %d" % fails)
	quit(fails)
