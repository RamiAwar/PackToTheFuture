extends Control

var scene_path_to_load


# Called when the node enters the scene tree for the first time.
func _ready():
	$MarginContainer/VBoxContainer/Start.grab_focus()
	pass

func _on_Start_pressed():
	scene_path_to_load = "res://UI/HowToPlay.tscn"
	get_tree().change_scene(scene_path_to_load)

func _on_Quit_pressed():
	get_tree().quit()
