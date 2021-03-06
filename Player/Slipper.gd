extends KinematicBody2D

var bullet_velocity = Vector2.ZERO
var grounded = false
var gravity = false
var shadow_velocity = Vector2.ZERO
onready var collisionShape2D = $CollisionShape2D
onready var hitBoxCollision = $Body/Hitbox/CollisionShape2D
onready var animationPlayer = $AnimationPlayer


export (int) var MAX_SPEED = 300;
export (int) var GRAVITY = 1
export (int) var minimum_velocity_threshold = 5


func _ready():

	# Play boomerang sound
	SoundManager.get_node("Objects/Slipper/SlipperRandom").play(true)
	
	
	
func initialize(direction, jump_velocity):
	bullet_velocity = direction*MAX_SPEED;
	
	if bullet_velocity.x < 0:
		$AnimationPlayer.play("airborne")
	else:
		$AnimationPlayer.play_backwards("airborne")
	
func _physics_process(delta):
	
	if not gravity:
		var collision =  move_and_collide(bullet_velocity*delta)
		#position += bullet_velocity*delta;
		if collision:
			collisionShape2D.disabled = true
			hitBoxCollision.disabled = true
			animationPlayer.stop()
			bullet_velocity = Vector2.DOWN
			gravity = true
			if collision.collider.is_in_group("world"):
				SoundManager.get_node("Objects/Wall/WallRandom").play()
			elif collision.collider.is_in_group("leaves"):
				SoundManager.get_node("Objects/Bush/RandomBush").play()
				
		
		else:
			$Body/Hitbox.hit_center = $Body.global_position
	else:
		$Body.position += bullet_velocity;
		if $Body.position.y >= $Shadow.position.y - 4:
			bullet_velocity = Vector2.ZERO
			$Effect.queue_free()
			set_physics_process(false)
			

func collided():
	SoundManager.get_node("Objects/Hit/RandomHit").play(false)
	$Effect.trigger_effect(true, true, false);
	collisionShape2D.set_deferred("disabled", true)
	hitBoxCollision.set_deferred("disabled", true)
	animationPlayer.stop()
	bullet_velocity = Vector2.DOWN
	gravity = true
	
func apply_gravity(delta):

	if (not grounded):
		print("not grounded")
		# Check grounded
		if $Body.position.y <= $Shadow.position.y:
			grounded = true;
#			if bullet_velocity.length() < minimum_velocity_threshold:
			bullet_velocity = 0
			return
#		else:
#			bullet_velocity = 0.5*bullet_velocity.bounce(Vector2.UP);

		bullet_velocity.y += GRAVITY * delta;
#
		$Body.position += Vector2(0, bullet_velocity.y*delta);
		position += shadow_velocity;
		


func _on_Hitbox_area_entered(area):
	collided()
