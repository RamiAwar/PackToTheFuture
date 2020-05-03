extends Node


export (int) var boss_minimum_spawn_wait = 5
export (int) var boss_range_spawn_wait = 10
var granny_position = Vector2(0, 0)
var nav_2d = null
var detected_enemies = 0
var dayNum = 1

onready var shop_position = Vector2(0, 0)
onready var house_position = Vector2(0, 0)

var number_of_professors = 1;

var has_groceries:bool = false

var boss: Control
signal reset_hoard_timer


var transition_controller : ColorRect
var random_placer : YSort



var day_label: Label

func increment_variables():
	has_groceries = false
	dayNum += 1
	day_label.text = str(dayNum)

	ProceduralGeneration.min_dist_infected -= 1
	if ProceduralGeneration.min_dist_infected < 4:
		ProceduralGeneration.min_dist_infected = 4;

	ProceduralGeneration.lookaround_infected += 3;
	number_of_professors = dayNum/5

func reset_variables():
	ProceduralGeneration.min_dist_infected = 10
	ProceduralGeneration.lookaround_infected = 30
	number_of_professors = 1
	has_groceries = false
	dayNum = 1
	day_label.text = str(dayNum)

func initialize():
	fadeout()
	emit_signal("reset_hoard_timer")

func fadeout():
	transition_controller.fadeout()

func fadein():
	transition_controller.fadein()

func end_day():
	increment_variables()
	fadeout();
	$BossSpawn.stop()
	ProceduralGeneration._reset();

func end_life():
	reset_variables()
	fadeout()
	$BossSpawn.stop()
	ProceduralGeneration._reset();




func get_arrow():
	if has_groceries:
		return house_position
	else:
		return shop_position

func got_groceries():
	has_groceries = true
	$BossSpawn.wait_time = boss_minimum_spawn_wait + Random.rng.randi()%boss_range_spawn_wait
	$BossSpawn.start()

func _spawn_boss():
	boss.trigger();
	$BossSpawn.stop()
	for professor in number_of_professors:
		ProceduralGeneration.place_professor(granny_position)
#
#extends Node
#
#
#export (int) var boss_minimum_spawn_wait = 5
#export (int) var boss_range_spawn_wait = 10
#var granny_position = Vector2(0, 0)
#var nav_2d = null
#var detected_enemies = 0
#var dayNum = 1
#
#onready var shop_position = Vector2(0, 0)
#onready var house_position = Vector2(0, 0)
#
#var has_groceries:bool = false
#
#var boss: Control
#signal reset_hoard_timer
#
#
#var transition_controller : ColorRect
#var random_placer : YSort
#
#
#
#var day_label: Label
#
#func increment_variables():
#	dayNum += 1
#	day_label.text = str(dayNum)
#
#
#func reset_variables():
#	dayNum = 1
#	day_label.text = str(dayNum)
#
#func initialize():
#
#	fadeout()
#	emit_signal("reset_hoard_timer")
#
#
#
#func fadeout():
#	transition_controller.fadeout()
#
#func fadein():
#	transition_controller.fadein()
#
#func end_day():
#	increment_variables()
#	fadeout();
#	$BossSpawn.stop()
#	ProceduralGeneration._reset();
#
#
#func end_life():
#	reset_variables()
#	fadeout()
#	$BossSpawn.stop()
#	ProceduralGeneration._reset();
#
#func get_arrow():
#	if has_groceries:
#		return house_position
#	else:
#		return shop_position
#
#func got_groceries():
#	has_groceries = true
#	$BossSpawn.wait_time = boss_minimum_spawn_wait + Random.rng.randi()%boss_range_spawn_wait
#	$BossSpawn.start()
#
#func _spawn_boss():
#	boss.trigger();
#	$BossSpawn.stop()
#	ProceduralGeneration.place_professor(granny_position)
	

