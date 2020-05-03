extends Node2D

export (PackedScene) var houseA
export (PackedScene) var foodA

func place_house(location):
	var house = houseA.instance()
	house.global_position = location
	add_child(house)
	
func place_food(location):
	var food = foodA.instance()
	food.global_position = location
	add_child(food)
	
	
