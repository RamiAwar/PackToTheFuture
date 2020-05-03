extends Area2D

const HitEffect = preload("res://Effects/HitEffect.tscn")
var invincibility = false setget set_invincibility
onready var timer = $Timer;

signal invincibility_start
signal invincibility_end


func start_invincibility(duration):
	self.invincibility = true
	timer.start(duration);

func set_invincibility(value):
	
	invincibility = value
	
	if invincibility:
		emit_signal("invincibility_start")
	else:
		emit_signal("invincibility_end")

func create_hit_effect():
	var effect = HitEffect.instance()
	var main = get_tree().current_scene
	main.add_child(effect)
	effect.global_position = global_position # - Vector2(0,8)

func _on_Timer_timeout():
	self.invincibility = false
	
func _on_Hurtbox_invincibility_end():
	set_deferred("monitoring", true)

func _on_Hurtbox_invincibility_start():
	set_deferred("monitoring", false)
