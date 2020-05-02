extends KinematicBody2D

var bullet_velocity = Vector2.ZERO
var grounded = false
var gravity = false
var shadow_velocity = Vector2.ZERO


export (int) var MAX_SPEED = 300;
export (int) var GRAVITY = 5
export (int) var minimum_velocity_threshold = 5


func _ready():
	#call_deferred("set_process", false)
	pass
	
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
			bullet_velocity = 0.5*bullet_velocity.bounce(collision.normal)
			gravity = true
		
		shadow_velocity = bullet_velocity
		
	else:
		
		apply_gravity(delta)
	

	
func apply_gravity(delta):

	if (not grounded):
		# Check grounded
		if $Body.position >= $Shadow.position:
			grounded = true;
			if bullet_velocity.length() < minimum_velocity_threshold:
				bullet_velocity = 0
			else:
				bullet_velocity = 0.5*bullet_velocity.bounce(Vector2.UP);

		bullet_velocity.y += GRAVITY * delta;
		
		$Body.position += Vector2(0, bullet_velocity.y*0.5*delta);
		position += shadow_velocity;
		

func _on_Hurtbox_area_entered(area):
	SoundManager.get_node("Objects/Coin/CoinRandom").play();
	queue_free();


