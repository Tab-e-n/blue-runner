extends StaticBody2D

var editor_properties : Dictionary = {
	"description" : "Solid ground that is only visible up close.",
	"object_path" : "res://Objects/GroundGeneric.tscn",
	"object_type" : "normal",
	"layer" : "selected",
	"rect" : Rect2(0, 0, 64, 64),
	"editable_properties" : {
		"completely_invisible" : [TYPE_BOOL],
		#"name" : [TYPE, min, max, step],
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

export var completely_invisible : bool = false

