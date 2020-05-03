extends Control

var time = 3
onready var arr = [$LabelHoard, $Label1, $Label2, $Label3]
# Called when the node enters the scene tree for the first time.
func _ready():
	$Timer.start()
	arr[time].set_deferred("visible", true)
	

func _on_Timer_timeout():
	arr[time].set_deferred("visible", false)
	time -= 1
	if time >= 0:
		arr[time].set_deferred("visible", true)
		$Timer.start()
