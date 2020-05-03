extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

func point_towards(vector :Vector2):
	
	
#	if (start_point - position).y <= 0:  animationPlayer.play("WalkDown")
#	else: animationPlayer.play("WalkUp")
#	if (start_point - position).x <= 0: $Sprite.flip_h = false
#	else: $Sprite.flip_h = true
#
	var target = (vector - global_position).normalized() ###########
	var angle = atan2(target.y, target.x) ###########
	
	rotation = angle ############

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
