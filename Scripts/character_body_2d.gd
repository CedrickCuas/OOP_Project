extends CharacterBody2D

const MAX_HEALTH := 30
const MOVE_SPEED := 40.0
const DAMAGE_COOLDOWN := 1.0 # seconds between taking damage

# HP
var health: int = MAX_HEALTH
var is_alive := true
var can_take_damage := true
#var experience_level: int = 1
var current_exp: int = 0
var exp_to_next_level: int = 100

# Canvas layer nodes
@onready var expBar = get_node("%ExpBar")
@onready var lblLevel = get_node("%lbl_level")
@onready var levelPanel = get_node("%LevelUp")
@onready var upgradeOptions = get_node("%UpgradeOptions")

#Canvas Layer
#@onready var expBar = get_node("%ExperienceBar")
#@onready var lblLevel = get_node("%lbl_level")
#@onready var levelPanel = get_node("%LevelUp")
#@onready var upgradeOptions = get_node("%UpgradeOptions")
@onready var upgradeDB = preload("res://Scripts/upgrade_db.gd")
@onready var itemOptions: PackedScene = preload("res://Scenes/item_options.tscn")


func _ready():
	# Initialize health safely
	health = MAX_HEALTH
	if healthbar:
		healthbar.init_health(health)
	else:
		push_warning("HealthBar node not found! Health UI will not update.")


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
func gain_experience(amount: int) -> void:
	current_exp += amount
	check_levelup()
	update_expbar()


func check_levelup() -> void:
	var exp_cap = calculate_experiencecap()
	while current_exp >= exp_cap:
		current_exp -= exp_cap
		experience_level += 1
		levelup()
		exp_cap = calculate_experiencecap()


func calculate_experiencecap() -> int:
	if experience_level < 20:
		return experience_level * 5
	elif experience_level < 40:
		return 95 * (experience_level - 19) * 8
	else:
		return 255 + (experience_level - 39) * 12


func update_expbar() -> void:
	if not expBar:
		push_warning("ExpBar node not found! Cannot update XP bar.")
		return
	var exp_cap = calculate_experiencecap()
	expBar.max_value = exp_cap
	expBar.value = current_exp


func levelup() -> void:
	if lblLevel:
		lblLevel.text = "Level: %s" % experience_level
	if levelPanel:
		levelPanel.visible = true
		get_tree().paused = true
		var tween = levelPanel.create_tween()
		tween.tween_property(levelPanel, "position", Vector2(220, 50), 2).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_IN)
		tween.play()
	if sndLevelUp:
		sndLevelUp.play()


# -------------------------
# Loot / Collection
# -------------------------
func _on_grab_area_area_entered(area: Area2D) -> void:
	if area.is_in_group("loot"):
		area.target = self


func _on_collect_area_area_entered(area: Area2D) -> void:
	if area.is_in_group("loot"):
		var gem_exp = area.collect()
		gain_experience(gem_exp)
