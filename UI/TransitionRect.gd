extends ColorRect

func _ready():
	pass

func fadeout():
	$AnimationPlayer.play("fadeout")
	
func cutout():
	material.set_deferred("shader_param/cutoff", 0)
	
func fadein():
	$AnimationPlayer.play("fadein")
	
