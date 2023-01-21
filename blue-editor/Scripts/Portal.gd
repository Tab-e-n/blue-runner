extends Node2D

export var editor_properties : Dictionary = {
	"object_path" : "res://Objects/Finish.tscn",
	"object_type" : "finish", # some object types have a limited amount of the times they can appear
	"layer" : "special", # selected or special
	"rect" : Rect2(0, -32, 64, 64),
	"editable_properties" : {
		"tele_destination" : [TYPE_STRING, 0, 0, 0],
		"par" : [TYPE_REAL, 0, 0, 0],
		"type" : [TYPE_INT, 0, 1, 1],
		"unlock" : [TYPE_STRING, 0, 0, 0],
	},
	"unchangeable_properties" : {
		"scale" : false,
		"rotation" : false,
		"z_index" : false,
		"color" : false,
		"order" : true,
	},
	"attachable" : false,
}

export var tele_destination : String = "res://Scenes/Menu_Level_Select.tscn"
export var par : float = 0

export(int, "XT9", "S1") var type = 0
export var unlock : String = ""

func _ready():
	if name == "Portal":
		$AnimationPlayer.current_animation = "Speen"

func _process(_delta):
	if name == "Finish":
		if type == 0:
			$finish_XT9.visible = true
			$finish_S1.visible = false
		else:
			$finish_XT9.visible = false
			$finish_S1.visible = true
