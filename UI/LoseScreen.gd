extends Control

func _ready():
	visible = false

func trigger():
	visible = true
	get_tree().paused = true
	
	$Timer2.start()
	$AnimationPlayer.play("idle")
	$highscore.text = "Longest: " + str(Persistent.highscore)

func _on_Timer2_timeout():
	$CenterContainer.visible = true
	$CenterContainer/VBoxContainer/Retry.grab_focus()


func _on_Retry_pressed():
	GameManager.cutout()
	get_tree().paused = false
	visible = false
	ProceduralGeneration._reset()


func _on_Quit_pressed():
	get_tree().quit()
