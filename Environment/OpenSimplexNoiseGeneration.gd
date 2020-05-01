extends Node

const WIDTH = 500
const HEIGHT = 500

export var Octaves = 5
export var Period = 5
export var Lacunarity = 1.5
export var Persistence = 0.75

const TILES = {
	'walls': 0,
	'grass': 1
}

var noise 

func _ready():
	randomize()
	noise = OpenSimplexNoise.new()
	noise.seed = randi()
	
	noise.octaves = Octaves
	noise.period = Period
	noise.lacunarity = Lacunarity
	noise.persistence = Persistence
	
	
func _generate_world(tilemap: TileMap):
	for x in WIDTH:
		for y in HEIGHT:
			var tile_index = _get_tile_index(noise.get_noise_2d(float(x), float(y)));
			if tile_index != -1:
				tilemap.set_cellv(Vector2(x - WIDTH/2, y - HEIGHT/2), tile_index);
				
	tilemap.update_bitmask_region()
	
func _get_tile_index(noise_sample):
	if noise_sample < -0.1:
		return TILES.walls;
	else:
		return -1;
