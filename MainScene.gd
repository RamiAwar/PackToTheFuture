extends Node2D

export var CellSize: Vector2 = Vector2(32, 32);


export var WIDTH:int = 1024/CellSize.x	
export var HEIGHT:int = 1024/CellSize.y


export (float) var max_iterations = 100000
export (float) var walker_destroy_chance = 0.4
export (float) var walker_change_chance = 0.4
export (float) var walker_spawn_chance = 0.2
export (int) var walker_max_streak = 4
export (int) var walker_max_count = 3
export (float) var max_fill_percent = 0.4

# Called when the node enters the scene tree for the first time.
func _ready():
	
	ProceduralGeneration.max_iterations = max_iterations
	ProceduralGeneration.max_fill_percent = max_fill_percent
	ProceduralGeneration.walker_change_chance = walker_change_chance
	ProceduralGeneration.walker_spawn_chance = walker_spawn_chance
	ProceduralGeneration.walker_destroy_chance = walker_destroy_chance
	ProceduralGeneration.walker_max_streak = walker_max_streak
	ProceduralGeneration.walker_max_count = walker_max_count
	ProceduralGeneration.WIDTH = WIDTH
	ProceduralGeneration.HEIGHT = HEIGHT
	ProceduralGeneration.CellSize = CellSize
	
	ProceduralGeneration.character = $YSort/Grandma
	ProceduralGeneration.house = $YSort/House
	ProceduralGeneration.container = $YSort
	ProceduralGeneration.shop = $YSort/Shop
	ProceduralGeneration.food = $YSort/Food
	
	ProceduralGeneration._generate_world($WallTileMap, $DirtTileMap, $DebugTileMap)
	
	
	GameManager.boss = $CanvasLayer/BossScreen 
	
	pass
	
	
func _input(event):

#	pass
	if Input.is_action_pressed("roll"):
		ProceduralGeneration._reset()
	
	
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
