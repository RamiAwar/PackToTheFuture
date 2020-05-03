extends KinematicBody2D


var OS_MOBILE = OS.get_name() == "Android" or OS.get_name() == "iOS";

var player_velocity = Vector2.ZERO

var player_globals = PlayerGlobals

var FRICTION = 600
var ACCELERATION = 680
var MAX_VELOCITY = 100
var ROLL_SPEED = 150
var ROLL_ANIMATION_SPEED = 1.2
var roll_timer = 0;



var player_state = states.MOVE
var input_vector = Vector2.DOWN
var last_input = Vector2.DOWN

var groceries = false

onready var vsize = get_viewport_rect().size
onready var animation_player = get_node("AnimationPlayer")
onready var animation_tree = get_node("AnimationTree")
onready var animation_state = animation_tree.get("parameters/playback")

#onready var sword_hitbox = get_node("SwordPivot/SwordHitbox")

onready var joystick_move: Joystick = $"../../CanvasLayer/UI/Joystick";
onready var attack_button: TouchScreenButton = $"../../CanvasLayer/UI/Attack"
onready var roll_button: TouchScreenButton = $"../../CanvasLayer/UI/Roll";


enum states {
	MOVE
}


func _reset():
	groceries = false

		
func _ready():
	
	animation_tree.active = true;
	
	# Connect no HP signal from PlayerGlobals singleton	
	#player_globals.connect("no_health", self, "_on_PlayerGlobals_no_health");

	# Setup touch button signals if right OS
	if OS_MOBILE:
		#attack_button.connect("pressed", self, "_attack")
		#roll_button.connect("pressed", self, "_roll")
		pass

		
	# Modify animation speed snippet
	animation_tree.set("parameters/Idle/Speed/scale", 1.0)
	animation_tree.set("parameters/MoveUp/Speed/scale", 1.4)
	animation_tree.set("parameters/MoveDown/Speed/scale", 1.4)
	
	UpdateBlendSpaces() # To make all blend spaces face same direction on startup
	
	if has_node("DebugStats"):
		$DebugStats.health = player_globals.health/player_globals.max_health;


# Input Handling
func _process(delta):

	# If desktop get desktop input
	if !OS_MOBILE :
		input_vector.x = Input.get_action_strength("right") - Input.get_action_strength("left")
		input_vector.y = Input.get_action_strength("down") - Input.get_action_strength("up")
	# Else get virtual joystick input
	else:	
		input_vector = joystick_move.get_value()
	
	$Arrow.point_towards(GameManager.get_arrow())
	
	# State machine
	match player_state:
		states.MOVE:
			MoveState(delta)
#		ROLL:
#			RollState(delta)
#		ATTACK:
#			AttackState(delta)


# Physics handling
func _physics_process(delta):
	player_velocity = move_and_slide(player_velocity)
	GameManager.granny_position = global_position


	

func MoveState(delta):
	
	if input_vector != Vector2.ZERO:	
		
		# Set blend spaces to last non-zero input
		UpdateBlendSpaces()
		
		# Steering behavior: Move player velocity towards input with delta acceleration 
		player_velocity = player_velocity.move_toward(input_vector.normalized() * MAX_VELOCITY, ACCELERATION * delta)	
		last_input = input_vector
		
		if input_vector.x < 0:
			$Sprite.flip_h = true
		else:
			$Sprite.flip_h = false
			
		if input_vector.y < 0:
			animation_state.travel("MoveUp");
		else: 
			animation_state.travel("MoveDown");
		
		# Time delay before starting to animate
#		if player_velocity.length() > 20:
#			animation_state.travel("Run")
		
		# User changed his mind, cancel movement
#		else:
#			animation_state.travel("Idle")
		
		# Move interrupt actions:
		# Check if roll button pressed
#		if !OS_MOBILE and Input.is_action_just_pressed("roll"):
#			_roll();
			
	else:	
		# Steer player velocity to zero with stopping friction
		player_velocity = player_velocity.move_toward(Vector2.ZERO, FRICTION*delta)
		
		if last_input.x < 0:
			animation_state.travel("IdleUp")
			animation_state.travel("IdleDown")
		
#	if !OS_MOBILE and Input.is_action_just_pressed("mouse_attack"):
#		var relative_position = get_global_mouse_position() - global_position
#		input_vector = relative_position.normalized()
#		UpdateBlendSpaces()
#		_attack()
	
#func _attack():
#	player_state = ATTACK
#	animation_state.travel("Attack")
#func _roll():
#	if input_vector == Vector2.ZERO:
#		return 
#	player_state = ROLL 
#	animation_state.travel("Roll")


#func AttackState(delta):
#	player_velocity = Vector2.ZERO
#	sword_hitbox.hit_center = position
#
#func attack_animation_begin():
#	SoundManager.get_node("Player/Attack").pitch_scale = SoundManager.get_random_range(AttackPitchRange)
#	SoundManager.get_node("Player/Attack").play()
#
#func attack_animation_end():
#	player_state = MOVE
	
	
#func RollState(delta):
#	if roll_timer <= 0.08:
#		player_velocity = Vector2.ZERO
#		roll_timer += delta
#		if input_vector.length() > 20:
#			last_input = input_vector	
#	elif roll_timer > 0.08:
#		player_velocity = last_input.normalized() * ROLL_SPEED
#
#func roll_animation_end():
#
#	player_velocity = Vector2.ZERO
#	player_state = MOVE
#	roll_timer = 0	


# On player hit
func _on_Hurtbox_area_entered(area):
	
	# Enable invincibility
	$Hurtbox.start_invincibility(0.5)
	
	# Apply damage
	player_globals.health -= area.Damage
	
	# Update debug health bar
	if has_node("DebugStats"):
		$DebugStats.health = player_globals.health/player_globals.max_health;

#func _on_PlayerGlobals_no_health():
#	pass # Replace with function body.

# Update animation blend tree values to get transitions
func UpdateBlendSpaces():
#	animation_tree.set("parameters/Idle/IdleBlendSpace/blend_position", input_vector)
#	animation_tree.set("parameters/Run/RunBlendSpace/blend_position", input_vector)
#	animation_tree.set("parameters/Attack/AttackBlendSpace/blend_position", input_vector)
#	animation_tree.set("parameters/Roll/RollBlendSpace/blend_position", input_vector)
	pass

func _on_GroceryHurtbox_area_entered(area):
	groceries = true
	GameManager.got_groceries()



func _on_GoalHurtbox_area_entered(area):
	if groceries:
		_reset()
		GameManager.end_day()
