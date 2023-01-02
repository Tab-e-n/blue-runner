extends Node2D

export var scroll_constant : float = 32

onready var camera : Camera2D
var start_position : Vector2

# Called when the node enters the scene tree for the first time.
func _ready():
	camera = get_parent().find_node("Camera")
	if camera != null:
		start_position = camera.position
		var size = camera.scrolling_objects.size()
		camera.scrolling_objects.resize(size + 1)
		camera.scrolling_objects[size] = self


func update_self(cam_target : Vector2):
	position = cam_target
	
	position.x = (start_position.x - position.x) / scroll_constant
	position.y = (start_position.y - position.y) / (scroll_constant * 2)

