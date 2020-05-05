extends ColorRect


signal fade_finished

func _ready():
	visible = false

func fade_in():
	visible = true
	$AnimationPlayer.play("FadeIn")

func _on_AnimationPlayer_animation_finished(anim_name):
	emit_signal("fade_finished")
