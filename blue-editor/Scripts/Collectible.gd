extends Area2D

var editor_properties : Dictionary = {
	"object_path" : "res://Objects/Collectible.tscn",
	"object_type" : "normal",
	"layer" : "selected",
	"rect" : Rect2(0, 0, 32, 64),
	"editable_properties" : {
		"id" : [TYPE_INT, 1, 3, 1],
		"unlock" : [TYPE_STRING, 0, 0, 0],
	},
	"unchangeable_properties" : {
		"scale" : true,
		"rotation" : true,
		"z_index" : false,
		"color" : true,
		"order" : false,
	},
	"attachable" : false,
}

export(int, 1, 3) var id : int = 1
export var unlock : String = ""

func _process(_delta):
	$boltcollect.visible = unlock == ""
	$keycollect.visible = unlock != ""
	
	if collision_mask == 0 or collision_layer == 0:
		$hitbox.visible = false
	else:
		$hitbox.visible = true
		if unlock != "":
			$hitbox.color = Color(0, 1, 1, 0.25)
		elif id == 1:
			$hitbox.color = Color(1, 0, 0, 0.25)
		elif id == 2:
			$hitbox.color = Color(0, 1, 0, 0.25)
		elif id == 3:
			$hitbox.color = Color(0, 0, 1, 0.25)

func edit_left_just_pressed(_mouse_pos, _cursor_pos, _level_scale):
	id += 1
	if id > 3: id = 1
