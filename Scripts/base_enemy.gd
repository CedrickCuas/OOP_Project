extends CharacterBody2D

class_name BaseEnemy

# Enemy stats
@export var max_health: int = 10
@export var speed: float = 25.0
@export var damage: int = 1
@export var experience_drop: int = 5

var health: int
var is_dead: bool = false

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var player = get_tree().get_first_node_in_group("Player")
@onready var hitbox: Area2D = $Hitbox

# Experience gem scene
var exp_gem = preload("res://Objects/experience_gem.tscn")

func _ready():
	health = max_health
	
	# Setup hitbox if it exists
	if hitbox:
		hitbox.connect("area_entered", _on_hitbox_area_entered)

func _physics_process(_delta):
	if is_dead or not player:
		return
	
	# Move towards player
	var direction = global_position.direction_to(player.global_position)
	velocity = direction * speed
	move_and_slide()
	
	# Flip sprite based on direction
	if direction.x > 0:
		animated_sprite.flip_h = true
	elif direction.x < 0:
		animated_sprite.flip_h = false
	
	# Play run animation if not dead
	if animated_sprite.sprite_frames.has_animation("Run"):
		animated_sprite.play("Run")

func take_damage(amount: int):
	if is_dead:
		return
	
	health -= amount
	
	if health <= 0:
		die()

func die():
	if is_dead:
		return
	
	is_dead = true
	
	# Disable collision
	set_physics_process(false)
	$ObstacleCollision.set_deferred("disabled", true)
	
	# Disable hitbox
	if hitbox:
		hitbox.monitoring = false
		hitbox.monitorable = false
	
	# Drop experience
	drop_experience()
	
	# Play death animation
	if animated_sprite.sprite_frames.has_animation("Death"):
		animated_sprite.play("Death")
		await animated_sprite.animation_finished
	
	queue_free()

func drop_experience():
	var gem = exp_gem.instantiate()
	gem.global_position = global_position
	gem.experience = experience_drop
	get_parent().call_deferred("add_child", gem)

func _on_hitbox_area_entered(area: Area2D):
	# This will be connected to player's weapon attacks
	if area.is_in_group("player_attack"):
		take_damage(area.damage if area.has_method("get") and "damage" in area else 1)
