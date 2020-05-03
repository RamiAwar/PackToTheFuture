extends Node2D

export (PackedScene) var houseA
export (PackedScene) var foodA
export (PackedScene) var treeA
export (PackedScene) var Bush
export (PackedScene) var Shrub

func place_house(location):
	var house = houseA.instance()
	house.global_position = location
	add_child(house)
	house.add_to_group("world")
	
func place_food(location):
	var food = foodA.instance()
	food.global_position = location
	add_child(food)
	
func place_tree(location):
	var tree = treeA.instance()
	tree.global_position = location
	add_child(tree)
	tree.add_to_group("leaves")

func place_bush(location):
	var bush = Bush.instance()
	bush.global_position = location
	add_child(bush)
	bush.add_to_group("leaves")
	
func place_shrub(location):
	var shrub = Shrub.instance()
	shrub.global_position = location 
	add_child(shrub)

