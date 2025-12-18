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
@onready var hurtbox: Area2D = $HurtBox

# Experience gem scene
var exp_gem = preload("res://Objects/experience_gem.tscn")
var hp_potion_scene = preload("res://Scenes/hp_potion.tscn")

func _ready():
	health = max_health
	
	# Setup hitbox for damaging player
	if hitbox:
		hitbox.collision_layer = 8  # Enemy layer
		hitbox.collision_mask = 2   # Detect player
		if not hitbox.area_entered.is_connected(_on_hitbox_area_entered):
			hitbox.area_entered.connect(_on_hitbox_area_entered)
	
	# Setup hurtbox for taking damage from player
	if hurtbox:
		hurtbox.collision_layer = 8  # Enemy layer
		hurtbox.collision_mask = 8   # Detect player attacks
		if not hurtbox.area_entered.is_connected(_on_hurtbox_area_entered):
			hurtbox.area_entered.connect(_on_hurtbox_area_entered)

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
	print("Enemy took ", amount, " damage. Health: ", health)
	
	if health <= 0:
		die()

func die():
	if is_dead:
		return
	
	is_dead = true
	print("Enemy died!")
	
	# Disable collision
	set_physics_process(false)
	$CollisionShape2D.set_deferred("disabled", true)
	
	# Disable hitbox and hurtbox
	if hitbox:
		hitbox.monitoring = false
		hitbox.monitorable = false
	if hurtbox:
		hurtbox.monitoring = false
		hurtbox.monitorable = false
	
	# Drop experience and potions
	drop_experience()
	drop_potion_chance()
	
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
	
func drop_potion_chance():
	var chance = randf() # Generates a number between 0.0 and 1.0
	if chance <= 0.2: # 20% chance (changed from 1.0 which was 100%)
		var potion = hp_potion_scene.instantiate()
		potion.global_position = global_position
		get_parent().call_deferred("add_child", potion)

# Handle damage from player attacks
func _on_hurtbox_area_entered(area: Area2D):
	if is_dead:
		return
	
	if area.is_in_group("player_attack"):
		var dmg = area.damage if "damage" in area else 1
		print("Enemy hit by player attack for ", dmg, " damage")
		take_damage(dmg)

# Handle enemy damaging player
func _on_hitbox_area_entered(area: Area2D):
	if is_dead:
		return
	
	# Check if we hit player's HurtBox
	if area.get_parent() and area.get_parent().is_in_group("Player"):
		print("Enemy hit player!")
		# The player's HurtBox will handle the damage
