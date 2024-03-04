extends Node2D

var editor_properties : Dictionary = {
	"description" : "Hot ground that hurt's to touch. Optional icy theming.",
	"object_path" : "res://Objects/April/Magma.tscn",
	"object_type" : "normal",
	"layer" : "selected",
	"rect" : Rect2(0, 0, 64, 64),
	"editable_properties" : {
		"icy" : [TYPE_BOOL],
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


export var icy : bool = false


func _physics_process(_delta):
   $melt.visible = not icy
   $ice.visible = icy
