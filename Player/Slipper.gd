extends Node2D

var bullet_velocity = Vector2.ZERO

export (int) var MAX_SPEED = 300;

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
	position += bullet_velocity*delta;

func _on_Hurtbox_area_entered(area):
	SoundManager.get_node("Objects/Coin/CoinRandom").play();
	queue_free();


