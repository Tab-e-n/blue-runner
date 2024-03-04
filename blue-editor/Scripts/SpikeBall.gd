extends Node2D

var editor_properties : Dictionary = {
	"description" : "A spinning spikeball. Dangerous. Does allow spike jumps.",
	"object_path" : "res://Objects/April/SpikeBall.tscn",
	"object_type" : "normal",
	"layer" : "selected",
	"rect" : Rect2(0, 0, 64, 64),
	"editable_properties" : {
		"stylish" : [TYPE_BOOL],
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


export var stylish : bool = false


func _physics_process(_delta):
	$StylishCheck.visible = stylish
	if stylish:
		$sprite.texture = preload("res://Visual/April/spr_MoveSpike_stylish.png")
		$StylishCheck.scale.y =  1 + 1.25 / scale.y
	else:
		$sprite.texture = preload("res://Visual/April/spr_MoveSpike_strip3.png")
