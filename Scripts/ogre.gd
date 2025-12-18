extends BaseEnemy

func _ready():
	max_health = 25
	speed = 18.0  # Ogres are slow but very tanky
	damage = 4
	experience_drop = 20
	super._ready()

func _physics_process(delta):
	if is_dead:
		return
	
	super._physics_process(delta)
