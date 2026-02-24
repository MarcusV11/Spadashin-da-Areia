extends Node2D


func _on_escolher_fase_1_pressed() -> void:
	get_tree().change_scene_to_file("res://Cenas/level_1.tscn")

func _on_escoler_fase_2_pressed() -> void:
	get_tree().change_scene_to_file("res://Cenas/level_2.tscn")


func _on_escolher_fase_3_pressed() -> void:
	get_tree().change_scene_to_file("res://Cenas/level_3.tscn")


func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Cenas/menu.tscn")
