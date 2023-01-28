extends Node2D

onready var global : Control = $"/root/Global"
onready var parent : Node2D = get_parent()
onready var camera : Node2D = get_parent().get_node("Camera")

var current_world : int = 1
var selected_level : int = 0
var cursor_positions = [	Vector2(-192,0), Vector2(64,0), Vector2(320,0), Vector2(576,0), Vector2(832,0),
							Vector2(-192,192), Vector2(64,192), Vector2(320,192), Vector2(576,192), Vector2(832,192), 
							Vector2(-192,384), Vector2(64,384), Vector2(320,384), Vector2(576,384), Vector2(832,384), 
							Vector2(-192,576), Vector2(64,576), Vector2(320,576), Vector2(576,576), Vector2(832,576),]
var selected : bool = false
var selected_level_name : String
var selected_level_location : String

var group_shift : int = 0
var selected_group : int = 0
var group_select : bool = false

var loaded_level_groups : Array

var user_levels : Array
var user_levels_page : int = 0
var user_pages : int = 0

func _ready():
	loaded_level_groups = Global.loaded_level_groups.duplicate()
	loaded_level_groups.append(["SRLevels","user://"])
	camera.bg = $BG_0
	$BG_0.camera = camera
	
	change_controls()
	
	for i in range(12):
		var new_sprite : Sprite = Sprite.new()
		$group_select.add_child(new_sprite)
		new_sprite.texture = load("res://Visual/Editor/editor_empty.png")
		new_sprite.scale = Vector2(2, 2)
		new_sprite.position = Vector2((i + 1) * 160 - 40, 64 + 8)
		new_sprite.name = String(i)

func change_controls():
	$back.bbcode_text = "[right]"
	$back.bbcode_text += global.key_names(7) + " - GO BACK\n"
	$back.bbcode_text += global.key_names(6) + " - CHANGE ZONE"
	$back.bbcode_text += "[/right]"
	$Level_Descriptor/replay.text = global.key_names(5) + " - Best Replay"

func menu_update():
	var update_level_text = false
	var update_group_text = false
	var user_group = loaded_level_groups[selected_group][1] == "user://"
	
	if Input.is_action_just_pressed("reset"):
		group_select = !group_select
		$group_select.visible = group_select
		update_group_text = true
		group_visuals()
	# - - - LEVEL SELECT - - -
	if !group_select:
		if Input.is_action_just_pressed("jump"):
			if !get_node("L/Level_" + String(selected_level)).locked:
				selected = true
				$Cursor/AnimationPlayer.play("Go_In")
				get_node("L/Level_" + String(selected_level)).get_node("Anim").play("Bump")
			else:
				$Cursor/AnimationPlayer.play("Refuse")
		
		if Input.is_action_just_pressed("special"):
			if global.load_replay(selected_level_location + selected_level_name + "_Best", true):
				global.current_recording = global.load_replay(selected_level_location + selected_level_name + "_Best")
				global.replay = true
				selected = true
				$Cursor/AnimationPlayer.play("Go_In")
				get_node("L/Level_" + String(selected_level)).get_node("Anim").play("Bump")
			else:
				global.replay = false
				selected = false
				$Cursor/AnimationPlayer.play("Refuse")
		
		if selected: parent.move = false
		
		if Input.is_action_pressed("left") and parent.move and (selected_level > 0 or user_group):
			selected_level -= 1
			if user_group and selected_level - user_levels_page * 20 < 0:
				user_levels_page -= 1
				if user_levels_page <= -1:
					user_levels_page += 1
					selected_level += 1
				else:
					reload_all_levels()
			$Cursor/AnimationPlayer.stop()
			$Cursor/AnimationPlayer.play("Spin")
		if Input.is_action_pressed("right") and parent.move and (selected_level < 19 or user_group):
			selected_level += 1
			if user_group and selected_level - user_levels_page * 20 > 19:
				user_levels_page += 1
				if user_levels_page >= user_pages:
					user_levels_page -= 1
					selected_level -= 1
				else:
					reload_all_levels()
			$Cursor/AnimationPlayer.stop()
			$Cursor/AnimationPlayer.play("Spin")
		if Input.is_action_pressed("up") and parent.move and (selected_level - 4 > 0 or user_group):
			selected_level -= 5
			if user_group and selected_level - user_levels_page * 20 < 0:
				user_levels_page -= 1
				if user_levels_page <= -1:
					user_levels_page += 1
					selected_level += 5
				else:
					reload_all_levels()
			$Cursor/AnimationPlayer.stop()
			$Cursor/AnimationPlayer.play("Spin")
		if Input.is_action_pressed("down") and parent.move and (selected_level + 4 < 19 or user_group):
			selected_level += 5
			if user_group and selected_level - user_levels_page * 20 > 19:
				user_levels_page += 1
				if user_levels_page >= user_pages:
					user_levels_page -= 1
					selected_level -= 5
				else:
					reload_all_levels()
			$Cursor/AnimationPlayer.stop()
			$Cursor/AnimationPlayer.play("Spin")
	elif group_select:
		if Input.is_action_pressed("left") and parent.move and selected_group > 0:
			selected_group -= 1
			if selected_group - group_shift < 0:
				group_shift -= 1
				group_visuals()
		if Input.is_action_pressed("right") and parent.move and selected_group < loaded_level_groups.size() - 1:
			selected_group += 1
			if selected_group - group_shift > 11:
				group_shift += 1
				group_visuals()
		if Input.is_action_just_pressed("jump"):
			global.current_level_location = loaded_level_groups[selected_group][1] + loaded_level_groups[selected_group][0] + "/"
			group_select = false
			$group_select.visible = group_select
			reload_all_levels()
			update_level_text = true
	
	selected_level_name = get_node("L/Level_" + String(selected_level)).level_name
	selected_level_location = get_node("L/Level_" + String(selected_level)).level_location
	
	if parent.move:
		$dependencies.visible = false
	
	if (parent.move and !group_select) or update_level_text:
		#print(selected_level_location + selected_level_name)
		var level_dat = global.load_level_dat_file(selected_level_location + selected_level_name)
		#print(level_dat)
		$Level_Descriptor/level_name.text = selected_level_name
		$Level_Descriptor/creator.text = ""
		if get_node("L/Level_" + String(selected_level)).locked == true:
				$Level_Descriptor/level_name.text = "LOCKED"
		elif level_dat != null:
			$Level_Descriptor/level_name.text = level_dat["level_name"]
			if level_dat["official"]:
				if level_dat["creator"] != "Tabin": 
					$Level_Descriptor/creator.text = "My thanks goes to " + level_dat["creator"] + " for making this!"
			else:
				$Level_Descriptor/creator.text = "  Creator:" + level_dat["creator"]
		
		$Level_Descriptor/best_time.text = "Best time: ???"
		$Level_Descriptor/par.text = ""
		$Level_Descriptor/deaths.text = ""
		
		if global.level_completion.has(selected_level_location + selected_level_name):
			if global.level_completion[selected_level_location + selected_level_name][0] != null:
				var timer : float = global.level_completion[selected_level_location + selected_level_name][0]
				var minutes : int = int(floor(timer) / 60)
				var seconds : int = int(floor(timer)) - minutes * 60
				var decimal : int = int(floor(timer * 100 + 0.1)) % 100
				
				# warning-ignore:integer_division
				# warning-ignore:integer_division
				$Level_Descriptor/best_time.text = "Best time: " + String(minutes)+":"+String(seconds/10)+String(seconds%10)+"."+String(decimal/10)+String(decimal%10)
				
				timer = global.level_completion[selected_level_location + selected_level_name][1]
				if timer != 0:
					minutes = int(floor(timer) / 60)
					seconds = int(floor(timer)) - minutes * 60
					decimal = int(floor(timer * 100 + 0.1)) % 100
					
					# warning-ignore:integer_division
					# warning-ignore:integer_division
					$Level_Descriptor/par.text = "Par: " + String(minutes)+":"+String(seconds/10)+String(seconds%10)+"."+String(decimal/10)+String(decimal%10)
			
			if global.level_completion[selected_level_location + selected_level_name].size() > 2: 
				$Level_Descriptor/deaths.text = "Deaths: " + String(global.level_completion[selected_level_location + selected_level_name][2])
		$Level_Descriptor/replay.visible = global.load_replay(selected_level_location + selected_level_name + "_Best", true)
	elif (parent.move and group_select) or update_group_text:
		$group_select/name.bbcode_text = "[center]" + loaded_level_groups[selected_group][0] + "[/center]"
	
	if !group_select:
		$Cursor.position = cursor_positions[selected_level]
	else:
		$group_select/cursor.position = Vector2((selected_group - group_shift + 1) * 160 - 40, 192)

func group_visuals():
	var repetitions = loaded_level_groups.size()
	if repetitions > 12:
		repetitions = 12
	for i in range(repetitions):
		if loaded_level_groups[i + group_shift][1] == "user://":
			get_node("group_select/" + String(i)).texture = load("res://Visual/Title/logo_user.png")
			return
		var file : String = loaded_level_groups[i + group_shift][1] + loaded_level_groups[i + group_shift][0] + "/logo.png"
		get_node("group_select/" + String(i)).texture = load(file)
		if get_node("group_select/" + String(i)).texture == null:
			get_node("group_select/" + String(i)).texture = load("res://Visual/Title/logo_custom.png")
	

func reload_all_levels():
	var user_group = global.current_level_location == "user://SRLevels/"
	
	if !global.load_level_group() and !user_group:
		return
	if !global.level_completion.has(global.current_level_location):
		global.level_completion[global.current_level_location] = {}
	if !global.level_completion["*collectibles"].has(global.current_level_location):
		global.level_completion["*collectibles"][global.current_level_location] = {}
	if !user_group:
		if !global.unlocked.has(global.current_level_location):
			global.unlocked[global.current_level_location] = {}
		if typeof(global.unlocked[global.current_level_location]) != TYPE_DICTIONARY:
			global.unlocked[global.current_level_location] = {}
		for i in range(20):
			if global.unlocked[global.current_level_location].has(global.level_group["levels"][i][0]):
				continue
			if !global.level_group["levels"][i][0] == "*Level_Missing":
				continue
			if (global.level_group["levels"][i][1] or global.level_group["levels"][i][2] != 0):
				global.unlocked[global.current_level_location][global.level_group["levels"][i][0]] = false
	
	if user_group:
		$title.texture = load("res://Visual/Title/title_user.png")
	else:
		$title.texture = load(global.current_level_location + "title.png")
		if $title.texture == null:
			$title.texture = load("res://Visual/Title/title_custom.png")
	
	var comp_list : Array = []
	for i in range(20):
		var level = get_node("L/Level_" + String(i))
		if user_group:
			if i + user_levels_page * 20 >= user_levels.size():
				level.level_name = "*Level_Missing"
			else:
				level.level_name = user_levels[i + user_levels_page * 20]
		else:
			level.level_name = global.level_group["levels"][i][0]
		
		if level.level_name != "*Level_Missing":
			level.level_location = Global.current_level_location
			if user_group:
				level.locked = false
			elif global.unlocked[global.current_level_location].has(level.level_name):
				level.locked = !global.unlocked[global.current_level_location][level.level_name]
				if global.level_group["levels"][i][2] != 0 and level.locked:
					comp_list.append(i)
			else:
				level.locked = false
		else:
			level.level_location = "res://Scenes/"
			level.level_name = "Level_Missing"
			level.locked = true
	
	var stats : Array = completion_percentage()
	if !user_group: 
		for i in comp_list:
			get_node("L/Level_" + String(i)).locked = !stats[0] > float(global.level_group["levels"][i][2])
			global.unlocked[global.current_level_location][get_node("L/Level_" + String(i)).level_name] = true
			stats[3] += 1
		$completion_filling/text.text = String(stepify(stats[0], 1)) + "%"
		$completion_filling/bar.scale.x = stats[0] / 100
		$completion_filling.visible = true
	else:
		$completion_filling.visible = false
	
	$Stats.text = "Beat: " + String(stats[1]) + "\n"
	$Stats.text += "Par: " + String(stats[2]) + "\n"
	$Stats.text += "Unlocked: " + String(stats[3]) + "\n"
	$Stats.text += "Bonuses: " + String(stats[4])
	
	for i in range(20):
		get_node("L/Level_" + String(i)).reload()

func character_select():
	global.current_level = selected_level_name
	global.current_level_location = selected_level_location
	
	var level_dat =  get_node("L/Level_" + String(selected_level)).level_dat.duplicate()
	var error : int = false
	if !level_dat.has("dependencies"):
		error = true
	else:
		for i in level_dat["dependencies"]:
			if !Global.mods_installed.has(i):
				error = true
				$dependencies.visible = true
	var file : File = File.new()
	if !file.file_exists(global.current_level_location + global.current_level + ".tscn"):
		error = true
	
	if error:
		$Cursor/AnimationPlayer.play("Refuse")
		selected = false
	elif global.unlocked["*char_select_active"]:
		parent.get_node("AnimationPlayer").play("SELECT-CHARACTER")
		parent.menu = "CHARACTER"
		$Cursor/AnimationPlayer.play("Reset")
		selected = false
		#parent.get_node("CHARACTER").selected_level = selected_level_name
		#parent.get_node("CHARACTER").selected_location = selected_level_location
	else:
		if Global.change_level("", true) != OK:
			$Cursor/AnimationPlayer.play("Refuse")
			selected = false

func completion_percentage():
	var full : float = 0
	var completion : float = 0
	var beat : int = 0
	var par : int = 0
	var unlock : int = 0
	var bonus : int = 0
	for i in range(20):
		if get_node("L/Level_" + String(i)).level_name == "Level_Missing" and get_node("L/Level_" + String(i)).level_location == "res://Scenes/": continue
		full += 2
		var level_string : String = get_node("L/Level_" + String(i)).level_name
		if global.level_completion[global.current_level_location].has(level_string): if global.level_completion[global.current_level_location][level_string][0] != null:
			completion += 1
			beat += 1
			#print("beat " + String(i))
			if global.level_completion[global.current_level_location][level_string][1] != null:
				if global.level_completion[global.current_level_location][level_string][0] < global.level_completion[global.current_level_location][level_string][1] and global.level_completion[global.current_level_location][level_string][1] != 0:
					completion += 1
					par += 1
					#print("par " + String(i))
			else:
				completion += 1
		if global.unlocked.has(global.current_level_location): if global.unlocked[global.current_level_location].has(get_node("L/Level_" + String(i)).level_name):
			full += 1
			if global.unlocked[global.current_level_location][get_node("L/Level_" + String(i)).level_name]:
				completion += 1
				unlock += 1
				#print("unlocked " + String(i))
		for c in range(3):
			if global.level_completion["*collectibles"][global.current_level_location].has(level_string + "*" + String(c)):
				bonus += 1
	#print(String(completion) + " / " + String(full))
	
	var stats : Array = [0, beat, par, unlock, bonus]
	
	if full > 0:
		stats[0] = (completion / full) * 100
	else:
		stats[0] =  0
	return stats
