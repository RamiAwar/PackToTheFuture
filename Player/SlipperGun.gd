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

	if target.x < 0:
		scale.x = -1
#		$Sprite/Sprite2.flip_h = true
#		$Sprite/Sprite2.rotation_degrees = -75
#		$Sprite/Sprite2.position.x = -11.6*$Sprite/Sprite2.scale.x
		
#		$Sprite.flip_h = true
#		$Sprite.offset.x = -4.6*$Sprite.scale.x

#		$Emitter.position.x = -20*$Sprite.scale.x
		
		rotation = -angle

	else:
		scale.x = 1
#		$Sprite/Sprite2.rotation_degrees = 65.8
#		$Sprite/Sprite2.position.x = 11.6*$Sprite/Sprite2.scale.x
#		$Sprite/Sprite2.flip_h = false
		
#		$Sprite.offset.x = 4.6*$Sprite.scale.x
#		$Sprite.flip_h = false
		
#		$Emitter.position.x =  20*$Sprite.scale.x

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
		$Emitter.trigger(angle)

func ShootState():
	
	pass
		
		
func _on_Shoot_animation_end():
	gun_state = states.IDLE
	animation_state.travel("Idle")
	
