extends StaticBody2D

var editor_properties : Dictionary = {
	"description" : "Breakable glass.\nIt is solid until the player does a specific action, which then breaks the glass, allowing you to go through it. What action breaks the glass is character specific.",
	"object_path" : "res://Objects/BreakableGlass.tscn",
	"object_type" : "normal",
	"layer" : "selected",
	"rect" : Rect2(64, 64, 128, 128),
	"editable_properties" : {
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

var line_offset : float = 2

func _process(_delta):
	$stained_glass.scale =Vector2(2, 2) / scale
	$stained_glass.region_rect.size = scale * 64
	$stained_glass/Outline.points[0].x = line_offset
	$stained_glass/Outline.points[0].y = line_offset
	$stained_glass/Outline.points[1].x = scale.x * 128 - line_offset
	$stained_glass/Outline.points[1].y = line_offset
	$stained_glass/Outline.points[2].x = scale.x * 128 - line_offset
	$stained_glass/Outline.points[2].y = scale.y * 128 - line_offset
	$stained_glass/Outline.points[3].x = line_offset
	$stained_glass/Outline.points[3].y = scale.y * 128 - line_offset
	$stained_glass/Outline.points[4].x = line_offset
	$stained_glass/Outline.points[4].y = line_offset
