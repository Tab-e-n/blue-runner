extends Node2D

var editor_properties : Dictionary = {
	"description" : "Gas Gas G G Gas",
	"object_path" : "res://Objects/Gas.tscn",
	"object_type" : "normal",
	"layer" : "selected",
	"rect" : Rect2(0, 0, 1024, 256),
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
		"rotation" : true,
		"z_index" : false,
		"color" : false,
		"order" : false,
	},
	"attachable" : false,
}


func _ready():
	pass


func _physics_process(_delta):
   pass
