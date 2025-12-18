extends BaseEnemy

func _ready():
	max_health = 20
	speed = 20.0  # Knights are slower but tankier
	damage = 3
	experience_drop = 15
	super._ready()

func _physics_process(delta):
	if is_dead:
		return
		
	if player:
		var direction = global_position.direction_to(player.global_position)
		velocity = direction * speed
		move_and_slide()
		
		# Flip sprite
		if direction.x < 0:
			animated_sprite.flip_h = true
		elif direction.x > 0:
			animated_sprite.flip_h = false
		
		# Play run animation
		if animated_sprite.sprite_frames.has_animation("Run"):
			animated_sprite.play("Run")
