extends RigidBody2D

@export var speed = 1000
@export var damage = 3


var direction: Vector2
var is_rolando = false

func _on_area_2d_body_entered(body: Node2D) -> void:
	if is_rolando and body.is_in_group("inimigo"):
		$AnimationPlayer.play("destruido")
		body.take_damage(damage)
		queue_free() # destrói ao acertar

func rolando():
	is_rolando = true
	linear_velocity = direction * speed
	$Timer.start(2)


func _on_Timer_timeout() -> void:
	queue_free() # destrói se não acertar ninguém
