extends Area2D

@export var experience = 1

var spr_green = preload("res://MapAssets/candleA_01.png")
var spr_blue = preload("res://MapAssets/candleA_02.png")
var spr_red = preload("res://MapAssets/candleA_03.png")


var target = null
var speed = -1

@onready var sprite = $Sprite2D
@onready var collision = $CollisionShape2D
@onready var sound = $snd_collected

func _ready():
	if experience < 5:
		return
	elif experience < 25:
		sprite.texture = spr_blue
	else:
		sprite.texture = spr_red

func _physics_process(delta):
	if target != null:
		global_position = global_position.move_toward(target.global_position, speed)
		speed += 2*delta
