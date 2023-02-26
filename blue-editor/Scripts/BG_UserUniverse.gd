extends Node2D

var editor_properties : Dictionary = {
	"description" : "The User Universe background.",
	"object_path" : "res://Objects/Backgrounds/BG_UserUniverse.tscn",
	"object_type" : "bg", # some object types have a limited amount of the times they can appear
	"layer" : "bg", # selected or special
	"rect" : Rect2(0, 0, 2048, 1536),
	"editable_properties" : {
		"bg_color" : [TYPE_COLOR, 0, 0, 0],
	},
	"unchangeable_properties" : {
		"scale" : true,
		"rotation" : true,
		"z_index" : true,
		"color" : true,
		"order" : true,
	},
	"attachable" : false,
}

export var bg_color : Color = Color(0, 0.6, 0.57, 1)
var start_position : Vector2

func ready_up(camera : Node2D):
	camera = get_parent().find_node("Camera")
	if camera != null:
		start_position = camera.position
		
		scale = camera.zoom / 2
	$vis.modulate = bg_color

func update_self(cam_target : Vector2):
	position = cam_target
	
	for line in range(13):
		for i in range(2):
			get_node("vis/line_" + String(line)).points[i + 1].x = (int(start_position.x - position.x) % 384) / 4 + 512
		for i in range(2):
			get_node("vis/line_" + String(line)).points[i * 3].x = (int(start_position.x - position.x) % 384) / 2.5 + 128 + 64 * line
