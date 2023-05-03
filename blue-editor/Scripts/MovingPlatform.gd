extends Node2D

var editor_properties : Dictionary = {
	"description" : "A solid platform.\nIf the platform is moving, the player will move with it if they are touching it. It isn't solid from the bottom or the sides.",
	"object_path" : "res://Objects/MovingPlatform.tscn",
	"object_type" : "normal",
	"layer" : "selected",
	"rect" : Rect2(0, -10, 256, 20),
	"editable_properties" : {
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
