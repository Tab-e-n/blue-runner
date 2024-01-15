extends Node2D

onready var last_global_position : Vector2 = global_position
onready var starting_rotation : float = global_rotation_degrees

var momentum : Vector2

func _physics_process(delta):
	global_rotation_degrees = starting_rotation
	momentum = (global_position - last_global_position) / Vector2(delta, delta)
	last_global_position = global_position
