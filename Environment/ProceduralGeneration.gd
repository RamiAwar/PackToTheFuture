extends Node


var CellSize: Vector2 = Vector2(64, 64);


var WIDTH:int 
var HEIGHT:int


var max_iterations = 100000
var walker_destroy_chance = 0.4
var walker_change_chance = 0.4
var walker_spawn_chance = 0.2
var walker_max_streak = 4
var walker_max_count = 3
var max_fill_percent = 0.4
var tree_spawn_chance = 0.06
var bush_spawn_chance = 0.12

var minimum_shop_distance = 28


var min_dist_infected = 10
var lookaround_infected = 30

var TILEMAP_DEBUG_OFF = 0

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
	'house': 3,
	'tree': 4,
	'bush': 5,
	'shrub': 6,
	'flower': 7,
	'empty': -1
}
	
var wall_tilemap : TileMap
var dirt_tilemap: TileMap
var debug_tilemap: TileMap
var invisible_tilemap: TileMap
var flower_tilemap: TileMap

var grid :Array = []
var walkers: Array = []

var start_position:Vector2

var house_locations = []
var house_position: Vector2

var character: KinematicBody2D;
var house: StaticBody2D;
var container: YSort;
var shop: StaticBody2D;
var random_placer:YSort

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
	house_locations.append(start_position)
	
func _generate_world(_wall_tilemap : TileMap, _dirt_tilemap: TileMap, _debug_tilemap: TileMap, _invisible_tilemap: TileMap, _flower_tilemap: TileMap):
	
	wall_tilemap = _wall_tilemap
	dirt_tilemap = _dirt_tilemap
	debug_tilemap = _debug_tilemap
	invisible_tilemap = _invisible_tilemap
	flower_tilemap = _flower_tilemap
	
	_setup();
	_create_floor();
	_post_processing();
	_spawn_tiles();
	
func _reset():
	
	wall_tilemap.clear()
	dirt_tilemap.clear()
	debug_tilemap.clear()
	invisible_tilemap.clear()
	flower_tilemap.clear()
	
	house_locations = []
	for n in random_placer.get_children():
		n.queue_free()
	
	_setup();
	_create_floor();
	_post_processing();
	_spawn_tiles();
	
	GameManager.emit_signal("reset_hoard_timer")

	
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
			
			# Check if new house can be placed
			if (walkers[i].pos - house_locations.back()).length() > 20:
				# Check against all houses
				var curr_location = walkers[i].pos
				var can_place = true
				for location in house_locations:
					if (location - curr_location).length() < 20:
						can_place = false
				if can_place:
					# Place house
					house_locations.append(curr_location)
					
			
		if float(num_floors)/(WIDTH * HEIGHT) > max_fill_percent:
			break;
		
		_iterations += 1;



func _post_processing():
	
	var size = 8
	var house_top_left = _place_house(start_position, size);
	house_position = house_top_left
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
	
	
	size = 8
	var shop_position = last_position 
	var shop_top_left = _place_house(last_position, size);
	
	# Set SHOP	
	shop.global_position = (shop_top_left + Vector2(size/2, 2))*CellSize
	random_placer.place_food((shop_top_left + Vector2(size/2, 2))*CellSize + Vector2(0, 20))
	
	# Set arrow pointer
	GameManager.shop_position = shop.global_position
	
	# After shop is set, place houses
	# Remove house that is closest to shop
	var min_distance = 10000
	var min_index = -1
	for index in range(house_locations.size()):
		var distance = (house_locations[index] - last_position).length()
		if distance < min_distance:
			min_distance = distance
			min_index = index
	
	house_locations.remove(min_index)
	
	
	size = 8
	# Remove main house
	house_locations.pop_front()
	for location in house_locations:
		house_top_left = _place_house(location, size);
		# Set house	
		house_top_left = (house_top_left + Vector2(size/2, 2))*CellSize
		random_placer.place_house(house_top_left)
		
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
	
	
	
	
	
	# Place trees
	_generate_item("place_tree", Tiles.tree, 6, 35)
	_generate_item("place_bush", Tiles.bush, 4, 35)
	_generate_item("place_shrub", Tiles.shrub, 3, 120)
	_generate_item("place_flower", Tiles.flower, 4, 200, false)
	_generate_item("place_flower", Tiles.flower, 4, 200, false)
	_generate_item("place_flower", Tiles.flower, 4, 200, false)
	
	
	
	_generate_ai("place_infected", min_dist_infected, lookaround_infected)
	
	
	# Foreground tile placement:
	bfs = []
	grid_copy = []
	
	# Put in all wall nodes into queue
	for x in WIDTH:
		grid_copy.append([])
		for y in HEIGHT:
			if (grid[x][y] == Tiles.wall or grid[x][y] == Tiles.bush or grid[x][y] == Tiles.tree or grid[x][y] == Tiles.flower):
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
			if next.x >= 1 and next.x < WIDTH-1 and next.y >= 1 and next.y < HEIGHT - 1 and (
					grid_copy[next.x][next.y].x == Tiles.floor or
					grid_copy[next.x][next.y].x == Tiles.shrub 
				):
				grid_copy[next.x][next.y].y = min(grid_copy[next.x][next.y].y, grid_copy[position.x][position.y].y + 1)
				grid_copy[next.x][next.y].x = Tiles.empty
				bfs.append(next)

	# Set dirt tiles where distance from wall is 2
	for x in WIDTH:
		for y in HEIGHT:
			if x == 0 or y == 0 or x == WIDTH-1 or y == HEIGHT - 1:
				continue			
			if grid[x][y] == Tiles.floor and grid_copy[x][y].y >= 2:
				# Make sure it is not a single tile
				grid[x][y] = Tiles.dirt
				
	# Remove single walls and setup for dirt tiles
	_remove_diagonals(Tiles.dirt)
	_remove_singles(Tiles.dirt)
	_remove_diagonals(Tiles.dirt)
	_remove_diagonals(Tiles.dirt)
	
	
func _spawn_tiles():
	for x in WIDTH:
		for y in HEIGHT:
			var tile_index = grid[x][y];		
			if tile_index != -1:
				match tile_index:
					
					Tiles.floor:
						invisible_tilemap.set_cellv(Vector2(x, y), 0);
						
					Tiles.house:
						dirt_tilemap.set_cellv(Vector2(x*2, y*2), 0);
						dirt_tilemap.set_cellv(Vector2(x*2 + 1, y*2), 0);
						dirt_tilemap.set_cellv(Vector2(x*2, y*2 + 1), 0);
						dirt_tilemap.set_cellv(Vector2(x*2 + 1, y*2 + 1), 0);
#						debug_tilemap.set_cellv(Vector2(x, y), 0)
												
					Tiles.dirt:
						invisible_tilemap.set_cellv(Vector2(x, y), 0);
						dirt_tilemap.set_cellv(Vector2(x*2, y*2), 0);
						dirt_tilemap.set_cellv(Vector2(x*2 + 1, y*2), 0);
						dirt_tilemap.set_cellv(Vector2(x*2, y*2 + 1), 0);
						dirt_tilemap.set_cellv(Vector2(x*2 + 1, y*2 + 1), 0);
						
					Tiles.wall:	
						wall_tilemap.set_cellv(Vector2(x, y), 0);
						
					Tiles.flower:
						invisible_tilemap.set_cellv(Vector2(x, y), 0)
						flower_tilemap.set_cellv(Vector2(x, y), 0);
					
					Tiles.shrub:
						invisible_tilemap.set_cellv(Vector2(x, y), 0)
			else:
#				debug_tilemap.set_cellv(Vector2(x, y), 0);
				wall_tilemap.set_cellv(Vector2(x, y), 0);
										
	dirt_tilemap.update_bitmask_region()
	wall_tilemap.update_bitmask_region()
	debug_tilemap.update_bitmask_region()
#	invisible_tilemap.update_bitmask_region()
	flower_tilemap.update_bitmask_region()
	
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
	
	var top_left = position
	
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
			if x > 1 and y >2 and x < size-2 and y < size-3:
				grid[next_pos.x][next_pos.y] = Tiles.house
				
	return top_left + Vector2(0, 2.7)
	
	
	

func _check_placeable(z):
	var x = z.x
	var y = z.y
	var quad = [[1,1],[1,0],[0,1], [0,0]]
	var placeable = true
	if x <= 0 or y <= 0 or x >= WIDTH-1 or y >= HEIGHT-1:
		return false
		
	for q in quad:
		if grid[x+q[0]][y+q[1]] != Tiles.floor and grid[x+q[0]][y+q[1]] != Tiles.dirt:
			placeable = false
	return placeable
	
func _check_placeable2(z):
	var x = z.x
	var y = z.y
	
	var placeable = true
	if x <= 0 or y <= 0 or x >= WIDTH-1 or y >= HEIGHT-1:
		return false
		
	if grid[x][y] != Tiles.floor and grid[x][y] != Tiles.dirt:
		placeable = false
	
	return placeable
	
func _generate_random_point_around(point, min_dist):
	var r1 = Random.rng.randf()
	var r2 = Random.rng.randf()
	var radius = min_dist*(r1 + 1)
	var angle = 2*PI*r2
	return Vector2(int(point.x + radius*cos(angle)), int(point.y + radius*sin(angle)))
	
func _in_neighborhood(new_point, min_dist, item):
	for x in range(min_dist*2):
		for y in range(min_dist*2):
			if new_point.x + x - min_dist> 0 and new_point.x + x- min_dist < WIDTH-1 and new_point.y + y - min_dist> 0 and new_point.y + y - min_dist< HEIGHT-1:
				if grid[ int(new_point.x) + x - min_dist][ int(new_point.y) + y - min_dist] == item:
					return true
	return false
	
func _generate_item(method, item, min_dist, n_points, use_random_placer=true):

	var queue = []
	var sample_points = []

	var start_position =  Vector2( int((Random.rng.randf()*2 - 1)*(WIDTH/4) + WIDTH/2),
									int((Random.rng.randf()*2 - 1)*(HEIGHT/4) + HEIGHT/2))

	# Generate first point randomly
	while !_check_placeable(start_position):
		start_position = Vector2( int((Random.rng.randf()*2 - 1)*(WIDTH/4) + WIDTH/2),
									int((Random.rng.randf()*2 - 1)*(HEIGHT/4) + HEIGHT/2))
									
	# Guaranteed placeable point
	queue.append(start_position)
	sample_points.append(start_position)
	grid[start_position.x][start_position.y] = item
	
	while not queue.empty():
		
		# Select random element
		var random_index = Random.rng.randi()%queue.size()
		var point = queue[random_index]
		queue.remove(random_index)
		
		for i in range(n_points):
			var new_point = _generate_random_point_around(point, min_dist);
			
			# Check that point is in grid and placeable
			if(_check_placeable(new_point) and not _in_neighborhood(new_point, min_dist, item)):
				queue.append(new_point);
				sample_points.append(new_point);
				for x in range(5):
					for y in range(5):
						if new_point.x + x > 0 and new_point.x + x < WIDTH-1 and new_point.y + y > 0 and new_point.y + y < HEIGHT-1:
							if grid[new_point.x + x - 2][new_point.y + y - 2] == Tiles.dirt:
								grid[new_point.x + x - 2][new_point.y + y - 2] = Tiles.floor
								
				grid[new_point.x][new_point.y] = item
				
				if use_random_placer:
					random_placer.call(method, new_point*CellSize + CellSize/2)
	
	
	
	
func _in_neighborhood2(new_point, min_dist, points):
	
	for point in points:
		if (new_point - point).length() < min_dist:
			return true
	
	return false
	
	
	
	
	
	
func _generate_ai(method, min_dist, n_points, use_random_placer=true):

	var queue = []
	var sample_points = []

	var start_position =  Vector2( int((Random.rng.randf()*2 - 1)*(WIDTH/4) + WIDTH/2),
									int((Random.rng.randf()*2 - 1)*(HEIGHT/4) + HEIGHT/2))

	# Generate first point randomly
	while !_check_placeable2(start_position):
		start_position = Vector2( int((Random.rng.randf()*2 - 1)*(WIDTH/4) + WIDTH/2),
									int((Random.rng.randf()*2 - 1)*(HEIGHT/4) + HEIGHT/2))

	# Guaranteed placeable point
	queue.append(start_position)
	sample_points.append(start_position)
	
	while not queue.empty():
		
		# Select random element
		var random_index = Random.rng.randi()%queue.size()
		var point = queue[random_index]
		queue.remove(random_index)
		
		for i in range(n_points):
			
			var new_point = _generate_random_point_around(point, min_dist);
			
			# Check that point is in grid and placeable
			if(_check_placeable(new_point) and not _in_neighborhood2(new_point, min_dist, sample_points)):
				queue.append(new_point);
				sample_points.append(new_point);
	
	if use_random_placer:
		for i in range(sample_points.size()):
			if (sample_points[i] - house_position).length() > 8:
				random_placer.call(method, sample_points[i]*CellSize + CellSize/2)



func place_professor(position):

	var queue = []
	var sample_points = []

	var start_position =  Vector2( int((Random.rng.randf()*2 - 1)*(WIDTH/4) + WIDTH/2),
									int((Random.rng.randf()*2 - 1)*(HEIGHT/4) + HEIGHT/2))

	# Generate first point randomly
	while (not _check_placeable2(start_position) or (start_position*CellSize - position).length() < 10):
		start_position = Vector2( int((Random.rng.randf()*2 - 1)*(WIDTH/4) + WIDTH/2),
									int((Random.rng.randf()*2 - 1)*(HEIGHT/4) + HEIGHT/2))

	random_placer.place_professor(start_position*CellSize + CellSize/2)









