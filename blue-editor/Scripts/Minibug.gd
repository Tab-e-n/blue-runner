extends Node2D

var editor_properties : Dictionary = {
	"description" : "A cut enemy from Space Debugger. He is a friend now <3",
	"object_path" : "res://Objects/April/Minibug.tscn",
	"object_type" : "normal",
	"layer" : "selected",
	"rect" : Rect2(0, 0, 64, 64),
	"editable_properties" : {
		"activation_type" : [TYPE_INT, 0, 2, 1],
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


enum {ACTIVATE_ALWAYS, ACTIVATE_UNLOCK, ACTIVATE_NEVER}

export var activation_type : int = ACTIVATE_UNLOCK


func _ready():
	pass


func _physics_process(_delta):
	match(activation_type):
		ACTIVATE_ALWAYS:
			$heart.scale = Vector2(2.0, 2.0)
			$visual.modulate = Color(1.0, 1.0, 1.0)
		ACTIVATE_UNLOCK:
			$heart.scale = Vector2(0.0, 0.0)
			$visual.modulate = Color(1.0, 1.0, 1.0)
		ACTIVATE_NEVER:
			$heart.scale = Vector2(0.0, 0.0)
			$visual.modulate = Color(0.5, 0.5, 0.5)
