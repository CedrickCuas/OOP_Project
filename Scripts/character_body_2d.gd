extends CharacterBody2D

@export var healthbar: HealthBar

const MAX_HEALTH := 30
const MOVE_SPEED := 40.0

var health: int = MAX_HEALTH
var is_alive := true


func _ready() -> void:
	if healthbar == null:
		healthbar = get_tree().get_root().get_node("Root/CanvasLayer/HealthBar")
		
	if healthbar:
		healthbar.init_health(MAX_HEALTH)
	else:
		push_error("HealthBar not found! Check the node path.")
		
	health = MAX_HEALTH
	is_alive = true


func _physics_process(_delta: float) -> void:
	var input_vector := Vector2(
		Input.get_action_strength("right") - Input.get_action_strength("left"),
		Input.get_action_strength("down") - Input.get_action_strength("up")
	)

	velocity = input_vector.normalized() * MOVE_SPEED if input_vector.length() > 0 else Vector2.ZERO
	move_and_slide()


func take_damage(amount: int) -> void:
	if not is_alive:
		return

	health = clamp(health - amount, 0, MAX_HEALTH)
	healthbar.health = health

	if health == 0:
		die()


func heal(amount: int) -> void:
	if not is_alive:
		return

	health = clamp(health + amount, 0, MAX_HEALTH)
	healthbar.health = health


func die() -> void:
	is_alive = false
	print("Player died")
	queue_free()


func _on_hurtbox_area_entered(_area) -> void:
	take_damage(1)
