extends CharacterBody2D

@onready var healthbar = get_node_or_null("Healthbar")

var movement_speed = 40.0
var max_health: int = 100
var health: int

signal health_changed(current, max)

func _ready():
	health = max_health
	emit_signal("health_changed", health, max_health)

	if healthbar:
		healthbar.init_health(health)

func _physics_process(_delta):
	movement()

func movement():
	var x_mov = Input.get_action_strength("right") - Input.get_action_strength("left")
	var y_mov = Input.get_action_strength("down") - Input.get_action_strength("up")
	var mov = Vector2(x_mov, y_mov)
	velocity = mov.normalized() * movement_speed
	move_and_slide()

func take_damage(damage: int):
	health = clamp(health - damage, 0, max_health)
	emit_signal("health_changed", health, max_health)

	if healthbar:
		healthbar.health = health
