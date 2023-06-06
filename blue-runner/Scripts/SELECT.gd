extends Node2D

export var bg_transition : float = 0
export var bg_changing : bool = false
onready var bg_current : Node2D = null
onready var bg_next : Node2D = null

onready var parent : Node2D = get_parent()
#onready var camera : Node2D = get_parent().get_node("Camera")

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
	#loaded_level_groups = Global.loaded_level_groups.duplicate()
	#loaded_level_groups.append(["SRLevels","user://"])
	
	#print(loaded_level_groups)
	
	for i in Global.loaded_level_groups.size():
		if Global.check_unlock_requirements(Global.loaded_level_groups[i][5][0], Global.loaded_level_groups[i][5][1], Global.loaded_level_groups[i][5][2]):
			unlocked_level_group.append(Global.loaded_level_groups[i])
			if Global.current_level_location == Global.loaded_level_groups[i][1] + Global.loaded_level_groups[i][0] + "/":
				selected_group = unlocked_level_group.size() - 1
	#camera.bg = $BG_0
	#$BG_0.camera = camera
	
	change_controls()
	
	for i in range(12):
		var new_sprite : Sprite = Sprite.new()
		$group_select.add_child(new_sprite)
		new_sprite.texture = preload("res://Visual/Editor/editor_empty.png")
		new_sprite.scale = Vector2(2, 2)
		new_sprite.position = Vector2((i + 1) * 160 - 40, 64 + 8)
		new_sprite.name = String(i)

func change_controls():
	$back.bbcode_text = "[right]"
	$back.bbcode_text += Global.key_names(7) + " - GO BACK\n"
	$back.bbcode_text += Global.key_names(6) + " - CHANGE ZONE"
	$back.bbcode_text += "[/right]"
	$Level_Descriptor/replay.text = Global.key_names(5) + " - Best Replay"

func menu_update():
	var update_level_text = false
	var update_group_text = false
	var user_group = unlocked_level_group[selected_group][1] == "user://"
	
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
		if Input.is_action_just_pressed("jump"):
			if !get_node("L/Level_" + String(level_selected_convert)).locked:
				selected = true
				$Cursor/AnimationPlayer.play("Go_In")
				get_node("L/Level_" + String(level_selected_convert)).get_node("Anim").play("Bump")
			else:
				$Cursor/AnimationPlayer.play("Refuse")
		
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
		
		if selected:
			parent.move = false
		
		if Input.is_action_pressed("left") and parent.move and selected_level > 0 and !user_group:
			selected_level -= 1
			$Cursor/AnimationPlayer.stop()
			$Cursor/AnimationPlayer.play("Spin")
		if Input.is_action_pressed("right") and parent.move and selected_level < 19 and !user_group:
			selected_level += 1
			$Cursor/AnimationPlayer.stop()
			$Cursor/AnimationPlayer.play("Spin")
		if Input.is_action_pressed("up") and parent.move and selected_level - 4 > 0 and !user_group:
			selected_level -= 5
			$Cursor/AnimationPlayer.stop()
			$Cursor/AnimationPlayer.play("Spin")
		if Input.is_action_pressed("down") and parent.move and selected_level + 4 < 19 and !user_group:
			selected_level += 5
			$Cursor/AnimationPlayer.stop()
			$Cursor/AnimationPlayer.play("Spin")
			
		if Input.is_action_pressed("left") and parent.move and user_group:
			user_selected_level -= 1
			if user_group and user_selected_level - user_levels_page * 20 < 0:
				user_levels_page -= 1
				if user_levels_page <= -1:
					user_levels_page += 1
					user_selected_level += 1
				else:
					reload_all_levels()
			$Cursor/AnimationPlayer.stop()
			$Cursor/AnimationPlayer.play("Spin")
		if Input.is_action_pressed("right") and parent.move and user_group:
			user_selected_level += 1
			if user_group and user_selected_level - user_levels_page * 20 > 19:
				user_levels_page += 1
				if user_levels_page > user_pages:
					user_levels_page -= 1
					user_selected_level -= 1
				else:
					reload_all_levels()
			$Cursor/AnimationPlayer.stop()
			$Cursor/AnimationPlayer.play("Spin")
		if Input.is_action_pressed("up") and parent.move and user_group:
			user_selected_level -= 5
			if user_group and user_selected_level - user_levels_page * 20 < 0:
				user_levels_page -= 1
				if user_levels_page <= -1:
					user_levels_page += 1
					user_selected_level += 5
				else:
					reload_all_levels()
			$Cursor/AnimationPlayer.stop()
			$Cursor/AnimationPlayer.play("Spin")
		if Input.is_action_pressed("down") and parent.move and user_group:
			user_selected_level += 5
			if user_group and user_selected_level - user_levels_page * 20 > 19:
				user_levels_page += 1
				if user_levels_page > user_pages:
					user_levels_page -= 1
					user_selected_level -= 5
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
		#print(selected_level_location + selected_level_name)
		var level_dat = Global.load_dat_file(selected_level_location + selected_level_name)
		#print(level_dat)
		$Level_Descriptor/level_name.text = selected_level_name
		$Level_Descriptor/creator.text = ""
		$Level_Descriptor/best_time.text = "Best time: ???"
		$Level_Descriptor/par.text = ""
		$Level_Descriptor/deaths.text = ""
		
		if get_node("L/Level_" + String(level_selected_convert)).locked == true:
				$Level_Descriptor/level_name.text = "LOCKED"
				$Level_Descriptor/best_time.text = ""
		elif level_dat != null:
			$Level_Descriptor/level_name.text = level_dat["level_name"]
			var official = false
			if level_dat.has("tags"):
				official = level_dat["tags"].has("official")
			else:
				official = level_dat["official"]
			
			if user_group or !official:
				$Level_Descriptor/creator.text = "  Creator:" + level_dat["creator"]
			else: 
				if Global.level_group.has("author"):
					if level_dat["creator"] != Global.level_group["author"]:
						$Level_Descriptor/creator.text = "My thanks goes to " + level_dat["creator"] + " for making this!"
				elif level_dat["creator"] != "Tabin": 
					$Level_Descriptor/creator.text = "My thanks goes to " + level_dat["creator"] + " for making this!"

		if Global.level_completion.has(selected_level_location):
			if Global.level_completion[selected_level_location].has(selected_level_name):
				if Global.level_completion[selected_level_location][selected_level_name][0] != null:
					var timer : float = Global.level_completion[selected_level_location][selected_level_name][0]
					$Level_Descriptor/best_time.text = "Best time: " + Global.convert_float_to_time(timer, false)
					
					timer = Global.level_completion[selected_level_location][selected_level_name][1]
					if timer != 0:
						# warning-ignore:integer_division
						# warning-ignore:integer_division
						$Level_Descriptor/par.text = "Par: " + Global.convert_float_to_time(timer, false)
				
				if Global.level_completion[selected_level_location][selected_level_name].size() > 2: 
					$Level_Descriptor/deaths.text = "Deaths: " + String(Global.level_completion[selected_level_location][selected_level_name][2])
		$Level_Descriptor/replay.visible = Global.load_replay(selected_level_location + selected_level_name + "_Best", true)
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
	var user_group = Global.current_level_location == "user://SRLevels/"
	
	if !Global.load_level_group() and !user_group:
		return
	if !Global.level_completion.has(Global.current_level_location):
		Global.level_completion[Global.current_level_location] = {}
	if !Global.level_completion["*collectibles"].has(Global.current_level_location):
		Global.level_completion["*collectibles"][Global.current_level_location] = []
	if !user_group:
		if !Global.unlocked.has(Global.current_level_location):
			Global.unlocked[Global.current_level_location] = {}
		if typeof(Global.unlocked[Global.current_level_location]) != TYPE_DICTIONARY:
			Global.unlocked[Global.current_level_location] = {}
		for i in range(20):
			if Global.unlocked[Global.current_level_location].has(Global.level_group["levels"][i][0]):
				continue
			if Global.level_group["levels"][i][0] == "*Level_Missing":
				continue
			if Global.level_group["levels"][i][1]:
				Global.unlocked[Global.current_level_location][Global.level_group["levels"][i][0]] = false
	
	if user_group:
		$title.texture = preload("res://Visual/Title/title_user.png")
	else:
		if unlocked_level_group[selected_group][2] != null:
			$title.texture = unlocked_level_group[selected_group][2]
		else:
			$title.texture = Global.load_texture_from_png(Global.current_level_location + "title.png")
			unlocked_level_group[selected_group][2] = $title.texture
		if $title.texture == null:
			$title.texture = preload("res://Visual/Title/title_custom.png")
			unlocked_level_group[selected_group][2] = $title.texture 
	
	var comp_list : Array = []
	for i in range(20):
		var level = get_node("L/Level_" + String(i))
		if user_group:
			if i + user_levels_page * 20 >= user_levels.size():
				level.level_name = "*Level_Missing"
			else:
				level.level_name = user_levels[i + user_levels_page * 20]
		else:
			level.level_name = Global.level_group["levels"][i][0]
		
		if level.level_name != "*Level_Missing":
			level.level_location = Global.current_level_location
			if user_group:
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
	
	var stats : Array = completion_percentage()
	
	unlocked_level_group[selected_group][4] = stats[0]
	
	var group = -1
	for i in range(Global.loaded_level_groups.size()):
		if unlocked_level_group[selected_group][0] == Global.loaded_level_groups[i][0] and unlocked_level_group[selected_group][1] == Global.loaded_level_groups[i][1]:
			group = i
	
	Global.loaded_level_groups[group][4] = stats[0]
	
	if !user_group: 
		for i in comp_list:
			var level = get_node("L/Level_" + String(i))
			Global.unlocked[Global.current_level_location][level.level_name] = Global.check_unlock_requirements(Global.level_group["levels"][i][2][0], Global.level_group["levels"][i][2][1], Global.level_group["levels"][i][2][2])
			level.locked = !Global.unlocked[Global.current_level_location][level.level_name]
			if Global.unlocked[Global.current_level_location][level.level_name]:
				stats[3] += 1
		$completion_filling/text.text = String(stepify(stats[0], 1)) + "%"
		$completion_filling/bar.scale.x = stats[0] / 100
		$completion_filling.visible = true
	else:
		$completion_filling.visible = false
	
	$Stats.text = "Beat: " + String(stats[1]) + "\n"
	$Stats.text += "Par: " + String(stats[2]) + "\n"
	if !user_group:
		$Stats.text += "Unlocked: " + String(stats[3]) + "\n"
	$Stats.text += "Bonuses: " + String(stats[4])
	
	for i in range(20):
		get_node("L/Level_" + String(i)).reload()
	
	if user_group:
		bg_start_changing("res://Objects/Backgrounds/BG_UserUniverse.tscn", start)
	elif Global.level_group.has("bg"):
		bg_start_changing(Global.level_group["bg"], start)
	else:
		bg_start_changing("", start)

func character_select():
	Global.current_level = selected_level_name
	Global.current_level_location = selected_level_location
	
	var level_dat =  get_node("L/Level_" + String(level_selected_convert)).level_dat.duplicate()
	var error : int = false
	if !level_dat.has("dependencies"):
		error = true
	else:
		for i in level_dat["dependencies"]:
			if !Global.mods_installed.has(i):
				error = true
				$dependencies.visible = true
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
		$Cursor/AnimationPlayer.play("Refuse")
		selected = false
	elif activate_char_select:
		parent.get_node("AnimationPlayer").play("SELECT-CHARACTER")
		parent.menu = "CHARACTER"
		$Cursor/AnimationPlayer.play("Reset")
		selected = false
		#parent.get_node("CHARACTER").selected_level = selected_level_name
		#parent.get_node("CHARACTER").selected_location = selected_level_location
	else:
		if Global.change_level("", true, false) != OK:
			$Cursor/AnimationPlayer.play("Refuse")
			$fail.visible = true
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
		if Global.level_completion[Global.current_level_location].has(level_string):
			if Global.level_completion[Global.current_level_location][level_string][0] != null:
				completion += 1
				beat += 1
				#print("beat " + String(i))
				if Global.level_completion[Global.current_level_location][level_string][1] != null:
					if Global.level_completion[Global.current_level_location][level_string][1] == 0:
						completion += 1
					elif Global.level_completion[Global.current_level_location][level_string][0] < Global.level_completion[Global.current_level_location][level_string][1]:
						completion += 1
						par += 1
						#print("par " + String(i))
		if Global.unlocked.has(Global.current_level_location):
			if Global.unlocked[Global.current_level_location].has(get_node("L/Level_" + String(i)).level_name):
				full += 1
				if Global.unlocked[Global.current_level_location][get_node("L/Level_" + String(i)).level_name]:
					completion += 1
					unlock += 1
					#print("unlocked " + String(i))
		for c in range(3):
			if Global.level_completion["*collectibles"][Global.current_level_location].has(level_string + "*" + String(c + 1)):
				bonus += 1
	#print(String(completion) + " / " + String(full))
	
	var stats : Array = [0, beat, par, unlock, bonus]
	
	if full > 0:
		stats[0] = (completion / full) * 100
	else:
		stats[0] =  0
	return stats

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
	
