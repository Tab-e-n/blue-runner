extends Line2D

var editor_properties : Dictionary = {
	"description" : "A track.\nOther objects can be attached to this one. They will move on path that the creator specifies. You can edit the path only through edit mode.",
	"object_path" : "res://Objects/Track.tscn",
	"object_type" : "normal",
	"layer" : "selected",
	"rect" : Rect2(0, 0, 128, 128),
	"editable_properties" : {
		"time" : [TYPE_INT, 0, 0, 1],
		"is_a_loop" : [TYPE_BOOL, 0, 0, 0],
		"time_internal" : [TYPE_INT, 0, 0, 1],
		"time_direction" : [TYPE_BOOL, 0, 0, 0],
		"points" : [TYPE_NIL, 0, 0, 0],
		"attached_nodes" : [TYPE_NIL, 0, 0, 0],
	},
	"unchangeable_properties" : {
		"scale" : true,
		"rotation" : true,
		"z_index" : false,
		"color" : false,
		"order" : false,
	},
	"attachable" : true,
}

export var time : int = 120
export var is_a_loop : bool = false
export var time_internal : int = 0
export var time_direction : bool = true

export var auto_pos : bool = true
export var pre_pos : Dictionary = {}

var pos : Dictionary = {}

export var attached_nodes = [null]

func editor_ready():
	reset_points()
	
	#calculate_points()

func _process(_delta):
	if time_internal >= time: time_internal = time - 1

func attached(node : Node2D):
	attached_nodes.append(node)
	node.position -= position

func detached(node : Node2D):
	attached_nodes.erase(node)

func reset_points():
	$points.clear_points()
	for point in range(get_point_count()):
		$points.add_point(get_point_position(point))

func edit_left_just_pressed(mouse_pos, cursor_position, level_scale):
	add_point(Vector2(
		stepify((mouse_pos.x - cursor_position.x) * 1 / level_scale.x, 16),
		stepify((mouse_pos.y - cursor_position.y) * 1 / level_scale.y, 16))
	)
	$points.add_point(Vector2(
		stepify((mouse_pos.x - cursor_position.x) * 1 / level_scale.x, 16),
		stepify((mouse_pos.y - cursor_position.y) * 1 / level_scale.y, 16))
	)
	#calculate_points()

func edit_right_just_pressed(_mouse_pos, _cursor_position, _level_scale):
	if points.size() > 1:
		remove_point(points.size() - 1)
		$points.remove_point($points.points.size() - 1)
	#calculate_points()

func calculate_points():
	if time_internal > time:
		time_internal = time
	if time_internal < 0:
		time_internal = 0
	
	var positions = points
	for i in range(positions.size()):
		positions[i] += position
	
	var time_chunks : PoolIntArray = []
	time_chunks.resize(positions.size()-1)
	var individual_lenght : PoolRealArray = []
	individual_lenght.resize(positions.size()-1)
	var total_lenght : float = 0
	
	# First, we calculate the distances between points
	for i in range(time_chunks.size()):
		var a : float = abs(positions[i].x - positions[i+1].x)
		var b : float = abs(positions[i].y - positions[i+1].y)
		individual_lenght[i] = sqrt(a*a + b*b)
		total_lenght += individual_lenght[i]
	# We calculate the amount of time the lenghts should be moved in 
	for i in range(time_chunks.size()):
		time_chunks[i] = int(float(time) * (individual_lenght[i] / total_lenght))
	# We reconstuck time, just so there aren't any discrepancies
	time = 0
	for i in range(time_chunks.size()):
		time += time_chunks[i]
	
	var shift : int = 0
	for j in range(positions.size()-1):
		if time_chunks[j] == 0: continue
		var pos_fraction : Vector2 = Vector2((positions[j].x - positions[j+1].x) / time_chunks[j], (positions[j].y - positions[j+1].y) / time_chunks[j])
		for i in range(time_chunks[j]):
			pos[i+shift] = Vector2(positions[j].x - pos_fraction.x*i, positions[j].y - pos_fraction.y*i)
		shift += time_chunks[j]
		pos[shift] = positions[j+1]
		
