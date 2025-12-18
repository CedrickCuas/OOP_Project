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
	
	super._physics_process(delta)
