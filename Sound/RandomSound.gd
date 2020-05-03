extends Node


export var PitchRange = 0.3
export var NumberOfSources = 4
export var number_of_samples = 3

var index = 0;
export var transition_duration = 0.6
export var transition_type = 1 # SINE

export var volume = -20

# Called when the node enters the scene tree for the first time.
func _ready():
	
	for _i in range(NumberOfSources):
		var player = AudioStreamPlayer.new()
		var tween = Tween.new()
		tween.connect("tween_completed", self, "_on_Tween_completed")

		player.volume_db = volume
		add_child(player)
		add_child(tween)
		
func _on_Tween_completed(object, key):
	object.stop()
	
func play(fadeout=false):
	
	var sound = $"../".get_children()[SoundManager.get_random(1, number_of_samples)]
	var player = get_children()[(index)%get_child_count()];

	player.stop()
	player.pitch_scale = SoundManager.get_random_range(PitchRange)
	player.stream = sound.stream
	player.play()
	
	if fadeout:
		var tween = get_children()[(index+1)%get_child_count()]
		tween.stop_all()
		tween.interpolate_property(player, "volume_db", 0, -80, transition_duration, transition_type, Tween.EASE_IN, 0)
		tween.start()
	
	index += 2;
	if index > 10000: 
		index = 0;

func stop():
	for N in get_children():
		N.stop()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
