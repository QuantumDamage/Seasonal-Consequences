extends Node2D

func _process(delta):
	if Input.is_action_just_pressed("ui_select"):
		get_tree().change_scene_to_file("res://scenes/Main.tscn")
