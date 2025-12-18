extends BaseEnemy

func _ready():
	max_health = 8
	speed = 25.0
	damage = 1
	experience_drop = 5
	super._ready()

func _physics_process(delta):
	if is_dead:
		return
	
	super._physics_process(delta)
	
	# Slime uses "Walking" animation instead of "Run"
	if animated_sprite and animated_sprite.sprite_frames.has_animation("Walking"):
		animated_sprite.play("Walking")
