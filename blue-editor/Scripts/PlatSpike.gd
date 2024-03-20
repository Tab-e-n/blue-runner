extends StaticBody2D

var editor_properties : Dictionary = {
	"description" : "A sawblade.\nIt hurts to touch. However, with precise timing, you are able to jump off of it.",
	"object_path" : "res://Objects/April/PlatSpike.tscn",
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
	$Sprite.rotation += 0.2
	if stylish != prev_stylish:
		prev_stylish = stylish
		stylish_changed()
	if stylish:
		$style.scale.y = 1 + 1.25 / scale.y


func stylish_changed():
	if stylish:
		$Sprite/Middle.color = Color("ff0080")
		$style.visible = true
	else:
		$Sprite/Middle.color = Color("ff0000")
		$style.visible = false
