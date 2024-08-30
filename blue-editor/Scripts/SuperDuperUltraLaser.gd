extends Node2D

var editor_properties : Dictionary = {
	"description" : "THE SUPER DUPER ULTRA LASER. It charges for a some time and the fires, destroying any player in its tracks.",
	"object_path" : "res://Objects/April/SuperDuperUltraLaser.tscn",
	"object_type" : "normal",
	"layer" : "selected",
	"rect" : Rect2(0, 0, 128, 128),
	"editable_properties" : {
#		Default:
#		"variable" : [TYPE],
#		If the type is or includes numbers:
#		"variable" : [TYPE, min, max, step],
#		You can specify additional info if you want.
#		"variable" : [TYPE, min, max, step, suffix],
		"chargeup_time" : [TYPE_REAL],
		"blast_lenght" : [TYPE_REAL],
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


export var chargeup_time : float = 15
export var blast_lenght : float = 4096


func _ready():
	pass


func _physics_process(_delta):
   pass
