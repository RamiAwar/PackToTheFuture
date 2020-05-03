extends Node2D

export (Array, PackedScene) var packed_scenes;

func get_random_scene():
	var index = Random.rng.randi()%packed_scenes.size()
	return packed_scenes[index]
