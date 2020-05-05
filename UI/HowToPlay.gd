extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func _ready():
	$MarginContainer/VBoxContainer/Start.grab_focus()

func _on_FadeIn_fade_finished():
	get_tree().change_scene("res://MainScene.tscn")


func _on_Start_pressed():

	$FadeIn.fade_in()
