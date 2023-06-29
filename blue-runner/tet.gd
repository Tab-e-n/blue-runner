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
	# Group select visuals
	for i in range(12):
		var new_sprite : Sprite = Sprite.new()
		$group_select.add_child(new_sprite)
		new_sprite.texture = preload("res://Visual/Editor/editor_empty.png")
		new_sprite.scale = Vector2(2, 2)
		new_sprite.position = Vector2((i + 1) * 160 - 40, 64 + 8)
		new_sprite.name = String(i)

func menu_update():
	var update_level_text = false
	var update_group_text = false
	var user_group = unlocked_level_group[selected_group][1] == "user://"
	
	# Level group switcher
	if Input.is_action_just_pressed("reset"):
		if group_select:
			Global.current_level_location = unlocked_level_group[selected_group][1] + unlocked_level_group[selected_group][0] + "/"
			reload_all_levels()
			update_level_text = true
		else:
			update_group_text = true
			group_visuals()
		group_select = !group_select
		$group_select.visible = group_select
	
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
		
	elif group_select:
		if Input.is_action_pressed("left") and parent.move and selected_group > 0:
			selected_group -= 1
			if selected_group - group_shift < 0:
				group_shift -= 1
				group_visuals()
		if Input.is_action_pressed("right") and parent.move and selected_group < unlocked_level_group.size() - 1:
			selected_group += 1
			if selected_group - group_shift > 11:
				group_shift += 1
				group_visuals()
		if Input.is_action_just_pressed("jump"):
			Global.current_level_location = unlocked_level_group[selected_group][1] + unlocked_level_group[selected_group][0] + "/"
			group_select = false
			$group_select.visible = group_select
			reload_all_levels()
			update_level_text = true
	
	$pages.visible = user_group
	if user_group:
		$pages.text = String(user_levels_page) + "/" + String(user_pages)
		level_selected_convert = user_selected_level - user_levels_page * 20
	else:
		level_selected_convert = selected_level
	
	selected_level_name = get_node("L/Level_" + String(level_selected_convert)).level_name
	selected_level_location = get_node("L/Level_" + String(level_selected_convert)).level_location
	
	if parent.move:
		$dependencies.visible = false
		$fail.visible = false
	
	if (parent.move and !group_select) or update_level_text:
		pass
	elif (parent.move and group_select) or update_group_text:
		$group_select/name.bbcode_text = "[center]" + unlocked_level_group[selected_group][0] + "[/center]"
	
	if !group_select:
		$Cursor.position = cursor_positions[level_selected_convert]
	else:
		$group_select/cursor.position = Vector2((selected_group - group_shift + 1) * 160 - 40, 192)
	
	if bg_changing:
		if bg_current != null:
			bg_current.update_self(Vector2(1024 * bg_transition, 0))
			bg_current.position = Vector2(-1 * bg_transition, 0)
			bg_current.modulate = Color(1, 1, 1, 1 - bg_transition)
		if bg_next != null:
			bg_next.update_self(Vector2(1024 * bg_transition - 1024, 0))
			bg_next.position = Vector2(-1 * bg_transition, 0)
			if bg_current == null:
				bg_next.modulate = Color(1, 1, 1, bg_transition)

func group_visuals():
	var repetitions = unlocked_level_group.size()
	if repetitions > 12:
		repetitions = 12
	for i in range(repetitions):
		var file : String = unlocked_level_group[i + group_shift][1] + unlocked_level_group[i + group_shift][0] + "/logo.png"
		if unlocked_level_group[i + group_shift][1] == "user://":
			get_node("group_select/" + String(i)).texture = preload("res://Visual/Title/logo_user.png")
		elif unlocked_level_group[i + group_shift][3] != null:
			get_node("group_select/" + String(i)).texture = unlocked_level_group[i + group_shift][3]
		else:
			get_node("group_select/" + String(i)).texture = Global.load_texture_from_png(file)
			unlocked_level_group[i + group_shift][3] = get_node("group_select/" + String(i)).texture
			if get_node("group_select/" + String(i)).texture == null:
				get_node("group_select/" + String(i)).texture = preload("res://Visual/Title/logo_custom.png")
				unlocked_level_group[i + group_shift][3] = get_node("group_select/" + String(i)).texture
		
		Global.scale_down_sprite(get_node("group_select/" + String(i)), Vector2(2, 2))

func reload_all_levels(start : bool = false):
	pass

func bg_start_changing(bg_filepath : String, start : bool):
	if bg_filepath != "*none":
		var packed_bg = load(bg_filepath)
		if packed_bg != null:
			bg_next = packed_bg.instance()
			bg_next.z_index -= 10
			add_child(bg_next)
	if !start:
		bg_changing = true
		bg_transition = 0
		$bg_anim.play("change")
	else:
		bg_end_changing()

func bg_end_changing():
	bg_changing = false
	if bg_current != null:
		bg_current.queue_free()
	bg_current = bg_next
	bg_next = null
	if bg_current != null:
		bg_current.z_index += 10
		bg_current.update_self(Vector2(0, 0))
		bg_current.position = Vector2(0, 0)
	
