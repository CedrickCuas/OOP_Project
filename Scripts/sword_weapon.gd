extends Area2D

@export var damage: int = 5
@export var attack_duration: float = 2

@onready var attack_timer: Timer = $AttackTimer

func _ready():
	add_to_group("player_attack")
	monitoring = false

func _on_attack_timer_timeout():
	attack()

func attack():
	monitoring = true
	
	# Check for enemies in range
	var enemies = get_overlapping_areas()
	for enemy_area in enemies:
		if enemy_area.get_parent() is BaseEnemy:
			enemy_area.get_parent().take_damage(damage)
	
	# Disable after brief moment
	await get_tree().create_timer(attack_duration).timeout
	monitoring = false
