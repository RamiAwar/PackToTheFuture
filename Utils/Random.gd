extends Node

var rng = RandomNumberGenerator.new()

func RandomDirection():
	var i = rng.randi()%4
	match i:
		0:
			return Vector2.DOWN;
		1:
			return Vector2.LEFT;
		2:
			return Vector2.RIGHT;
		3: 
			return Vector2.UP;

func _ready():
	rng.randomize()
