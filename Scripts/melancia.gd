extends Area2D

@onready var sprite_2d: Sprite2D = $Sprite2D

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		body.get_fruit()
		call_deferred("queue_free")
