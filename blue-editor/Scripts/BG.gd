extends Node2D
class_name BG

export var bg_color : Color = Color(1, 1, 1, 1)
onready var camera : Camera2D
var start_position : Vector2


func ready_up(_camera : Node2D):
	pass


func update_self(_cam_target : Vector2):
	pass


func darken_color(color : Color, amount : float = 0.8) -> Color:
	color *= Color(amount, amount, min(amount + 0.1, 1))
	return color


func light_color(color : Color, amount : float = 1.2) -> Color:
	color *= Color(amount, amount, amount)
	color = Color(min(color.r, 1), min(color.g, 1), min(color.b, 1))
	return color
