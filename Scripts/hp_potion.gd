extends Area2D

@export var heal_amount: int = 5

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player") and body.has_method("heal"):
		body.heal(heal_amount)
	queue_free()
