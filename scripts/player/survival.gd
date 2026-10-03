class_name Survival
extends Node
## Oyuncunun can ve açlık değerleri: hasar, iyileşme, açlıktan zarar ve ölüm.
## Değerler Minecraft'taki gibi yarım kalp / yarım but birimindedir (20 = 10 kalp).

signal changed
signal damaged(amount: int)
signal died

const MAX_HEALTH := 20
const MAX_HUNGER := 20
## Her açlık puanı bu kadar saniyede azalır.
const HUNGER_INTERVAL := 30.0
## Tokken iyileşme ve açken can kaybı aralığı.
const TICK_INTERVAL := 4.0
const REGEN_MIN_HUNGER := 16
## Hasardan sonra kısa süre dokunulmazlık (aynı anda üst üste vurulmayı önler).
const INVULNERABLE_TIME := 0.5

var health := MAX_HEALTH
var hunger := MAX_HUNGER
var dead := false

var _hunger_timer := 0.0
var _tick_timer := 0.0
var _invulnerable := 0.0


func _process(delta: float) -> void:
	if dead:
		return
	_invulnerable = maxf(_invulnerable - delta, 0.0)

	_hunger_timer += delta
	if _hunger_timer >= HUNGER_INTERVAL:
		_hunger_timer = 0.0
		if hunger > 0:
			hunger -= 1
			changed.emit()

	_tick_timer += delta
	if _tick_timer >= TICK_INTERVAL:
		_tick_timer = 0.0
		if hunger == 0:
			take_damage(1)
		elif hunger >= REGEN_MIN_HUNGER and health < MAX_HEALTH:
			health += 1
			changed.emit()


func take_damage(amount: int) -> void:
	if dead or amount <= 0 or _invulnerable > 0.0:
		return
	_invulnerable = INVULNERABLE_TIME
	health = maxi(health - amount, 0)
	damaged.emit(amount)
	changed.emit()
	if health == 0:
		dead = true
		died.emit()


func eat(amount: int) -> void:
	hunger = mini(hunger + amount, MAX_HUNGER)
	changed.emit()


func reset() -> void:
	health = MAX_HEALTH
	hunger = MAX_HUNGER
	dead = false
	_hunger_timer = 0.0
	_tick_timer = 0.0
	_invulnerable = 0.0
	changed.emit()
