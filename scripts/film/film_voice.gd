class_name FilmVoice
extends Node
## Diyalog seslendirmesi. Önce kayıtlı ses dosyasına bakar
## (assets/audio/voices/<bölüm>/<satır>.ogg|.wav|.mp3, satır 01'den başlar);
## yoksa telefonun metin okuma motoruyla (Türkçe) her karaktere farklı ton verip okur.

## Karakter başına ses tonu (pitch 0-2, rate 0.1-10; 1.0 = normal). Çocuklar ince, yetişkinler kalın.
const TONES := {
	"emir": {"pitch": 1.45, "rate": 1.1},
	"ali": {"pitch": 1.3, "rate": 1.2},
	"zeynep": {"pitch": 1.6, "rate": 1.05},
	"anne": {"pitch": 1.15, "rate": 1.0},
	"ogretmen": {"pitch": 1.0, "rate": 0.95},
	"doktor": {"pitch": 0.8, "rate": 0.95},
	"bakkal": {"pitch": 0.65, "rate": 0.9},
}
const VOICE_DIR := "res://assets/audio/voices/"

var enabled := true
var _player := AudioStreamPlayer.new()
var _voice_id := ""


func _ready() -> void:
	add_child(_player)
	for lang in ["tr", "tr_TR", "tr-TR"]:
		var ids := DisplayServer.tts_get_voices_for_language(lang)
		if not ids.is_empty():
			_voice_id = ids[0]
			break
	if _voice_id == "":
		var all := DisplayServer.tts_get_voices()
		if not all.is_empty():
			_voice_id = all[0].get("id", "")


## Bir satırı seslendirir; bitmesini beklemez (speaking() ile sorulur). Ses çıktıysa true döner.
func speak(actor_id: String, text: String, episode_id: String, line: int) -> bool:
	stop()
	if not enabled:
		return false
	var stream := _recorded(episode_id, line)
	if stream:
		_player.stream = stream
		_player.play()
		return true
	if _voice_id == "":
		return false
	var tone: Dictionary = TONES.get(actor_id, {"pitch": 1.0, "rate": 1.0})
	DisplayServer.tts_speak(text, _voice_id, 100, tone["pitch"], tone["rate"])
	return true


## Çalan repliğin süresi (saniye); ses yoksa 0.
func length() -> float:
	return _player.stream.get_length() if _player.playing and _player.stream else 0.0


func speaking() -> bool:
	return _player.playing or (_voice_id != "" and DisplayServer.tts_is_speaking())


func stop() -> void:
	_player.stop()
	if _voice_id != "":
		DisplayServer.tts_stop()


## Mehmet'in kaydettiği ses dosyası varsa onu döner.
func _recorded(episode_id: String, line: int) -> AudioStream:
	for ext in ["ogg", "wav", "mp3"]:
		var path := "%s%s/%02d.%s" % [VOICE_DIR, episode_id, line, ext]
		if ResourceLoader.exists(path):
			return load(path)
	return null
