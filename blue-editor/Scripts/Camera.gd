extends Node2D

var editor_properties : Dictionary = {
	"description" : "The camera.\nTo see more of the level at once, increase zoom. The zoom is represented by the blue rectangle. The boundaries in which the camera can scroll are represented with the green rectangle. You can change these boundaries with the limit variables.",
	"object_path" : "res://Objects/Camera.tscn",
	"object_type" : "camera",
	"layer" : "camera",
	"rect" : Rect2(0, 0, 128, 64),
	"editable_properties" : {
		"zoom" : [TYPE_VECTOR2, -10, 10, 1],
		"limit_x" : [TYPE_VECTOR2, 0, 0, 1, "pixels"],
		"limit_y" : [TYPE_VECTOR2, 0, 0, 1, "pixels"],
		"fade_in_darkness_lenght" : [TYPE_INT, 0, 0, 1, "frames"],
		"fade_in_end" : [TYPE_INT, 0, 0, 1, "frames"],
		"fade_out_darkness_lenght" : [TYPE_INT, 0, 0, 1, "frames"],
		"fade_out_end" : [TYPE_INT, 0, 0, 1, "frames"],
		"compatibility_mode" : [TYPE_BOOL],
	},
	"unchangeable_properties" : {
		"scale" : true,
		"rotation" : true,
		"z_index" : true,
		"color" : true,
		"order" : true,
	},
	"attachable" : false,
}

export var limit_x : Vector2 = Vector2(0,0)
export var limit_y : Vector2 = Vector2(0,0)

export var zoom : Vector2 = Vector2(2, 2)

export var fade_in_darkness_lenght : int = 0
export var fade_in_end : int = 12

export var fade_out_darkness_lenght : int = 0
export var fade_out_end : int = 12

export var compatibility_mode : bool = false

var zoom_hinge

func _ready():
	pass

func _process(_delta):
	var screen_size = 640
	if compatibility_mode: screen_size = 512
	$camera_zoom.rect_size = Vector2(screen_size * 2, 768) * zoom
	$camera_zoom.rect_position = Vector2(-screen_size, -384) * zoom
	
	$play_area.points[0] = Vector2(limit_x.x, limit_y.x) + Vector2(-screen_size, -384) * zoom - position
	$play_area.points[1] = Vector2(limit_x.y, limit_y.x) + Vector2(screen_size, -384) * zoom - position
	$play_area.points[2] = Vector2(limit_x.y, limit_y.y) + Vector2(screen_size, 384) * zoom - position
	$play_area.points[3] = Vector2(limit_x.x, limit_y.y) + Vector2(-screen_size, 384) * zoom - position
	$play_area.points[4] = Vector2(limit_x.x, limit_y.x) + Vector2(-screen_size, -384) * zoom - position


func edit_left_just_pressed(_mouse_pos, _cursor_pos, _level_scale):
	zoom_hinge = zoom

func edit_left_pressed(mouse_pos, mouse_hinge):
	zoom.y = stepify(zoom_hinge.y + (mouse_hinge.y - mouse_pos.y) / 128, 1)
	if zoom.y < 1: zoom.y = 1
	if zoom.y > 10: zoom.y = 10
	zoom.x = zoom.y
