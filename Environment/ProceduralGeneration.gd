extends Node


var CellSize: Vector2 = Vector2(32, 32);


var WIDTH:int = 1024/CellSize.x	
var HEIGHT:int = 1024/CellSize.y


var max_iterations = 100000
var walker_destroy_chance = 0.4
var walker_change_chance = 0.4
var walker_spawn_chance = 0.2
var walker_max_streak = 4
var walker_max_count = 3
var max_fill_percent = 0.4

var minimum_shop_distance = 28

# Walker class (saves direction and position)
class Walker:
	var dir: Vector2
	var prev_dir:Vector2
	var pos: Vector2
	var streak:int
	
const Tiles = {
	'wall': 0,
	'floor': 1,
	'dirt': 2,
	'empty': -1
}
	
var wall_tilemap : TileMap
var dirt_tilemap: TileMap
var debug_tilemap: TileMap
	
var grid :Array = []
var walkers: Array = []

var start_position:Vector2


var character: KinematicBody2D;
var house: StaticBody2D;
var container: YSort;
var shop: StaticBody2D;
var food: Node2D

func _ready():
	
	pass
	
func _setup():
	# Initialize graph with -1
	grid = _initialize_grid(WIDTH, HEIGHT);	
	walkers = [] # Clear walkers array
	
	var walker = Walker.new();
	walker.dir = Random.RandomDirection();
	walker.prev_dir = walker.dir
	walker.pos = Vector2(Random.rng.randi()%(WIDTH - 6) + 3, Random.rng.randi()%(HEIGHT - 6) + 3);
	walkers.append(walker);
	
	# Set grandma position
	start_position = walker.pos
	
func _generate_world(_wall_tilemap : TileMap, _dirt_tilemap: TileMap, _debug_tilemap: TileMap):
	wall_tilemap = _wall_tilemap
	dirt_tilemap = _dirt_tilemap
	debug_tilemap = _debug_tilemap
	
	_setup();
	_create_floor();
	_post_processing();
	_spawn_tiles();
	
func _reset():
	wall_tilemap.clear()
	dirt_tilemap.clear()
	debug_tilemap.clear()
	
	_setup();
	_create_floor();
	_post_processing();
	_spawn_tiles();
	
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


			
func _post_processing():
	
	var size = 6
	var house_top_left = _place_house(start_position, size);
	# Set house	
	house.global_position = (house_top_left + Vector2(size/2, 2))*CellSize
	GameManager.house_position = house.global_position - Vector2(0, 30)
	character.global_position = (house_top_left + Vector2(size/2, 2.5))*CellSize 
	
	# Get farthest node from start and place grocery store
	var grid_copy = grid.duplicate(true)
	var neighbors = [[1, 0], [0, 1], [-1, 0], [0, -1]]
	var bfs = []
	var last_position = start_position
	bfs.append(start_position);
	
	while !bfs.empty():
		
		var position = bfs.pop_front();
		
		# Check neighbors
		for x in range(neighbors.size()):
			var next = Vector2(position.x + neighbors[x][0], position.y + neighbors[x][1])
			if next.x >= 1 and next.x < WIDTH-1 and next.y >= 1 and next.y < HEIGHT - 1 and grid_copy[next.x][next.y] != Tiles.empty:
				last_position = next
				bfs.append(next)
			grid_copy[next.x][next.y] = Tiles.empty;
			
	# If too close to each other, regenerate
	if (last_position - start_position).length() < minimum_shop_distance:
		_reset()
		return
	

	# TODO: Refactor into function find best rect(size)
	# Find fitting square
	size = 6
	var shop_top_left = _place_house(last_position, size);
	
	# Set SHOP	
	shop.global_position = (shop_top_left + Vector2(size/2, 2))*CellSize
	food.global_position = (shop_top_left + Vector2(size/2, 2))*CellSize + Vector2(0, 20)
	
	# Set arrow pointer
	GameManager.shop_position = shop.global_position
	
	# Create walls
	for x in WIDTH:
		for y in HEIGHT:
			if grid[x][y] == Tiles.floor:				
				for i in range(neighbors.size()):	
					var next = Vector2(x + neighbors[i][0], y + neighbors[i][1])
					if next.x >= 0 and next.x < WIDTH and next.y >= 0 and next.y < HEIGHT:		
						if grid[next.x][next.y] == Tiles.empty:
							grid[next.x][next.y] = Tiles.wall
					
	
	# Remove single walls and setup for dirt tiles
	_remove_singles(Tiles.wall)
	
	
	# Foreground tile placement:
	bfs = []
	grid_copy = []
	
	# Put in all wall nodes into queue
	for x in WIDTH:
		grid_copy.append([])
		for y in HEIGHT:
			if grid[x][y] == Tiles.wall:
				bfs.append(Vector2(x, y))
				grid_copy[x].append(Vector2(grid[x][y], 0))
			else:
				grid_copy[x].append(Vector2(grid[x][y], 50000))
	
	var neighbors8 = [[1, 0], [0, 1], [-1, 0], [0, -1], [-1, -1], [1, 1], [-1, 1], [1, -1]]
	while !bfs.empty():

		var position = bfs.pop_front();
		# Check neighbors
		for x in range(neighbors8.size()):
			var next = Vector2(position.x + neighbors8[x][0], position.y + neighbors8[x][1])
			if next.x >= 1 and next.x < WIDTH-1 and next.y >= 1 and next.y < HEIGHT - 1 and grid_copy[next.x][next.y].x == Tiles.floor:
				grid_copy[next.x][next.y].y = min(grid_copy[next.x][next.y].y, grid_copy[position.x][position.y].y + 1)
				grid_copy[next.x][next.y].x = Tiles.empty
				bfs.append(next)

	# Set dirt tiles where distance from wall is 2
	for x in WIDTH:
		for y in HEIGHT:
			if x == 0 or y == 0 or x == WIDTH-1 or y == HEIGHT - 1:
				continue			
			if grid[x][y] != Tiles.empty and grid_copy[x][y].y >= 2:
				# Make sure it is not a single tile
				grid[x][y] = Tiles.dirt
				
	# Remove single walls and setup for dirt tiles
	_remove_diagonals(Tiles.dirt)
	_remove_singles(Tiles.dirt)
	
func _spawn_tiles():
	for x in WIDTH:
		for y in HEIGHT:
			var tile_index = grid[x][y];		
			if tile_index != -1:
				match tile_index:
					
					Tiles.floor:
						pass
						
					Tiles.dirt:
						dirt_tilemap.set_cellv(Vector2(x*2, y*2), 0);
						dirt_tilemap.set_cellv(Vector2(x*2 + 1, y*2), 0);
						dirt_tilemap.set_cellv(Vector2(x*2, y*2 + 1), 0);
						dirt_tilemap.set_cellv(Vector2(x*2 + 1, y*2 + 1), 0);
						
					Tiles.wall:	
						wall_tilemap.set_cellv(Vector2(x, y), 0);
			else:
				debug_tilemap.set_cellv(Vector2(x, y), 0);
				
										
	dirt_tilemap.update_bitmask_region()
	wall_tilemap.update_bitmask_region()
	debug_tilemap.update_bitmask_region()

	
# Initializes grid to -1 (unassigned)
func _initialize_grid(width: int, height: int):
	var matrix:Array = []
	for x in range(width):
		matrix.append([])
		for y in range(height):
			matrix[x].append(-1)
	return matrix;
		
func _remove_singles(tile_index):
	for x in WIDTH:
		for y in HEIGHT:
			
			# Check if on edges
			if x == 0 or y == 0 or x == WIDTH-1 or y == HEIGHT-1:
				continue
			
			# If not on edges, make sure all surrounding tiles are floor and this is wall
			var position = Vector2(x, y);
			if grid[position.x][position.y] == tile_index:
				# Check if single tile
				if (grid[position.x - 1][position.y] == Tiles.floor and grid[position.x + 1][position.y] == Tiles.floor and
					grid[position.x][position.y - 1] == Tiles.floor and grid[position.x][position.y + 1] == Tiles.floor):
					grid[position.x][position.y] = Tiles.floor

func _remove_diagonals(tile_index):
	for x in WIDTH:
		for y in HEIGHT:
			# Check if on edges
			if x == 0 or y == 0 or x == WIDTH-1 or y == HEIGHT-1:
				continue
				
			# If not on edges, make sure all surrounding tiles are floor and this is wall
			var position = Vector2(x, y);
			if grid[position.x][position.y] == tile_index:
				if (grid[position.x - 1][position.y] == Tiles.floor and grid[position.x + 1][position.y] == Tiles.floor and
					grid[position.x][position.y - 1] == Tiles.floor and grid[position.x][position.y + 1] == Tiles.floor):
					grid[position.x][position.y] = Tiles.floor

				# Check if diagonal tile
				if (grid[position.x - 1][position.y] == Tiles.floor and grid[position.x][position.y-1] == Tiles.floor and
					grid[position.x - 1][position.y-1] == tile_index) or (grid[position.x + 1][position.y] == Tiles.floor and grid[position.x][position.y+1] == Tiles.floor and
					grid[position.x + 1][position.y+1] == tile_index) or (grid[position.x + 1][position.y] == Tiles.floor and grid[position.x][position.y-1] == Tiles.floor and
					grid[position.x + 1][position.y-1] == tile_index) or (grid[position.x - 1][position.y] == Tiles.floor and grid[position.x][position.y+1] == Tiles.floor and
					grid[position.x - 1][position.y+1] == tile_index):
					grid[position.x][position.y] = Tiles.floor

func _remove_diagonals_singles(tile_index):
	for x in WIDTH:
		for y in HEIGHT:
			
			# Check if on edges
			if x == 0 or y == 0 or x == WIDTH-1 or y == HEIGHT-1:
				continue
			
			# If not on edges, make sure all surrounding tiles are floor and this is wall
			var position = Vector2(x, y);
			if grid[position.x][position.y] == tile_index:
				# Check if single tile
				if (grid[position.x - 1][position.y] == Tiles.floor and grid[position.x][position.y-1] == Tiles.floor and
					grid[position.x - 1][position.y-1] == tile_index) or (grid[position.x + 1][position.y] == Tiles.floor and grid[position.x][position.y+1] == Tiles.floor and
					grid[position.x + 1][position.y+1] == tile_index) or (grid[position.x + 1][position.y] == Tiles.floor and grid[position.x][position.y-1] == Tiles.floor and
					grid[position.x + 1][position.y-1] == tile_index) or (grid[position.x - 1][position.y] == Tiles.floor and grid[position.x][position.y+1] == Tiles.floor and
					grid[position.x - 1][position.y+1] == tile_index):
					grid[position.x][position.y] = Tiles.floor

func _find_best_fit(size:int, position:Vector2):
	
	var top_left = position - Vector2(size, size)
	
	top_left.x = max(1, top_left.x)
	top_left.y = max(1, top_left.y)
	
	var bottom_right = top_left + Vector2(size, size)
	bottom_right.x = min(WIDTH-1, bottom_right.x)
	bottom_right.y = min(HEIGHT-1, bottom_right.y)
	
	top_left = bottom_right - Vector2(size, size)
	
	return top_left
	
func _place_house(position, size):
	# Clear tiles for house
	var top_left = _find_best_fit(size, position)
	for x in size:
		for y in size:
			var next_pos = Vector2(top_left.x + x, top_left.y + y);
			grid[next_pos.x][next_pos.y] = Tiles.floor
	return top_left
	
