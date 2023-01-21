extends Node2D

var editor_properties : Dictionary = {
	"object_path" : "res://Objects/Backgrounds/BG_WaterWay.tscn",
	"object_type" : "bg", # some object types have a limited amount of the times they can appear
	"layer" : "bg", # selected or special
	"rect" : Rect2(0, 0, 2048, 1536),
	"editable_properties" : {
		"bg_color" : [TYPE_COLOR, 0, 0, 0],
		"hill_offset" : [TYPE_VECTOR2, 0, 0, 1],
		"sun_position" : [TYPE_VECTOR2, 0, 0, 1],
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

export var bg_color : Color = Color(1, 1, 1, 1)
export var hill_offset : Vector2 = Vector2(512, 512)
export var sun_position : Vector2 = Vector2(0, 0)

var hills_hinge : Vector2
var sun_hinge : Vector2

var start_position : Vector2

# Called when the node enters the scene tree for the first time.
func ready_up(camera : Node2D):
	
	if camera != null:
		start_position = camera.position
		
		scale = camera.zoom / 2
	
	$back.color = Color(bg_color.r / 2, bg_color.g / 2, bg_color.b / 2, 1)
	$bg3.modulate = Color(bg_color.r, bg_color.g, bg_color.b, 1)
	$bg3/bg2.modulate = Color(bg_color.r, bg_color.g, bg_color.b, 1)
	$bg3/bg2/bg1.modulate = Color(bg_color.r, bg_color.g, bg_color.b, 1)
	
	$sun.position = sun_position


func update_self(cam_target : Vector2):
	position = cam_target
	
	$bg3.position.x = (start_position.x - position.x) / 4 + hill_offset.x
	$bg3.position.y = (start_position.y - position.y) / 8 + hill_offset.y
	
	$bg3/bg2.position.x = (start_position.x - position.x) / 16 + -384
	$bg3/bg2.position.y = (start_position.y - position.y) / 32 + 48
	
	$bg3/bg2/bg1.position.x = (start_position.x - position.x) / 16 + -384
	$bg3/bg2/bg1.position.y = (start_position.y - position.y) / 32 + 48

func edit_left_just_pressed(_level_mouse_position):
	hills_hinge = hill_offset

func edit_left_pressed(mouse_pos, mouse_hinge):
	hill_offset.x = stepify(hills_hinge.x - (mouse_hinge.x - mouse_pos.x), 1)
	hill_offset.y = stepify(hills_hinge.y - (mouse_hinge.y - mouse_pos.y), 1)

func edit_right_just_pressed(_level_mouse_position):
	sun_hinge = sun_position

func edit_right_pressed(mouse_pos, mouse_hinge):
	sun_position.x = stepify(sun_hinge.x - (mouse_hinge.x - mouse_pos.x), 1)
	sun_position.y = stepify(sun_hinge.y - (mouse_hinge.y - mouse_pos.y), 1)
