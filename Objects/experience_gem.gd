extends Area2D

@export var experience = 1

var spr_green = preload("res://MapAssets/candleA_01.png")
var spr_blue = preload("res://MapAssets/candleA_02.png")
var spr_red = preload("res://MapAssets/candleA_03.png")

var target = null
var speed = -1  # positive speed

@onready var sprite = $Sprite2D
@onready var collision = $CollisionShape2D
@onready var sound: AudioStreamPlayer2D = $snd_collected


#Exp
@onready var expBar = get_node("%ExperienceBar")
@onready var lblLevel = get_node("%lbl_level")

func _ready():
	# Set sprite based on experience
	if experience < 5:
		sprite.texture = spr_green
	elif experience < 25:
		sprite.texture = spr_blue
	else:
		sprite.texture = spr_red

	if not sound:
		push_warning("snd_collected node not found! Loot will disappear immediately upon collection.")

func _physics_process(delta):
	if target != null:
		global_position = global_position.move_toward(target.global_position, speed)
		speed += 2 * delta

func collect() -> int:
	collision.disabled = true
	sprite.visible = false

	# Play sound if it exists
	if sound:
		sound.play()
		# Queue free after sound finishes
		
	else:
		queue_free()  # No sound, free immediately

	return experience

func _on_snd_collected_finished():
	queue_free()
