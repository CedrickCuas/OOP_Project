extends ProgressBar

var level: int = 1
var current_exp: int = 0
var base_exp_needed: int = 100
var exp_growth_factor: float = 1.5

signal level_up(new_level)

# Exported variable so you can drag the ProgressBar in the Inspector
@export var exp_bar: ProgressBar

func _ready():
	update_exp_ui()

func gain_exp(amount: int):
	current_exp += amount
	while current_exp >= exp_needed():
		current_exp -= exp_needed()
		level += 1
		emit_signal("level_up", level)
	update_exp_ui()

func exp_needed() -> int:
	return int(base_exp_needed * pow(exp_growth_factor, level - 1))

func update_exp_ui():
	if exp_bar != null:
		exp_bar.max_value = exp_needed()
		exp_bar.value = current_exp
	else:
		print("EXP bar is not assigned!")
