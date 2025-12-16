class_name HealthBar
extends ProgressBar

@onready var timer: Timer = $Timer
@onready var damage_bar: ProgressBar = $damageBar

var health: int = 0 : set = _set_health


func _set_health(new_health: int) -> void:
	var prev_health := health
	health = clamp(new_health, 0, max_value)
	value = health

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
