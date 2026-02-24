extends CharacterBody2D


const SPEED = 550.0
const vida_max = 10
const DANO = 2


@onready var animation: AnimationPlayer = $Animation
@onready var ray: RayCast2D = $Ray
@onready var collision: CollisionShape2D = $AttackArea/Collision
@onready var barra_de_vida: ProgressBar = $ProgressBar

@export var knockback_duration = 0.2
@export var knockback_strength = 100.0

var knockback_velocity = Vector2.ZERO
var knockback_timer = 0.0



var target: Node2D = null
var atacando: bool
var vida: int = vida_max
var is_dead: bool = false
var levando_hit : bool = false

@export var direction := -10

func _ready():
	barra_de_vida.max_value = vida_max
	barra_de_vida.value = vida


var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")


func _physics_process(delta):
	if is_dead:
		return
	if levando_hit:
		velocity.x *= 0.5
	if not is_on_floor():
		velocity += get_gravity() * delta
	# aplica knockback se estiver ativo
	if knockback_timer > 0.0:
		velocity.x = knockback_velocity.x
		velocity.y = knockback_velocity.y
		knockback_timer -= delta
	else:
		if ray.is_colliding():
			direction *= -1
			ray.scale.x *= -1
			flip()
		if direction and not atacando:
			velocity.x = direction * SPEED * delta
			if not levando_hit:
				animation.play("run")
		move_and_slide()

func flip():
	if velocity.x > 0:
		$Sprite2D.flip_h = false
	if velocity.x < 0:
		$Sprite2D.flip_h = true


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		target = body
		atacando = true
		animation.play("attack")
		target.take_damage(DANO)
		$DamageTimer.start()
		var knockback_direction = (body.global_position - global_position).normalized()
		body.apply_knockback(knockback_direction, knockback_strength)


func apply_knockback(direction: Vector2, strength: float):
	knockback_velocity = direction * strength
	knockback_timer = knockback_duration


func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		target = null
		atacando = false
		animation.play("run")
		$DamageTimer.stop()

func _on_damage_timer_timeout():
	if target and not target.is_dead:
		target.take_damage(DANO)


func _on_animation_finished(anim_name: StringName) -> void:
	if anim_name == "death":
		queue_free()
	if anim_name == "attack":
		if atacando:
			animation.play("attack")
		else:
			animation.play("run")
	elif anim_name == "hit":
		levando_hit = false
		if atacando:
			animation.play("attack")
		else:
			animation.play("run")


func take_damage(amount: int):
	if is_dead:
		return
	vida -= amount
	barra_de_vida.value = vida
	if vida <= 0:
		die()
	else:
		levando_hit = true
		animation.play("hit")

func die():
	if is_dead:
		return
	is_dead = true
	velocity = Vector2.ZERO
	animation.play("death")
