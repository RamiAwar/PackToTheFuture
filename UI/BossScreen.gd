extends Control

func _ready():
	visible = false

func trigger():
	visible = true
	get_tree().paused = true
	$Timer.start()
	$AnimationPlayer.play("idle")

#func _input(_event):
#	if _event.is_action_pressed("roll"):
#		trigger()


func _on_Timer_timeout():
	get_tree().paused = false
	visible = false
