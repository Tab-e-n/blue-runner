extends Node2D

var editor_properties : Dictionary = {
	"object_path" : "res://Objects/HoverText.tscn",
	"object_type" : "normal",
	"layer" : "selected",
	"rect" : Rect2(0, 0, 64, 64),
	"editable_properties" : {
		"text" : [TYPE_STRING, 0, 0, 0],
		"offset" : [TYPE_VECTOR2, 0, 0, 1],
		"text_size" : [TYPE_VECTOR2, 0, 0, 1],
		"text_scale" : [TYPE_VECTOR2, 0, 0, 0.05],
		"text_color" : [TYPE_COLOR, 0, 0, 0],
		"follow_player" : [TYPE_BOOL, 0, 0, 0],
		"delay_until_appearing" : [TYPE_INT, 0, 0, 1],
		"appear_time" : [TYPE_INT, 0, 0, 1],
		#"name" : [TYPE, min, max, step],
	},
	"unchangeable_properties" : {
		"scale" : false,
		"rotation" : true,
		"z_index" : false,
		"color" : true,
		"order" : false,
	},
	"attachable" : false,
}

export var text : String = "empty"
export var offset : Vector2 = Vector2(0, 0)
export var text_size : Vector2 = Vector2(341, 85)
export var text_scale : Vector2 = Vector2(0.75, 0.75)
export var text_color : Color = Color(1, 1, 1, 1)
export var follow_player : bool = false
export var delay_until_appearing : int = 0
export var appear_time : int = 60

func _process(_delta):
	$Text.rect_scale = text_scale / scale
	$editor_point.scale = Vector2(1, 1) / scale
	$Text.rect_size = text_size
	$Text.text = text
	$Text.modulate = Color(text_color.r, text_color.g, text_color.b, 1)
	$editor_point.modulate = Color(text_color.r, text_color.g, text_color.b, 1)
	$Text.rect_position = offset
