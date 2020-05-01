extends Node


export var CellSize: Vector2 = Vector2(32, 32);


var WIDTH:int = 1024/CellSize.x	
var HEIGHT:int = 1024/CellSize.y


export (float) var max_iterations = 100000
export (float) var walker_destroy_chance = 0.4
export (float) var walker_change_chance = 0.4
export (float) var walker_spawn_chance = 0.2
export (int) var walker_max_streak = 4
export (int) var walker_max_count = 3
export (float) var max_fill_percent = 0.4

# Walker class (saves direction and position)
class Walker:
	var dir: Vector2
	var prev_dir:Vector2
	var pos: Vector2
	var streak:int
	
const Tiles = {
	'wall': 0,
	'floor': 1,
	'empty': -1
}
	
var grid :Array = []
var walkers: Array = []

func _ready():
	
	pass
	
func _setup():
	# Initialize graph with -1
	grid = _initialize_grid(WIDTH, HEIGHT);	
	walkers = [] # Clear walkers array
	
	var walker = Walker.new();
	walker.dir = Random.RandomDirection();
	walker.prev_dir = walker.dir
	walker.pos = Vector2(1, 1);
	walkers.append(walker);
	
	
func _generate_world(wall_tilemap : TileMap, dirt_tilemap: TileMap):
	_setup();
	_create_floor();
	_create_walls();
	_post_processing();
	_spawn_tiles(wall_tilemap, dirt_tilemap);
	
func _create_floor():
	
	var _iterations = 0
	var num_floors = 0
	
	while _iterations < max_iterations:

		# Set tiles
		for i in range(walkers.size()):
			
			if grid[walkers[i].pos.x][walkers[i].pos.y] == Tiles.empty:
				num_floors += 1
				
			grid[walkers[i].pos.x][walkers[i].pos.y] = Tiles.floor;
			
			# Increment streak
			if walkers[i].prev_dir == walkers[i].dir:
				walkers[i].streak += 1
			
			# Check streak
			if walkers[i].streak >= walker_max_streak:
				var new_direction = Random.RandomDirection()
				while new_direction == walkers[i].dir:
					new_direction = Random.RandomDirection()
				walkers[i].dir = new_direction
			
			
		# Random: Maybe destroy walker?
		for i in range(walkers.size()):
			if Random.rng.randf() < walker_destroy_chance and walkers.size() > 1:
				walkers.remove(i);
				break; # Destroy only one walker per iteration
				
		# Random: Pick new direction
		for i in range(walkers.size()):
			if Random.rng.randf() < walker_change_chance:
				walkers[i].dir = Random.RandomDirection()
				
				
		
		# Random: Spawn new walker
		for i in range(walkers.size()):
			if Random.rng.randf() < walker_spawn_chance and walkers.size() < walker_max_count:
				var walker = Walker.new()
				walker.dir = Random.RandomDirection()
				walker.pos = walkers[i].pos
				walkers.append(walker)
				
		# Advance walkers
		for i in range(walkers.size()):
			walkers[i].pos += walkers[i].dir
			
			# Check bounds
			walkers[i].pos.x = clamp(walkers[i].pos.x, 1, WIDTH - 2)
			walkers[i].pos.y = clamp(walkers[i].pos.y, 1, HEIGHT - 2)
			
		if float(num_floors)/(WIDTH * HEIGHT) > max_fill_percent:
			break;
		
		_iterations += 1;
	
	print(num_floors)
	print(_iterations)
		
	
func _create_walls():
	pass
	
func _post_processing():
	pass

func _spawn_tiles(wall_tilemap : TileMap, dirt_tilemap:TileMap):
	for x in WIDTH:
		for y in HEIGHT:
			var tile_index = grid[x][y];		
			if tile_index != -1:
				match tile_index:
					
					Tiles.floor:
						dirt_tilemap.set_cellv(Vector2(x*2, y*2), 0);
						dirt_tilemap.set_cellv(Vector2(x*2 + 1, y*2), 0);
						dirt_tilemap.set_cellv(Vector2(x*2, y*2 + 1), 0);
						dirt_tilemap.set_cellv(Vector2(x*2 + 1, y*2 + 1), 0);	

			else:
				wall_tilemap.set_cellv(Vector2(x, y), 0);
						
										
	dirt_tilemap.update_bitmask_region()
	wall_tilemap.update_bitmask_region()

	
# Initializes grid to -1 (unassigned)
func _initialize_grid(width: int, height: int):
	var matrix:Array = []
	for x in range(width):
		matrix.append([])
		for y in range(height):
			matrix[x].append(-1)
	return matrix;
		
	
