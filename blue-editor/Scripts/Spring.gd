extends Node2D

var editor_properties : Dictionary = {
	"description" : "Will boost the player if they press jump when colliding with it.",
	"object_path" : "res://Objects/April/Spring.tscn",
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
