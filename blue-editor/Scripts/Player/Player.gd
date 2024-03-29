extends Node2D

export var editor_properties : Dictionary = {
	"description" : "The player.\nThis objects position is where the player starts. With the character properties you can specify which character the player plays as. if character_name is left blank, the player will choose the character they want for the level.",
	"object_path" : "res://Objects/Player/Player.tscn",
	"object_type" : "player", # some object types have a limited amount of the times they can appear
	"layer" : "special", # selected or special
	"rect" : Rect2(0, -32, 64, 64), 
	"editable_properties" : {
		"character_name" : [TYPE_STRING, 0, 0, 0],
		"character_location" : [TYPE_STRING, 0, 0, 0],
		"facing" : [TYPE_STRING, 0, 0, 0],
	},
	"unchangeable_properties" : {
		"scale" : true,
		"rotation" : true,
		"z_index" : true,
		"color" : false,
		"order" : true,
	},
	"attachable" : false,
}

export var character_name : String = ""
export var character_location : String = "res:/"
export var facing : String = "right"
export var deny_input : bool = true
export var ghost : bool = false


func _ready():
	if !ghost:
		var child : Sprite = Sprite.new()
		add_child(child)
		child.position.y = -32
		new_texture()


func _process(_delta):
	if !ghost:
		var tcl = character_location
		if tcl == "res:/": tcl = " "
		if !get_child(0).name == tcl + character_name:
			new_texture()
		if facing == "right":
			get_child(0).flip_h = false
		else:
			get_child(0).flip_h = true


func new_texture():
	var tcl = character_location
	if tcl == "res:/":
		tcl = " "
	get_child(0).name = tcl + character_name
#	print(get_child(0).name)
	if data.characters.has([character_name, character_location]):
		get_child(0).texture = load(character_location + "/Visual/Objects/character_" + character_name + ".png")
	elif character_name == "":
		get_child(0).texture = preload("res://Visual/Objects/Player.tscn.png")
	else:
		get_child(0).texture = preload("res://Visual/Objects/character_missing.png")


func edit_left_just_pressed(_mouse_pos, _cursor_pos, _level_scale):
	if facing == "left":
		facing = "right"
	elif facing == "right":
		facing = "left"
	else:
		facing = "right"
