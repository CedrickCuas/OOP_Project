extends CharacterBody2D

const MAX_HEALTH := 30
const MOVE_SPEED := 40.0
const DAMAGE_COOLDOWN := 1.0

# HP
var health: int = MAX_HEALTH
var is_alive := true
var can_take_damage := true

# Experience
var current_exp: int = 0
var experience = 0
var experience_level = 1
var collected_experience = 0

# UI References
@onready var expBar = get_node("%ExperienceBar")
@onready var lblLevel = get_node("%lbl_level")
@onready var levelPanel = get_node_or_null("%LevelUp")
@onready var upgradeOptions = get_node_or_null("%UpgradeOptions")
@onready var sndLevelUp = get_node_or_null("%snd_levelup")
@onready var healthbar = get_node_or_null("%HealthBar")
@onready var lblTimer = get_node_or_null("%lblTimer")
@onready var collectedWeapons = get_node_or_null("%CollectedWeapons")
@onready var collectedUpgrades = get_node_or_null("%CollectedUpgrades")

# Weapon
var sword_scene = preload("res://Scenes/sword_weapon.tscn")
var sword_weapon = null

func _ready():
	health = MAX_HEALTH
	if healthbar:
		healthbar.init_health(health)
	
	set_expbar(current_exp, calculate_experiencecap())
	
	# Connect HurtBox signal
	var hurtbox = $HurtBox
	if hurtbox and not hurtbox.area_entered.is_connected(_on_hurtbox_area_entered):
		hurtbox.area_entered.connect(_on_hurtbox_area_entered)
	
	# Spawn starting weapon
	spawn_sword()

func spawn_sword():
	if not sword_weapon:
		sword_weapon = sword_scene.instantiate()
		add_child(sword_weapon)

func _physics_process(_delta: float) -> void:
	if not is_alive:
		return
		
	var input_vector := Vector2(
		Input.get_action_strength("right") - Input.get_action_strength("left"),
		Input.get_action_strength("down") - Input.get_action_strength("up")
	)
	velocity = input_vector.normalized() * MOVE_SPEED if input_vector.length() > 0 else Vector2.ZERO
	move_and_slide()

# Health functions
func take_damage(amount: int) -> void:
	if not is_alive:
		return
	health = clamp(health - amount, 0, MAX_HEALTH)
	if healthbar:
		healthbar.health = health
	if health == 0:
		die()

func heal(amount: int) -> void:
	if not is_alive:
		return
	health = clamp(health + amount, 0, MAX_HEALTH)
	if healthbar:
		healthbar.health = health

func die() -> void:
	is_alive = false
	print("Player died")
	queue_free()

func _on_hurtbox_area_entered(_area) -> void:
	if can_take_damage:
		take_damage(1)
		can_take_damage = false
		await get_tree().create_timer(DAMAGE_COOLDOWN).timeout
		can_take_damage = true

# Experience functions
func _on_grab_area_area_entered(area: Area2D) -> void:
	if area.is_in_group("loot"):
		area.target = self

func _on_collect_area_area_entered(area: Area2D) -> void:
	if area.is_in_group("loot"):
		var gem_exp = area.collect()
		gain_experience(gem_exp)

func gain_experience(amount: int) -> void:
	current_exp += amount
	check_levelup()
	set_expbar(current_exp, calculate_experiencecap())

func check_levelup() -> void:
	var exp_cap = calculate_experiencecap()
	while current_exp >= exp_cap:
		current_exp -= exp_cap
		experience_level += 1
		exp_cap = calculate_experiencecap()

func calculate_experiencecap():
	var exp_cap = experience_level
	if experience_level < 20:
		exp_cap = experience_level * 5
	elif experience_level < 40:
		exp_cap = 95 * (experience_level - 19) * 8
	else:
		exp_cap = 255 + (experience_level - 39) * 12
	return exp_cap

func set_expbar(set_value = 1, set_max_value = 100):
	if expBar:
		expBar.value = set_value
		expBar.max_value = set_max_value
