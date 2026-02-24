extends Area2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

signal chave_coletada  # <- sinal criado aqui


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		body.tem_chave = true
		GameState.chave_coletada = true
		GameState.chave_pega.emit()
		queue_free()
