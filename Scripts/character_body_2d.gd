extends CharacterBody2D

const MAX_HEALTH := 30
const MOVE_SPEED := 40.0
const DAMAGE_COOLDOWN := 1.0 # seconds between taking damage

# HP
var health: int = MAX_HEALTH
var is_alive := true
var can_take_damage := true

# Experience
var experience = 0
var experience_level = 1
var collected_experience = 0

# Canvas layer nodes (safe null checks)
@onready var expBar = get_node("%ExperienceBar")
@onready var lblLevel = get_node("%lbl_level")
@onready var levelPanel = get_node("%LevelUp")
@onready var upgradeOptions = get_node("%UpgradeOptions")
@onready var healthbar = get_node_or_null("%HealthBar")
@onready var lblTimer = get_node_or_null("%lblTimer")
@onready var collectedWeapons = get_node_or_null("%CollectedWeapons")
@onready var collectedUpgrades = get_node_or_null("%CollectedUpgrades")

# Packed scenes
@onready var itemOptions: PackedScene = preload("res://Scenes/item_options.tscn")


func _ready():
	health = MAX_HEALTH
	if healthbar:
		healthbar.init_health(health)
	else:
		push_warning("HealthBar node not found! Health UI will not update.")

	# initialize EXP bar correctly
	set_expbar(experience, calculate_experiencecap())


func _physics_process(_delta: float) -> void:
	var input_vector := Vector2(
		Input.get_action_strength("right") - Input.get_action_strength("left"),
		Input.get_action_strength("down") - Input.get_action_strength("up")
	)
	velocity = input_vector.normalized() * MOVE_SPEED if input_vector.length() > 0 else Vector2.ZERO
	move_and_slide()


# -------------------------
# Health functions
# -------------------------
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


# -------------------------
# Experience / Leveling
# -------------------------
func _on_grab_area_area_entered(area: Area2D) -> void:
	if area.is_in_group("loot"):
		area.target = self


func _on_collect_area_area_entered(area: Area2D) -> void:
	if area.is_in_group("loot"):
		var gem_exp = area.collect()
		calculate_experience(gem_exp)


func calculate_experience(gem_exp):
	var exp_required = calculate_experiencecap()
	collected_experience += gem_exp

	if experience + collected_experience > exp_required:
		collected_experience -= exp_required - experience
		experience_level += 1
		lblLevel.text = str("Level: ",experience_level)
		experience = 0
		exp_required = calculate_experiencecap()
		calculate_experience(0)
	else:
		experience += collected_experience
		collected_experience = 0

	set_expbar(experience, exp_required)


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
	expBar.value = set_value
	expBar.max_value = set_max_value
