extends CharacterBody2D

@onready var healthbar = $HealthBar

var movement_speed = 40.0
var health := 10
var is_alive := true

func _ready(): 
	healthbar.init_health(health)

func _physics_process(_delta):
	movement()

func movement():
	var x_mov = Input.get_action_strength("right") - Input.get_action_strength("left")
	var y_mov = Input.get_action_strength("down") - Input.get_action_strength("up")
	var mov = Vector2(x_mov, y_mov)
	velocity = mov.normalized() * movement_speed
	move_and_slide()

func take_damage(amount):
	if not is_alive:
		return
	
	health -= amount
	healthbar.health = health
	
	if health <= 0:
		die()

func die():
	is_alive = false
	queue_free()
