extends Node2D

export var spin_time_frames : int = 120
export var direction : bool = true
export var timer : int = 0
export var lenght : float = 1

var rotations = []

func _ready():
	rotations.resize(spin_time_frames)
	var step : float = 360 / float(spin_time_frames)
	var current : float = 0
	for i in range(rotations.size()):
		if direction: rotations[i] = current
		else: rotations[59 - i] = current
		current += step
		pass
	
	$decor_steel_pipe.scale.y = lenght + 0.125

func _physics_process(_delta):
	rotation_degrees = rotations[timer]
	timer += 1
	if timer == rotations.size():
		timer = 0
