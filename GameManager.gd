extends Node


export (int) var boss_minimum_spawn_wait = 5
export (int) var boss_range_spawn_wait = 10
var granny_position = Vector2(0, 0)
var nav_2d = null

onready var shop_position = Vector2(0, 0)
onready var house_position = Vector2(0, 0)

var has_groceries:bool = false

var boss: Control
signal reset_hoard_timer

func end_day():
	$BossSpawn.stop()
	ProceduralGeneration._reset();
	emit_signal("reset_hoard_timer")
	

func end_life():
	$BossSpawn.stop()
	ProceduralGeneration._reset();
	emit_signal("reset_hoard_timer")

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

