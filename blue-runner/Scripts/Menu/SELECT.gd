extends Node2D

onready var parent : Node2D = get_parent()

#export var bg_transition : float = 0
#export var bg_changing : bool = false
#onready var bg_current : Node2D = null
#onready var bg_next : Node2D = null

#var current_world : int = 1
#var selected_level : int = 0
#var level_selected_convert : int = 0
#var cursor_positions = [
#		Vector2(-192,0), Vector2(64,0), Vector2(320,0), Vector2(576,0), Vector2(832,0),
#		Vector2(-192,192), Vector2(64,192), Vector2(320,192), Vector2(576,192), Vector2(832,192), 
#		Vector2(-192,384), Vector2(64,384), Vector2(320,384), Vector2(576,384), Vector2(832,384), 
#		Vector2(-192,576), Vector2(64,576), Vector2(320,576), Vector2(576,576), Vector2(832,576),
#]
#var selected : bool = false
#var selected_level_name : String
#var selected_level_location : String

#var group_shift : int = 0
#var group_select : bool = false

#var user_selected_level : int = 0
#var user_pages : int = 0

var selected_level : int
var has_selected_level : bool = false

var unlocked_level_groups : Array = []
var group_current : int = 0

var user_levels : Array
var user_page_current : int = 0

var user_selected_level : int = 0
var user_current_page : int = 0
var user_page_amount : int = 0

func _ready():
	for i in Global.loaded_level_groups.size():
		if Global.check_unlock_requirements(Global.loaded_level_groups[i][5][0], Global.loaded_level_groups[i][5][1], Global.loaded_level_groups[i][5][2]):
			unlocked_level_groups.append(Global.loaded_level_groups[i])
			if Global.current_level_location == Global.loaded_level_groups[i][1] + Global.loaded_level_groups[i][0] + "/":
				group_current = unlocked_level_groups.size() - 1
	
	reload_all_levels()
	set_level_data_text(false)

func menu_update():
	if Input.is_action_pressed("left") and parent.move:
		move_cursor(-1)
	if Input.is_action_pressed("right") and parent.move:
		move_cursor(1)
	if Input.is_action_pressed("up") and parent.move:
		move_cursor(-5)
	if Input.is_action_pressed("down") and parent.move:
		move_cursor(5)
	if Input.is_action_just_pressed("accept"):
		get_node("level_select/levels/" + String(selected_level)).get_node("Anim").play("Bump")
		character_select()

func move_cursor(move_amount : int = 0, is_in_user_universe : bool = false):
	if move_amount == 0:
		return
	
	if !is_in_user_universe:
		if sign(move_amount) == -1 and selected_level + (move_amount - sign(move_amount)) > 0:
			selected_level += move_amount
		if sign(move_amount) == 1 and selected_level + (move_amount - sign(move_amount)) < 19:
			selected_level += move_amount
	else:
		if sign(move_amount) == -1:
			user_selected_level += move_amount
			if user_selected_level - user_current_page * 20 < 0:
				user_current_page -= 1
				if user_current_page <= -1:
					user_current_page += 1
					user_selected_level -= move_amount
				else:
					reload_all_levels()
		if sign(move_amount) == 1:
			user_selected_level += move_amount
			if user_selected_level - user_current_page * 20 > 19:
				user_current_page += 1
				if user_current_page > user_page_amount:
					user_current_page -= 1
					user_selected_level -= move_amount
				else:
					reload_all_levels()
	
	$level_select/levels/selected_level.position = Vector2(-288 + 144 * (selected_level % 5), -144 + 96 * (selected_level / 5))
	
	set_level_data_text()

func reload_all_levels(start : bool = false):
	var is_user_group : bool = Global.current_level_location == "user://SRLevels/"
	
	if !Global.load_level_group() and !is_user_group:
		return
	
	Global.update_level_group_save()
	
	# Group title
	#if is_user_group:
		#$title.texture = preload("res://Visual/Title/title_user.png")
	#else:
		#if unlocked_level_groups[group_current][2] != null:
			#$title.texture = unlocked_level_groups[group_current][2]
		#else:
			#$title.texture = Global.load_texture_from_png(Global.current_level_location + "title.png")
			#unlocked_level_groups[group_current][2] = $title.texture
		#if $title.texture == null:
			#$title.texture = preload("res://Visual/Title/title_custom.png")
			#unlocked_level_groups[group_current][2] = $title.texture 
	
	var comp_list : Array = []
	for i in range(20):
		var level = get_node("level_select/levels/" + String(i))
		if is_user_group:
			if i + user_page_current * 20 >= user_levels.size():
				level.level_name = "*Level_Missing"
			else:
				level.level_name = user_levels[i + user_page_current * 20]
		else:
			level.level_name = Global.level_group["levels"][i][0]
		
		if level.level_name != "*Level_Missing":
			level.level_location = Global.current_level_location
			if is_user_group:
				level.locked = false
			elif Global.unlocked[Global.current_level_location].has(level.level_name):
				level.locked = !Global.unlocked[Global.current_level_location][level.level_name]
				if level.locked and (Global.level_group["levels"][i][2][0] == 3 or Global.level_group["levels"][i][2][0] == 4):
					comp_list.append(i)
				if level.locked and Global.level_group["levels"][i][2][0] != 6:
					Global.unlocked[Global.current_level_location][level.level_name] = Global.check_unlock_requirements(Global.level_group["levels"][i][2][0], Global.level_group["levels"][i][2][1], Global.level_group["levels"][i][2][2])
					level.locked = !Global.unlocked[Global.current_level_location][level.level_name]
			else:
				level.locked = false
		else:
			level.level_location = "res://Scenes/"
			level.level_name = "Level_Missing"
			level.locked = true
	
	var stats : Array = Global.completion_percentage()
	
	unlocked_level_groups[group_current][4] = stats[0]
	
	var group = -1
	for i in range(Global.loaded_level_groups.size()):
		if unlocked_level_groups[group_current][0] == Global.loaded_level_groups[i][0] and unlocked_level_groups[group_current][1] == Global.loaded_level_groups[i][1]:
			group = i
	
	Global.loaded_level_groups[group][4] = stats[0]
	
	if !is_user_group: 
		for i in comp_list:
			var level = get_node("level_select/levels/" + String(i))
			Global.unlocked[Global.current_level_location][level.level_name] = Global.check_unlock_requirements(Global.level_group["levels"][i][2][0], Global.level_group["levels"][i][2][1], Global.level_group["levels"][i][2][2])
			level.locked = !Global.unlocked[Global.current_level_location][level.level_name]
			if Global.unlocked[Global.current_level_location][level.level_name]:
				stats[3] += 1
		#$completion_filling/text.text = String(stepify(stats[0], 1)) + "%"
		#$completion_filling/bar.scale.x = stats[0] / 100
		#$completion_filling.visible = true
	#else:
		#$completion_filling.visible = false
	
	#$Stats.text = "Beat: " + String(stats[1]) + "\n"
	#$Stats.text += "Par: " + String(stats[2]) + "\n"
	#if !is_user_group:
		#$Stats.text += "Unlocked: " + String(stats[3]) + "\n"
	#$Stats.text += "Bonuses: " + String(stats[4])
	
	for i in range(20):
		get_node("level_select/levels/" + String(i)).reload()
	
	#if is_user_group:
		#bg_start_changing("res://Objects/Backgrounds/BG_UserUniverse.tscn", start)
	#elif Global.level_group.has("bg"):
		#bg_start_changing(Global.level_group["bg"], start)
	#else:
		#bg_start_changing("", start)

func set_level_data_text(is_in_user_universe : bool = false):
	var selected_level_location = get_node("level_select/levels/" + String(selected_level)).level_location
	var selected_level_name = get_node("level_select/levels/" + String(selected_level)).level_name
	#print(selected_level_location + selected_level_name)
	
	var level_dat = Global.load_dat_file(selected_level_location + selected_level_name)
	#print(level_dat)
	
	# Default text
	$level_select/level_data/level_name.set_text(selected_level_name)
	$level_select/level_data/creator.set_text("")
	$level_select/level_data/best_time.set_text("Best time: ???")
	$level_select/level_data/par.set_text("")
	$level_select/level_data/deaths.set_text("")
	
	# The level is locked
	if get_node("level_select/levels/" + String(selected_level)).locked == true:
		$level_select/level_data/level_name.set_text("LOCKED")
		$level_select/level_data/best_time.set_text("")
		return
	
	# Author and level name
	if level_dat != null:
		$level_select/level_data/level_name.set_text(level_dat["level_name"])
		
		if is_in_user_universe:
			$level_select/level_data/creator.set_text("  Creator:" + level_dat["creator"])
		else:
			var official = false
			if level_dat.has("tags"):
				official = level_dat["tags"].has("official")
			else:
				official = level_dat["official"]
			
			if !official:
				$level_select/level_data/creator.set_text("  Creator:" + level_dat["creator"])
			elif Global.level_group.has("author"):
				if level_dat["creator"] != Global.level_group["author"]:
					$level_select/level_data/creator.set_text("My thanks goes to " + level_dat["creator"] + " for making this!")
			elif level_dat["creator"] != "Tabin": 
				$level_select/level_data/creator.set_text("My thanks goes to " + level_dat["creator"] + " for making this!")
	
	# Best time, par, deaths
	if Global.level_completion.has(selected_level_location):
		if Global.level_completion[selected_level_location].has(selected_level_name):
			if Global.level_completion[selected_level_location][selected_level_name][0] != null:
				var timer : float = Global.level_completion[selected_level_location][selected_level_name][0]
				$level_select/level_data/best_time.set_text("Best time: " + Global.convert_float_to_time(timer, false))
				
				timer = Global.level_completion[selected_level_location][selected_level_name][1]
				if timer != 0:
					# warning-ignore:integer_division
					# warning-ignore:integer_division
					$level_select/level_data/par.set_text("Par: " + Global.convert_float_to_time(timer, false))
			
			if Global.level_completion[selected_level_location][selected_level_name].size() > 2: 
				$level_select/level_data/deaths.set_text("Deaths: " + String(Global.level_completion[selected_level_location][selected_level_name][2]))
	
	#$level_data/replay.visible = Global.load_replay(selected_level_location + selected_level_name + "_Best", true)

func character_select():
	Global.current_level = get_node("level_select/levels/" + String(selected_level)).level_name
	Global.current_level_location = get_node("level_select/levels/" + String(selected_level)).level_location
	
	var level_dat = get_node("level_select/levels/" + String(selected_level)).level_dat.duplicate()
	var error : int = false
	if !level_dat.has("dependencies"):
		error = true
	else:
		for i in level_dat["dependencies"]:
			if !Global.mods_installed.has(i):
				error = true
				#$dependencies.visible = true
	var file : File = File.new()
	if !file.file_exists(Global.current_level_location + Global.current_level + ".tscn"):
		error = true
	
	var activate_char_select : bool = true
	
	if !Global.check_unlock("*char_select_active"):
		activate_char_select = false
	if Global.replay:
		activate_char_select = false
	if level_dat.has("tags"):
		if level_dat["tags"].has("character_preselected"):
			activate_char_select = false
	
	if error:
		#$Cursor/AnimationPlayer.play("Refuse")
		has_selected_level = false
	elif activate_char_select:
		#parent.get_node("AnimationPlayer").play("SELECT-CHARACTER")
		#parent.menu = "CHARACTER"
		#$Cursor/AnimationPlayer.play("Reset")
		has_selected_level = false
	else:
		if Global.change_level("", true, false) != OK:
			#$Cursor/AnimationPlayer.play("Refuse")
			#$fail.visible = true
			has_selected_level = false
