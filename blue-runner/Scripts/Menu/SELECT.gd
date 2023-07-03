extends Node2D

onready var parent : Node2D = get_parent()

#export var bg_transition : float = 0
#export var bg_changing : bool = false
#onready var bg_current : Node2D = null
#onready var bg_next : Node2D = null

#var current_world : int = 1

#var group_select : bool = false


var is_selecting_groups : bool = false
var groups_first_time : bool = true
var current_group_color : int = 0


var selected_level : int
var has_selected_level : bool = false

var unlocked_level_groups : Array = []
var group_current : int = 0

var user_levels : Array
var user_page_current : int = 0

var user_selected_level : int = 0
var user_current_page : int = 0
var user_page_amount : int = 0

var bg : Node2D
export var cam_target : Vector2 = Vector2(0, 0)


export var character_pulse : float = 0

var is_selecting_characters : bool = false
var characters_first_time : bool = true
var unlocked_characters : Array = []
var selected_character : int = 0

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
		# warning-ignore:integer_division
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
	reload_all_levels()
	if Global.select_menu:
		Global.select_menu = false
		for i in range(20):
			if get_node("level_select/levels/" + String(i)).level_name == Global.current_level and get_node("level_select/levels/" + String(i)).level_location == Global.current_level_location:
				selected_level = i
				break
	
#	reload_all_levels()
	set_level_data_text(false)
	level_move_cursor()
	
#	group_move_cursor()
	
	check_character_unlocks()
	
	$mainAnim.play("enter")

func menu_update():
	if $mainAnim.is_playing() and bg != null:
		bg.update_self(cam_target)
		bg.position = Vector2(0, 0)
	
	if parent.move:
		$level_select/dependency.visible = false
		$level_select/fail.visible = false
	
	if is_selecting_groups:
		if Input.is_action_just_pressed("deny"):
			parent.switch_menu("MAIN", "SELECT")
			$mainAnim.play("exit")
			return
		
		if Input.is_action_just_pressed("accept"):
			Global.current_level_location = unlocked_level_groups[group_current][1] + unlocked_level_groups[group_current][0] + "/"
			is_selecting_groups = false
			selected_level = 0
			user_current_page = 0
			user_page_amount = 0
			reload_all_levels()
			set_level_data_text(false)
			level_move_cursor()
			$mainAnim.play("GROUP -> LEVEL")
		
		if Input.is_action_pressed("menu_left") and parent.move:
			group_move_cursor(Vector2(-1, 0))
		if Input.is_action_pressed("menu_right") and parent.move:
			group_move_cursor(Vector2(1, 0))
		if Input.is_action_pressed("menu_up") and parent.move:
			group_move_cursor(Vector2(0, -1))
		if Input.is_action_pressed("menu_down") and parent.move:
			group_move_cursor(Vector2(0, 1))
		
	elif is_selecting_characters:
		if Input.is_action_just_pressed("deny"):
			is_selecting_characters = false
			$mainAnim.play("CHARACTER -> LEVEL")
			
		if Input.is_action_just_pressed("jump"):
			Global.current_character = unlocked_characters[selected_character][0]
			Global.current_character_location = unlocked_characters[selected_character][1]
			if Global.change_level("", true) != OK:
				is_selecting_characters = false
				$mainAnim.play("CHARACTER -> LEVEL")
		
		if Input.is_action_pressed("menu_left") and parent.move:
			character_move_cursor(-1)
		if Input.is_action_pressed("menu_right") and parent.move:
			character_move_cursor(1)
		if Input.is_action_pressed("menu_up") and parent.move:
			character_move_cursor(-4)
		if Input.is_action_pressed("menu_down") and parent.move:
			character_move_cursor(4)
		
		$character_select/options_rectangle.material.set_shader_param("offset", character_pulse)
	else:
		if Input.is_action_just_pressed("deny"):
			is_selecting_groups = true
			if groups_first_time:
				make_group_icons()
				groups_first_time = false
			group_move_cursor()
			$mainAnim.play("LEVEL -> GROUP")
		if Input.is_action_just_pressed("accept"):
			if not get_node("level_select/levels/" + String(selected_level)).locked:
				get_node("level_select/levels/" + String(selected_level)).get_node("Anim").play("Bump")
				$level_select/levels/selected_level/anim.play("Bump")
				
				var timer : Timer = Timer.new()
				# warning-ignore:return_value_discarded
				timer.connect("timeout", self, "level_selected")
				# warning-ignore:return_value_discarded
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
		
		if Input.is_action_pressed("menu_left") and parent.move:
			level_move_cursor(-1)
		if Input.is_action_pressed("menu_right") and parent.move:
			level_move_cursor(1)
		if Input.is_action_pressed("menu_up") and parent.move:
			level_move_cursor(-5)
		if Input.is_action_pressed("menu_down") and parent.move:
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
					$level_select/author.text = String(user_current_page + 1) + "/" + String(user_page_amount + 1)
				else:
					reload_all_levels()
		if sign(move_amount) == 1:
			user_selected_level += move_amount
			if user_selected_level - user_current_page * 20 > 19:
				user_current_page += 1
				if user_current_page > user_page_amount:
					user_current_page -= 1
					user_selected_level -= move_amount
					$level_select/author.text = String(user_current_page + 1) + "/" + String(user_page_amount + 1)
				else:
					reload_all_levels()
		
		selected_level = user_selected_level - user_current_page * 20
	# warning-ignore:integer_division
	$level_select/levels/selected_level.position = Vector2(-288 + 144 * (selected_level % 5), -144 + 96 * (selected_level / 5))
	$level_select/levels/selected_level/anim.stop()
	$level_select/levels/selected_level/anim.play("Reset")
	
	set_level_data_text()

func group_move_cursor(move_amount : Vector2 = Vector2(0, 0)):
	if move_amount.x != 0:
		if sign(move_amount.x) == -1:
			if (group_current % 7) + move_amount.x < 0:
				# warning-ignore:integer_division
				group_current = (group_current / 7) * 7
			else:
				# warning-ignore:narrowing_conversion
				group_current += move_amount.x
		if sign(move_amount.x) == 1:
			if (group_current % 7) + move_amount.x >= 7:
				# warning-ignore:integer_division
				group_current = (group_current / 7) * 7 + 6
			else:
				# warning-ignore:narrowing_conversion
				group_current += move_amount.x
	
	var group_num : int = unlocked_level_groups.size()
	
	if move_amount.y != 0:
		# warning-ignore:narrowing_conversion
		var row_amount : int = ceil(float(group_num) / 7)
		if sign(move_amount.y) == -1:
			if ceil(float(group_current + 1) / 7) == row_amount:
				var end_columbs : int = group_num % 7
				if end_columbs == 0:
					end_columbs = 7
				# warning-ignore:integer_division
				var left_end : int = (7 - end_columbs) / 2
				
				# warning-ignore:narrowing_conversion
				group_current += move_amount.y * 7 + left_end
			elif group_current + move_amount.y * 7 >= 0:
				# warning-ignore:narrowing_conversion
				group_current += move_amount.y * 7
		if sign(move_amount.y) == 1:
			if ceil(float(group_current + move_amount.y * 7) / 7) == row_amount:
				var starting_columb : int = group_current % 7
				var end_columbs : int = group_num % 7
				if end_columbs == 0:
					end_columbs = 7
				# warning-ignore:integer_division
				var left_end : int = (7 - end_columbs) / 2 + 1
				# warning-ignore:integer_division
				var right_end : int = 7 - (8 - end_columbs) / 2 - 1
				
				if starting_columb < left_end:
					group_current = (row_amount - 1) * 7
				elif starting_columb > right_end:
					group_current = group_num - 1
				else:
					group_current = (row_amount - 1) * 7 + starting_columb - left_end + 1
				
#				print(starting_columb, " ", group_current % 7)
				
			elif ceil(float(group_current + move_amount.y * 7) / 7) < row_amount:
				# warning-ignore:narrowing_conversion
				group_current += move_amount.y * 7
	
	if group_current >= group_num:
		group_current = group_num - 1
	
	if group_current < 0:
		group_current = 0
	
	$group_select/groups/cursor.position = get_node("group_select/groups/" + String(group_current)).position
	
	while $group_select/groups.position.y + $group_select/groups/cursor.position.y < -192:
		$group_select/groups.position.y += 64
	while $group_select/groups.position.y + $group_select/groups/cursor.position.y > 192:
		$group_select/groups.position.y -= 64
	
#	print(group_current)

func character_move_cursor(move_amount : int = 0):
	if move_amount == 0:
		pass
	else:
		if sign(move_amount) == -1 and selected_character + move_amount >= 0:
			selected_character += move_amount
		if sign(move_amount) == 1 and selected_character + move_amount < unlocked_characters.size():
			selected_character += move_amount
	
#	print(selected_character)
	
	if selected_character < 0:
		selected_character = 0
	if selected_character >= unlocked_characters.size():
		selected_character = unlocked_characters.size() - 1
	
	# warning-ignore:integer_division
	# warning-ignore:integer_division
	$character_select/characters.position = Vector2(160 - (selected_character / 4) * 32, (selected_character / 4) * 128)
	$character_select/characters/cursor.position = get_node("character_select/characters/" + String(selected_character)).position
	load_render(selected_character)
	
	if Global.loaded_characters[unlocked_characters[selected_character][1]][unlocked_characters[selected_character][0]].size() > 3:
		$character_select/name.bbcode_text = "[center]" + Global.loaded_characters[unlocked_characters[selected_character][1]][unlocked_characters[selected_character][0]][3] + "[/center]"
		$character_select/description.bbcode_text = "[center]" + Global.loaded_characters[unlocked_characters[selected_character][1]][unlocked_characters[selected_character][0]][4] + "[/center]"
	else:
		$character_select/name.bbcode_text = "[center]" + unlocked_characters[selected_character][0] + "[/center]"
		$character_select/description.bbcode_text = ""

func make_group_icons():
	var repetitions : int = unlocked_level_groups.size()
	# warning-ignore:narrowing_conversion
	var row_amount : int = ceil(float(repetitions) / 7)
	for i in range(repetitions):
		var new_sprite : Sprite = Sprite.new()
		new_sprite.name = String(i)
		new_sprite.texture = preload("res://Visual/Editor/editor_missing.png")
		new_sprite.scale = Vector2(2, 2)
		
		var sprite_position : Vector2 = Vector2(0, 0)
		if i + 1 > (row_amount - 1) * 7 and repetitions % 7 != 0:
			sprite_position.x = (repetitions % 7 - 1) * -64 + 128 * (i % 7)
		else:
			sprite_position.x = -384 + 128 * (i % 7)
		# warning-ignore:integer_division
		sprite_position.y = (-64 * (row_amount - 1)) + 128 * (i / 7)
		
		new_sprite.position = sprite_position
		
		$group_select/groups.add_child(new_sprite)
	
	for i in range(repetitions):
		var file : String = unlocked_level_groups[i][1] + unlocked_level_groups[i][0] + "/logo.png"
		if unlocked_level_groups[i][1] == "user://":
			get_node("group_select/groups/" + String(i)).texture = preload("res://Visual/Title/logo_user.png")
		elif unlocked_level_groups[i][3] != null:
			get_node("group_select/groups/" + String(i)).texture = unlocked_level_groups[i][3]
		else:
			get_node("group_select/groups/" + String(i)).texture = Global.load_texture_from_png(file)
			unlocked_level_groups[i][3] = get_node("group_select/groups/" + String(i)).texture
			if get_node("group_select/groups/" + String(i)).texture == null:
				get_node("group_select/groups/" + String(i)).texture = preload("res://Visual/Title/logo_custom.png")
				unlocked_level_groups[i][3] = get_node("group_select/groups/" + String(i)).texture
		
		Global.scale_down_sprite(get_node("group_select/groups/" + String(i)), Vector2(2, 2))

func reload_all_levels():
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
	
	var stats : Array = Global.completion_percentage(is_user_group, user_current_page)
	
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
	
	if is_user_group:
		make_new_bg("res://Objects/Backgrounds/BG_UserUniverse.tscn")
	elif Global.level_group.has("bg"):
		make_new_bg(Global.level_group["bg"])
	else:
		make_new_bg("")
	
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
	else:
		$level_select/author.visible = true
		$level_select/author.text = String(user_current_page + 1) + "/" + String(user_page_amount + 1)
	
	$level_select/levels/selected_level.modulate = color
	$level_select/Completion.set_color(color)
	$level_select/beatflag.modulate = color
	$level_select/parstar.modulate = color
	$level_select/boltcollect.modulate = color
	$level_select/keycollect.modulate = color
	
	$level_select/level_data.material.set_shader_param("color", color)
#	$level_select/level_data/level_name.modulate = color
#	$level_select/level_data/best_time.modulate = color
#	$level_select/level_data/par.modulate = color
#	$level_select/level_data/deaths.modulate = color
#	$level_select/level_data/creator.modulate = color

func make_new_bg(bg_filepath : String):
	if bg != null:
		bg.queue_free()
	if bg_filepath != "*none":
		var packed_bg = load(bg_filepath)
		if packed_bg != null:
			bg = packed_bg.instance()
			bg.update_self(cam_target)
			bg.position = Vector2(0, 0)
			bg.scale = Vector2(0.5, 0.5)
			$level_select.add_child(bg)

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
		$level_select/level_data/creator.set_text("")
		
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

func remove_bg():
	if bg != null:
		bg.queue_free()

func level_selected():
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
				$level_select/dependency.visible = true
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
		if characters_first_time:
			make_character_icons()
			characters_first_time = false
		character_move_cursor()
		$mainAnim.play("LEVEL -> CHARACTER")
		is_selecting_characters = true
		has_selected_level = false
	else:
		Global.select_menu = true
		if Global.change_level("", true, false) != OK:
			get_node("level_select/levels/" + String(selected_level)).get_node("Anim").play("Refuse")
			$level_select/levels/selected_level/anim.play("Refuse")
			$level_select/fail.visible = true
			has_selected_level = false

func check_character_unlocks():
	
	unlocked_characters = []
	print(Global.loaded_characters)
	for place in Global.loaded_characters.keys():
		for character in Global.loaded_characters[place].keys():
			
			var unlock_type : int = Global.loaded_characters[place][character][0]
			var parameter_1 = Global.loaded_characters[place][character][1]
			var parameter_2 = Global.loaded_characters[place][character][2]
			
			var check : bool = false
			
			if unlock_type == 5:
				check = Global.check_unlock_requirements(unlock_type, parameter_1, place)
			else:
				check = Global.check_unlock_requirements(unlock_type, parameter_1, parameter_2)
			
			if check:
				unlocked_characters.append([character, place, "", ""])
				
				if unlocked_characters.size() > 1: Global.unlock("*char_select_active")

func make_character_icons():
	var repetitions : int = unlocked_characters.size()
	# warning-ignore:narrowing_conversion
	var row_amount : int = ceil(float(repetitions) / 4)
	for i in range(repetitions):
		var new_sprite : Sprite = Sprite.new()
		new_sprite.name = String(i)
		new_sprite.texture = preload("res://Visual/Editor/editor_missing.png")
		new_sprite.scale = Vector2(2, 2)
		
		var sprite_position : Vector2 = Vector2(0, 0)
		sprite_position.x = 128 * (i % 4) - 32 * (int(i) / 4)
		# warning-ignore:integer_division
		sprite_position.y = 128 * (int(i) / 4)
		
		new_sprite.position = sprite_position
		
		$character_select/characters.add_child(new_sprite)
	
	for i in range(repetitions):
		load_icon(i)

func load_render(index : int):
	if unlocked_characters.size() == 0:
		$character_select/character_render.texture = preload("res://Visual/Menu/no_character_found.png")
		return
	if index < 0:
		index += unlocked_characters.size()
	if index >= unlocked_characters.size():
		index -= unlocked_characters.size()
	
	var texture : Texture
	if unlocked_characters[index][2] != "":
		texture = load(unlocked_characters[index][2])
	else:
		texture = load(unlocked_characters[index][1] + "/Visual/" + unlocked_characters[index][0] + "/portrait.png")
		unlocked_characters[index][2] = unlocked_characters[index][1] + "/Visual/" + unlocked_characters[index][0] + "/portrait.png"
		if texture == null:
			texture = preload("res://Visual/Menu/no_character_found.png")
			unlocked_characters[index][2] = "res://Visual/Menu/no_character_found.png"
	$character_select/character_render.texture = texture
	
	Global.scale_down_sprite($character_select/character_render, Vector2(1, 1), Vector2(384, 384))

func load_icon(index : int):
	if unlocked_characters.size() == 0:
		get_node("character_select/characters/" + String(index)).texture.texture = preload("res://Visual/Menu/no_icon_found.png")
		return
	if index < 0:
		index += unlocked_characters.size()
	if index >= unlocked_characters.size():
		index -= unlocked_characters.size()
	
	var texture : Texture
	if unlocked_characters[index][3] != "":
		texture = load(unlocked_characters[index][3])
	else:
		texture = load(unlocked_characters[index][1] + "/Visual/" + unlocked_characters[index][0] + "/icon.png")
		unlocked_characters[index][3] = unlocked_characters[index][1] + "/Visual/" + unlocked_characters[index][0] + "/icon.png"
		if texture == null:
			texture = preload("res://Visual/Menu/no_icon_found.png")
			unlocked_characters[index][3] = "res://Visual/Menu/no_icon_found.png"
	get_node("character_select/characters/" + String(index)).texture = texture
	
	Global.scale_down_sprite(get_node("character_select/characters/" + String(index)), Vector2(1, 1), Vector2(128, 128))
