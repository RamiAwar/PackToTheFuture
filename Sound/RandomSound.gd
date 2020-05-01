extends Node


export var PitchRange = 0.0
export var NumberOfSources = 4
var index = 0;

# Called when the node enters the scene tree for the first time.
func _ready():
	
	for _i in range(NumberOfSources):
		var player = AudioStreamPlayer.new()
		player.volume_db = -20
		add_child(player)
	
func play():
	
	var sound = SoundManager.get_node("Objects/Coin").get_children()[SoundManager.get_random(1, 3)]
	var player = get_children()[(index)%get_child_count()];
	index += 1;
	player.stop()
	player.pitch_scale = SoundManager.get_random_range(PitchRange)
	player.stream = sound.stream
	player.play()
	
	if index > 10000: 
		index = 0;

func stop():
	for N in get_children():
		N.stop()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
