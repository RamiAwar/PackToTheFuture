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

func _ready():
	animation_tree.active = true
	
func _physics_process(delta):
	
	var target: Vector2 = get_viewport().get_mouse_position() - global_position
	angle = atan2(target.y, abs(target.x))

	if target.x < 0:
		$Sprite.flip_h = true
		$Sprite.offset.x = -15*$Sprite.scale.x
		$Emitter.position.x = -23*$Sprite.scale.x

		rotation = -angle

	else:
		$Sprite.offset.x = 15*$Sprite.scale.x
		$Emitter.position.x = 23*$Sprite.scale.x

		$Sprite.flip_h = false
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
	
	if Input.is_action_just_pressed("attack"):
		pass
		
func _on_Shoot_animation_end():
	gun_state = states.IDLE
	animation_state.travel("Idle")
	
