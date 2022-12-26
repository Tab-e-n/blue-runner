extends Node2D

export var bg_color : Vector3 = Vector3(1, 1, 1)
export var hill_offset : Vector2 = Vector2(512, 576)
export var sun_position : Vector2 = Vector2(0, 0)

onready var camera : Camera2D
var start_position : Vector2

# Called when the node enters the scene tree for the first time.
func _ready():
	camera = get_parent().find_node("Camera")
	if camera != null:
		start_position = camera.position
		
		scale = camera.zoom / 2
	
	$back.color = Color(bg_color.x / 2, bg_color.y / 2, bg_color.z / 2, 1)
	$bg3.modulate = Color(bg_color.x, bg_color.y, bg_color.z, 1)
	$bg3/bg2.modulate = Color(bg_color.x, bg_color.y, bg_color.z, 1)
	$bg3/bg2/bg1.modulate = Color(bg_color.x, bg_color.y, bg_color.z, 1)
	
	$sun.position = sun_position


func update_self(cam_target : Vector2):
	position = cam_target
	
	$bg3.position.x = (start_position.x - position.x) / 4 + hill_offset.x
	$bg3.position.y = (start_position.y - position.y) / 8 + hill_offset.y
	
	$bg3/bg2.position.x = (start_position.x - position.x) / 16 + -384
	$bg3/bg2.position.y = (start_position.y - position.y) / 32 + 48
	
	$bg3/bg2/bg1.position.x = (start_position.x - position.x) / 16 + -384
	$bg3/bg2/bg1.position.y = (start_position.y - position.y) / 32 + 48

