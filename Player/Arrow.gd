extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

func point_towards(vector :Vector2):
	
	var target = (vector - global_position).normalized()
	var angle = atan2(target.y, target.x)
	
	rotation = angle

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
