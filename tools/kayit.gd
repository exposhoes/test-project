extends SceneTree
## Bir bölümü baştan sona oynatıp çıkar; Godot'nun film kaydedicisiyle (--write-movie) videoya çekilir:
##   godot --path . --write-movie cikti.avi --fixed-fps 30 --script res://tools/kayit.gd -- <bölüm_id>
## "--liste" verilirse bölümleri "id|format|ad" olarak yazıp çıkar. Kullanım: tools/kayit.ps1


func _init() -> void:
	var args := OS.get_cmdline_user_args()
	if args.is_empty() or args[0] == "--liste":
		for ep: Dictionary in Episodes.LIST:
			print("BOLUM|%s|%s|%s" % [ep["id"], ep.get("format", "short"), ep["name"]])
		quit()
		return
	var studio: FilmStudio = load("res://tools/kayit_studyo.gd").new()
	root.add_child(studio)
	await process_frame
	await studio.play(args[0])
	print("KAYIT BITTI: ", args[0])
	quit()
