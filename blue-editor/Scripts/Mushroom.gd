extends Node2D

var editor_properties : Dictionary = {
	"object_path" : "res://Objects/Mushroom.tscn",
	"object_type" : "normal",
	"layer" : "selected",
	"rect" : Rect2(0, -36, 96, 80),
	"editable_properties" : {
		"boost_strenght" : [TYPE_INT, 0, 0, 1],
		"overwrite_momentum" : [TYPE_BOOL, 0, 0, 0],
	},
	"unchangeable_properties" : {
		"scale" : false,
		"rotation" : false,
		"z_index" : false,
		"color" : false,
		"order" : false,
	},
	"attachable" : false,
}

export var boost_strenght : int = 0
export var overwrite_momentum : bool = false

func _process(_delta):
	var boost : Vector2 = Vector2(0, 0)
	var temp_boost_strenght = boost_strenght
	
	if temp_boost_strenght == 0:
		temp_boost_strenght = int(scale.y * 1200)
	boost.y = round(temp_boost_strenght * cos(rotation) * -1)
	boost.x = round(temp_boost_strenght * sin(rotation))
	
	$launch.rotation_degrees = -rotation_degrees
	$launch.scale = Vector2(1, 1) / scale
	
	var gravity = 40
	var ascend_frames : int = int(ceil(temp_boost_strenght / gravity))
	var pos_y = 0
	var momentum_y = boost.y
	var intersect_array : PoolIntArray = []
	intersect_array.resize($launch.points.size())
	for i in range($launch.points.size() - 1):
		intersect_array[i] = (ascend_frames / $launch.points.size()) * i
	intersect_array[$launch.points.size() - 1] = ascend_frames - 1
	var l : int = 0
	for i in range(ascend_frames):
		if i == intersect_array[l]:
			$launch.points[l].x = boost.x * i / 60
			$launch.points[l].y = pos_y / 60
			l += 1
		momentum_y += gravity
		pos_y += momentum_y
