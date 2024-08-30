extends Node2D

var editor_properties : Dictionary = {
	"description" : "Ground that crumbles when stood on.",
	"object_path" : "res://Objects/April/WeakGround.tscn",
	"object_type" : "normal",
	"layer" : "selected",
	"rect" : Rect2(0, 0, 64, 64),
	"editable_properties" : {
		"stability" : [TYPE_INT, 1, 29, 1, "frames"],
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


export var stability : int = 29


func _ready():
	pass


func _physics_process(_delta):
	$sprite.frame = stability * 0.5
