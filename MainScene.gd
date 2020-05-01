extends Node2D



# Called when the node enters the scene tree for the first time.
func _ready():
	ProceduralGeneration._generate_world($WallTileMap, $DirtTileMap)
	pass
	
	
func _input(event):

#	pass
	if Input.is_action_pressed("roll"):
		$WallTileMap.clear()
		$DirtTileMap.clear()
		ProceduralGeneration._generate_world($WallTileMap, $DirtTileMap)
	
	
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
