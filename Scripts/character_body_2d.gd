extends CharacterBody2D

@export var healthbar: HealthBar

const MAX_HEALTH := 30
const MOVE_SPEED := 40.0
const DAMAGE_COOLDOWN := 1.0 # seconds between taking damage

var experience_level: int = 1
var health: int = MAX_HEALTH
var is_alive := true
var can_take_damage := true
var experience_level: int = 1
var current_exp: int = 0
var exp_to_next_level: int = 100

# Canvas layer nodes
@onready var expBar = get_node("%ExpBar")
@onready var lblLevel = get_node("%lbl_level")
@onready var levelPanel = get_node("%LevelUp")
@onready var upgradeOptions = get_node("%UpgradeOptions")

#Canvas Layer
@onready var expBar = get_node("%ExperienceBar")
@onready var lblLevel = get_node("%lbl_level")
@onready var levelPanel = get_node("%LevelUp")
@onready var upgradeOptions = get_node("%UpgradeOptions")
@onready var upgradeDB = preload("res://Scripts/upgrade_db.gd")
@onready var sndLevelUp = get_node("%snd_levelup")
@onready var healthBar = get_node("%HealthBar")
@onready var lblTimer = get_node("%lblTimer")
@onready var collectedWeapons = get_node("%CollectedWeapons")
@onready var collectedUpgrades = get_node("%CollectedUpgrades")
@onready var itemOptions: PackedScene = preload("res://Scenes/item_options.tscn")




func _physics_process(_delta: float) -> void:
	var input_vector := Vector2(
		Input.get_action_strength("right") - Input.get_action_strength("left"),
		Input.get_action_strength("down") - Input.get_action_strength("up")
	)

	velocity = input_vector.normalized() * MOVE_SPEED if input_vector.length() > 0 else Vector2.ZERO
	move_and_slide()
	
func gain_experience(amount: int) -> void:
	current_exp += amount
	expBar.value = current_exp
	
	if current_exp >= exp_to_next_level:
		current_exp -= exp_to_next_level
		experience_level += 1
		levelup()


func take_damage(amount: int) -> void:
	if not is_alive:
		return

	health = clamp(health - amount, 0, MAX_HEALTH)
	healthbar.health = health

	if health == 0:
		die()


func heal(amount: int) -> void:
	if not is_alive:
		return

	health = clamp(health + amount, 0, MAX_HEALTH)
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
	

func levelup():
	lblLevel.text = "Level: %s" % experience_level
	levelPanel.visible = true
	get_tree().paused = true
	
	var tween = levelPanel.create_tween()
	tween.tween_property(levelPanel, "position", Vector2(220, 50), 2).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_IN)
	tween.play()
