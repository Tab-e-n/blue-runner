extends Sprite

var editor_properties : Dictionary = {
	"object_path" : "res://Objects/Decor/Waterfall.tscn",
	"object_type" : "normal", # some object types have a limited amount of the times they can appear
	"layer" : "selected", # selected or special
	"rect" : Rect2(0, 0, 36, 256),
	"editable_properties" : {
		"frame" : [TYPE_INT, 0, 11, 1] # "name" : [TYPE, min, max, step, start]
	},
	"unchangeable_properties" : {
		"scale" : false,
		"rotation" : false,
		"z_index" : false,
		"color" : false,
		"order" : false,
	},
	"attachable" : false,
}

var timer : int = 0

var frame_hinge

func _ready():
	pass

func _physics_process(_delta):
	pass
	#timer += 1
	#if timer == 3:
	#	if frame == 11: frame = 0
	#	else: frame += 1
	#	timer = 0

func edit_left_just_pressed(_level_mouse_position):
	frame_hinge = frame

func edit_left_pressed(mouse_pos, mouse_hinge):
	# warning-ignore:narrowing_conversion
	frame = stepify(frame_hinge - (mouse_hinge.y - mouse_pos.y) / 16, 1)
	if frame < 0: frame = 0
	if frame > 11: frame = 11
