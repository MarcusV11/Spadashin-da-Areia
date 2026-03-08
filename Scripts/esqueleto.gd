extends CharacterBody2D


const SPEED = 500.0
const vida_max = 15
const DANO = 4



@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var ray: RayCast2D = $Ray
@onready var collision: CollisionShape2D = $AttackArea/Collision
@onready var barra_de_vida: ProgressBar = $ProgressBar
@export var knockback_duration: float = 0.1
@export var knockback_strength: float = 50.0


var knockback_velocity: Vector2 = Vector2.ZERO
var knockback_timer: float = 0.0
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
	if atacando and target and not levando_hit:
		if animated_sprite_2d.animation != "attack":
			animated_sprite_2d.play("attack")
	if levando_hit:
		velocity.x *= 0.5
	if not is_on_floor():
		velocity += get_gravity() * delta
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
				animated_sprite_2d.play("run")
		move_and_slide()



func flip():
	if velocity.x > 0:
		$AnimatedSprite2D.flip_h = false
		$AttackArea.position.x = abs($AttackArea.position.x)
	if velocity.x < 0:
		$AnimatedSprite2D.flip_h = true
		$AttackArea.position.x = -abs($AttackArea.position.x)

func _on_area_2d_body_entered(body: Node2D) -> void:
	if is_dead:
		return
	if body.is_in_group("player"):
		target = body
		atacando = true
		animated_sprite_2d.play("attack")
		$DamageTimer.start()




func _on_animation_frame_changed() -> void:
	if not is_instance_valid(animated_sprite_2d):
		return
	if animated_sprite_2d.animation == "attack":
		if animated_sprite_2d.frame == 6:
			if target and atacando:
				target.take_damage(DANO)
				var knockback_direction = (target.global_position - global_position).normalized()
				target.apply_knockback(knockback_direction, knockback_strength)



func apply_knockback(direction: Vector2, strength: float):
	knockback_velocity = direction * strength
	knockback_timer = knockback_duration


func _on_area_2d_body_exited(body: Node2D) -> void:
	if is_dead:
		return
	if body.is_in_group("player"):
		target = null
		atacando = false
		animated_sprite_2d.play("run")
		$DamageTimer.stop()


func _on_damage_timer_timeout():
	if target and not target.is_dead and atacando:
		target.take_damage(DANO)
		$DamageTimer.start()


func _on_animation_finished() -> void:
	var anim_name = animated_sprite_2d.animation 
	if anim_name == "death":
		queue_free()
	if anim_name == "attack":
		if atacando:
			animated_sprite_2d.play("attack")
		else:
			animated_sprite_2d.play("run")
	elif anim_name == "hit":
		levando_hit = false
		if atacando:
			animated_sprite_2d.play("attack")
		else:
			animated_sprite_2d.play("run")



func take_damage(amount: int):
	if is_dead:
		return
	vida -= amount
	barra_de_vida.value = vida
	if vida <= 0:
		die()
	else:
		levando_hit = true
		animated_sprite_2d.play("hit")



func die():
	if is_dead:
		return
	is_dead = true
	velocity = Vector2.ZERO
	atacando = false
	target = null
	$DamageTimer.stop()
	$AttackArea/Collision.set_deferred("disabled", true)
	animated_sprite_2d.play("death")
