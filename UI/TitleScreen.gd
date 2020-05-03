extends Control

var scene_path_to_load


# Called when the node enters the scene tree for the first time.
func _ready():
	$MarginContainer/VBoxContainer/NewGame.grab_focus()
	pass


func _on_FadeIn_fade_finished():
	get_tree().change_scene(scene_path_to_load)


func _on_NewGame_pressed():
	scene_path_to_load = $MarginContainer/VBoxContainer/NewGame.scene_to_load
	$FadeIn.show()
	$FadeIn.fade_in()


func _on_Quit_pressed():
	get_tree().quit()
