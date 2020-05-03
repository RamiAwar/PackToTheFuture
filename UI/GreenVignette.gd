extends ColorRect

func _physics_process(_delta):
	material.set("shader_param/cutoff", GameManager.danger_value)
	
