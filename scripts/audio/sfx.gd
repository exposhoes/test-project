class_name Sfx
extends RefCounted
## Ses efektleri ve ortam sesleri. Ses dosyası yoksa sesler koddan sentezlenir;
## res://assets/sounds/<ad>.wav ya da .ogg eklenince otomatik onu kullanır.

const SOUND_DIR := "res://assets/sounds/"
const RATE := 22050
const POOL_SIZE := 8

## Efekt adları; her biri _synth içinde tanımlı.
const NAMES := ["break", "place", "hit", "hurt", "eat", "pickup", "craft", "portal", "tool_break", "chirp", "gas",
	"hum_halls", "music_factory"]

static var _cache := {}
static var _pool: Array[AudioStreamPlayer] = []
static var _next := 0


## Kısa bir efekt çalar (aynı anda en fazla POOL_SIZE ses).
static func play(sound: String, pitch_jitter := 0.08) -> void:
	var tree := Engine.get_main_loop() as SceneTree
	if tree == null or tree.root == null:
		return
	if _pool.is_empty() or not is_instance_valid(_pool[0]):
		_pool.clear()
		for i in POOL_SIZE:
			var p := AudioStreamPlayer.new()
			p.process_mode = Node.PROCESS_MODE_ALWAYS
			tree.root.add_child.call_deferred(p)
			_pool.append(p)
	var player := _pool[_next]
	_next = (_next + 1) % POOL_SIZE
	if not player.is_inside_tree():
		return
	player.stream = stream(sound)
	player.pitch_scale = 1.0 + randf_range(-pitch_jitter, pitch_jitter)
	player.play()


## Sesin akışı (önbellekli). Döngülü ortam sesleri "hum_"/"music_" ile başlar.
static func stream(sound: String) -> AudioStream:
	if _cache.has(sound):
		return _cache[sound]
	var s: AudioStream = null
	for ext in [".ogg", ".wav"]:
		if ResourceLoader.exists(SOUND_DIR + sound + ext):
			s = load(SOUND_DIR + sound + ext)
			break
	if s == null:
		s = _to_wav(_synth(sound), sound.begins_with("hum_") or sound.begins_with("music_"))
	_cache[sound] = s
	return s


static func _to_wav(samples: PackedFloat32Array, loop: bool) -> AudioStreamWAV:
	var bytes := PackedByteArray()
	bytes.resize(samples.size() * 2)
	for i in samples.size():
		bytes.encode_s16(i * 2, int(clampf(samples[i], -1.0, 1.0) * 32000.0))
	var wav := AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = RATE
	wav.data = bytes
	if loop:
		wav.loop_mode = AudioStreamWAV.LOOP_FORWARD
		wav.loop_end = samples.size()
	return wav


static func _synth(sound: String) -> PackedFloat32Array:
	var rng := RandomNumberGenerator.new()
	rng.seed = hash(sound)
	match sound:
		"break":
			return _noise(rng, 0.14, 0.5, 0.35)
		"place":
			return _mix(_tone(0.09, 140.0, 90.0, 0.7, "sine"), _noise(rng, 0.05, 0.25, 0.2))
		"hit":
			return _tone(0.1, 230.0, 110.0, 0.45, "square")
		"hurt":
			return _tone(0.25, 420.0, 200.0, 0.5, "saw")
		"eat":
			return _concat([_noise(rng, 0.06, 0.4, 0.5), _silence(0.05), _noise(rng, 0.06, 0.4, 0.5), _silence(0.05), _noise(rng, 0.07, 0.4, 0.5)])
		"pickup":
			return _tone(0.08, 880.0, 1320.0, 0.35, "sine")
		"craft":
			return _concat([_tone(0.07, 660.0, 660.0, 0.35, "triangle"), _tone(0.1, 990.0, 990.0, 0.35, "triangle")])
		"portal":
			return _tone(0.9, 180.0, 900.0, 0.4, "sine", 7.0)
		"tool_break":
			return _mix(_noise(rng, 0.2, 0.5, 0.1), _tone(0.2, 1400.0, 600.0, 0.25, "square"))
		"chirp":
			return _concat([_tone(0.06, 1800.0, 2600.0, 0.3, "sine"), _silence(0.04), _tone(0.06, 1900.0, 2700.0, 0.3, "sine"), _silence(0.04), _tone(0.09, 2000.0, 2400.0, 0.3, "sine")])
		"gas":
			return _noise(rng, 0.7, 0.3, 0.9)
		"hum_halls":
			return _hum(rng)
		"music_factory":
			return _music_box()
	return PackedFloat32Array()


## Floresan uğultusu: 60/120 Hz ve hafif cızırtı, 2 saniyelik döngü.
static func _hum(rng: RandomNumberGenerator) -> PackedFloat32Array:
	var n := RATE * 2
	var out := PackedFloat32Array()
	out.resize(n)
	for i in n:
		var t := float(i) / RATE
		out[i] = 0.12 * sin(TAU * 60.0 * t) + 0.08 * sin(TAU * 120.0 * t) + 0.03 * sin(TAU * 240.0 * t) + rng.randf_range(-0.015, 0.015)
	return out


## Oyuncak fabrikası müzik kutusu: yavaş, biraz tekinsiz bir arpej döngüsü.
static func _music_box() -> PackedFloat32Array:
	var notes := [72, 76, 79, 83, 81, 76, 72, 71, 69, 72, 76, 74, 72, 71, 67, 71]
	var parts: Array[PackedFloat32Array] = []
	for m in notes:
		var f := 440.0 * pow(2.0, (m - 69) / 12.0)
		parts.append(_pluck(0.3, f))
	return _concat(parts)


static func _pluck(dur: float, freq: float) -> PackedFloat32Array:
	var n := int(dur * RATE)
	var out := PackedFloat32Array()
	out.resize(n)
	for i in n:
		var t := float(i) / RATE
		var env := exp(-t * 7.0)
		out[i] = env * 0.22 * (sin(TAU * freq * t) + 0.3 * sin(TAU * freq * 2.0 * t))
	return out


## freq0'dan freq1'e kayan, sönümlenen ton. tremolo > 0 ise genliği titrer.
static func _tone(dur: float, freq0: float, freq1: float, vol: float, wave: String, tremolo := 0.0) -> PackedFloat32Array:
	var n := int(dur * RATE)
	var out := PackedFloat32Array()
	out.resize(n)
	var phase := 0.0
	for i in n:
		var k := float(i) / n
		var freq := lerpf(freq0, freq1, k)
		phase = fmod(phase + freq / RATE, 1.0)
		var v: float
		match wave:
			"square":
				v = 1.0 if phase < 0.5 else -1.0
			"saw":
				v = phase * 2.0 - 1.0
			"triangle":
				v = 1.0 - 4.0 * absf(phase - 0.5)
			_:
				v = sin(TAU * phase)
		var env := minf(k * 20.0, 1.0) * (1.0 - k)
		if tremolo > 0.0:
			env *= 0.7 + 0.3 * sin(TAU * tremolo * k * dur)
		out[i] = v * env * vol
	return out


## Sönümlenen gürültü. smooth 0..1: büyüdükçe daha boğuk.
static func _noise(rng: RandomNumberGenerator, dur: float, vol: float, smooth: float) -> PackedFloat32Array:
	var n := int(dur * RATE)
	var out := PackedFloat32Array()
	out.resize(n)
	var last := 0.0
	for i in n:
		var k := float(i) / n
		last = lerpf(rng.randf_range(-1.0, 1.0), last, smooth)
		out[i] = last * vol * (1.0 - k) * minf(k * 30.0, 1.0)
	return out


static func _silence(dur: float) -> PackedFloat32Array:
	var out := PackedFloat32Array()
	out.resize(int(dur * RATE))
	return out


static func _concat(parts: Array) -> PackedFloat32Array:
	var out := PackedFloat32Array()
	for p: PackedFloat32Array in parts:
		out.append_array(p)
	return out


static func _mix(a: PackedFloat32Array, b: PackedFloat32Array) -> PackedFloat32Array:
	var out := a.duplicate() if a.size() >= b.size() else b.duplicate()
	var other := b if a.size() >= b.size() else a
	for i in other.size():
		out[i] += other[i]
	return out
