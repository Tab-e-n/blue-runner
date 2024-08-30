extends Sprite

var editor_properties : Dictionary = {
	"description" : "???",
	"object_path" : "res://Objects/PurpleGuy.tscn",
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
	pass


func _physics_process(_delta):
   pass
