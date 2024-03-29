extends BG


var editor_properties : Dictionary = {
	"description" : "The Greenbox Stars background.",
	"object_path" : "res://Objects/Backgrounds/BG_Greenbox_Star.tscn",
	"object_type" : "bg", # some object types have a limited amount of the times they can appear
	"layer" : "bg", # selected or special
	"rect" : Rect2(0, 0, 2560, 1536),
	"editable_properties" : {
		"bg_color" : [TYPE_COLOR, 0, 0, 0],
		"star_color" : [TYPE_COLOR, 0, 0, 0],
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

export var star_color : Color = Color(0.9, 0.9, 0.9)


func ready_up(camera : Node2D):
	if camera != null:
		start_position = camera.position
		
		scale = camera.zoom * 0.5
	
	for i in range(3):
		var stars : CPUParticles2D = get_node("stars" + String(i + 1))
		stars.emitting = true
		stars.self_modulate = star_color
	$back.color = bg_color


func update_self(cam_target : Vector2):
	position = cam_target
