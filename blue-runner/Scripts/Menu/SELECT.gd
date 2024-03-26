extends Node2D


const UNFINISHED_GROUP_TIMER_TEXT = "Time: N/A"
const NO_GROUP_DESCRIPTION = "No description given."


onready var parent : Node2D = get_parent()

var is_selecting_groups : bool = false
var groups_first_time : bool = true
var current_group_color : int = 0

var selected_level : int
var has_selected_level : bool = false

var group_current : int = 0

var user_levels : Array

var user_selected_level : int = 0
var user_current_page : int = 0
var user_page_amount : int = 0

var bg : Node2D
export var cam_target : Vector2 = Vector2(0, 0)

export var character_pulse : float = 0

var is_selecting_characters : bool = false
var characters_first_time : bool = true
var selected_character : int = 0

var showcase_characters : Array = []
var showcase_groups : Array = []


func _ready():
	check_group_unlocks()
	
	var directory : Directory = Directory.new()
	var check_exist = directory.open(Global.USER_LEVELS)
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
	user_page_amount = user_levels.size() / 20 + 1
	
#	print(user_levels)
	if Global.current_level_location == Global.USER_LEVELS:
		for i in range(user_levels.size()):
			if user_levels[i] == Global.current_level:
				user_selected_level = int(i)
				# warning-ignore:integer_division
				user_current_page = int(i) / 20
				Global.select_menu = false
				break
	
	reload_all_levels()
	if Global.select_menu:
		Global.select_menu = false
		for i in range(20):
			if get_node("level_select/levels/" + String(i)).level_name == Global.current_level and get_node("level_select/levels/" + String(i)).level_location == Global.current_level_location:
				selected_level = i
				break
	
	set_level_data_text(false)
#	print(Global.current_level_location)
	level_move_cursor()
	
#	group_move_cursor()
	
	check_character_unlocks()
	
	$bg.modulate.a = 1
	$bg.visible = true
	$level_select.visible = true
	cam_target = Vector2(320, 160)
	$level_select/levels.position = Vector2(1024, 160)
	$level_select/level_data.position = Vector2(-800, 0)
	
	$mainAnim.play("enter")


func _physics_process(_delta):
	if $mainAnim.is_playing() and bg != null:
		bg.update_self(cam_target)
		bg.position = Vector2(0, 0)


func _exit_tree():
	Global.wipe_loaded_group_textures()


func menu_update():
	if parent.move:
		$level_select/dependency.visible = false
		$level_select/fail.visible = false
	
	if is_selecting_groups:
		if Input.is_action_just_pressed("deny"):
			parent.switch_menu("MAIN", "SELECT")
			$mainAnim.play("exit")
			return
		
		if Input.is_action_just_pressed("accept"):
			Global.current_level_location = Global.location_of_loaded_group(group_current, Global.unlocked_level_groups)
			is_selecting_groups = false
			selected_level = 0
			user_selected_level = 0
			user_current_page = 0
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
			Global.current_character = Global.unlocked_characters[selected_character][0]
			Global.current_character_location = Global.unlocked_characters[selected_character][1]
			Global.select_menu = true
			if Global.change_level("", true) != OK:
				$level_select/fail.visible = true
				is_selecting_characters = false
				$mainAnim.play("CHARACTER -> LEVEL")
			else:
				parent.get_node("Camera").start_fade_out("")
		
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
		if Input.is_action_just_pressed("deny") and not has_selected_level:
			if Global.unlocked_level_groups.size() > 1:
				is_selecting_groups = true
				if groups_first_time:
					make_group_icons()
					groups_first_time = false
				group_move_cursor()
				$mainAnim.play("LEVEL -> GROUP")
			else:
				parent.switch_menu("MAIN", "SELECT")
				$mainAnim.play("exit_alt")
				return
		if Input.is_action_just_pressed("accept") and not has_selected_level:
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
		
		if parent.move == true:
			$level_select/new_version.visible = false
	
	if showcase_characters:
		var chara : int = showcase_characters.pop_back()
		parent.showcase_unlock(Global.unlocked_characters[chara][0] + " unlocked!", load_character_sprite(chara))
	elif showcase_groups:
		var group : int = showcase_groups.pop_back()
		parent.showcase_unlock(Global.unlocked_level_groups[group][0] + " unlocked!", load_group_title(group))
	
	$level_select/description.visible = Input.is_action_pressed("info")


func level_move_cursor(move_amount : int = 0):
	
	var is_in_user_universe = Global.current_level_location == Global.USER_LEVELS
	
	if move_amount == 0:
		pass
	elif !is_in_user_universe:
		if sign(move_amount) == -1 and selected_level + (move_amount - sign(move_amount)) > 0:
			selected_level += move_amount
		if sign(move_amount) == 1 and selected_level + (move_amount - sign(move_amount)) < 19:
			selected_level += move_amount
	elif is_in_user_universe:
		user_selected_level += move_amount
		if sign(move_amount) == -1:
			if user_selected_level - user_current_page * 20 < 0:
				user_current_page -= 1
				if user_current_page <= -1:
					user_current_page += 1
					user_selected_level -= move_amount
				else:
					$level_select/author.text = String(user_current_page + 1) + "/" + String(user_page_amount)
					reload_all_levels()
		if sign(move_amount) == 1:
			if user_selected_level - user_current_page * 20 > 19:
				user_current_page += 1
				if user_current_page >= user_page_amount:
					user_current_page -= 1
					user_selected_level -= move_amount
				else:
					$level_select/author.text = String(user_current_page + 1) + "/" + String(user_page_amount)
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
	
	var group_num : int = Global.unlocked_level_groups.size()
	
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
		if sign(move_amount) == 1 and selected_character + move_amount < Global.unlocked_characters.size():
			selected_character += move_amount
	
#	print(selected_character)
	
	if selected_character < 0:
		selected_character = 0
	if selected_character >= Global.unlocked_characters.size():
		selected_character = Global.unlocked_characters.size() - 1
	
	update_character_visuals()


func find_current_character():
	for i in range(Global.unlocked_characters.size()):
		if Global.unlocked_characters[i][0] == Global.current_character and Global.unlocked_characters[i][1] == Global.current_character_location:
			selected_character = i
			return
	selected_character = 0


func update_character_visuals():
	# warning-ignore:integer_division
	# warning-ignore:integer_division
	$character_select/characters.position = Vector2(160 + (selected_character / 4) * 32, -(selected_character / 4) * 128)
	$character_select/characters/cursor.position = get_node("character_select/characters/" + String(selected_character)).position
	load_render(selected_character)
	
	if Global.loaded_characters[Global.unlocked_characters[selected_character][1]][Global.unlocked_characters[selected_character][0]].size() > 3:
		$character_select/name.bbcode_text = "[center]" + Global.loaded_characters[Global.unlocked_characters[selected_character][1]][Global.unlocked_characters[selected_character][0]][3] + "[/center]"
		$character_select/description.bbcode_text = "[center]" + Global.loaded_characters[Global.unlocked_characters[selected_character][1]][Global.unlocked_characters[selected_character][0]][4] + "[/center]"
	else:
		$character_select/name.bbcode_text = "[center]" + Global.unlocked_characters[selected_character][0] + "[/center]"
		$character_select/description.bbcode_text = ""


func make_group_icons():
	var repetitions : int = Global.unlocked_level_groups.size()
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
		var file : String = Global.location_of_loaded_group(i, Global.unlocked_level_groups) + "logo.png"
		if Global.unlocked_level_groups[i][1] == "user://":
			get_node("group_select/groups/" + String(i)).texture = preload("res://Visual/Title/logo_user.png")
		elif Global.unlocked_level_groups[i][3] != null:
			get_node("group_select/groups/" + String(i)).texture = Global.unlocked_level_groups[i][3]
		else:
			get_node("group_select/groups/" + String(i)).texture = Global.load_texture_from_png(file)
			Global.unlocked_level_groups[i][3] = get_node("group_select/groups/" + String(i)).texture
			if get_node("group_select/groups/" + String(i)).texture == null:
				get_node("group_select/groups/" + String(i)).texture = preload("res://Visual/Title/logo_custom.png")
				Global.unlocked_level_groups[i][3] = get_node("group_select/groups/" + String(i)).texture
		
		Global.scale_down_sprite(get_node("group_select/groups/" + String(i)), Vector2(2, 2))


func load_group_title(index : int) -> Texture:
	var group_location = Global.location_of_loaded_group(index, Global.unlocked_level_groups)
	var is_user_group : bool = group_location == Global.USER_LEVELS
	var texture : Texture
	
	if is_user_group:
		texture = preload("res://Visual/Title/title_user.png")
	else:
		if Global.unlocked_level_groups[index][2] != null:
			texture = Global.unlocked_level_groups[index][2]
		else:
			texture = Global.load_texture_from_png(group_location + "title.png")
			Global.unlocked_level_groups[index][2] = texture
		if texture == null:
			texture = preload("res://Visual/Title/title_custom.png")
			Global.unlocked_level_groups[index][2] = texture 
	
	return texture


func reload_all_levels():
	var is_user_group : bool = Global.current_level_location == Global.USER_LEVELS
	
	if !Global.load_level_group() and !is_user_group:
		return
	
	Global.update_level_group_save()
	
	# Group title
	$level_select/title.texture = load_group_title(group_current)
	
	var comp_list : Array = []
	for i in range(20):
		var level = get_node("level_select/levels/" + String(i))
		if is_user_group:
			if i + user_current_page * 20 >= user_levels.size():
				level.level_name = "*Level_Missing"
			else:
				level.level_name = user_levels[i + user_current_page * 20]
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
	
	Global.unlocked_level_groups[group_current][4] = stats[0]
	
	var group = -1
	for i in range(Global.loaded_level_groups.size()):
		if Global.unlocked_level_groups[group_current][0] == Global.loaded_level_groups[i][0] and Global.unlocked_level_groups[group_current][1] == Global.loaded_level_groups[i][1]:
			group = i
	
	Global.loaded_level_groups[group][4] = stats[0]
	Global.unlocked["completion_percentages"][Global.loaded_level_groups[group][1] + Global.loaded_level_groups[group][0]] = stats[0]
	
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
	
	$level_select/description/stats_beat.text = String(stats[1])
	$level_select/description/stats_par.text = String(stats[2])
	$level_select/description/stats_bonus.text = String(stats[4])
	$level_select/description/stats_unlock.text = String(stats[3])
	$level_select/description/keycollect.visible = not is_user_group
	$level_select/description/stats_unlock.visible = not is_user_group
	
	$level_select/description/name.text = Global.loaded_level_groups[group_current][0]
	$level_select/time.text = level_group_complete_time(Global.current_level_location)
	
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
		
		if Global.level_group.has("author"):
			if Global.level_group["author"] == "":
				$level_select/author.text = ""
				$level_select/description/author.text = ""
			else:
				var author_text = "By: " + Global.level_group["author"]
				$level_select/author.text = author_text
				$level_select/description/author.text = author_text
		
		if Global.level_group.has("description"):
			if Global.level_group["description"] == "":
				$level_select/description/text.text = NO_GROUP_DESCRIPTION
			else:
				$level_select/description/text.text = Global.level_group["description"]
		else:
			$level_select/description/text.text = NO_GROUP_DESCRIPTION
		
		if Global.level_group.has("ui_color"):
			color = Color(Global.level_group["ui_color"][0], Global.level_group["ui_color"][1], Global.level_group["ui_color"][2])
	else:
		$level_select/author.visible = true
		$level_select/author.text = String(user_current_page + 1) + "/" + String(user_page_amount)
	
	$level_select/levels/selected_level.modulate = color
	$level_select/Completion.set_color(color)
	
	$level_select/level_data.material.set_shader_param("color", color)
	$level_select/level_data.material.set_shader_param("secondary_color", color * Color(0.2, 0.2, 0.3, 1))
	
	if is_user_group and Global.new_version_alert:
		$level_select/new_version.visible = true
		Global.new_version_alert = false


func level_group_complete_time(group : String) -> String:
	if not Global.level_completion.has(group):
		return UNFINISHED_GROUP_TIMER_TEXT
	var time : float = 0
	for level in Global.level_completion[group].keys():
		if not Global.level_completion[group].has(level):
			return UNFINISHED_GROUP_TIMER_TEXT
		if Global.level_completion[group][level][0] == null:
			return UNFINISHED_GROUP_TIMER_TEXT
		time += Global.level_completion[group][level][0]
	return "Time: " + Global.convert_float_to_time(time)


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
		$level_select/level_data/level_picture.texture = null
		$level_select/level_data/level_picture.visible = false
		return
	
	# level picture
	var picture_filepath : String = selected_level_location + selected_level_name + ".png"
	var f : File = File.new()
	if f.file_exists(picture_filepath):
		Global.load_external_picture(picture_filepath, $level_select/level_data/level_picture)
		Global.scale_down_sprite($level_select/level_data/level_picture, Vector2(1, 1), Vector2(0, 192))
		$level_select/level_data/level_picture.visible = true
		$level_select/level_data/level_name.rect_position.y = -216
		$level_select/level_data/best_time.rect_position.y = 128
		$level_select/level_data/par.rect_position.y = 160
		$level_select/level_data/deaths.rect_position.y = 192
		$level_select/level_data/creator.rect_position.y = 224
	else:
		$level_select/level_data/level_picture.texture = null
		$level_select/level_data/level_picture.visible = false
		$level_select/level_data/level_name.rect_position.y = -104
		$level_select/level_data/best_time.rect_position.y = 0
		$level_select/level_data/par.rect_position.y = 32
		$level_select/level_data/deaths.rect_position.y = 64
		$level_select/level_data/creator.rect_position.y = 96
	
	# Author and level name
	if !level_dat.empty():
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
				else:
					$level_select/level_data/creator.set_text("")
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
	elif Global.change_level("", true, false) != OK:
		get_node("level_select/levels/" + String(selected_level)).get_node("Anim").play("Refuse")
		$level_select/levels/selected_level/anim.play("Refuse")
		$level_select/fail.visible = true
		has_selected_level = false
	elif activate_char_select:
		if characters_first_time:
			find_current_character()
			make_character_icons()
			characters_first_time = false
		update_character_visuals()
		$mainAnim.play("LEVEL -> CHARACTER")
		is_selecting_characters = true
		has_selected_level = false
	else:
		Global.select_menu = true
		parent.get_node("Camera").start_fade_out("")


func check_group_unlocks():
	var unlocked_level_groups : Array = []
	var group_not_found : bool = true
	var check_group : int = 0
	
	for i in Global.loaded_level_groups.size():
		var check : bool = false
		var showcase : bool = false
		var new_unlock : bool = true
		
		if Global.unlocked_level_groups.size() > check_group:
			if Global.location_of_loaded_group(check_group, Global.unlocked_level_groups) == Global.location_of_loaded_group(i):
				check_group += 1
				check = true
				new_unlock = false
		if new_unlock:
			if Global.check_loaded_group_unlocked(i):
				check = true
				showcase = true
		
		if check:
			unlocked_level_groups.append(Global.loaded_level_groups[i])
			if Global.current_level_location == Global.location_of_loaded_group(i):
				group_current = unlocked_level_groups.size() - 1
				group_not_found = false
			if showcase and Global.unlocked_level_groups.size() != 0:
				showcase_groups.append(unlocked_level_groups.size() - 1)
		
	if group_not_found:
		group_current = 0
		Global.current_level_location = Global.location_of_loaded_group(0, unlocked_level_groups)
	
	Global.unlocked_level_groups = unlocked_level_groups.duplicate()


func check_character_unlocks():
	var unlocked_characters : Array = []
	var check_character : int = 0
	
#	print(Global.loaded_characters)
	for place in Global.loaded_characters.keys():
		for character in Global.character_order[place]:
			var check : bool = false
			var showcase : bool = false
			
			if Global.unlocked_characters.size() > check_character and character == Global.unlocked_characters[check_character][0]:
				check_character += 1
				check = true
				
			else:
				var unlock_type : int = Global.loaded_characters[place][character][0]
				var parameter_1 = Global.loaded_characters[place][character][1]
				var parameter_2 = Global.loaded_characters[place][character][2]
				
				if unlock_type == 5:
					check = Global.check_unlock_requirements(unlock_type, parameter_1, place, place)
				else:
					check = Global.check_unlock_requirements(unlock_type, parameter_1, parameter_2, place)
				
				showcase = check
			
			if check:
				unlocked_characters.append([character, place, "", ""])
				
				if unlocked_characters.size() > 1:
					Global.unlock("*char_select_active")
				if showcase and Global.unlocked_characters.size() != 0:
					showcase_characters.append(unlocked_characters.size() - 1)
	
	Global.unlocked_characters = unlocked_characters.duplicate()


func make_character_icons():
	var repetitions : int = Global.unlocked_characters.size()
	# warning-ignore:narrowing_conversion
	for i in range(repetitions):
		var new_sprite : Sprite = Sprite.new()
		new_sprite.name = String(i)
		new_sprite.texture = preload("res://Visual/Editor/editor_missing.png")
		new_sprite.scale = Vector2(2, 2)
		
		var sprite_position : Vector2 = Vector2(0, 0)
		# warning-ignore:integer_division
		sprite_position.x = 128 * (i % 4) - 32 * (int(i) / 4)
		# warning-ignore:integer_division
		sprite_position.y = 128 * (int(i) / 4)
		
		new_sprite.position = sprite_position
		
		$character_select/characters.add_child(new_sprite)
	
	for i in range(repetitions):
		load_icon(i)


func load_render(index : int, icon : bool = false):
	var sprite : Sprite
	if icon:
		sprite = get_node("character_select/characters/" + String(index))
	else:
		sprite = $character_select/character_render
	
	if Global.unlocked_characters.size() == 0:
		if icon:
			sprite.texture = preload("res://Visual/Menu/no_icon_found.png")
		else:
			sprite.texture = preload("res://Visual/Menu/no_character_found.png")
		return
	if index < 0:
		index += Global.unlocked_characters.size()
	if index >= Global.unlocked_characters.size():
		index -= Global.unlocked_characters.size()
	
	sprite.texture = load_character_sprite(index, icon)
	
	var size = Vector2(384, 384)
	if icon:
		size = Vector2(128, 128)
	
	Global.scale_down_sprite(sprite, Vector2(1, 1), size)


func load_icon(index : int):
	load_render(index, true)


func load_character_sprite(index : int, icon : bool = false) -> Texture:
	var dat : int = 2
	var file : String = "portrait.png"
	if icon:
		dat = 3
		file = "icon.png"
	var texture : Texture
	
	if Global.unlocked_characters[index][dat] != "":
		texture = load(Global.unlocked_characters[index][dat])
	else:
		texture = load(Global.unlocked_characters[index][1] + "/Visual/" + Global.unlocked_characters[index][0] + "/" + file)
		Global.unlocked_characters[index][dat] = Global.unlocked_characters[index][1] + "/Visual/" + Global.unlocked_characters[index][0] + "/" + file
		if texture == null:
			if icon:
				texture = preload("res://Visual/Menu/no_icon_found.png")
				Global.unlocked_characters[index][3] = "res://Visual/Menu/no_icon_found.png"
			else:
				texture = preload("res://Visual/Menu/no_character_found.png")
				Global.unlocked_characters[index][2] = "res://Visual/Menu/no_character_found.png"
	
	return texture
