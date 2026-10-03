extends SceneTree
## tools/art/build_heads.py çıktısı olan <kod>_head.bin dosyalarını Godot kaynağına (<kod>_head.res,
## doku gömülü ArrayMesh) çevirir. Kaynaklar Android paketine otomatik girer; .bin girmez.
##   godot --headless --path . --script res://tools/bake_heads.gd

func _initialize() -> void:
	var dir := "res://assets/textures/actors/"
	for f in DirAccess.get_files_at(dir):
		if not f.ends_with("_head.bin"):
			continue
		var code := f.trim_suffix("_head.bin")
		var mesh := Actor._load_head(dir + f, dir + code + "_head.png")
		var err := ResourceSaver.save(mesh, dir + code + "_head.res")
		print(code, " -> ", error_string(err))
	quit()
