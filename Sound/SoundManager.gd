extends Node


func get_random_range(a):
	return Random.rng.randf_range(1 - a/2, 1 + a/2)

func get_random(a, b):
	return Random.rng.randi_range(a, b)
