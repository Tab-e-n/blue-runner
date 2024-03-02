extends %BASE%

var editor_properties : Dictionary = {
	"description" : "DESCRIPTION",
	"object_path" : "res://filepath",
	"object_type" : "normal",
	"layer" : "selected",
	"rect" : Rect2(0, 0, 64, 64),
	"editable_properties" : {
#		Default:
#		"variable" : [TYPE, min, max, step]
#		You can specify additional info if you want.
#		If the type includes numbers:
#		"variable" : [TYPE, min, max, step, suffix]
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


func _ready()%VOID_RETURN%:
	pass

func _physics_process(delta%FLOAT_TYPE%)%VOID_RETURN%:
   pass
