extends CharacterBody2D

const VIDA_MAX = 50
const SPEED = 150.0
const DANO = 5
const FRAMES_TOLERANCIA: int = 10

@onready var animation: AnimationPlayer = $Animation
@onready var attack_area: Area2D = $AttackArea
@onready var attack_timer: Timer = $AttackTimer
@onready var movement_timer: Timer = $MovementTimer
@onready var barra_de_vida: ProgressBar = $ProgressBar

var frames_sem_player: int = 0
var estado_anterior: String = ""
var tomando_dano: bool = false
var vida: int = VIDA_MAX
var is_dead: bool = false
var atacando: bool = false
var direction: Vector2 = Vector2(1, 0)
var player_ref: Node2D = null
var knockback_velocity = Vector2.ZERO
var knockback_timer = 0.0
@export var knockback_duration = 0.1



const NUMERO_COLLISION = 34.5


func _ready():
	barra_de_vida.max_value = VIDA_MAX
	barra_de_vida.value = vida
	movement_timer.start()

func _process(_delta: float) -> void:
	if is_dead:
		return
	animate()

func _physics_process(delta: float) -> void:
	if is_dead:
		return
	
	if knockback_timer > 0.0:
		velocity.x = knockback_velocity.x
		velocity.y = knockback_velocity.y
		knockback_timer -= delta
	
	var bodies = attack_area.get_overlapping_bodies()
	var player_na_area = false
	for body in bodies:
		if body.is_in_group("player"):
			player_na_area = true
			if player_ref == null:
				player_ref = body
			break
	
	if player_na_area:
		frames_sem_player = 0
		if not atacando:
			atacando = true
			attack_timer.stop()
			attack_timer.start()
	else:
		frames_sem_player += 1
		if frames_sem_player >= FRAMES_TOLERANCIA:
			if atacando:
				atacando = false
				player_ref = null
				attack_timer.stop()
	
	mover()

func animate() -> void:
	var novo_estado: String
	if is_dead:
		novo_estado = "death"
	elif tomando_dano:
		novo_estado = "hit"
	elif atacando:
		novo_estado = "attack"
	else:
		novo_estado = "run"
	
	if novo_estado != estado_anterior:
		estado_anterior = novo_estado
		animation.play(novo_estado)

func mover() -> void:
	if atacando:
		velocity = Vector2.ZERO
		move_and_slide()
		return
	
	velocity = direction * SPEED
	
	if velocity.x > 0:
		$Sprite2D.flip_h = true
		$AttackArea/CollisionShape2D.position.x = NUMERO_COLLISION
	elif velocity.x < 0:
		$Sprite2D.flip_h = false
		$AttackArea/CollisionShape2D.position.x = -NUMERO_COLLISION
	
	move_and_slide()

func change_direction() -> void:
	direction = Vector2([-1, 1].pick_random(), 0)

func take_damage(amount: int) -> void:
	if is_dead:
		return
	vida -= amount
	barra_de_vida.value = vida
	if vida <= 0:
		die()
	else:
		if not atacando:
			tomando_dano = true

func die() -> void:
	if is_dead:
		return
	is_dead = true
	atacando = false
	tomando_dano = false
	velocity = Vector2.ZERO
	estado_anterior = ""
	attack_timer.stop()
	movement_timer.stop()
	animation.stop()
	animation.play("death")

func _on_AttackTimer_timeout() -> void:
	if not is_dead and atacando and player_ref != null:
		player_ref.take_damage(DANO)
		attack_timer.start()
	elif not is_dead and player_ref != null:
		atacando = true
		attack_timer.start()

func _on_MovementTimer_timeout() -> void:
	if not is_dead:
		change_direction()

func _on_animation_animation_finished(anim_name: StringName) -> void:
	if anim_name == "death":
		queue_free()
	elif anim_name == "hit":
		tomando_dano = false
	elif anim_name == "attack":
		pass


func apply_knockback(direction: Vector2, strength: float):
	pass  # o boss ignora knockback, ou adicione a lógica se quiser
