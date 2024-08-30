extends Node2D

var editor_properties : Dictionary = {
	"description" : "Discoball decoration. If the hitbox is enabled, the player will gain style bonus when touching it.",
	"object_path" : "res://Objects/Discoball.tscn",
	"object_type" : "normal",
	"layer" : "selected",
	"rect" : Rect2(0, 0, 128, 128),
	"editable_properties" : {
		"disabled_hitbox" : [TYPE_BOOL],
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

export var disabled_hitbox : bool = false


func _physics_process(delta):
	$Discoball.global_rotation = 0

