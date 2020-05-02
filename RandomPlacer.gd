extends Node2D

export (PackedScene) var houseA




func place_house(location):
	var house = houseA.instance()
	house.global_position = location
	add_child(house)
	
	
