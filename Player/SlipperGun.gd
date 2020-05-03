extends Node2D

enum states {
	IDLE,
	SHOOT
}

onready var gun_state = states.IDLE
onready var animation_player = get_node("AnimationPlayer")
onready var animation_tree = get_node("AnimationTree")
onready var animation_state = animation_tree.get("parameters/playback")

var angle 
var target: Vector2
var facing_up: bool

func _ready():
	animation_tree.active = true

#func _draw():
#
#	var target: Vector2 = (get_global_mouse_position() - global_position).normalized()
#	draw_circle(Vector2.ZERO, 4, Color(1, 0, 0, 1))
#	draw_line(Vector2.ZERO, target, Color(1, 0, 0, 1))

func _physics_process(delta):
	
	target = (get_global_mouse_position() - global_position).normalized()

	angle = atan2(target.y, abs(target.x))

	
	update()
	
	if facing_up:
		show_behind_parent = true
	else:
		show_behind_parent = false

		


	if target.x < 0:
		scale.x = 1
		
		rotation = -angle

	else:
		scale.x = -1
		rotation = angle
	
	match gun_state:
		
		states.IDLE:
			IdleState()
		states.SHOOT:
			ShootState()
		
		
func IdleState():
	
	if Input.is_action_just_pressed("attack"):
	
		gun_state = states.SHOOT
		animation_state.travel("Shoot");
		$Emitter.trigger()

func ShootState():
	
	pass
		
		
func _on_Shoot_animation_end():
	gun_state = states.IDLE
	animation_state.travel("Idle")
	
