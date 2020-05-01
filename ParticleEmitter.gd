tool
extends Node2D

export (PackedScene) var Scene;
export var MaxParticles = 3

export(float, -1, 1) var TargetDirectionRangeX;
export(float, -1, 1) var TargetDirectionRangeY setget set_range_y;
export(Vector2) var VerticalVelocityRange;

export var center: Vector2 = Vector2(0.0, 0.0) setget set_center
export var color: Color = Color(1, 0, 0, 0.5) setget set_color
export var radius: float = 10.0 setget set_radius
export var angle_from:int = 0 setget set_angle_from
export var angle_to: int = 360 setget set_angle_to 

var n_particles = 0;

func set_range_y(value):
		if value > TargetDirectionRangeX:
			TargetDirectionRangeY = value;
		else:
			TargetDirectionRangeY = TargetDirectionRangeX;


func _ready():
	n_particles = Random.rng.randi()%MaxParticles;
	n_particles = 100

func _physics_process(_delta):
	pass
	

func trigger(angle):
	
	if n_particles == 0:
		return
	
	n_particles -= 1;		
	var particle = Scene.instance()
	particle.global_position = global_position;
	
	
	var random_direction = Vector2(global_position - get_parent().global_position - Vector2(0, position.y)).normalized()
	var jump_velocity = Random.rng.randf_range(150, 300);
	
	particle.initialize(random_direction, jump_velocity);
	$Node.call_deferred("add_child", particle)

func set_center(value):
	center = value
	update()
	
func set_color(value):
	color = value
	update()
	
func set_radius(value):
	radius = value
	update()
	
func set_angle_from(value):
	angle_from = value
	if value > angle_to:
		angle_to = angle_from;
	
	update()

func set_angle_to(value):
	if value < angle_from:
		angle_to = angle_from;
	else:
		angle_to = value
	update()

func draw_circle_arc(_center, _radius, _angle_from, _angle_to, _color):
	
	var nb_points = 32
	var points_arc = PoolVector2Array()

	for i in range(nb_points + 1):
		var angle_point = deg2rad(_angle_from + i * (_angle_to-_angle_from) / nb_points - 90)
		points_arc.push_back(_center + Vector2(cos(angle_point), sin(angle_point)) * _radius)

	for index_point in range(nb_points):
		draw_line(points_arc[index_point], points_arc[index_point + 1], _color)


func draw_circle_arc_poly( _center, _radius, _angleFrom, _angleTo, _color ):
	var nbPoints = 32
	var pointsArc = PoolVector2Array()
	pointsArc.push_back(_center)
	var colors = PoolColorArray([_color])
	
	for i in range(nbPoints+1):
		var anglePoint = _angleFrom + i*(_angleTo-_angleFrom)/nbPoints - 90
		pointsArc.push_back(center + Vector2( cos( deg2rad(anglePoint) ), sin( deg2rad(anglePoint) ) )* _radius)
	draw_polygon(pointsArc, colors)


func _draw():
	
	if not Engine.editor_hint:
		return
		
		
	draw_circle_arc_poly(center, radius, angle_from, angle_to, color)
