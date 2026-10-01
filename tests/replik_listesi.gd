extends SceneTree
## Tüm bölümlerin repliklerini seslendirme için JSON'a döker:
## godot --headless --path . --script res://tests/replik_listesi.gd -- cikti.json
## Satır numarası film_studio._say ile aynı sayılır (bölüm başına 1'den).


func _init() -> void:
	var out := []
	for ep: Dictionary in Episodes.LIST:
		var n := 0
		for s: Dictionary in ep["steps"]:
			if s.has("say"):
				n += 1
				out.append({"bolum": ep["id"], "satir": n, "kim": s["say"], "metin": s["text"]})
	var args := OS.get_cmdline_user_args()
	var path: String = args[0] if args.size() > 0 else "user://replikler.json"
	var f := FileAccess.open(path, FileAccess.WRITE)
	f.store_string(JSON.stringify(out, "\t"))
	f.close()
	print("replik: ", out.size(), " -> ", path)
	quit()
