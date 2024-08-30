extends Node2D
class_name SpeedArrow

var editor_properties : Dictionary = {
	"description" : "Speed arrow that lights up when touched.",
	"object_path" : "res://Objects/SpeedArrow.tscn",
	"object_type" : "normal",
	"layer" : "selected",
	"rect" : Rect2(0, 0, 32, 32),
	"editable_properties" : {
#		Default:
#		"variable" : [TYPE],
#		If the type is or includes numbers:
#		"variable" : [TYPE, min, max, step],
#		You can specify additional info if you want.
#		"variable" : [TYPE, min, max, step, suffix],
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

func _ready():
	$SpeedArrowBack.play("Move")
