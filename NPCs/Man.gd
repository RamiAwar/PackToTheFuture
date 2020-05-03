extends KinematicBody2D


#const EnemyDeathEffect = preload("res://Effects/EnemyDeathEffect.tscn")

export var ACCELERATION = 300
export var MAX_SPEED = 80
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
onready var stats = $Stats
onready var playerDetectionZone = $PlayerDetectionZone
onready var hurtbox = $Hurtbox
onready var softCollision = $SoftCollision
onready var wanderController = $WanderController

func _ready():
#	state = pick_random_state([IDLE, WANDER])
#	animationTree.active = true
	animationState.travel("Walk")
	state = pick_random_state([WANDER])

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
			var player = playerDetectionZone.player
			if player != null:
				accelerate_towards(player.global_position, delta)
			else:
				state = IDLE
#				state = WANDER

	if softCollision.is_colliding():
		velocity += softCollision.get_push_vector() * delta * 400
	velocity = move_and_slide(velocity)

func accelerate_towards(point, delta):
	var direction = global_position.direction_to(point)
	velocity = velocity.move_toward(direction * MAX_SPEED, ACCELERATION * delta)
	if velocity.y > 0:  animationPlayer.play("WalkDown")
	else: animationPlayer.play("WalkUp")
#	animationTree.set("parameters/Walk/blend_position", velocity.normalized())
#	sprite.flip_h = velocity.x < 0

func seek_player():
	if playerDetectionZone.can_see_player():
		state = CHASE

func update_wander():
	state = pick_random_state([IDLE, WANDER])
#	state = WANDER
	if state == WANDER:
		wanderController.start_wander_timer(rand_range(1,3))
	else: 
		wanderController.start_wander_timer(rand_range(0,1))

func pick_random_state(state_list):
	state_list.shuffle()
	return state_list.pop_front()

func _on_Hurtbox_area_entered(area):
	
	stats.health -= area.Damage
#	knockback = area.knockback_vector*120
	knockback = -(area.hit_center - global_position).normalized()*120
	hurtbox.create_hit_effect()


func _on_Stats_no_health():
	$PlayerDetectionZone/CollisionShape2D.set_deferred("disabled", true)


func _on_Timer_timeout():
	stats.health = stats.max_health
	$Speech.set_talk()
	$PlayerDetectionZone/CollisionShape2D.set_deferred("disabled", false)
