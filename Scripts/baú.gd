extends StaticBody2D
@export var vida_max = 4
@onready var animation: AnimatedSprite2D = $AnimatedSprite2D
@onready var area_2d: Area2D = $Area2D
@onready var timer: Timer = $Timer
@export var max_moedas := 5


var moedas_dropadas := 0
var vida: int = vida_max
var open: bool = false





func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and not open:
		take_damage(1)

func take_damage(amount: int):
	if open:
		return   # <- trava total
	vida -= amount
	if vida <= 0:
		open_bau()

func open_bau():
	if open:
		return
	open = true
	animation.play("open")
	for i in max_moedas:
		await get_tree().create_timer(0.2).timeout
		drop_itens()
	timer.start(1.0)

func drop_itens():
	if open and moedas_dropadas >= max_moedas:
		return
	var moeda = preload("res://Cenas/moeda.tscn").instantiate()
	get_parent().add_child(moeda)
	moeda.position = position + Vector2(randf_range(-40, 40), 0)
	moedas_dropadas += 1

func _on_timer_timeout() -> void:
	queue_free()


func apply_knockback(direction: Vector2, strengt: float):
	pass
