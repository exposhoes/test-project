extends FilmStudio
## Bilgisayarda otomatik video kaydı için Film Stüdyosu (tools/kayit.ps1 kullanır).
## Menü göstermez, pencere boyutuna dokunmaz (kayıt baştan doğru boyutta açılır) ve
## telefonun metin okuma motorunu kullanmaz: kayıtta yalnızca ses dosyaları duyulur.
## Videolarda altyazı (diyalog kutusu) yoktur: konuşmalar seslendirmeyle duyulur.


func _ready() -> void:
	# Pencere boyutu sabit kalsın (set_portrait bunu recording ile atlar).
	recording = true
	super._ready()
	# Film kaydı gerçek zamanlı akmaz; işletim sisteminin sesi kayda girmez ve zamanlamayı bozar.
	voice._voice_id = ""
	_panel.visible = false
	# Mehmet'in isteği: videolarda altyazı kutusu olmasın. Kutu çalışmaya devam eder (replik süreleri
	# aynı kalsın diye) ama görünmez.
	_box.modulate.a = 0.0


## Kayıtta menü yok: bölüm bitince kayıt betiği çıkar.
func _show_menu(_format := "", _page := 0) -> void:
	_panel.visible = false
