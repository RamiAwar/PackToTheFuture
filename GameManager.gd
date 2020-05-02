extends Node


export (int) var boss_minimum_spawn_wait = 5
export (int) var boss_range_spawn_wait = 10

var boss: Control


func got_groceries():
	$BossSpawn.wait_time = boss_minimum_spawn_wait + Random.rng.randi()%boss_range_spawn_wait
	$BossSpawn.start()

func _spawn_boss():
	boss.trigger();
