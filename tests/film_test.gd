extends SceneTree
## Film Stüdyosu: tüm bölümler hızlı modda baştan sona hatasız oynuyor mu, noktalar set içinde mi.

func _init() -> void:
	var studio: FilmStudio = load("res://scenes/film.tscn").instantiate()
	studio.fast = true
	root.add_child(studio)
	await process_frame
	var fails := 0
	var sets: FilmSets = studio.world.generator
	for set_id in FilmSets.POINTS:
		for p in FilmSets.POINTS[set_id]:
			var pos := FilmSets.point(set_id + "." + p)
			# Bodrum gibi oyulmuş yer altı noktaları serbest.
			if pos.y < FilmSets.GROUND and not sets.is_air(Vector3i(pos.floor())):
				fails += 1
				print("FAIL nokta yerin altında: ", set_id, ".", p)
	# Karakterlerin durduğu noktalar eşyaların içinde olmasın (yerdeki noktalar; kameralar ve yatak üstü hariç).
	for set_id in FilmSets.POINTS:
		for p: String in FilmSets.POINTS[set_id]:
			if p.begins_with("kam") or fposmod(FilmSets.POINTS[set_id][p].y, 5.0) > 0.0 and fposmod(FilmSets.POINTS[set_id][p].y, 5.0) < 1.0:
				continue
			var pos := FilmSets.point(set_id + "." + p)
			if not sets.is_free(Vector3i(floori(pos.x), floori(pos.y), floori(pos.z))):
				fails += 1
				print("FAIL nokta eşyanın içinde: ", set_id, ".", p)
	# Senaryolardaki her set noktası gerçekten tanımlı mı (yoksa oyun o adımda hata verir, test yine geçerdi).
	for ep: Dictionary in Episodes.LIST:
		if not FilmSets.SETS.has(ep["set"]):
			fails += 1
			print("FAIL bilinmeyen set: ", ep["set"])
		for step: Dictionary in ep["steps"]:
			for key in ["at", "look", "to", "cam"]:
				var v = step.get(key)
				if v is String:
					var parts := String(v).split(".")
					if parts.size() != 2 or not FilmSets.POINTS.has(parts[0]) or not FilmSets.POINTS[parts[0]].has(parts[1]):
						fails += 1
						print("FAIL tanımsız nokta: ", ep["id"], " ", v)
	# Aynı id'li iki bölüm olursa Episodes.find hep ilkini döndürür, ikincisi hiç oynamaz.
	var seen := {}
	for ep: Dictionary in Episodes.LIST:
		if seen.has(ep["id"]):
			fails += 1
			print("FAIL tekrarlanan bölüm id: ", ep["id"])
		seen[ep["id"]] = true
	for set_id in FilmSets.SETS:
		if not FilmSets.POINTS.has(set_id):
			fails += 1
			print("FAIL noktasız set: ", set_id)
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
	if studio.route_failures > 0:
		fails += 1
		print("FAIL eşyalara takılmadan yol bulunamayan yürüyüş: ", studio.route_failures)
	# Yatak seti gerçekten evde mi?
	if studio.world.get_block(Vector3i(FilmSets.SETS["ev"]) + Vector3i(1, 5, 1)) != Blocks.BED:
		fails += 1
		print("FAIL evde yatak yok")
	print("FILM TEST ", "PASS" if fails == 0 else "FAIL %d" % fails)
	quit(fails)
