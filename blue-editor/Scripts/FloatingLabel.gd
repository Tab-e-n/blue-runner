extends Node2D

var editor_properties : Dictionary = {
	"description" : "A text object that appears when the player is in it's area.",
	"object_path" : "res://Objects/Decor/FloatingLabel.tscn",
	"object_type" : "normal",
	"layer" : "selected",
	"rect" : Rect2(0, 0, 64, 64),
	"editable_properties" : {
		"text" : [TYPE_STRING],
		"text_scale" : [TYPE_VECTOR2, 0, 0, 0],
		"text_color" : [TYPE_COLOR],
		"text_outline" : [TYPE_COLOR],
		"font" : [TYPE_STRING],
		"align" : [TYPE_INT, 0, 4, 0],
		"valign" : [TYPE_INT, 0, 4, 0],
		"delay" : [TYPE_REAL, 0, 0, 0, "seconds"],
		"fade" : [TYPE_REAL, 0, 0, 0, "seconds"],
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


const DEFAULT_TEXT_SIZE : Vector2 = Vector2(128, 128)


export(String, MULTILINE) var text : String = """empty"""
export var text_scale : Vector2 = Vector2(0.75, 0.75)
export var text_color : Color = Color(0.92, 0.93, 0.95, 1)
export var text_outline : Color = Color(0.02, 0.02, 0.13, 1)
export var font : String = "Lacrimae"
export var align : int = 1
export var valign : int = 1
export var delay : float = 0
export var fade : float = 1


var last_font : String = "Lacrimae"


func _process(_delta):
	$label.rect_scale = text_scale / scale
	$editor_point.scale = Vector2(1, 1) / scale
	$label.rect_size = (DEFAULT_TEXT_SIZE * scale) / text_scale
	$label.rect_position = -DEFAULT_TEXT_SIZE * Vector2(0.5, 0.5)
	$label.text = text
	$label.align = align
	$label.valign = valign
	
	if last_font != font:
		var font_file = load("res://Text/" + font + ".tres")
		if font_file != null:
			$label.add_font_override("font", font_file)
		else:
			$label.add_font_override("font", preload("res://Text/Lacrimae.tres"))
		
		$label.add_color_override("font_color", text_color)
		$label.add_color_override("font_outline_modulate", text_outline)
		
		last_font = font
