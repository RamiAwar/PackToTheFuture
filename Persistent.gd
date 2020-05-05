extends Node



var highscore: int 

func _ready():
	
	var save = File.new()
	if not save.file_exists("user://PackToTheFuture.save"):
		return
		
	save.open("user://PackToTheFuture.save", File.READ)
	var data = parse_json(save.get_line())
	
	highscore = data
	
func save():
	
	var dict = {
		"highscore": highscore
	}
	
	var save_game = File.new()
	save_game.open("user://PackToTheFuture.save", File.WRITE)
	
	save_game.store_line(to_json(highscore))
	
	save_game.close()
	


