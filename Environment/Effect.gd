extends Sprite

onready var effect = $Tween
var delete_on_finish = true;

# Specifies whether effect should follow its parent or should be globally statically positioned
export (bool) var StaticPosition = false;
export (float) var TriggerDelay = 0.5;
export (float) var AppendTime = 0; # Time to append to fade out animation

func _ready():
	visible = false
	$AnimationPlayer.stop(true)
	if StaticPosition:
		set_as_toplevel(true);
	
func trigger_effect(_delete_on_finish=true, _trigger_delay=false, fadeout=true):
	
	delete_on_finish = _delete_on_finish
	
	if _trigger_delay:
		trigger_delay(TriggerDelay);		
	
	effect.interpolate_property(
		self, 
		"modulate", 
		Color(1, 1, 1, 1), 
		Color(1, 1, 1, 0), 
		$AnimationPlayer.get_animation("default").length + AppendTime, 
		Tween.TRANS_LINEAR, 
		Tween.EASE_IN
	)
	
	
	# print(self.frames.get_animation_speed("default")/self.frames.get_frame_count("default"))
	
	# Set position if static
	if StaticPosition:
		self.global_position = get_parent().global_position

		
	visible = true
	$AnimationPlayer.play("default")
	if fadeout:
		effect.start()

func _on_Effect_animation_finished():
	if delete_on_finish:
		queue_free()
	else:
		$AnimationPlayer.stop("default")
		visible = false

func trigger_delay(x):
	delay(x)
	get_tree().paused = true

func delay(x):
	yield(get_tree().create_timer(x), "timeout")
	get_tree().paused = false
