extends StaticBody2D

var editor_properties : Dictionary = {
	"object_path" : "res://Objects/Spike.tscn",
	"object_type" : "normal",
	"layer" : "selected",
	"rect" : Rect2(0, 0, 64, 64),
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

func _ready():
	pass

func _physics_process(_delta):
	if collision_mask == 0 or collision_layer == 0:
		$Polygon2D.visible = false
	$saw_1.rotation_degrees += 6
	$saw_2.rotation_degrees -= 6
