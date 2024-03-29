extends Node2D

var editor_properties : Dictionary = {
	"description" : "A temporary start position for the player. When playtesting a level, the player will start on this spot. Does nothing in normal gameplay.",
	"object_path" : "res://Objects/Player/StartPos.tscn",
	"object_type" : "normal",
	"layer" : "selected",
	"rect" : Rect2(0, -32, 64, 64),
	"editable_properties" : {
	},
	"unchangeable_properties" : {
		"scale" : true,
		"rotation" : true,
		"z_index" : true,
		"color" : true,
		"order" : false,
	},
	"attachable" : false,
}


func _ready():
	pass


func _physics_process(_delta):
   pass
