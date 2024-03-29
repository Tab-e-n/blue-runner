extends Node2D

var editor_properties : Dictionary = {
	"description" : "A node that tells the game what music should be playing.",
	"object_path" : "res://Objects/MusicControl.tscn",
	"object_type" : "normal",
	"layer" : "selected",
	"rect" : Rect2(0, 0, 64, 64),
	"editable_properties" : {
		"song" : [TYPE_STRING],
		"stop_music" : [TYPE_BOOL],
		"fast_transition" : [TYPE_BOOL],
	},
	"unchangeable_properties" : {
		"scale" : true,
		"rotation" : true,
		"z_index" : true,
		"color" : true,
		"order" : true,
	},
	"attachable" : false,
}


export var song : String = ""
export var stop_music : bool = false
export var fast_transition : bool = true

