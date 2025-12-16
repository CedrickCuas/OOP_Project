extends CharacterBody2D

@export var healthbar: ProgressBar

var max_health = 30
var health = max_health
var is_alive = true
var movement_speed = 40.0

func _ready():
	is_alive = true
	full_heal()  # restore full HP and update health bar immediately

func _physics_process(_delta):
	var x_mov = Input.get_action_strength("right") - Input.get_action_strength("left")
	var y_mov = Input.get_action_strength("down") - Input.get_action_strength("up")
	var mov = Vector2(x_mov, y_mov)
	velocity = mov.normalized() * movement_speed if mov.length() > 0 else Vector2.ZERO
	move_and_slide()

func take_damage(amount: int):
	if not is_alive:
		return
	health -= amount
	health = clamp(health, 0, max_health)
	if healthbar:
		healthbar.set_health(health)
	if health <= 0:
		die()

func heal(amount: int):
	if not is_alive:
		return
	health += amount
	health = clamp(health, 0, max_health)
	if healthbar:
		healthbar.set_health(health)

func full_heal():
	if not is_alive:
		return
	health = max_health
	if healthbar:
		healthbar.set_health(health)

func die():
	if not is_alive:
		return
	is_alive = false
	print("Player died!")
	queue_free()

# Triggered by enemy collisions
func _on_hurtbox_area_entered(area):
	take_damage(1)
