extends Node2D

export var editor_properties : Dictionary = {
	"description" : "The old player from plat.\nUse the new one instead of this one, it is better.",
	"object_path" : "res://Objects/Player/Player_Old.tscn",
	"object_type" : "player", # some object types have a limited amount of the times they can appear
	"layer" : "special", # selected or special
	"rect" : Rect2(0, -32, 64, 64), 
	"editable_properties" : {
		"facing" : [TYPE_STRING, 0, 0, 0],
	},
	"unchangeable_properties" : {
		"scale" : true,
		"rotation" : true,
		"z_index" : false,
		"color" : false,
		"order" : true,
	},
	"attachable" : false,
}

export var character_name : String = "greenbox"
export var facing : String = "right"

func _process(_delta):
	$Player_Oldtscn.flip_h = facing == "left"
