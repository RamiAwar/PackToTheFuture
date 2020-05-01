extends Sprite

class_name Joystick

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var OS_MOBILE = OS.get_name() == "Android" or OS.get_name() == "iOS";

func get_value():
	return $JoystickButton.get_value()
	
# Called when the node enters the scene tree for the first time.
func _ready():
	if !OS_MOBILE:
		queue_free()


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
