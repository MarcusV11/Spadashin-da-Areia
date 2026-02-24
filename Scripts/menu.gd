extends Node2D


func _on_fase_pressed() -> void:
	get_tree().change_scene_to_file("res://Cenas/escolher_fase.tscn")




func _on_iniciar_pressed() -> void:
	get_tree().change_scene_to_file("res://Cenas/level_1.tscn")


func _on_sair_pressed() -> void:
	get_tree().quit()
