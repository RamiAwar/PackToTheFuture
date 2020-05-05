extends Node2D

export var CellSize: Vector2 = Vector2(32, 32);


export var WIDTH:int = 1024
export var HEIGHT:int = 1024


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
	ProceduralGeneration.WIDTH = WIDTH/CellSize.x	
	ProceduralGeneration.HEIGHT = HEIGHT/CellSize.y
	GameManager.WIDTH = WIDTH
	GameManager.HEIGHT = HEIGHT
	GameManager.CellSize = CellSize
	GameManager.camera = $YSort/Grandma/Camera2D
	ProceduralGeneration.CellSize = CellSize
	
	ProceduralGeneration.character = $YSort/Grandma
	ProceduralGeneration.house = $YSort/House
	ProceduralGeneration.container = $YSort
	ProceduralGeneration.shop = $YSort/Shop
	
	ProceduralGeneration.random_placer = $YSort/RandomPlacer
	
	GameManager.transition_controller = $CanvasLayer/TransitionController
	GameManager.grandma = $YSort/Grandma
	
	GameManager.initialize()
	
	ProceduralGeneration._generate_world($WallTileMap, $DirtTileMap, $DebugTileMap, $Navigation2D/InvisibleTileMap, $FlowerTileMap)
	
	GameManager.boss = $CanvasLayer/BossScreen
	GameManager.lose = $CanvasLayer/LoseScreen
	GameManager.nav_2d = $Navigation2D
	GameManager.random_placer = $YSort/RandomPlacer
	
	GameManager.day_label = $CanvasLayer/Day
	$CanvasLayer/Day.text = "1"
	
func _input(event):

#	pass
#	if Input.is_action_pressed("roll"):
#		GameManager.end_day()
#
#	if Input.is_action_pressed("ui_cancel"):
#		GameManager.fadein()
#
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
	pass
