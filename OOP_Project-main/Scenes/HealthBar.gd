extends ProgressBar

@onready var timer: Timer = $Timer
@onready var damage_bar: ProgressBar = $Damagebar

var health = 0

func _set_health(new_health):
	var prev_health = health
	health = min(max_value, new_health)
	value = health

	if health <= 0:
		queue_free()

	if health < prev_health:
		timer.start()
	else:
		damage_bar.value = health

func init_health(_health):
	health = _health
	max_value = _health
	value = _health
	damage_bar.max_value = _health
	damage_bar.value = _health

func _on_timer_timeout() -> void:
	damage_bar.value = health
