extends Node2D

var editor_properties : Dictionary = {
	"description" : "A techno-magical pellet spawner. Every six seconds it will spawn a pellet which follows the player. The green variant spawns a pellet every three seconds, but the pellets go to where the player was when the pellet spawned, not following them.",
	"object_path" : "res://Objects/April/Sender.tscn",
	"object_type" : "normal",
	"layer" : "selected",
	"rect" : Rect2(0, 0, 64, 64),
	"editable_properties" : {
		"green" : [TYPE_BOOL],
		"start_delay" : [TYPE_REAL, 0, 0, 0, "seconds"],
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


export var green : bool = false
export var start_delay : float = 1


func _process(_delta):
	$sprite.frame = green
