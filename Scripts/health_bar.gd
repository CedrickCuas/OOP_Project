extends ProgressBar

@onready var timer: Timer = $Timer
@onready var damage_bar: ProgressBar = $DamageBar

var health: int = 0 : set = _set_health


func _set_health(new_health):
	var prev_health := health
	health = min(max_value, new_health)
	value = health

	if health < 0:
		queue_free()
	if health < prev_health:
		timer.start()
	else:
		damage_bar.value = health


func init_health(max_health: int) -> void:
	max_value = max_health
	health = max_health
	value = max_health

	damage_bar.max_value = max_health
	damage_bar.value = max_health


func _on_timer_timeout() -> void:
	damage_bar.value = health
