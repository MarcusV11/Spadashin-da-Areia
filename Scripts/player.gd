extends CharacterBody2D

@export var speed = 300.0
@export var jump_velocity = 400.0
@export var vida_max = 10
@export var dano = 2
@export var speed_boost = 50.0
@export var boost_duration = 5.0
@export var dano_boost = 3
@export var knockback_duration = 0.2
@export var velocidade_bala = 500.0
@export var cena_bala: PackedScene = preload("res://Cenas/bala.tscn")

@onready var animation: AnimationPlayer = $AnimationPlayer
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var attack_area: Area2D = $AttackArea
@onready var timer: Timer = $Timer
@onready var barril_detector: Area2D = $BarrilDetector
@onready var barra_de_vida: ProgressBar = $ProgressBar
@onready var hud: Label = $"../Hud/Moeda"
@onready var boost_timer: Timer = $BoostTimer


var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var dano_original: float = 0.0 
var tem_chave: bool = false
var speed_original: float = 0.0
var direction: float
var atacando: bool
var vida: int = vida_max
var is_dead: bool = false
var levando_hit: bool = false
var detected_barril: RigidBody2D = null
var contador_de_moeda: int = 0
var pode_atirar: bool = false
var knockback_velocity = Vector2.ZERO
var knockback_timer = 0.0

const NUMERO_COLLISION = 24

func _ready():
	if GameState.vida <= 0:
		GameState.vida = vida_max
	vida = GameState.vida
	contador_de_moeda = GameState.moedas
	pode_atirar = GameState.pode_atirar  # <- carrega o tiro
	barra_de_vida.max_value = vida_max
	barra_de_vida.value = vida
	atualiza_hud()

func _process(delta):
	if is_dead:
		return
	animate()
	fliph()

func fliph():
	if velocity.x > 0:
		$Sprite2D.flip_h = false
		$AttackArea/Collision.position.x = NUMERO_COLLISION
	if velocity.x < 0:
		$Sprite2D.flip_h = true
		$AttackArea/Collision.position.x = -NUMERO_COLLISION

func animate():
	if is_dead:
		animation.play("death")
		return
	if levando_hit:
		animation.play("hit")
		return
	if atacando:
		animation.play("attack")
		return
	if velocity.y > 0 and not is_on_floor():
		animation.play("fall")
		return
	if velocity.y < 0 and not is_on_floor():
		animation.play("jump")
		return
	if velocity.x != 0:
		animation.play("run")
		return
	if velocity.x == 0:
		animation.play("idle")
		return

func _physics_process(delta):
	if is_dead:
		move_and_slide()
		return
	gravidade(delta)
	if knockback_timer > 0.0:
		velocity.x = knockback_velocity.x
		velocity.y = knockback_velocity.y
		knockback_timer -= delta
	else:
		mover()

func _input(event: InputEvent):
	if is_dead:
		return
	if Input.is_action_just_pressed("jump") and is_on_floor():
		jump()
	if Input.is_action_just_pressed("ataque"):
		ataque()
	if Input.is_action_just_pressed("tiro"):
		disparar()
	direction = Input.get_axis("esquerda", "direita")

func mover():
	velocity.x = direction * speed
	move_and_slide()

func gravidade(delta: float):
	if not is_on_floor():
		velocity.y += gravity * delta

func jump():
	velocity.y = -jump_velocity

func ataque():
	if atacando or is_dead:
		return
	atacando = true
	animation.play("attack")
	if detected_barril:
		roll_barril(detected_barril)
	await animation.animation_finished
	atacando = false

func roll_barril(barril):
	var roll_direction = Vector2(1, 0) if not $Sprite2D.flip_h else Vector2(-1, 0)
	barril.direction = roll_direction
	barril.rolando()

func _on_animation_finished(anim_name):
	if anim_name == "attack":
		atacando = false
	if anim_name == "death":
		timer.start()
	if anim_name == "hit":
		levando_hit = false

func take_damage(amount: int):
	if is_dead:
		return
	vida -= amount
	GameState.vida = vida  # salva no GameState
	barra_de_vida.value = vida
	if vida <= 0:
		die()
	else:
		levando_hit = true
		animation.play("hit")

func apply_knockback(direction: Vector2, strength: float):
	knockback_velocity = direction * strength
	knockback_timer = knockback_duration

func die():
	is_dead = true
	velocity = Vector2.ZERO
	set_collision_layer_value(1, false)
	set_collision_mask_value(2, false)
	animation.play("death")
	GameState.vida = vida_max
	GameState.moedas = 0
	GameState.chave_coletada = false
	GameState.pode_atirar = false

func _on_attack_area_body_entered(body):
	if body.is_in_group("inimigo") and atacando:
		body.take_damage(dano)
		var knockback_direction = (body.global_position - global_position).normalized()
		body.apply_knockback(knockback_direction, 300.0)

func _on_timer_timeout() -> void:
	get_tree().reload_current_scene()

func _on_Barril_detector_body_entered(body: Node2D) -> void:
	if body.is_in_group("barril"):
		detected_barril = body

func _on_Barril_detector_body_exited(body: Node2D) -> void:
	if body.is_in_group("barril"):
		detected_barril = null

func coletaMoeda():
	contador_de_moeda += 1
	GameState.moedas = contador_de_moeda  # salva no GameState
	atualiza_hud()

func atualiza_hud():
	hud.text = "Moedas: %d" % contador_de_moeda

func get_fruit():
	vida = min(vida + 5, vida_max)  # <- recupera 3 de vida, ajuste o valor
	GameState.vida = vida
	barra_de_vida.value = vida
	# boost de velocidade e dano
	if boost_timer.is_stopped():
		speed_original = speed
		dano_original = dano
	speed = speed_original + speed_boost
	dano = dano_original + dano_boost
	boost_timer.wait_time = boost_duration
	boost_timer.start()

func _on_boost_timer_timeout() -> void:
	speed = speed_original
	dano = dano_original

func desbloquear_tiro():
	pode_atirar = true
	GameState.pode_atirar = true 

func disparar():
	if not pode_atirar:
		return
	var bala = cena_bala.instantiate() as Area2D
	var direcao = -1 if $Sprite2D.flip_h else 1
	bala.position = global_position + Vector2(direcao * 20, 0)
	bala.velocidade = direcao * velocidade_bala
	get_parent().add_child(bala)
