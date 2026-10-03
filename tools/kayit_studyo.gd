extends FilmStudio
## Bilgisayarda otomatik video kaydı için Film Stüdyosu (tools/kayit.ps1 kullanır).
## Menü göstermez, pencere boyutuna dokunmaz (kayıt baştan doğru boyutta açılır) ve
## telefonun metin okuma motorunu kullanmaz: kayıtta yalnızca ses dosyaları duyulur.
## Videolarda altyazı (diyalog kutusu) yoktur: konuşmalar seslendirmeyle duyulur.

## Kayıtta görüş mesafesi (chunk): şehrin uzak binaları da çizilsin, ufukta boşluk kalmasın.
const KAYIT_GORUS := 10


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
	# Mehmet: "arkadaki siyahlıklar kare kare geliyor". Kayıt gerçek zamanlı olmadığı için her karede
	# bekleyen bütün chunk'lar hemen çizilir (parça parça belirme olmaz) ve görüş mesafesi geniştir.
	world.threaded = false
	world.meshes_per_frame = 4096
	world.set_render_distance(KAYIT_GORUS)
	camera.far = 420.0
	# Görüş mesafesinin ötesi koyu kahverengi görünmesin: ufkun altı çimen yeşili.
	_sky.ground_horizon_color = Color("7fb069")
	_sky.ground_bottom_color = Color("5f9a4f")


## Kayıtta menü yok: bölüm bitince kayıt betiği çıkar.
func _show_menu(_format := "", _page := 0) -> void:
	_panel.visible = false
