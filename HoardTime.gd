extends Control

var time = 3
onready var arr = [$LabelHoard, $Label1, $Label2, $Label3]
# Called when the node enters the scene tree for the first time.
func _ready():
	GameManager.connect("reset_hoard_timer", self, "play_hoard")


func play_hoard():
	get_tree().paused = true
	$Timer.start()
	#$LabelDay.set_deferred("visible", true)
	#$LabelDay.set_deferred("text", "Day " + str(GameManager.dayNum))
	arr[time].set_deferred("visible", true)
	

func _on_Timer_timeout():
	arr[time].set_deferred("visible", false)
	time -= 1
	if time >= 0:
		arr[time].set_deferred("visible", true)
		$Timer.start()
	else:
		#$LabelDay.set_deferred("visible", false)
		get_tree().paused = false
		time = 3
		GameManager.fadein()

