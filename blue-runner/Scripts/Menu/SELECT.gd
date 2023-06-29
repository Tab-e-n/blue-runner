extends Node2D

onready var parent : Node2D = get_parent()

#export var bg_transition : float = 0
#export var bg_changing : bool = false
#onready var bg_current : Node2D = null
#onready var bg_next : Node2D = null

#var current_world : int = 1

#var group_select : bool = false

var is_selecting_groups : bool = true
var is_selecting_characters : bool = false

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
	
	var directory : Directory = Directory.new()
	var check_exist = directory.open("user://SRLevels/")
	var current_file
	
	if check_exist == OK:
		# warning-ignore:return_value_discarded
		directory.list_dir_begin(true)
		
		current_file = directory.get_next()
		while current_file != "":
			if current_file.ends_with(".tscn"):
				user_levels.append(current_file.trim_suffix(".tscn"))
			current_file = directory.get_next()
		user_page_amount = user_levels.size() / 20
	
	if Global.current_level_location == "user://SRLevels/":
		for i in range(user_levels.size()):
			if user_levels[i] == Global.current_level:
				user_selected_level = int(i)
				# warning-ignore:integer_division
				user_current_page = int(i) / 20
				Global.select_menu = false
				break
#	selected_level_name = Global.current_level
#	selected_level_location = Global.current_level_location
	reload_all_levels(true)
	if Global.select_menu:
		Global.select_menu = false
		for i in range(20):
			if get_node("level_select/levels/" + String(i)).level_name == Global.current_level and get_node("level_select/levels/" + String(i)).level_location == Global.current_level_location:
				selected_level = i
				break
	
#	reload_all_levels()
	set_level_data_text(false)
	level_move_cursor()
	
	make_group_icons()
	group_move_cursor()

func menu_update():
	if is_selecting_groups:
		if Input.is_action_pressed("left") and parent.move:
			group_move_cursor(Vector2(-1, 0))
		if Input.is_action_pressed("right") and parent.move:
			group_move_cursor(Vector2(1, 0))
		if Input.is_action_pressed("up") and parent.move:
			group_move_cursor(Vector2(0, -1))
		if Input.is_action_pressed("down") and parent.move:
			group_move_cursor(Vector2(0, 1))
	elif is_selecting_characters:
		pass
	else:
		if Input.is_action_just_pressed("accept"):
			if not get_node("level_select/levels/" + String(selected_level)).locked:
				get_node("level_select/levels/" + String(selected_level)).get_node("Anim").play("Bump")
				$level_select/levels/selected_level/anim.play("Bump")
				
				var timer : Timer = Timer.new()
				timer.connect("timeout", self, "character_select")
				timer.connect("timeout", timer, "queue_free")
				timer.paused = false
				add_child(timer)
				timer.start(0.5)
				
				has_selected_level = true
			else:
				get_node("level_select/levels/" + String(selected_level)).get_node("Anim").play("Refuse")
				$level_select/levels/selected_level/anim.play("Refuse")
		
		if has_selected_level:
			parent.move = false
		
		if Input.is_action_pressed("left") and parent.move:
			level_move_cursor(-1)
		if Input.is_action_pressed("right") and parent.move:
			level_move_cursor(1)
		if Input.is_action_pressed("up") and parent.move:
			level_move_cursor(-5)
		if Input.is_action_pressed("down") and parent.move:
			level_move_cursor(5)


func level_move_cursor(move_amount : int = 0, is_in_user_universe : bool = false):
	if move_amount == 0:
		pass
	elif !is_in_user_universe:
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
	$level_select/levels/selected_level/anim.stop()
	$level_select/levels/selected_level/anim.play("Reset")
	
	set_level_data_text()

func group_move_cursor(move_amount : Vector2 = Vector2(0, 0)):
	if move_amount.x != 0:
		if sign(move_amount.x) == -1:
			if (group_current % 7) + move_amount.x < 0:
				group_current = (group_current / 7) * 7
			else:
				group_current += move_amount.x
		if sign(move_amount.x) == 1:
			if (group_current % 7) + move_amount.x >= 7:
				group_current = (group_current / 7) * 7 + 6
			else:
				group_current += move_amount.x
	
	var group_num : int = unlocked_level_groups.size()
	
	if move_amount.y != 0:
		var row_amount : int = ceil(float(group_num) / 7)
		if sign(move_amount.y) == -1:
			if ceil(float(group_current + 1) / 7) == row_amount:
				var end_columbs : int = group_num % 7
				if end_columbs == 0:
					end_columbs = 7
				var left_end : int = (7 - end_columbs) / 2
				
				group_current += move_amount.y * 7 + left_end
			elif group_current + move_amount.y * 7 >= 0:
				group_current += move_amount.y * 7
		if sign(move_amount.y) == 1:
			if ceil(float(group_current + move_amount.y * 7) / 7) == row_amount:
				var starting_columb : int = group_current % 7
				var end_columbs : int = group_num % 7
				if end_columbs == 0:
					end_columbs = 7
				var left_end : int = (7 - end_columbs) / 2 + 1
				var right_end : int = 7 - (8 - end_columbs) / 2 - 1
				
				if starting_columb < left_end:
					group_current = (row_amount - 1) * 7
				elif starting_columb > right_end:
					group_current = group_num - 1
				else:
					group_current = (row_amount - 1) * 7 + starting_columb - left_end + 1
				
#				print(starting_columb, " ", group_current % 7)
				
			elif ceil(float(group_current + move_amount.y * 7) / 7) < row_amount:
				group_current += move_amount.y * 7
	
	if group_current >= group_num:
		group_current = group_num - 1
	
	$group_select/cursor.position = get_node("group_select/" + String(group_current)).position
#	print(group_current)

func make_group_icons():
	var repetitions : int = unlocked_level_groups.size()
	var row_amount : int = ceil(float(repetitions) / 7)
	for i in range(repetitions):
		var new_sprite : Sprite = Sprite.new()
		new_sprite.name = String(i)
		new_sprite.texture = preload("res://Visual/Editor/editor_missing.png")
		new_sprite.scale = Vector2(2, 2)
		
		var sprite_position : Vector2
		if i + 1 > (row_amount - 1) * 7 and repetitions % 7 != 0:
			sprite_position.x = (repetitions % 7 - 1) * -64 + 128 * (i % 7)
		else:
			sprite_position.x = -384 + 128 * (i % 7)
		sprite_position.y = (-64 * (row_amount - 1)) + 128 * (i / 7)
		
		new_sprite.position = sprite_position
		
		$group_select.add_child(new_sprite)
	
	for i in range(repetitions):
		var file : String = unlocked_level_groups[i][1] + unlocked_level_groups[i][0] + "/logo.png"
		if unlocked_level_groups[i][1] == "user://":
			get_node("group_select/" + String(i)).texture = preload("res://Visual/Title/logo_user.png")
		elif unlocked_level_groups[i][3] != null:
			get_node("group_select/" + String(i)).texture = unlocked_level_groups[i][3]
		else:
			get_node("group_select/" + String(i)).texture = Global.load_texture_from_png(file)
			unlocked_level_groups[i][3] = get_node("group_select/" + String(i)).texture
			if get_node("group_select/" + String(i)).texture == null:
				get_node("group_select/" + String(i)).texture = preload("res://Visual/Title/logo_custom.png")
				unlocked_level_groups[i][3] = get_node("group_select/" + String(i)).texture
		
		Global.scale_down_sprite(get_node("group_select/" + String(i)), Vector2(2, 2))

func reload_all_levels(start : bool = false):
	var is_user_group : bool = Global.current_level_location == "user://SRLevels/"
	
	if !Global.load_level_group() and !is_user_group:
		return
	
	Global.update_level_group_save()
	
	# Group title
	if is_user_group:
		$level_select/title.texture = preload("res://Visual/Title/title_user.png")
	else:
		if unlocked_level_groups[group_current][2] != null:
			$level_select/title.texture = unlocked_level_groups[group_current][2]
		else:
			$level_select/title.texture = Global.load_texture_from_png(Global.current_level_location + "title.png")
			unlocked_level_groups[group_current][2] = $level_select/title.texture
		if $level_select/title.texture == null:
			$level_select/title.texture = preload("res://Visual/Title/title_custom.png")
			unlocked_level_groups[group_current][2] = $level_select/title.texture 
	
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
		$level_select/Completion.set_completion(stats[0])
		$level_select/Completion.visible = true
	else:
		$level_select/Completion.visible = false
	
	$level_select/stats.text = String(stats[1]) + "\n" + String(stats[2]) + "\n" + String(stats[4]) + "\n"
	$level_select/keycollect.visible = !is_user_group
	if !is_user_group:
		$level_select/stats.text += String(stats[3]) + "\n"
	
	for i in range(20):
		get_node("level_select/levels/" + String(i)).reload()
	
	#if is_user_group:
		#bg_start_changing("res://Objects/Backgrounds/BG_UserUniverse.tscn", start)
	#elif Global.level_group.has("bg"):
		#bg_start_changing(Global.level_group["bg"], start)
	#else:
		#bg_start_changing("", start)
	
	var color = Color(0.02, 0.9, 0.63, 1)
	if !is_user_group:
		$level_select/author.visible = true
		if Global.level_group.has("tags"):
			if Global.level_group["tags"].has("hide_author"):
				$level_select/author.visible = false
		
		if Global.level_group.has("ui_color"):
			color = Color(Global.level_group["ui_color"][0], Global.level_group["ui_color"][1], Global.level_group["ui_color"][2])
		
		if Global.level_group.has("author"):
			if Global.level_group["author"] == "":
				$level_select/author.text = ""
			else:
				$level_select/author.text = "By: " + Global.level_group["author"]
	
	$level_select/levels/selected_level.modulate = color
	$level_select/Completion.set_color(color)
	$level_select/beatflag.modulate = color
	$level_select/parstar.modulate = color
	$level_select/boltcollect.modulate = color
	$level_select/keycollect.modulate = color

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
		get_node("level_select/levels/" + String(selected_level)).get_node("Anim").play("Refuse")
		$level_select/levels/selected_level/anim.play("Refuse")
		has_selected_level = false
	elif activate_char_select:
		#parent.get_node("AnimationPlayer").play("SELECT-CHARACTER")
		#parent.menu = "CHARACTER"
		#$Cursor/AnimationPlayer.play("Reset")
		has_selected_level = false
	else:
		Global.select_menu = true
		if Global.change_level("", true, false) != OK:
			get_node("level_select/levels/" + String(selected_level)).get_node("Anim").play("Refuse")
			$level_select/levels/selected_level/anim.play("Refuse")
			#$fail.visible = true
			has_selected_level = false
