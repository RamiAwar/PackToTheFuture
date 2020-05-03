extends Control

var scene_path_to_load


# Called when the node enters the scene tree for the first time.
func _ready():
	$Menu/CenterRow/Buttons/NewGame.grab_focus()
	pass
#	for button in $Menu/CenterRow/Buttons.get_children():
#		print(button)
#		button.connect("pressed", self, "_on_Button_pressed", [button.scene_to_load])
#
#func _on_Button_pressed(scene_to_load):
#	scene_path_to_load = scene_to_load
#	$FadeIn.show()
#	$FadeIn.fade_in()

func _on_FadeIn_fade_finished():
	get_tree().change_scene(scene_path_to_load)


func _on_NewGame_pressed():
	scene_path_to_load = $Menu/CenterRow/Buttons/NewGame.scene_to_load
	$FadeIn.show()
	$FadeIn.fade_in()


func _on_Quit_pressed():
	get_tree().quit()
