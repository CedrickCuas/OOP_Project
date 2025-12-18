extends CharacterBody2D # Changed from Node2D so move_and_slide works

const SPEED = 25 # Adjust this to make the slime faster or slower

@onready var animated_sprite = $AnimatedSprite2D
# Finds the player node automatically
@onready var player = get_tree().get_first_node_in_group("Player")

func _physics_process(_delta):
	if player:
		# Calculate the direction towards the player
		var direction = global_position.direction_to(player.global_position)
		
		# Set velocity and move
		velocity = direction * SPEED
		move_and_slide()
		
		# Optional: Flip the sprite to face the player
		if direction.x > 0:
			animated_sprite.flip_h = true # Face right
		elif direction.x < 0:
			animated_sprite.flip_h = false  # Face left
