extends Node2D

var editor_properties : Dictionary = {
	"description" : "A solid block. When hit from the bottom, will release a sawblade. Can be set to start invisible.",
	"object_path" : "res://Objects/April/Qblock.tscn",
	"object_type" : "normal",
	"layer" : "selected",
	"rect" : Rect2(0, 0, 64, 64),
	"editable_properties" : {
		"hidden" : [TYPE_BOOL],
#		Default:
#		"variable" : [TYPE],
#		If the type is or includes numbers:
#		"variable" : [TYPE, min, max, step],
#		You can specify additional info if you want.
#		"variable" : [TYPE, min, max, step, suffix],
	},
	"unchangeable_properties" : {
		"scale" : false,
		"rotation" : true,
		"z_index" : false,
		"color" : false,
		"order" : false,
	},
	"attachable" : false,
}


export var hidden : bool = false


func _physics_process(delta):
	if hidden:
		$block.self_modulate = Color(1.0, 1.0, 1.0, 0.5)
	else:
		$block.self_modulate = Color(1.0, 1.0, 1.0, 1.0)

