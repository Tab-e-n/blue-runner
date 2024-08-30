extends StaticBody2D

export var editor_properties : Dictionary = {
	"description" : "The levels finish.\nThe player wins if they touch this object. You can change which level the player goes to after their done with this one with tele_destination. You can also set the par time (in seconds), what unlocks after you beat the level and if XT9 or S1 appears as the damsel.",
	"object_path" : "res://Objects/Finish.tscn",
	"object_type" : "finish", # some object types have a limited amount of the times they can appear
	"layer" : "special", # selected or special
	"rect" : Rect2(0, -32, 64, 64),
	"editable_properties" : {
		"tele_destination" : [TYPE_STRING],
		"par" : [TYPE_REAL, 0, 0, 0, "seconds"],
		"type" : [TYPE_INT, 0, 1, 1],
		"unlock" : [TYPE_STRING],
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

export var tele_destination : String = "*Level_Next"
export var par : float = 0

export(int, "XT9", "S1") var type = 0
export var unlock : String = ""

export var silent_portal : bool = false

func _ready():
	if editor_properties["object_type"] == "normal":
		$AnimationPlayer.current_animation = "Speen"

func _process(_delta):
	if editor_properties["object_type"] == "finish":
		if type == 0:
			$finish_XT9.visible = true
			$finish_S1.visible = false
		else:
			$finish_XT9.visible = false
			$finish_S1.visible = true
