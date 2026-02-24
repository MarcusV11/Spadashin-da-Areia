extends Area2D

@export_file("*.tscn") var next_scene_path
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

func _ready():
	animated_sprite_2d.play("close")
	GameState.chave_pega.connect(_ao_coletar_chave)  # escuta o sinal

func _ao_coletar_chave():
	animated_sprite_2d.play("open")

func _on_body_entered(body):
	if body.name == "Player":
		if GameState.chave_coletada:
			call_deferred("change_level")

func change_level():
	GameState.chave_coletada = false  # <- reseta para a próxima fase
	if next_scene_path:
		get_tree().change_scene_to_file(next_scene_path)
