extends Area2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		body.coletaMoeda()  # <- só conta a moeda, sem mexer na chave
		coletando()

func coletando():
	call_deferred("queue_free")
