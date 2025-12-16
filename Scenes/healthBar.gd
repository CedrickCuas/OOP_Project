extends ProgressBar

@onready var damage_bar = $DamageBar   # optional
@onready var tween = $Tween            # optional

var health := 0
var max_health := 10

# Initialize health bar at max
func init_health(_max_health: int):
	max_health = _max_health
	health = max_health
	max_value = max_health
	value = health
	
	if damage_bar:
		damage_bar.max_value = max_health
		damage_bar.value = health

# Set health instantly
func set_health(new_health: int):
	health = clamp(new_health, 0, max_health)
	value = health
	
	if damage_bar:
		if tween:
			tween.stop(damage_bar, "value")
			# immediately set the damage bar to health if health is max
			if health == max_health:
				damage_bar.value = health
			else:
				tween.tween_property(damage_bar, "value", health, 0.3)
		else:
			damage_bar.value = health
