extends Node2D

var editor_properties : Dictionary = {
	"object_path" : "res://Objects/Camera.tscn",
	"object_type" : "camera",
	"layer" : "camera",
	"rect" : Vector2(128, 64),
	"editable_properties" : {
		"limit_x" : [TYPE_VECTOR2, 0, 0, 1, 0],
		"limit_y" : [TYPE_VECTOR2, 0, 0, 1, 0],
		"zoom" : [TYPE_VECTOR2, 1, 10, 1, 2],
	},
	"unchangeable_properties" : {
		"scale" : true,
		"rotation" : true,
		"z_index" : true,
		"color" : true,
		"order" : true,
	},
}

export var limit_x : Vector2 = Vector2(0,0)
export var limit_y : Vector2 = Vector2(0,0)

export var zoom : Vector2 = Vector2(2, 2)

func _ready():
	pass

func _process(_delta):
	$camera_zoom.rect_size = Vector2(1024, 768) * zoom
	$camera_zoom.rect_position = Vector2(-512, -384) * zoom
	
	$play_area.points[0] = Vector2(limit_x.x, limit_y.x) + Vector2(-512, -384) * zoom - position
	$play_area.points[1] = Vector2(limit_x.y, limit_y.x) + Vector2(512, -384) * zoom - position
	$play_area.points[2] = Vector2(limit_x.y, limit_y.y) + Vector2(512, 384) * zoom - position
	$play_area.points[3] = Vector2(limit_x.x, limit_y.y) + Vector2(-512, 384) * zoom - position
	$play_area.points[4] = Vector2(limit_x.x, limit_y.x) + Vector2(-512, -384) * zoom - position
