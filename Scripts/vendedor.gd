extends Node2D

@export var item_cost = 10
@export var item_name = "Melancia"
@export var custo_tiro = 20
@export var nome_tiro = "Habilidade de Tiro"

var player = null
var menu_aberto: bool = false
var processando_compra: bool = false  # trava para evitar compra dupla

func _ready() -> void:
	$Label.visible = false
	$Melancia.visible = false
	$Tiro.visible = false

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		player = body
		$Label.text = "%s: %d Moedas | %s: %d Moedas" % [item_name, item_cost, nome_tiro, custo_tiro]
		$Label.visible = true

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		player = null
		menu_aberto = false
		processando_compra = false
		$Melancia.visible = false
		$Tiro.visible = false
		$Label.visible = false

func _process(delta: float) -> void:
	if player and Input.is_action_just_pressed("interação") and not menu_aberto:
		menu_aberto = true
		$Melancia.visible = true
		$Tiro.visible = true

func fechar_botoes():
	menu_aberto = false
	$Melancia.visible = false
	$Tiro.visible = false
	await get_tree().create_timer(0.1).timeout  # pequena pausa antes de reabilitar
	processando_compra = false

func _on_texture_button_pressed() -> void:
	if processando_compra:
		return
	processando_compra = true
	$Melancia.visible = false
	$Tiro.visible = false
	if player and player.contador_de_moeda >= item_cost:
		player.contador_de_moeda -= item_cost
		player.atualiza_hud()
		player.get_fruit()
		$Label.text = "Comprado!"
	else:
		$Label.text = "Moedas insuficientes."
	processando_compra = false  # reseta direto, sem await
	menu_aberto = false

func _on_texture_button_2_pressed() -> void:
	if processando_compra:
		return
	processando_compra = true
	$Melancia.visible = false
	$Tiro.visible = false
	if player.pode_atirar:
		$Label.text = "Já comprado!"
	elif player.contador_de_moeda >= custo_tiro:
		player.contador_de_moeda -= custo_tiro
		player.atualiza_hud()
		player.desbloquear_tiro()
		$Label.text = "Tiro desbloqueado!"
	else:
		$Label.text = "Moedas insuficientes."
	processando_compra = false  # reseta direto, sem await
	menu_aberto = false


func fechar_B():
	menu_aberto = false
	$Melancia.visible = false
	$Tiro.visible = false
