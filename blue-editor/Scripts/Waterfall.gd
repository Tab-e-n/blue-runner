extends Sprite

var editor_properties : Dictionary = {
	"object_path" : "res://Objects/Decor/Waterfall.tscn",
	"object_type" : "normal", # some object types have a limited amount of the times they can appear
	"layer" : "selected", # selected or special
	"rect" : Vector2(36, 256),
	"editable_properties" : {
		"frame" : [TYPE_INT, 0, 11, 1] # "name" : [TYPE, min, max, step, start]
	},
	"unchangeable_properties" : {
		"scale" : false,
		"rotation" : false,
		"z_index" : false,
		"color" : false,
		"order" : false,
	},
}

var timer : int = 0

func _ready():
	pass

func _physics_process(_delta):
	timer += 1
	if timer == 3:
		if frame == 11: frame = 0
		else: frame += 1
		timer = 0
