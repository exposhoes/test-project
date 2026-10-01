extends FilmStudio
## Bilgisayarda otomatik video kaydı için Film Stüdyosu (tools/kayit.ps1 kullanır).
## Menü göstermez, pencere boyutuna dokunmaz (kayıt baştan doğru boyutta açılır) ve
## telefonun metin okuma motorunu kullanmaz: kayıtta yalnızca ses dosyaları duyulur.


func _ready() -> void:
	# Pencere boyutu sabit kalsın (set_portrait bunu recording ile atlar).
	recording = true
	super._ready()
	# Film kaydı gerçek zamanlı akmaz; işletim sisteminin sesi kayda girmez ve zamanlamayı bozar.
	voice._voice_id = ""
	_panel.visible = false


## Kayıtta menü yok: bölüm bitince kayıt betiği çıkar.
func _show_menu(_format := "", _page := 0) -> void:
	_panel.visible = false
