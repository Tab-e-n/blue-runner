extends Node2D

onready var last_global_position : Vector2 = global_position
onready var starting_rotation : float = global_rotation_degrees

var player : Node2D = null
var momentum : Vector2

func _physics_process(delta):
	global_rotation_degrees = starting_rotation
	
	if player:
		if player.moving_ground:
			player.position += (global_position - last_global_position)
			momentum = (global_position - last_global_position) / Vector2(delta, delta)
		else:
			player = null
	
	last_global_position = global_position
