extends Timer


func _ready():
	self.wait_time = 10
	self.one_shot = true

func _on_Stats_no_health():
	start()
