extends Control

#game Stuff
const VERSION : String = "2.0.0-dev"
const USER_LEVELS : String = "user://SRLevels/"
const SAVEFILE : String = "user://sonicRunner"
const MODS_SAVEFILE : String = "user://sonicRunnerMods"
const KEYBIND_NAMES : Array = ["*left", "*right", "*up", "*down", "*jump", "*special", "*reset", "*return", "*menu_left", "*menu_right", "*menu_up", "*menu_down", "*accept", "*deny", "*save_replay", "*screenshot", "*info"]

const DEFAULT_OPTIONS : Dictionary = {
	"*version" : VERSION,
	"*left" : KEY_LEFT,
	"*right" : KEY_RIGHT,
	"*up" : KEY_UP,
	"*down" : KEY_DOWN,
	"*jump" : KEY_SPACE,
	"*special" : KEY_CONTROL,
	"*reset" : KEY_ENTER,
	"*return" : KEY_ESCAPE,
	"*menu_left" : KEY_LEFT,
	"*menu_right" : KEY_RIGHT,
	"*menu_up" : KEY_UP,
	"*menu_down" : KEY_DOWN,
	"*accept" : KEY_SPACE,
	"*deny" : KEY_ESCAPE,
	"*save_replay" : KEY_F6,
	"*screenshot" : KEY_F2,
	"*info" : KEY_F3,
	"*outlines_on" : false,
	"*ghosts_on" : false,
	"*up_key_jump" : true,
	"*timer_on" : 0,
	"*first_time_load" : true,
	"*last_level_location" : "res://Scenes/waterway/",
	"*audio_sfx" : 60,
	"*audio_music" : 60,
}


var new_version_alert : bool = false
var savefile_interaction : int = 3
var compatibility_mode : bool = false
var playtesting : bool = false
var speedometer_active : bool = false

var level_completion : Dictionary = {
	"*collectibles" : {},
}
var unlocked : Dictionary = {
	"*char_select_active" : false,
	"completion_percentages" : {},
}
var options : Dictionary = {}

var mods_installed = []

var rand : RandomNumberGenerator = RandomNumberGenerator.new()

var current_character : String = "S1"
var current_character_location : String = "res:/"

var in_load_previously : bool = true

var replay : bool = false
var current_recording = {}
var replay_menu : bool = false
var replay_save : Array = [0, 0, ""]
var race_mode : bool = false

var select_menu : bool = false
var current_page : int = 0
var current_level : String = ""
var current_level_location : String = "res://Scenes/waterway/"

var loaded_level_groups = []
var user_levels : Array
var user_pages : int
var level_group = {}
var unlocked_level_groups : Array = []

var loaded_characters : Dictionary = {}
var character_order : Dictionary = {}
var unlocked_characters : Array = []

var last_input_events : Array = []

var doing_tutorial : bool = false


func _ready():
	console_arguments()
	
	rand.randomize()
	var scaling = OS.window_size.x / OS.window_size.y
	var height = get_tree().get_root().size.y
	
	# warning-ignore:integer_division
	get_tree().get_root().size.x = int(height * scaling) / 2 * 2
	
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	
	load_game()
	var dir = Directory.new()
	dir.open("user://")
	if !dir.dir_exists("SRReplays"):
		dir.make_dir("SRReplays")
	if !dir.dir_exists("SRReplays/res"):
		dir.make_dir("SRReplays/res")
	if !dir.dir_exists("SRReplays/mods"):
		dir.make_dir("SRReplays/mods")
	if !dir.dir_exists("SRReplays/user"):
		dir.make_dir("SRReplays/user")
	if !dir.dir_exists("SRScreenshots"):
		dir.make_dir("SRScreenshots")
	
	# Load user levels
	var directory : Directory = Directory.new()
	var check_exist = directory.open(USER_LEVELS)
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
		user_pages = user_levels.size() / 20
	
	load_data()
	
	# Bindings
	for inputs in KEYBIND_NAMES:
		var new_key = InputEventKey.new()
		if options[inputs] != null:
			new_key.scancode = options[inputs]
		else:
			new_key.scancode = DEFAULT_OPTIONS[inputs]
		last_input_events.append(new_key)
	
	for i in range(last_input_events.size()):
		change_input(i, last_input_events[i])
	
	current_level_location = options["*last_level_location"]
	# warning-ignore:return_value_discarded
	load_level_group()


func console_arguments():
	var arguments = {}
	for arg in OS.get_cmdline_args():
		var key_value = ["",""]
		if arg.find("=") > -1:
			key_value = arg.split("=")
		elif arg.find(" ") > -1:
			key_value = arg.split(" ")
		else:
			key_value[0] = arg
		arguments[key_value[0].lstrip("--")] = key_value[1]
	
	#--level=res://Scenes/waterway/Level_1-0.tscn
	if arguments.has("level"):
		call_deferred("change_level", "*" + arguments["level"])
	if arguments.has("playtest"):
#		print(arguments["playtest"])
		call_deferred("change_level", "!*" + arguments["playtest"])
		playtesting = true
	if arguments.has("speedometer"):
		speedometer_active = true
	if arguments.has("save_interaction"):
		match(arguments["save_interaction"]):
			"x":
				savefile_interaction = 0
			"r":
				savefile_interaction = 1
			"w":
				savefile_interaction = 2
			"rw":
				savefile_interaction = 3
			"wr":
				savefile_interaction = 3
	if savefile_interaction % 2:
		print("read allowed")
	# warning-ignore:integer_division
	if savefile_interaction / 2:
		print("write allowed")


func _physics_process(_delta):
	var curr_scene = get_tree().current_scene.name
	
	if Input.is_action_just_pressed("return") and !(curr_scene == "MENU" or curr_scene == "LOAD"):
		change_level_fade_out("*MENU")
	if Input.is_action_just_released("reset") and !(curr_scene == "MENU" or curr_scene == "LOAD"):
		change_level_fade_out("")
	
	if Input.is_action_just_pressed("screenshot"):
		screenshot()


func _exit_tree():
	save_game()


func quit_game():
	get_tree().current_scene.queue_free()
	
	get_tree().call_deferred("quit")


func fade_float(start : float, end : float, progress : float) -> float:
	if progress == 0:
		return start
	if progress == 1:
		return end
	return start + (end - start) * progress


func string_start_similarity(string1 : String, string2 : String) -> int:
	var max_s = string1.length()
	if string2.length() < max_s:
		max_s = string2.length()
	
	var s : int = 0
	
	while s < max_s and string1[s] == string2[s]:
		s += 1
	
	return s


func change_input(input_id : int, new_input):
	var input_string : String = KEYBIND_NAMES[input_id].trim_prefix("*")
#	print(input_string)
	if InputMap.action_has_event(input_string, last_input_events[input_id]):
		InputMap.action_erase_event(input_string, last_input_events[input_id])
	InputMap.action_add_event(input_string, new_input)
	
	last_input_events[input_id] = new_input
	options["*" + input_string] = new_input.scancode


const NAMES : Dictionary = {
	KEY_SPACE : "SPACE",
	KEY_ESCAPE : "ESCAPE",
	KEY_TAB : "TAB",
	KEY_BACKTAB : "BACKTAB",
	KEY_BACKSPACE : "BACKSPACE",
	KEY_ENTER : "ENTER",
	KEY_KP_ENTER : "KEYPAD ENTER",
	KEY_INSERT : "INSERT",
	KEY_DELETE : "DELETE",
	KEY_PAUSE : "PAUSE",
	KEY_PRINT : "SCREENSHOT",
	KEY_SYSREQ : "SYSTEM REQUEST",
	KEY_CLEAR : "CLEAR",
	KEY_HOME : "S1 COME HOME",
	KEY_END : "THE END",
	KEY_LEFT : "LEFT ARROW",
	KEY_UP : "UP ARROW",
	KEY_RIGHT : "RIGHT ARROW",
	KEY_DOWN : "DOWN ARROW",
	KEY_PAGEUP : "PAGE UP",
	KEY_PAGEDOWN : "PAGE DOWN",
	KEY_SHIFT : "SHIFT",
	KEY_CONTROL : "CONTROL",
	KEY_META : "THIS KEY IS THE META",
	KEY_ALT : "ALT",
	KEY_CAPSLOCK : "SCREAM LOCK",
	KEY_NUMLOCK : "ALWAYS ON LOCK",
	KEY_SCROLLLOCK : "SOMETHING LOCK",
	KEY_F1 : "F1",
	KEY_F2 : "F2",
	KEY_F3 : "F3",
	KEY_F4 : "F4",
	KEY_F5 : "F5",
	KEY_F6 : "F6",
	KEY_F7 : "F7",
	KEY_F8 : "F8",
	KEY_F9 : "F9",
	KEY_F10 : "F10",
	KEY_F11 : "F11",
	KEY_F12 : "F12",
	KEY_F13 : "F13",
	KEY_F14 : "F14",
	KEY_F15 : "F15",
	KEY_F16 : "F16",
	KEY_KP_MULTIPLY : "KEYPAD *",
	KEY_KP_DIVIDE : "KEYPAD /",
	KEY_KP_SUBTRACT : "KEYPAD -",
	KEY_KP_PERIOD : "KEYPAD .",
	KEY_KP_ADD : "KEYPAD +",
	KEY_KP_0 : "KEYPAD 0",
	KEY_KP_1 : "KEYPAD 1",
	KEY_KP_2 : "KEYPAD 2",
	KEY_KP_3 : "KEYPAD 3",
	KEY_KP_4 : "KEYPAD 4",
	KEY_KP_5 : "KEYPAD 5",
	KEY_KP_6 : "KEYPAD 6",
	KEY_KP_7 : "KEYPAD 7",
	KEY_KP_8 : "KEYPAD 8",
	KEY_KP_9 : "KEYPAD 9",
	KEY_SUPER_L : "SUPER LEFT",
	KEY_SUPER_R : "SUPER RIGHT",
	KEY_MENU : "GIVE THE CONTEXT",
	KEY_HYPER_L : "HYPER LEFT",
	KEY_HYPER_R : "HYPER RIGHT",
	KEY_HELP : "HELP THEM GOD",
	KEY_DIRECTION_L : "DIRECTIONAL LEFT",
	KEY_DIRECTION_R : "DIRECTIONAL RIGHT",
	KEY_BACK : "BACK TO THE MARK",
	KEY_FORWARD : "FOWARD TO THE FUTURE",
	KEY_STOP : "STOP IT",
	KEY_REFRESH : "REFRESHING",
	KEY_VOLUMEDOWN : "TURN IT DOWN",
	KEY_VOLUMEMUTE : "MUTE IT PLEASE",
	KEY_VOLUMEUP : "TURN IT UP",
	KEY_BASSBOOST : "LOUD = FUNNY",
	KEY_BASSUP : "BASS UP",
	KEY_BASSDOWN : "BASS DOWN",
	KEY_TREBLEUP : "TREBLE UP",
	KEY_TREBLEDOWN : "TREBLE DOWN",
	KEY_MEDIAPLAY : "PLAY THAT SONG AGAIN",
	KEY_MEDIASTOP : "STOP THE MUSIC",
	KEY_MEDIAPREVIOUS : "CLASSICAL ART",
	KEY_MEDIANEXT : "ART OF THE FUTURE",
	KEY_MEDIARECORD : "CAUGHT ON CAMERA",
	KEY_HOMEPAGE : "HOME WITH PAGE",
	KEY_FAVORITES : "MY JAM",
	KEY_SEARCH : "FIND THEM",
	KEY_STANDBY : "HALT",
	KEY_OPENURL : "BROWSER TIME",
	KEY_LAUNCHMAIL : "MAIL TIME",
	KEY_LAUNCHMEDIA : "MEDIA TIME",
	KEY_LAUNCH0 : "SHORTCUT 0",
	KEY_LAUNCH1 : "SHORTCUT 1",
	KEY_LAUNCH2 : "SHORTCUT 2",
	KEY_LAUNCH3 : "SHORTCUT 3",
	KEY_LAUNCH4 : "SHORTCUT 4",
	KEY_LAUNCH5 : "SHORTCUT 5",
	KEY_LAUNCH6 : "SHORTCUT 6",
	KEY_LAUNCH7 : "SHORTCUT 7",
	KEY_LAUNCH8 : "SHORTCUT 8",
	KEY_LAUNCH9 : "SHORTCUT 9",
	KEY_LAUNCHA : "SHORTCUT A",
	KEY_LAUNCHB : "SHORTCUT B",
	KEY_LAUNCHC : "SHORTCUT C",
	KEY_LAUNCHD : "SHORTCUT D",
	KEY_LAUNCHE : "SHORTCUT E",
	KEY_LAUNCHF : "SHORTCUT F",
	KEY_UNKNOWN : "???",
}
func key_names(key : int):
	var key_number = options[KEYBIND_NAMES[key]]
	if key_number >= 33 and key_number <= 255:
		return char(key_number)
	else:
		if NAMES.has(key_number):
			return NAMES[key_number]
		else:
			return "WHAT IS THIS?"


func text_interpretor(text : String):
	var next_text : String = text
	var new_text : String = ""
	
	#print("starting :",text)
	while next_text != "":
		var interpret : String
		if next_text.find("%") == -1 and next_text.find("`") == -1:
			new_text += next_text
			break
		elif next_text.find("%") == -1:
			interpret = "`"
		elif next_text.find("`") == -1:
			interpret = "%"
		elif next_text.find("`") < next_text.find("%"):
			interpret = "`"
		elif next_text.find("%") < next_text.find("`"):
			interpret = "%"
		
		new_text += next_text.substr(0, next_text.find(interpret))
		var op_text = next_text.substr(next_text.find(interpret) + 1, next_text.length() - next_text.find(interpret))
		next_text = op_text.substr(op_text.find(interpret) + 1, op_text.length() - op_text.find(interpret) - 1)
		
		op_text = op_text.substr(0, op_text.find(interpret))
		#print("op_text  :",op_text)
		if interpret == "`":
			new_text += op_text
		if interpret == "%":
			if "*" + op_text in KEYBIND_NAMES:
				new_text += key_names(KEYBIND_NAMES.find("*" + op_text))
			else: match op_text:
				"`":
					new_text += "`"
				"current_level":
					new_text += current_level
				"current_level_location":
					new_text += current_level_location
				"current_character":
					new_text += current_character
				"current_character_location":
					new_text += current_character_location
				"version":
					new_text += VERSION
				_: # bruh
					if op_text.begins_with("unlock"):
						if check_unlock(op_text.substr(7, op_text.length() - 7)):
							new_text += "YES"
						else:
							new_text += "NO"
					if op_text.begins_with("level"):
						var level : Node2D = get_tree().current_scene
						var data : String = op_text.substr(6, op_text.length() - 6)
						if !level.dat.has(data): continue
						if data == "dependencies" or data == "tags": continue
						if data == "level_base" or data == "level_icon":
							new_text += level.dat[data][0] + " from " + level.dat[data][1]
							continue
						new_text += level.dat[data]
#		print("next     :",next_text)
#	print("return   :",new_text)
#	breakpoint
	
	return new_text


func add_date_to_name(dname : String):
	var date = OS.get_datetime()
	dname = (dname +
			"_" + String(date["year"]) +
			"-" + String(date["month"]) +
			"-" + String(date["day"]) +
			"_" + String(date["hour"]) +
			"-" + String(date["minute"]) +
			"-" + String(date["second"]))
	return dname


func load_external_picture(picture_filename : String, sprite : Sprite, image_was_imported : bool = false):
	if image_was_imported:
		sprite.texture = load(picture_filename)
	else:
		var pngf = File.new()
		if not pngf.file_exists(picture_filename):
			sprite.texture = preload("res://Visual/no_image.png")
			return
		
		pngf.open(picture_filename, File.READ)
		var pnglen = pngf.get_len()
		var pngdata = pngf.get_buffer(pnglen)
		pngf.close()
		
		var image = Image.new()
		image.load_png_from_buffer(pngdata)
		var image_texture : ImageTexture = ImageTexture.new()
		image_texture.create_from_image(image.get_rect(image.get_used_rect()))
		
		sprite.texture = image_texture
	
	if sprite.texture == null:
		sprite.texture = preload("res://Visual/no_image.png")


func convert_float_to_time(timer : float, limit_size : bool = true):
	# warning-ignore:narrowing_conversion
	var minutes : int = int(abs(floor(timer) / 60))
	# warning-ignore:narrowing_conversion
	var seconds : int = int(abs(floor(timer))) - minutes * 60
	# warning-ignore:narrowing_conversion
	var decimal : int = int(abs(floor(timer * 100 + 0.1))) % 100
	if timer >= 6000 and limit_size:
		return "too much"
	elif timer >= 0:
		# warning-ignore:integer_division
		# warning-ignore:integer_division
		return String(minutes)+":"+String(seconds/10)+String(seconds%10)+"."+String(decimal/10)+String(decimal%10)
	else:
		# warning-ignore:integer_division
		# warning-ignore:integer_division
		return "-"+String(minutes)+":"+String(seconds/10)+String(seconds%10)+"."+String(decimal/10)+String(decimal%10)


func scale_down_sprite(sprite : Sprite, final_scale : Vector2 = Vector2(1, 1), desired_rect : Vector2 = Vector2(64, 64)):
	if desired_rect.x == 0 and desired_rect.y == 0:
		return
	
	sprite.scale = Vector2(1, 1)
	var sprite_rect : Vector2 = sprite.get_rect().size
	
	var x_is_longer_side : bool = false
	if desired_rect.y == 0:
		x_is_longer_side = true
	elif desired_rect.x == 0:
		x_is_longer_side = false
	elif sprite_rect.x > sprite_rect.y:
		x_is_longer_side = true
	
	if x_is_longer_side:
		sprite.scale.x = final_scale.x / (sprite_rect.x / desired_rect.x)
	else:
		sprite.scale.x = final_scale.y / (sprite_rect.y / desired_rect.y)
	sprite.scale.y = sprite.scale.x


func load_texture_from_png(path : String = ""):
	if path == "": return null
	
	if path.begins_with("res://"):
		var stream_texture : StreamTexture = load(path)
		if stream_texture != null:
			return stream_texture
		return null
	
	var file : File = File.new()
	var image : Image = Image.new()
	var texture : ImageTexture = ImageTexture.new()
	
	if file.file_exists(path):
		# warning-ignore:return_value_discarded
		file.open(path, File.READ)
		var buffer = file.get_buffer(file.get_len())
		# warning-ignore:return_value_discarded
		image.load_png_from_buffer(buffer)
		texture.create_from_image(image, texture.STORAGE_COMPRESS_LOSSLESS)
		#print(ResourceSaver.get_recognized_extensions(texture))
		return texture
	return null


func update_level_group_save():
	var is_user_group : bool = current_level_location == USER_LEVELS
	
	if !load_level_group() and !is_user_group:
		return false
	
	if !level_completion.has(current_level_location):
		level_completion[current_level_location] = {}
	if !level_completion["*collectibles"].has(current_level_location):
		level_completion["*collectibles"][current_level_location] = []
	if !is_user_group:
		if !unlocked.has(current_level_location):
			unlocked[current_level_location] = {}
		if typeof(unlocked[current_level_location]) != TYPE_DICTIONARY:
			unlocked[current_level_location] = {}
		for i in range(20):
			if unlocked[current_level_location].has(level_group["levels"][i][0]):
				continue
			if level_group["levels"][i][0] == "*Level_Missing":
				continue
			if level_group["levels"][i][1]:
				unlocked[current_level_location][level_group["levels"][i][0]] = false


func completion_percentage(is_user_group : bool, user_current_page : int):
	var full : float = 0
	var completion : float = 0
	var beat : int = 0
	var par : int = 0
	var unlock : int = 0
	var bonus : int = 0
	for i in range(20):
		var level_name : String
		if !is_user_group:
			if level_group["levels"][i][0] == "*Level_Missing":# and current_level_location == "res://Scenes/":
				continue
			level_name = level_group["levels"][i][0]
		else:
			if i + user_current_page * 20 >= user_levels.size():
				continue
			level_name = user_levels[i + user_current_page * 20]
		full += 2
#		print(level_group["levels"][i][0])
		
		if level_completion[current_level_location].has(level_name):
			if level_completion[current_level_location][level_name][0] != null:
				completion += 1
				beat += 1
#				print("beat " + level_name)
				if level_completion[current_level_location][level_name][1] != null:
					if level_completion[current_level_location][level_name][1] == 0:
						completion += 1
					elif level_completion[current_level_location][level_name][0] < level_completion[current_level_location][level_name][1]:
						completion += 1
						par += 1
#						print("par " + level_name)
		if unlocked.has(current_level_location):
			if unlocked[current_level_location].has(level_name):
				full += 1
				if unlocked[current_level_location][level_name]:
					completion += 1
					unlock += 1
#					print("unlocked " + level_name)
		for c in range(3):
			if level_completion["*collectibles"][current_level_location].has(level_name + "*" + String(c + 1)):
				bonus += 1
#	print(String(completion) + " / " + String(full))
	
	var stats : Array = [0, beat, par, unlock, bonus]
	
	if full > 0:
		stats[0] = (completion / full) * 100
	else:
		stats[0] =  0
	return stats.duplicate()


func change_level_fade_out(destination : String):
	var camera = null
	if get_tree().current_scene.has_node("Camera"):
		camera = get_tree().current_scene.get_node("Camera")
	if camera:
		camera.start_fade_out(destination, true)
	else:
		change_level(destination) 


func change_level(destination : String, return_value : bool = false, check_dependencies : bool = true):
	compatibility_mode = false
	
	var destination_new : String
	var check_if_unlocked : bool = true
	
#	print("location: ", current_level_location)
#	print("destination: ", destination)
	
	if destination.begins_with("!"):
		destination = destination.substr(1, destination.length() - 1)
		check_if_unlocked = false
	
	if destination == "":
		destination_new = current_level_location + current_level + ".tscn"
	elif destination == "*MENU" or destination == "*Menu_Level_Select" or destination == "*Menu_Level_Select.tscn":
		destination_new = "res://Scenes/MENU.tscn"
	elif destination == "*Level_Missing":
		destination_new = "res://Scenes/other/Level_Missing.tscn"
	elif destination == "*Level_Next" and current_level_location == USER_LEVELS:
		destination_new = "res://Scenes/MENU.tscn"
	elif destination == "*Level_Next" and not level_group.has("levels"):
		destination_new = "res://Scenes/MENU.tscn"
	elif destination == "*Level_Next":
		var level : int = 0
		for i in range(19):
			if level_group["levels"][i][0] == current_level:
				if not is_level_unlocked(current_level_location, level_group["levels"][i + 1][0]):
					break
				if level_group["levels"][i + 1][0] == "*Level_Missing":
					break
				level = i + 1
				break
		if level == 0:
			destination_new = "res://Scenes/MENU.tscn"
		else:
			destination_new = current_level_location + level_group["levels"][level][0] + ".tscn"
	elif destination.begins_with("*"):
		destination_new = destination.trim_prefix("*")
	elif destination.begins_with("@"):
		var parsed : Array = parse_level_group_abreviation(destination)
		if not parsed.empty():
			destination_new = parsed[0] + parsed[1] + ".tscn"
		else:
			destination_new = "res://Scenes/other/Level_Missing.tscn"
			call_deferred("make_text_debug", "Cannot find group from abreviation: " + String(destination))
	else:
		destination_new = current_level_location + destination + ".tscn"
	
	var error = OK
	
#	print("destination converted: ", destination_new)
	
	if check_dependencies:
		var level_dat = load_dat_file(destination_new.left(destination_new.find_last(".")))
		if !level_dat.has("dependencies"):
			error = ERR_FILE_MISSING_DEPENDENCIES
		else:
			for i in level_dat["dependencies"]:
				if !mods_installed.has(i):
					error = ERR_FILE_MISSING_DEPENDENCIES
	
#	print(destination_new)
	
	if destination_new != "res://Scenes/MENU.tscn" and check_if_unlocked and not playtesting:
		if not is_level_file_unlocked(destination_new):
			destination_new = "res://Scenes/MENU.tscn"
	
	# End playtesting if you are going to the menu
	if destination_new == "res://Scenes/MENU.tscn" and playtesting:
		quit_game()
		return OK
	
	if destination_new != "res://Scenes/MENU.tscn":
		var current_group = get_group_from_filepath(destination_new)
		if current_group != current_level_location:
			current_level_location = get_group_from_filepath(destination_new)
			# warning-ignore:return_value_discarded
			load_level_group()
		current_level = get_level_from_filepath(destination_new)
		
#		print("CL " + current_level)
#		print("CLL " + current_level_location)
		if error == OK:
#			print(destination_new)
			error = change_scene_level(destination_new, return_value)
	else:
		error = get_tree().change_scene(destination_new)
	
	if return_value:
		return error
	elif error != OK:
		if playtesting:
			quit_game()
			return error
		# warning-ignore:return_value_discarded
		get_tree().change_scene("res://Scenes/other/Level_Missing.tscn")
		call_deferred("make_text_debug", String(destination_new) + " " + String(error))


func change_scene_level(file : String, return_only : bool = false):
	var packed_scene : PackedScene = load(file)
	if packed_scene == null:
		return ERR_CANT_OPEN
	var current_scene = packed_scene.instance()
	if current_scene == null:
		return ERR_CANT_CREATE
	if return_only:
		return OK
	
#	print(current_scene.name)
#	print(current_scene.get_script())
	
	if current_scene.get_script() == null:
		compatibility_mode = true
		current_scene.set_script(load("res://Scripts/Level_Control.gd"))
#		print(current_scene.get_script())
		
		# warning-ignore:return_value_discarded
		packed_scene.pack(current_scene)
	
	
	current_scene.free()
	
	# warning-ignore:return_value_discarded
	get_tree().change_scene_to(packed_scene)
	
	return OK


func get_group_from_filepath(filepath : String) -> String:
	return filepath.substr(0, filepath.find_last("/") + 1)


func get_level_from_filepath(filepath : String) -> String:
	return filepath.substr(filepath.find_last("/") + 1, filepath.find_last(".tscn") - filepath.find_last("/") - 1)


func make_text_debug(_text : String):
	var text = RichTextLabel.new()
	text.rect_size = Vector2(1024, 1024)
	text.text = _text
	text.rect_scale = Vector2(2, 2)
	get_tree().current_scene.add_child(text)
	print(_text)
#	print(get_tree().current_scene.name)


func unlock(unlock):
	if unlock != "":
		if unlock.begins_with("*"):
			unlocked[unlock] = true
		else:
			var location : String
			if unlock.begins_with("@"):
				var parsed : Array = parse_level_group_abreviation(unlock)
				if not parsed.empty():
					location = parsed[0]
					unlock = parsed[1]
				else:
					return
			else:
				location = current_level_location
			
			if !unlocked.has(location):
				unlocked[location] = {}
			unlocked[location][unlock] = true
			
#			print("unlocked ", location, " ", unlock)


func check_unlock(unlock):
	if unlock != "":
		if unlock.begins_with("*"):
			if !unlocked.has(unlock):
				unlocked[unlock] = false
			return unlocked[unlock]
		else:
			var location : String
			if unlock.begins_with("@"):
				var parsed : Array = parse_level_group_abreviation(unlock)
				if not parsed.empty():
					location = parsed[0]
					unlock = parsed[1]
				else:
					return false
			else:
				location = current_level_location
			
			if !unlocked.has(location):
				unlocked[location] = {}
			if !unlocked[location].has(unlock):
				unlocked[location][unlock] = false
			return unlocked[location][unlock]


enum {UNLOCK_ALWAYS, UNLOCK_BEAT, UNLOCK_PAR, UNLOCK_COMPLETION, UNLOCK_BONUS, UNLOCK_CUSTOM, UNLOCK_NEVER}
func check_unlock_requirements(unlock_type : int, parameter_1, parameter_2):
	
	if unlock_type == UNLOCK_NEVER:
		return false
	
	if unlock_type == UNLOCK_BEAT or unlock_type == UNLOCK_PAR or unlock_type == UNLOCK_COMPLETION:
#		if parameter_1.begins_with("@"):
#			parameter_1 = parse_level_group_abreviation(parameter_1)
		if not level_completion.has(parameter_1):
			return false
	
	if unlock_type == UNLOCK_BEAT or unlock_type == UNLOCK_PAR:
		if !level_completion[parameter_1].has(parameter_2):
			return false
		if level_completion[parameter_1][parameter_2][0] == null:
			return false
		
		var time = level_completion[parameter_1][parameter_2][0]
		var par = level_completion[parameter_1][parameter_2][1]
		if time > par and par != 0 and unlock_type == UNLOCK_PAR:
			return false
	
	if unlock_type == UNLOCK_COMPLETION:
		var group = -1
		for i in range(loaded_level_groups.size()):
			if parameter_1 == loaded_level_groups[i][1] + loaded_level_groups[i][0] + "/":
				group = i
				break
		if group == -1:
			return false
		if float(parameter_2) > loaded_level_groups[group][4]:
			return false
	
	if unlock_type == UNLOCK_BONUS:
		var collectible_amount : int = 0
		for i in level_completion["*collectibles"].keys():
			if i.begins_with(parameter_1):
				collectible_amount += level_completion["*collectibles"][i].size()
		if parameter_2 > collectible_amount:
			return false
	
	if unlock_type == UNLOCK_CUSTOM:
		return check_unlock(parameter_1)
	
	return true


func should_check_unlocks(group : String, level : String) -> bool:
	if not unlocked.has(group):
		unlocked[group] = {}
	return unlocked[group].has(level)


func is_level_unlocked(group : String, level : String) -> bool:
	if group == USER_LEVELS:
		return true
	
	var is_unlocked : bool = true
	var unlock_requirements : Array
	var lv_group : Dictionary
	
	if group == current_level_location:
		lv_group = level_group
	else:
		lv_group = load_group(group)
	
	if lv_group.empty():
#		print(lv_group, " ", level_group)
		return false
	
	var i = -1
	for j in range(lv_group["levels"].size()):
		if lv_group["levels"][j][0] == level:
			i = j
			break
	if i == -1:
#		print("side level, always unlocked")
		return true
	unlock_requirements = lv_group["levels"][i][2]
	
	if should_check_unlocks(group, level):
		if unlock_requirements[0] != 6:
			unlocked[group][level] = check_unlock_requirements(unlock_requirements[0], unlock_requirements[1], unlock_requirements[2])
		is_unlocked = unlocked[group][level]
	
#	print(is_unlocked)
	return is_unlocked


func is_level_file_unlocked(level_filename : String) -> bool:
	return is_level_unlocked(get_group_from_filepath(level_filename), get_level_from_filepath(level_filename))


func showcase_unlock(text : String, texture : Texture) -> Node2D:
	var show_unlock : Node2D = preload("res://Objects/Unlock.tscn").instance()
	show_unlock.texture = texture
	get_tree().current_scene.add_child(show_unlock)
	show_unlock.set_text(text)
	return show_unlock


func parse_level_group_abreviation(abr : String, context : String = current_level_location) -> Array:
	var p = abr.find("*")
	
#	print(group)
	var group : String = abr.substr(1, p - 1)
#	print(group)
	
	var matches : Array = []
	for i in range(loaded_level_groups.size()):
		if loaded_level_groups[i][0] == group:
			matches.append(i)
	
	if matches.size() == 0:
		group = ""
		print("Can't find level group from: ", abr)
	elif matches.size() == 1:
		group = location_of_loaded_group(matches[0])
	elif matches.size() > 1:
		print("More than one group shares this abreviation: ", abr)
		
		var previous_matches : Array = matches.duplicate()
		matches = []
		var best_s : int = 0
		for i in range(previous_matches.size()):
			var s : int = string_start_similarity(location_of_loaded_group(previous_matches[i]), context)
			if s > best_s:
				matches = [previous_matches[i]]
			if s == best_s:
				matches.append(previous_matches[i])
		
		if matches.size() == 0:
			group = ""
		elif matches.size() == 1:
			group = location_of_loaded_group(matches[0])
		if matches.size() > 1:
			group = ""
	
	if not group.empty():
		return [group, abr.substr(p + 1, abr.length() - p - 1)]
	else:
		return []


func level_group_in_save(level_location : String, data : Dictionary = level_completion) -> bool:
	return data.has(level_location)


func level_in_save(level : String, level_location : String, data : Dictionary = level_completion) -> bool:
	return data[level_location].has(level)


func level_group_index(level_location : String) -> int:
	for i in range(loaded_level_groups.size()):
		if location_of_loaded_group(i) == level_location:
			return i
	return -1


func check_level_group_unlocked(level_location : String) -> bool:
	var index = level_group_index(level_location)
	if index != -1:
		return check_loaded_group_unlocked(index)
	return false


func check_loaded_group_unlocked(index : int) -> bool:
	return check_unlock_requirements(loaded_level_groups[index][5][0], loaded_level_groups[index][5][1], loaded_level_groups[index][5][2])


func location_of_loaded_group(index : int, data : Array = loaded_level_groups) -> String:
	return data[index][1] + data[index][0] + "/"


func wipe_loaded_group_textures():
	for i in loaded_level_groups:
		i[2] = null
		i[3] = null


func save_game(timer : float = 0, par : float = 0, collectible : Array = [], level = null, recording : Dictionary = {}):
	print("saving game")
	
	var temp = {}
	
	temp = level_completion.duplicate()
	
	if !temp.has(current_level_location):
		temp[current_level_location] = {}
	if temp[current_level_location].has(level):
		var level_data : Array = temp[current_level_location][level]
		if level_data.size() < 3:
			level_data.resize(3)
		if level_data[0] == null:
			level_data[0] = timer
		elif level_data[0] > timer:
			level_data[0] = timer
		level_data[1] = par
	elif level != null:
		temp[current_level_location][level] = [timer, par, 0]
	
	if !temp.has("*collectibles"):
		temp["*collectibles"] = {}
	if !temp["*collectibles"].has(current_level_location):
		temp["*collectibles"][current_level_location] = []
	if typeof(temp["*collectibles"][current_level_location]) == TYPE_DICTIONARY:
		temp["*collectibles"][current_level_location] = []
	for collect in collectible:
		if collect != "" and !temp["*collectibles"][current_level_location].has(collect):
			temp["*collectibles"][current_level_location].append(collect)
	
	level_completion = temp.duplicate()
	
	options["*last_level_location"] = current_level_location
	
	# warning-ignore:integer_division
	if !savefile_interaction / 2:
		print("saving disabled")
	else:
		var temp_full = {
			"level_completion" : {},
			"options" : {},
			"unlocked" : {},
		}
		temp_full["level_completion"] = temp.duplicate()
		temp_full["options"] = options.duplicate()
		temp_full["unlocked"] = unlocked.duplicate()
		
		temp_full = update_old_save(VERSION, temp_full.duplicate())
		
		print("save successful")
		var savefile = File.new()
		savefile.open(SAVEFILE, File.WRITE)
		savefile.store_line(to_json(temp_full))
		savefile.close()
		
		if level != null:
			condicional_save_replay(current_level_location + level + "_Best", recording)


func load_game():
	
	print("loading game")
	
	var loadfile = File.new()
	var temp = {}
	
	if !savefile_interaction % 2:
		print("loading disabled")
	elif !loadfile.file_exists(SAVEFILE): # does file exist
		print("save doesn't exist")
		options = DEFAULT_OPTIONS.duplicate()
		save_game()
	else:
		print("loading successful")
		
		loadfile.open(SAVEFILE, File.READ)
		
		while loadfile.get_position() < loadfile.get_len():
			var parsedData = parse_json(loadfile.get_line())
			
			temp = parsedData
		
		loadfile.close()
		
		var version : String
		if !temp.has("options"):
			version = "0.X"
		elif !temp["options"].has("*version"):
			version = "1.0.0-dev"
		elif typeof(temp["options"]["*version"]) == TYPE_REAL:
			version = "1.0.0"
		else:
			version = temp["options"]["*version"]
		
		if version != VERSION:
			new_version_alert = true
		
		temp = update_old_save(version, temp.duplicate())
		
		level_completion = temp["level_completion"].duplicate()
		options = temp["options"].duplicate()
		unlocked = temp["unlocked"].duplicate()
	
	temp = {"*mods" : []}
	
	# MOD LOADING IS DISABLED FOR NOW
	if false: #loadfile.file_exists(MODS_SAVEFILE): # does file exist 
		loadfile.open(MODS_SAVEFILE, File.READ)
		
		while loadfile.get_position() < loadfile.get_len():
			var parsedData = parse_json(loadfile.get_line())
			
			temp = parsedData
		
		loadfile.close()
	
	mods_installed = temp["*mods"].duplicate()
	#print(mods_installed)


func delete_save(): 
	level_completion.clear()
	unlocked = {
		"*char_select_active" : false,
		"completion_percentages" : {},
	}
	unlocked_characters = []
	unlocked_level_groups = []
	save_game()


func reset_options():
	options = DEFAULT_OPTIONS.duplicate()
	save_game()


func update_old_save(version : String, save : Dictionary):
	var settings : Dictionary = {}
#	var unlocks : Dictionary = {}
	var levels : Dictionary = {}
	
	#print(version)
	if version == "0.X":
		
		settings = {}
		levels = {}
		
		for i in DEFAULT_OPTIONS.keys():
			if save.has(i):
				settings[i] = save[i]
				# warning-ignore:return_value_discarded
				save.erase(i)
			else:
				settings[i] = DEFAULT_OPTIONS[i]
		
		levels = save.duplicate()
		
		save.clear()
		
		settings["*first_time_load"] = false
		
		save["options"] = settings.duplicate()
		
		save["level_completion"] = {}
		save["level_completion"]["*collectibles"] = {}
		save["level_completion"]["*collectibles"]["res://Scenes/waterway/"] = []
		save["level_completion"]["res://Scenes/waterway/"] = {}
		
		for i in ["4", "6", "7", "9", "11", "13"]:
			if levels.has(i):
				save["level_completion"]["*collectibles"]["res://Scenes/waterway/"].append("Level_1-" + i + "*1")
				# warning-ignore:return_value_discarded
				levels.erase(i)
		
		for i in levels.keys():
			save["level_completion"]["res://Scenes/waterway/"][i] = levels[i]
			# warning-ignore:return_value_discarded
			levels.erase(i)
		
		save["unlocked"] = {}
		save["unlocked"]["*char_select_active"] = false
		
		version = "1.1.0"
	if version == "1.0.0" or version == "1.0.0-dev":
		levels = save["level_completion"].duplicate()
		save["level_completion"].clear()
		
		save["level_completion"]["*collectibles"] = {}
		for i in levels["*collectibles"]:
			var level_name = i.substr(i.find_last("/") + 1, i.length() - i.find_last("/"))
			var level_location = i.substr(0, i.find_last("/") + 1)
			if not save["level_completion"]["*collectibles"].has(level_location):
				save["level_completion"]["*collectibles"][level_location] = []
			save["level_completion"]["*collectibles"][level_location].append(level_name)
		# warning-ignore:return_value_discarded
		levels.erase("*collectibles")
		
		for i in levels.keys():
			var level_name = i.substr(i.find_last("/") + 1, i.length() - i.find_last("/"))
			var level_location = i.substr(0, i.find_last("/") + 1)
			if not save["level_completion"].has(level_location):
				save["level_completion"][level_location] = {}
			save["level_completion"][level_location][level_name] = levels[i]
		
		version = "1.1.0"
	if version == "1.1.0-dev":
		version = "1.1.0"
	if version == "1.1.0":
		if save["options"]["*timer_on"]:
			save["options"]["*timer_on"] = 1
		else:
			save["options"]["*timer_on"] = 0
		
		version = "2.0.0"
	if version == "1.2.0-dev":
		if !save["unlocked"].has("completion_percentages"):
			save["unlocked"]["completion_percentages"] = {}
		version = "2.0.0"
	if version == "2.0.0-dev":
		version = "2.0.0"
	
	if not save["unlocked"].has("*char_select_active"):
		save["unlocked"]["*char_select_active"] = false
	if not save["unlocked"].has("completion_percentages"):
		save["unlocked"]["completion_percentages"] = {}
	for i in DEFAULT_OPTIONS.keys():
		if !save["options"].has(i):
			save["options"][i] = DEFAULT_OPTIONS[i]
			#print(i)
	if !save["level_completion"].has("*collectibles"):
		save["level_completion"]["*collectibles"] = []
	
	save["options"]["*version"] = VERSION
	
	return save


func condicional_save_replay(replay_name, recording : Dictionary):
	if load_replay(replay_name, true):
		var temp = load_replay(replay_name, false)
		if recording["timer"] < temp["timer"]:
			save_replay(replay_name, recording.duplicate())
	else:
		save_replay(replay_name, recording.duplicate())


func save_replay_with_date(new_name : String, recording : Dictionary):
	print("save replay")
	Global.save_replay(add_date_to_name(new_name),
	recording)


func save_replay(new_name : String, recording : Dictionary, level : bool = true):
	var replay_name : String = new_name
	if level: replay_name = replay_filename(new_name, true)
	
	replay_name = "user://SRReplays/" + replay_name
	
	#print("save: " + replay_name)
	
	var savefile = File.new()
	var temp = recording.duplicate()
	
	#print("save: ", temp)
	
	savefile.open(replay_name, File.WRITE) #res://Visual/bg_hills.png
	savefile.store_line(to_json(temp))
	savefile.close()


func load_replay(new_name, existance_check : bool = false, level : bool = true, built_in : bool = false):
	var replay_name : String = new_name
	if level:
		replay_name = replay_filename(new_name, false)

	if built_in:
		replay_name = "res://Replays/" + replay_name
	else:
		replay_name = "user://SRReplays/" + replay_name
	
	#print("load: " + replay_name)
	
	var loadfile = File.new()
	var temp = {}
	
	if not loadfile.file_exists(replay_name): # does file exist
		if existance_check: 
			return false
		else: 
			return temp
	
	if !existance_check:
		loadfile.open(replay_name, File.READ)
		
		while loadfile.get_position() < loadfile.get_len():
			var parsedData = parse_json(loadfile.get_line())
			
			temp = parsedData
		loadfile.close()
		
#		print("load: ", temp)
		
		if !temp.has("character"):
			temp["character"] = "S1"
		
		return temp
	else:
		return true


func delete_replay(new_name, level : bool = true):
	var replay_name : String = new_name
	if level: replay_name = replay_filename(new_name, false)
	replay_name = "user://SRReplays/" + replay_name
	
	#print("delete: " + replay_name)
	
	var deletefile = Directory.new()
	
	deletefile.remove(replay_name)


func replay_filename(new_name : String, create_dir : bool):
	var replay_name
	replay_name = new_name.substr(new_name.find_last("/") + 1, new_name.length())
	var folder_path : String = new_name.substr(0, new_name.find_last("/"))
	#print(folder_path)
	var folder_name = folder_path.substr(folder_path.find_last("/") + 1, folder_path.length()) + "/"
	#print(folder_name)
	var directory : Directory = Directory.new()
	match(new_name.substr(0, new_name.find("/"))):
		"res:":
			if folder_path == "res://Scenes":
				folder_name = ""
			replay_name = "res/" + folder_name + replay_name
			# warning-ignore:return_value_discarded
			if create_dir:
				directory.make_dir_recursive("user://SRReplays/res/" + folder_name)
		"user:":
			if folder_path == "user://SRLevels":
				folder_name = ""
			replay_name = "user/" + folder_name + replay_name
			# warning-ignore:return_value_discarded
			if create_dir:
				directory.make_dir_recursive("user://SRReplays/user/" + folder_name)
		"Mods":
			folder_path = folder_path.replace("/Scenes/", "/")
			folder_path = folder_path.substr(folder_path.find("/") + 1, folder_path.length() - folder_path.find("/")) + "/"
			replay_name = "mods/" + folder_path + replay_name
			# warning-ignore:return_value_discarded
			if create_dir:
				directory.make_dir_recursive("user://SRReplays/mods/" + folder_path)
	
	return replay_name


func load_level_dat_file(filename_ : String, _official : bool = true):
	print(get_stack())
	return load_dat_file(filename_)


func load_dat_file(filename_ : String):
	
	#print(filename_)
	
	var loadfile = File.new()
	var temp = {}
	
	if not loadfile.file_exists(filename_ + ".dat"): # does file exist
		return {}
	
	loadfile.open(filename_ + ".dat", File.READ)
	
	while loadfile.get_position() < loadfile.get_len():
		var parsedData = parse_json(loadfile.get_line())
		
		temp = parsedData
	
	loadfile.close()
	
	#print("load: ", temp)
	
	return temp.duplicate()


func load_level_group() -> bool:
	level_group = load_group(current_level_location)
	return level_group


func load_group(group : String) -> Dictionary:
	var loadfile = File.new()
	var temp : Dictionary = {}
	
	#print(group + "level_group.dat")
	
	if not loadfile.file_exists(group + "level_group.dat"):
		return {}
	
	loadfile.open(group + "level_group.dat", File.READ)
	
	while loadfile.get_position() < loadfile.get_len():
		var parsedData = parse_json(loadfile.get_line())
		
		temp = parsedData
	
	loadfile.close()
	
	return temp.duplicate()


func load_data():
	loaded_level_groups.append(["SRLevels","user://"])
	
	scan_for_directories("res://Scenes/", loaded_level_groups, "group")
	for mod_name in mods_installed:
		scan_for_directories("Mods/" + mod_name + "/Scenes/", loaded_level_groups, "group")
	scan_for_directories(USER_LEVELS, loaded_level_groups, "group")
	
	var temp_level_groups = loaded_level_groups.duplicate()
	var group_unlocks : Array = []
	
	for group in range(loaded_level_groups.size()):
		if group == 0:
			if user_levels.size() == 0:
				temp_level_groups.remove(group)
			else:
				group_unlocks.append([UNLOCK_ALWAYS, "", ""])
			continue
		var level_dat = load_dat_file(loaded_level_groups[group][1] + loaded_level_groups[group][0] + "/level_group")
		if level_dat.empty():
			group_unlocks.append([UNLOCK_NEVER, "", ""])
			continue
		var depend_test = true
		for i in level_dat["dependencies"]:
			if !mods_installed.has(i):
				temp_level_groups.remove(group)
				depend_test = false
		if depend_test:
			if level_dat.has("unlock"):
				group_unlocks.append(level_dat["unlock"])
			else:
				group_unlocks.append([UNLOCK_ALWAYS, "", ""])
	loaded_level_groups = temp_level_groups.duplicate()
	
	for i in range(loaded_level_groups.size()):
		loaded_level_groups[i].resize(6)
		loaded_level_groups[i][2] = null
		loaded_level_groups[i][3] = null
		if unlocked["completion_percentages"].has(loaded_level_groups[i][1] + loaded_level_groups[i][0]):
			loaded_level_groups[i][4] = unlocked["completion_percentages"][loaded_level_groups[i][1] + loaded_level_groups[i][0]]
		else:
			loaded_level_groups[i][4] = 0
			unlocked["completion_percentages"][loaded_level_groups[i][1] + loaded_level_groups[i][0]] = 0
		loaded_level_groups[i][5] = group_unlocks[i]
	
	# CHARACTERS.DAT
	
	var scan_places = ["res:/"]
	for mod_name in mods_installed:
		scan_places.append("Mods/" + mod_name)
	for place in scan_places:
		var dat_file = load_dat_file(place + "/Objects/Player/characters")
		
		if dat_file.size() > 0:
			loaded_characters[place] = dat_file["*characters"].duplicate()
			character_order[place] = dat_file["*order"].duplicate()
	
	#print(loaded_characters)


func scan_single_directory(main_directory : String, sub_directory : String, storage : Array, file_type : String, _file_descriptor : String):
	var directory : Directory = Directory.new()
	var check_exist = directory.open(main_directory + sub_directory)
	var current_file
	
	if check_exist == OK:
		# warning-ignore:return_value_discarded
		directory.list_dir_begin(true)
		
		current_file = directory.get_next()
		while current_file != "":
			if current_file.ends_with(file_type):
				#print("found " + _file_descriptor + ": " + current_file)
				storage.append([current_file, main_directory])
			current_file = directory.get_next()


func scan_for_directories(main_directory : String, storage : Array, _file_descriptor : String):
	var directory : Directory = Directory.new()
	var check_exist = directory.open(main_directory)# + sub_directory)
	var current_file
	
	if check_exist == OK:
		# warning-ignore:return_value_discarded
		directory.list_dir_begin(true)
		
		current_file = directory.get_next()
		while current_file != "":
			if directory.current_is_dir():
				#print("found " + _file_descriptor + ": " + current_file)
				storage.append([current_file, main_directory])
			current_file = directory.get_next()


func screenshot():
	print("screenshot")
	
	var image : Image = get_viewport().get_texture().get_data()
	image.flip_y()
	# warning-ignore:return_value_discarded
	image.save_png("user://SRScreenshots/" + add_date_to_name("screenshot") + ".png")
