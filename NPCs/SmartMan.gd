extends KinematicBody2D


#const EnemyDeathEffect = preload("res://Effects/EnemyDeathEffect.tscn")
export var speed = 50 ################## NEW
var path = PoolVector2Array() setget set_path ################ NEW
func set_path(value : PoolVector2Array): ########
	path = value #########
	if value.size() ==0: ############
		return ###############
	# set_process(true) ###############
	
export var ACCELERATION = 300
export var MAX_SPEED = 50
export var FRICTION = 200
export var WANDER_TARGET_RANGE = 20

enum {
	IDLE,
	WANDER,
	CHASE
}
var state = WANDER
var velocity = Vector2.ZERO
var knockback = Vector2.ZERO

onready var animationPlayer = $AnimationPlayer
onready var animationTree = $AnimationTree
onready var animationState = animationTree.get("parameters/playback")
#onready var stats = $Stats
onready var playerDetectionZone = $PlayerDetectionZone
onready var hurtbox = $Hurtbox
onready var softCollision = $SoftCollision
onready var wanderController = $WanderController

var knockback_strength:int

func _ready():
#	state = pick_random_state([IDLE, WANDER])
#	animationTree.active = true
	animationState.travel("Walk")
#	state = pick_random_state([WANDER])
	state = pick_random_state([CHASE])
	knockback_strength = GameManager.knockback_strength

func _physics_process(delta):
	knockback = knockback.move_toward(Vector2.ZERO,FRICTION * delta)
	knockback = move_and_slide(knockback)
	
	match state:
		IDLE:
			velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
			seek_player()
			if wanderController.get_time_left() == 0:
				update_wander()
				
		WANDER:
			seek_player()
			if wanderController.get_time_left() == 0:
				update_wander()
			accelerate_towards(wanderController.target_position, delta)
			if global_position.distance_to(wanderController.target_position) <= WANDER_TARGET_RANGE:
				update_wander()
			
		CHASE:
#			var player = playerDetectionZone.player
#			if player != null:
			accelerate_towards(GameManager.granny_position, delta)
#			else:
#				state = IDLE
#				state = WANDER

	if softCollision.is_colliding():
		velocity += softCollision.get_push_vector() * delta * 400
#	velocity = move_and_slide(velocity)

func accelerate_towards(point, delta):
#	var direction = global_position.direction_to(point)
#	velocity = velocity.move_toward(direction * MAX_SPEED, ACCELERATION * delta)
	var distance = delta * speed
	var start_point = position
	path = GameManager.nav_2d.get_simple_path(global_position, point, false)
#	print(point)
	for i in range(path.size()):
		var distance_to_next = start_point.distance_to(path[0])
		if distance <= distance_to_next and distance >= 0.0:
			position = start_point.linear_interpolate(path[0], distance / distance_to_next)
			position += knockback
			break
		elif distance < 0.0:
			position = path[0]
			set_process(false)
			break
		distance -= distance_to_next
		start_point = path[0]
		path.remove(0)
	if (start_point - position).y <= 0:  animationPlayer.play("WalkDown")
	else: animationPlayer.play("WalkUp")
	if (start_point - position).x <= 0: $Sprite.flip_h = false
	else: $Sprite.flip_h = true
	
#	animationTree.set("parameters/Walk/blend_position", velocity.normalized())
#	sprite.flip_h = velocity.x < 0

func seek_player():
	if playerDetectionZone.can_see_player():
		state = CHASE

func update_wander():
	state = pick_random_state([IDLE, WANDER])
#	state = WANDER
	wanderController.start_wander_timer(rand_range(1,3))
		
func pick_random_state(state_list):
	state_list.shuffle()
	return state_list.pop_front()

func _on_Hurtbox_area_entered(area):
#	stats.health -= area.damage
#
#	$Body/Hitbox/CollisionShape2D.disabled = true
#	$AnimationPlayer.stop()
#	bullet_velocity = Vector2.DOWN
#	gravity = true
#	print(area.get_tree().root)
	knockback = -(area.hit_center - global_position).normalized()*knockback_strength
#	hurtbox.create_hit_effect()


#func _on_Stats_no_health():
#	queue_free()
#	var enemyDeathEffect = EnemyDeathEffect.instance()
#	get_parent().add_child(enemyDeathEffect)
#	enemyDeathEffect.global_position = global_position
