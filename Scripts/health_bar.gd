extends ProgressBar

@onready var timer: Timer = $Timer
@onready var damage_bar: ProgressBar = $DamageBar

var max_health: int
var current_health: int

func init_health(hp: int):
	max_health = hp
	current_health = hp
	value = current_health
	max_value = max_health

func set_health(hp: int):
	current_health = clamp(hp, 0, max_health)
	value = current_health
