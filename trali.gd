extends Line2D

@export var parent:Node
@export var trail_length = 50
var pos_points = Vector2()
var last_points = Vector2()

func _process(delta):
	global_position = Vector2(0,0)
	global_rotation = 0
	
	pos_points = parent.global_position
	if pos_points != last_points:
		add_point(pos_points)
		last_points = pos_points
	
	while get_point_count() > trail_length:
		remove_point(0)
