extends Area2D

class_name Health_Potion

func _on_body_entered(body: Node2D) -> void:
	print("Healed 10HP")
	queue_free()
