extends Node2D

export var shift : float = 0

var color_start : Color = Color(0.05, 0.9, 0.95, 1)
var color_end : Color = Color(0.13, 0.21, 0.38, 1)
var color_star : Color = Color(0.05, 0.9, 0.95, 1)

func start(type : int):
	if type == 0:
		$AnimationPlayer.play("Particle")
	else:
		$AnimationPlayer.play("Star")
		$star.modulate = color_star

func _physics_process(_delta):
	$Light.color = color_start * Color(1 - shift, 1 - shift, 1 - shift, 1 - shift) + color_end * Color(shift, shift, shift, shift)
