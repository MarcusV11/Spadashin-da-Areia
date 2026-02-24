extends Area2D

@export var velocidade = 500
@onready var sprite: Sprite2D = $Sprite2D
@export var dano = 3

func _ready() -> void:
	await get_tree().create_timer(3).timeout
	queue_free()



func _process(delta: float) -> void:
	position.x += velocidade * delta


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("inimigo"):
		body.take_damage(dano)
		queue_free()
