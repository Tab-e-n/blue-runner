extends Node2D

onready var level : Node2D = get_tree().current_scene

export var spin_time_frames : int = 120
export var direction : bool = true
export var timer : int = 0
export var lenght : float = 1

var rotations = []

func _ready():
	if spin_time_frames < 2: spin_time_frames = 2
	rotations.resize(spin_time_frames)
	var step : float = 360 / float(spin_time_frames)
	var current : float = 0
	for i in range(rotations.size()):
		if direction: rotations[i] = current
		else: rotations[spin_time_frames - i - 1] = current
		current += step
	
# warning-ignore:narrowing_conversion
	if abs(timer) >= spin_time_frames: timer = (spin_time_frames - 1) * sign(timer)
	$decor_steel_pipe.scale.y = lenght + 0.125

func _physics_process(_delta):
	rotation_degrees = rotations[timer]
	if level.timers_active:
		timer += 1
		if timer == rotations.size():
			timer = 0
