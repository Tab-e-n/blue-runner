extends Node2D

var editor_properties : Dictionary = {
	"object_path" : "res://Objects/SpinningArm.tscn",
	"object_type" : "normal",
	"layer" : "selected",
	"rect" : Rect2(0, -128, 24, 288),
	"editable_properties" : {
		"spin_time_frames" : [TYPE_INT, 0, 0, 1],
		"direction" : [TYPE_BOOL, 0, 0, 0],
		"timer" : [TYPE_INT, 0, 0, 1],
		"lenght" : [TYPE_REAL, 0, 0, 0.05],
		"attached_nodes" : [TYPE_NIL, 0, 0, 0],
	},
	"unchangeable_properties" : {
		"scale" : true,
		"rotation" : true,
		"z_index" : false,
		"color" : false,
		"order" : false,
	},
	"attachable" : true,
}

export var spin_time_frames : int = 120
export var direction : bool = true
export var timer : int = 0
export var lenght : float = 1

var rotations = []

var attached_nodes = [null]
var scale_hinge : float
var timer_hinge : int

func _ready():
	pass

func _process(_delta):
	rotations.resize(spin_time_frames)
	var step : float = 360 / float(spin_time_frames)
	var current : float = 0
	for i in range(rotations.size()):
		if direction: rotations[i] = current
		else: rotations[spin_time_frames - i - 1] = current
		current += step
	
	if timer >= spin_time_frames: timer = spin_time_frames - 1
	
	$decor_steel_pipe.rotation_degrees = rotations[timer]
	$editor_pointer.rotation_degrees = rotations[timer]
	
	$decor_steel_pipe.scale.y = lenght + 0.125
	$editor_circle.scale.x = lenght
	$editor_circle.scale.y = lenght
	$editor_pointer.offset.y = -256 * lenght - 32
	$editor_pointer.flip_h = direction
	if attached_nodes[0] != null:
		attached_nodes[0].position.y = lenght * -256

func attached(node : Node2D):
	if attached_nodes[0] != null:
		attached_nodes[0].queue_free()
	attached_nodes[0] = node
	node.position.x = 0
	node.position.y = lenght * -256

func detached(_node : Node2D):
	attached_nodes[0] = null

func edit_left_just_pressed(_mouse_pos, _cursor_pos, _level_scale):
	scale_hinge = lenght

func edit_left_pressed(mouse_pos, mouse_hinge):
	lenght = stepify(scale_hinge + (mouse_hinge.y - mouse_pos.y) / 512, 0.05)

func edit_right_just_pressed(_mouse_pos, _cursor_pos, _level_scale):
	timer_hinge = timer

func edit_right_pressed(mouse_pos, mouse_hinge):
	# warning-ignore:narrowing_conversion
	timer = stepify(timer_hinge + (mouse_hinge.y - mouse_pos.y) / 16, 1)
	if timer < 0: timer = 0
	if timer >= spin_time_frames: timer = spin_time_frames - 1
