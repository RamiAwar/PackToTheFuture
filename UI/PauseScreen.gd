extends Control

onready var button1 = $MarginContainer/CenterContainer/VBoxContainer/Button
onready var button2 = $MarginContainer/CenterContainer/VBoxContainer/Button2

func _ready():
	button1.grab_focus()
	
func _physics_process(_delta):
	if button1.is_hovered():
		button1.grab_focus()
	if button2.is_hovered():
		button2.grab_focus()
		
func _input(_event):
	if _event.is_action_pressed("ui_cancel"):
		button1.grab_focus()
		get_tree().paused = not get_tree().paused
		visible = not visible
		
	


func _on_Button_pressed():
	get_tree().paused = false
	visible = false

func _on_Button2_pressed():
	get_tree().quit()
