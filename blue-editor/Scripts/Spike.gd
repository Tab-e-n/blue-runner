extends StaticBody2D

var editor_properties : Dictionary = {
	"description" : "A sawblade.\nIt hurts to touch. However, with precise timing, you are able to jump off of it.",
	"object_path" : "res://Objects/Spike.tscn",
	"object_type" : "normal",
	"layer" : "selected",
	"rect" : Rect2(0, 0, 64, 64),
	"editable_properties" : {
		"stylish" : [TYPE_BOOL, 0, 0, 0],
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


var prev_stylish : bool = false


func _ready():
	stylish_changed()


func _physics_process(_delta):
	if collision_mask == 0 or collision_layer == 0:
		$Polygon2D.visible = false
	$saw_1.rotation_degrees += 6
	$saw_2.rotation_degrees -= 6
	if stylish != prev_stylish:
		prev_stylish = stylish
		stylish_changed()
	if stylish:
		$style.scale.y = 1 + 1.25 / scale.y

func stylish_changed():
	if stylish:
		$saw_2.texture = preload("res://Visual/saw_3.png")
		$style.visible = true
	else:
		$saw_2.texture = preload("res://Visual/saw_2.png")
		$style.visible = false
