extends Node2D



export (PackedScene) var treeA
export (PackedScene) var Bush
export (PackedScene) var Shrub
export (PackedScene) var Professor


func place_house(location):
	var house = HouseSpawner.get_random_scene().instance()
	house.global_position = location
	add_child(house)
	house.add_to_group("world")
	
func place_food(location):
#	var food = FoodSpawner.instance()
#	food.global_position = location
#	add_child(food)
	pass
	
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

func place_professor(location):
	var professor = Professor.instance()
	professor.global_position = location
	add_child(professor)
	professor.add_to_group("enemy")

func place_infected(location):
	var infected = InfectedSpawner.get_random_scene().instance()
	infected.global_position = location
	add_child(infected)
	infected.add_to_group("enemy")
