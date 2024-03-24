extends Node2D

var editor_properties : Dictionary = {
	"description" : "An finish but for the golf disk. Will remove it's attached nodes when a disk gets caught by it.",
	"object_path" : "res://Objects/April/GolfCatcher.tscn",
	"object_type" : "normal",
	"layer" : "selected",
	"rect" : Rect2(0, -64, 96, 128),
	"editable_properties" : {
#		Default:
#		"variable" : [TYPE],
#		If the type is or includes numbers:
#		"variable" : [TYPE, min, max, step],
#		You can specify additional info if you want.
#		"variable" : [TYPE, min, max, step, suffix],
		"wall_scale" : [TYPE_VECTOR2, 0, 0, 0.01],
		"wall_offset" : [TYPE_VECTOR2, 0, 0, 1],
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


export var wall_scale : Vector2 = Vector2(1, 0.5)
export var wall_offset : Vector2 = Vector2(0, 32)


func _ready():
	pass


func _physics_process(_delta):
	$wall.scale = wall_scale
	$wall.position = wall_offset
