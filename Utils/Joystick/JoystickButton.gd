extends TouchScreenButton

var radius = Vector2(16, 16)

var bound_radius = 32
onready var bound_scale = get_parent().scale
onready var boundary_center = get_parent().global_position

onready var offset = radius*global_scale

export var DeadZone = 0.3;

var ongoing_drag = -1

func _ready():
	position = -offset

func get_button_position():
	return position + radius

func _input(event):
		
	if event is InputEventScreenDrag or (event is InputEventScreenTouch and event.is_pressed()):
		
		if event.get_index() != ongoing_drag and ongoing_drag != -1:
			print("second touch detected")
			return
		
		
		
		var dist_from_center = (event.position - boundary_center).length()
		
		if dist_from_center <= bound_radius*bound_scale.x or event.get_index() == ongoing_drag:
			
			global_position = event.position - offset
			
			if get_button_position().length() > bound_radius*bound_scale.x:
				position = get_button_position().normalized()*bound_radius*get_parent().global_scale - offset;
			
			ongoing_drag = event.get_index()
			
	if event is InputEventScreenTouch and !event.is_pressed() and event.get_index() == ongoing_drag:
		position = -offset
		ongoing_drag = -1
		
func get_value():
	if get_button_position().length() > DeadZone:
		return get_button_position().normalized()
	else:
		return Vector2.ZERO
