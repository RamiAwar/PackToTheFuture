extends Control

#onready var button1 = $MarginContainer/CenterContainer/VBoxContainer/Button
onready var resumebtn = $MarginContainer/CenterContainer/VBoxContainer/Resume
onready var button2 = $MarginContainer/CenterContainer/VBoxContainer/Quit

func _ready():
	visible = false
#	button1.grab_focus()
	resumebtn.grab_focus()
	
func _physics_process(_delta):
	if resumebtn.is_hovered():
		resumebtn.grab_focus()
#	if button1.is_hovered():
#		button1.grab_focus()
	if button2.is_hovered():
		button2.grab_focus()
		
func _input(_event):
	if _event.is_action_pressed("ui_cancel"):
		resumebtn.grab_focus()
#		button1.grab_focus()
		get_tree().paused = not get_tree().paused
		visible = not visible
		
	


func _on_Button_pressed():
	get_tree().paused = false
	visible = false

func _on_Button2_pressed():
	get_tree().quit()


func _on_Resume_pressed():
	get_tree().paused = false
	visible = false


func _on_Quit_pressed():
	get_tree().quit()
