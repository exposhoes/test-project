extends FilmStudio
## Bilgisayarda otomatik video kaydı için Film Stüdyosu (tools/kayit.ps1 kullanır).
## Menü göstermez, pencere boyutuna dokunmaz (kayıt baştan doğru boyutta açılır) ve
## telefonun metin okuma motorunu kullanmaz: kayıtta yalnızca ses dosyaları duyulur.


func _ready() -> void:
	super._ready()
	# Film kaydı gerçek zamanlı akmaz; işletim sisteminin sesi kayda girmez ve zamanlamayı bozar.
	voice._voice_id = ""
	_panel.visible = false


## Kayıtta menü yok: bölüm bitince kayıt betiği çıkar.
func _show_menu(_format := "", _page := 0) -> void:
	_panel.visible = false


## Sadece yazı düzenini dikey/yatay ekrana göre ayarlar.
func set_portrait(on: bool) -> void:
	_box.anchor_left = 0.04 if on else 0.12
	_box.anchor_right = 0.96 if on else 0.88
	_box.offset_top = -330 if on else -210
	_box.offset_bottom = -90 if on else -64
	_title.add_theme_font_size_override("font_size", 44 if on else 64)
	_title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART if on else TextServer.AUTOWRAP_OFF


## "Kayıt için hazırlan" geri sayımı videoda görünmesin.
func _show_title(text: String) -> void:
	if text.begins_with("Kayıt için hazırlan"):
		return
	super._show_title(text)
