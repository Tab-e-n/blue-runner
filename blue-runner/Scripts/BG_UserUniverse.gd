extends Node2D

export var bg_color : Color = Color(0, 0.6, 0.57, 1)
onready var camera : Camera2D
var start_position : Vector2

func _ready():
	camera = get_parent().find_node("Camera")
	if camera != null:
		start_position = camera.position
		
		scale = camera.zoom / 2
	$vis.modulate = bg_color

func update_self(cam_target : Vector2):
	position = cam_target
	
	for line in range(15):
		for i in range(2):
			# warning-ignore:integer_division
			get_node("vis/line_" + String(line)).points[i + 1].x = (int(start_position.x - position.x) % 384) / 4 + 512
		for i in range(2):
			get_node("vis/line_" + String(line)).points[i * 3].x = (int(start_position.x - position.x) % 384) / 2.5 + 64 + 64 * line
