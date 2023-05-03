extends Node2D

var editor_properties : Dictionary = {
	"description" : "A booster.\nWhenever the player touches it, it launches the player into the direction its facing. The launches strenght is determined by the amount you set with boost strenght. The booster will add to the players current momentum, unless overwrite_momentum is toggled on.",
	"object_path" : "res://Objects/Booster.tscn",
	"object_type" : "normal",
	"layer" : "selected",
	"rect" : Rect2(0, -12, 48, 24),
	"editable_properties" : {
		"boost_strenght" : [TYPE_INT, 0, 0, 1],
		"overwrite_momentum" : [TYPE_BOOL, 0, 0, 0],
		"flip_direction" : [TYPE_BOOL, 0, 0, 0],
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

export var boost_strenght : int = 0
export var overwrite_momentum : bool = false
export var flip_direction : bool = false

func _physics_process(_delta):
	$booster.flip_h = flip_direction
