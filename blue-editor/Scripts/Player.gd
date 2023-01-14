extends Node2D

var editor_properties : Dictionary = {
	"object_path" : "res://Objects/Player/Player.tscn",
	"object_type" : "player", # some object types have a limited amount of the times they can appear
	"layer" : "special", # selected or special
	"rect" : Vector2(0, 0),
	"editable_properties" : {
		#"name" : [TYPE, min, max, step, start],
	},
	"unchangeable_properties" : {
		"scale" : true,
		"rotation" : true,
		"z_index" : false,
		"color" : false,
		"order" : true,
	},
}

export var character_name : String = ""
export var facing : String = "right"
export var deny_input : bool = true
export var ghost : bool = false

func _ready():
	pass
