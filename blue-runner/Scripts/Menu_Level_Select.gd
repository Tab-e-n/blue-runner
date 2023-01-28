extends Node2D

var hold : int = 0
var move : bool = true

onready var global : Control = $"/root/Global"

var menu : String = "SELECT"

func _ready():
	global.replay = false
	global.race_mode = false
	var start : bool = true
	
	var directory : Directory = Directory.new()
	var check_exist = directory.open("user://SRLevels/")
	var current_file
	
	if check_exist == OK:
		# warning-ignore:return_value_discarded
		directory.list_dir_begin(true)
		
		current_file = directory.get_next()
		while current_file != "":
			if current_file.ends_with(".tscn"):
				$SELECT.user_levels.append(current_file.trim_suffix(".tscn"))
			current_file = directory.get_next()
		$SELECT.user_pages = $SELECT.user_levels.size() / 20
	
	if global.current_level_location == "user://SRLevels/":
		for i in range($SELECT.user_levels.size()):
			if $SELECT.user_levels[i] == global.current_level:
				$SELECT.selected_level = int(i)
				# warning-ignore:integer_division
				$SELECT.user_levels_page = int(i) / 20
				$SELECT.visible = true
				start = false
				break
	$SELECT.selected_level_name = global.current_level
	$SELECT.selected_level_location = global.current_level_location
	$SELECT.reload_all_levels()
	if start != false: 
		for i in range(20):
			if get_node("SELECT/L/Level_" + String(i)).level_name == global.current_level and get_node("SELECT/L/Level_" + String(i)).level_location == global.current_level_location:
				$SELECT.selected_level = i
				$SELECT.visible = true
				start = false
				break
	
	if start or global.replay_menu:
		$menu_circle_2.scale = Vector2(2.75, 2.75)
		$menu_button.position = Vector2(0, -64)
		$MAIN.position = Vector2(2048, -768)
		$MAIN.rotation_degrees = 0
		$SELECT/BG_MENU.color.a = 1
		$SELECT.visible = false
		menu = "MAIN"
		
		if global.replay_menu:
			global.replay_menu = false
			$REPLAY.selected_replay = global.replay_save[0]
			$REPLAY.replay_menu_mode = global.replay_save[1]
			$REPLAY.reset_replays()
			$REPLAY/replay_list.ensure_current_is_visible()
			menu = "REPLAY"
			$AnimationPlayer.play("SET_TO_REPLAY")
		else:
			$AnimationPlayer.play("ENTERING")
	if !start:
		$menu_circle_2.scale = Vector2(0, 0)
	if Global.new_version_alert:
		$NewVersionPopup.visible = true
		Global.new_version_alert = false

func _process(_delta):
	# MENU SWITCHING
	if Input.is_action_just_pressed("return") and $AnimationPlayer.current_animation == "" and menu != "MAIN":
		match menu:
			"SELECT":
				$AnimationPlayer.play("SELECT-MAIN")
				menu = "MAIN"
			"CHARACTER":
				$AnimationPlayer.play("CHARACTER-SELECT")
				menu = "SELECT"
			"OPTION":
				pass
			"HELP":
				$AnimationPlayer.play("HELP-MAIN")
				menu = "MAIN"
			"REPLAY":
				$AnimationPlayer.play("REPLAY-MAIN")
				menu = "MAIN"
	if $AnimationPlayer.current_animation != "ENTERING":
		$dim.color = Color(0.02, 0.02, 0.13, 0)
	if $AnimationPlayer.current_animation == "MAIN-SELECT":
		$SELECT.change_controls()
		move = true
	
	
	# MENU INPUT
	if Input.is_action_just_pressed("left") or Input.is_action_just_pressed("right") or Input.is_action_just_pressed("up") or Input.is_action_just_pressed("down"):
		move = true
	
	if Input.is_action_pressed("left") or Input.is_action_pressed("right") or Input.is_action_pressed("up") or Input.is_action_pressed("down"):
		hold += 1
	else:
		hold = 0
	
	if hold >= 20:
		var hold_shift : int = 6
		if menu == "MAIN" or menu == "HELP": hold_shift = 10
		hold -= hold_shift
		move = true
	
	match(menu):
		"SELECT":
			$SELECT.menu_update()
		"CHARACTER":
			$CHARACTER.menu_update()
		"MAIN":
			$MAIN.menu_update()
		"OPTION":
			$OPTION.menu_update()
		"HELP":
			$HELP.menu_update()
		"REPLAY":
			$REPLAY.menu_update()
	
	if move == true:
		$NewVersionPopup.visible = false
		move = false
