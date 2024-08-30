extends Node2D

var editor_properties : Dictionary = {
	"description" : "A sleeping ghost boy. Try not to disturb this little guy.",
	"object_path" : "res://Objects/April/Snoozy.tscn",
	"object_type" : "normal",
	"layer" : "selected",
	"rect" : Rect2(0, 0, 64, 64),
	"editable_properties" : {
		"flip_h" : [TYPE_BOOL, 0, 0, 0],
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

export var flip_h : bool = false


func _physics_process(_delta):
	$snoozy.flip_h = flip_h
