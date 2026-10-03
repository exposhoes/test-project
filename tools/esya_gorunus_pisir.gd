extends SceneTree
## Eşya PNG'lerini (assets/textures/esya/<ad>.png) görünüşlerine ayırıp
## assets/textures/esya/gorunus/<ad>_<n>.res olarak kaydeder. PNG değişince yeniden çalıştır:
## godot --headless --path . --script res://tools/esya_gorunus_pisir.gd


func _initialize() -> void:
	var dir := DirAccess.open("res://assets/textures/esya")
	var n := 0
	for f in dir.get_files():
		if not f.ends_with(".png"):
			continue
		var id := f.get_basename()
		var tex = load("res://assets/textures/esya/" + f)
		if not tex is Texture2D:
			continue
		var img: Image = (tex as Texture2D).get_image()
		if img.is_compressed():
			img.decompress()
		img.convert(Image.FORMAT_RGBA8)
		var parts: Array = FilmProps._split_views(img)
		for i in parts.size():
			ResourceSaver.save(parts[i], FilmProps.BAKED_VIEWS % [id, i], ResourceSaver.FLAG_COMPRESS)
		n += 1
	print("pişirilen eşya: ", n)
	quit()
