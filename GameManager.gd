extends Node


export (int) var boss_minimum_spawn_wait = 5
export (int) var boss_range_spawn_wait = 10


onready var shop_position = Vector2(0, 0)
onready var house_position = Vector2(0, 0)

var has_groceries:bool = false

var boss: Control




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

