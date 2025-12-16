extends Node


signal leveled_up(new_level)

@export var base_exp := 100       
@export var exp_growth_factor := 1.5 

var level := 1
var current_exp := 0
var exp_to_next_level := base_exp

func _ready():
	update_exp_ui()
	print("Starting at level %d" % level)

func add_exp(amount: int):
	current_exp += amount
	print("Gained %d XP" % amount)
	
	while current_exp >= exp_to_next_level:
		current_exp -= exp_to_next_level
		_level_up()
	
	update_exp_ui()

func _level_up():
	level += 1
	exp_to_next_level = int(exp_to_next_level * exp_growth_factor)
	emit_signal("leveled_up", level)
	print("Leveled up! New level: %d" % level)

func update_exp_ui():
	
	print("Level: %d | XP: %d/%d" % [level, current_exp, exp_to_next_level])
	
func get_level():
	return level

func get_exp_percentage():
	return float(current_exp) / float(exp_to_next_level)
