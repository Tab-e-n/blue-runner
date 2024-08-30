extends BG


var editor_properties : Dictionary = {
	"description" : "The User Universe background.",
	"object_path" : "res://Objects/Backgrounds/BG_UserUniverse.tscn",
	"object_type" : "bg", # some object types have a limited amount of the times they can appear
	"layer" : "bg", # selected or special
	"rect" : Rect2(0, 0, 2560, 1536),
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


func ready_up(camera : Node2D):
	if camera != null:
		start_position = camera.position
		
		scale = camera.zoom * 0.5
	$vis.modulate = bg_color


func update_self(cam_target : Vector2):
	position = cam_target
	
	for line in range(15):
		for i in range(2):
			# warning-ignore:integer_division
			get_node("vis/line_" + String(line)).points[i + 1].x = (int(start_position.x - position.x) % 384) * 0.25 + 512
		for i in range(2):
			get_node("vis/line_" + String(line)).points[i * 3].x = (int(start_position.x - position.x) % 384) * 0.4 + 64 + 64 * line
