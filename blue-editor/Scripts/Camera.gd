extends Node2D

var editor_properties : Dictionary

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
