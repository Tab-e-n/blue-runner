extends Node2D

export var bg_transition : float = 0
export var bg_changing : bool = false
onready var bg_current : Node2D = null
onready var bg_next : Node2D = null

onready var parent : Node2D = get_parent()

var current_world : int = 1
var selected_level : int = 0
var level_selected_convert : int = 0
var cursor_positions = [
		Vector2(-192,0), Vector2(64,0), Vector2(320,0), Vector2(576,0), Vector2(832,0),
		Vector2(-192,192), Vector2(64,192), Vector2(320,192), Vector2(576,192), Vector2(832,192), 
		Vector2(-192,384), Vector2(64,384), Vector2(320,384), Vector2(576,384), Vector2(832,384), 
		Vector2(-192,576), Vector2(64,576), Vector2(320,576), Vector2(576,576), Vector2(832,576),
]
var selected : bool = false
var selected_level_name : String
var selected_level_location : String

var unlocked_level_group : Array = []
var group_shift : int = 0
var selected_group : int = 0
var group_select : bool = false

var user_levels : Array
var user_levels_page : int = 0
var user_selected_level : int = 0
var user_pages : int = 0

func _ready():
	pass

func menu_update():
	var update_level_text = false
	var update_group_text = false
	var user_group = unlocked_level_group[selected_group][1] == "user://"
	
	# - - - LEVEL SELECT - - -
	if !group_select:
		if Input.is_action_just_pressed("special"):
			if Global.load_replay(selected_level_location + selected_level_name + "_Best", true):
				Global.current_recording = Global.load_replay(selected_level_location + selected_level_name + "_Best")
				Global.replay = true
				selected = true
				$Cursor/AnimationPlayer.play("Go_In")
				get_node("L/Level_" + String(level_selected_convert)).get_node("Anim").play("Bump")
			else:
				Global.replay = false
				selected = false
				$Cursor/AnimationPlayer.play("Refuse")
	
	selected_level_name = get_node("L/Level_" + String(level_selected_convert)).level_name
	selected_level_location = get_node("L/Level_" + String(level_selected_convert)).level_location
	
	if (parent.move and !group_select) or update_level_text:
		pass
	elif (parent.move and group_select) or update_group_text:
		$group_select/name.bbcode_text = "[center]" + unlocked_level_group[selected_group][0] + "[/center]"

func group_visuals():
	pass

func reload_all_levels(start : bool = false):
	pass

func bg_start_changing(bg_filepath : String, start : bool):
	pass

func bg_end_changing():
	pass
	
