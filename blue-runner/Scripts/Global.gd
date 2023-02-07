extends Control

#game Stuff
const VERSION : String = "1.1.0-dev"
var new_version_alert : bool = false
var user_directory : String = "user://sonicRunner"
var mod_user_directory : String = "user://sonicRunnerMods"
var level_completion = {
	"*collectibles" : {},
}
var unlocked = {
	"*char_select_active" : false,
}
var options = {
	"*version" : VERSION,
	"*left" : KEY_LEFT,
	"*right" : KEY_RIGHT,
	"*up" : KEY_UP,
	"*down" : KEY_DOWN,
	"*jump" : KEY_SPACE,
	"*special" : KEY_CONTROL,
	"*reset" : KEY_ENTER,
	"*return" : KEY_ESCAPE,
	"*ghosts_on" : false,
	"*timer_on" : false,
	"*first_time_load" : true,
}
var mods_installed = []
var default_options = {
	"*version" : VERSION,
	"*left" : KEY_LEFT,
	"*right" : KEY_RIGHT,
	"*up" : KEY_UP,
	"*down" : KEY_DOWN,
	"*jump" : KEY_SPACE,
	"*special" : KEY_CONTROL,
	"*reset" : KEY_ENTER,
	"*return" : KEY_ESCAPE,
	"*ghosts_on" : false,
	"*timer_on" : false,
	"*first_time_load" : true,
}

var rand : RandomNumberGenerator = RandomNumberGenerator.new()

var current_character : String = "S1"
var current_character_location : String = "res:/"

var replay : bool = false
var current_recording = {}
var replay_menu : bool = false
var replay_save : Array = [0, 0]
var race_mode : bool = false

var current_page : int = 0
var current_level : String = ""
var current_level_location : String = "res://Scenes/waterway/"

var loaded_level_groups = []
var level_group = {}

var loaded_characters = {}

var last_input_events : Array = range(8)

func _ready():
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
	
	load_data()
	
	# First it uses the default bindings
	last_input_events = InputMap.get_action_list("default").duplicate()
	
	# The every binding that has already been bound replaces the defaults
	if options["*left"] != null:
		last_input_events[0] = InputEventKey.new()
		last_input_events[0].scancode = options["*left"]
	if options["*right"] != null:
		last_input_events[1] = InputEventKey.new()
		last_input_events[1].scancode = options["*right"]
	if options["*up"] != null:
		last_input_events[2] = InputEventKey.new()
		last_input_events[2].scancode = options["*up"]
	if options["*down"] != null:
		last_input_events[3] = InputEventKey.new()
		last_input_events[3].scancode = options["*down"]
	if options["*jump"] != null:
		last_input_events[4] = InputEventKey.new()
		last_input_events[4].scancode = options["*jump"]
	if options["*special"] != null:
		last_input_events[5] = InputEventKey.new()
		last_input_events[5].scancode = options["*special"]
	if options["*reset"] != null:
		last_input_events[6] = InputEventKey.new()
		last_input_events[6].scancode = options["*reset"]
	if options["*return"] != null:
		last_input_events[7] = InputEventKey.new()
		last_input_events[7].scancode = options["*return"]
	
	# Then it actualy binds the shit
	for i in range(8):
		change_input(i, last_input_events[i])

func _process(_delta):
	var curr_scene = get_tree().current_scene.name
	if Input.is_action_just_pressed("return") and !(curr_scene == "Menu_Level_Select" or curr_scene == "Load"):
		change_level("*Menu_Level_Select")
	if Input.is_action_just_pressed("reset") and !(curr_scene == "Menu_Level_Select" or curr_scene == "Load"):
		change_level("")

func _exit_tree():
	save_game()

func change_input(input_id : int, new_input):
	var input_string : String
	match input_id:
		0: input_string = "left"
		1: input_string = "right"
		2: input_string = "up"
		3: input_string = "down"
		4: input_string = "jump"
		5: input_string = "special"
		6: input_string = "reset"
		7: input_string = "return"
	if InputMap.action_has_event(input_string, last_input_events[input_id]):
		InputMap.action_erase_event(input_string, last_input_events[input_id])
	InputMap.action_add_event(input_string, new_input)
	
	last_input_events[input_id] = new_input
	options["*" + input_string] = new_input.scancode

func key_names(key : int):
	var key_number
	match key:
		0: key_number = options["*left"]
		1: key_number = options["*right"]
		2: key_number = options["*up"]
		3: key_number = options["*down"]
		4: key_number = options["*jump"]
		5: key_number = options["*special"]
		6: key_number = options["*reset"]
		7: key_number = options["*return"]
	
	if key_number >= 33 and key_number <= 255: return char(key_number)
	else: match(key_number):
		KEY_SPACE: return "SPACE"
		KEY_ESCAPE: return "ESCAPE"
		KEY_TAB: return "TAB"
		KEY_BACKTAB: return "SPICY TAB"
		KEY_BACKSPACE: return "BACKSPACE"
		KEY_ENTER: return "ENTER"
		KEY_KP_ENTER: return "KEYPAD ENTER"
		KEY_INSERT: return "INSERT"
		KEY_DELETE: return "DELETE"
		KEY_PAUSE: return "PAUSE"
		KEY_PRINT: return "SCREENSHOT"
		KEY_SYSREQ: return "SYSTEM REQUEST"
		KEY_CLEAR: return "CLEAR"
		KEY_HOME: return "SWEET HOME ALABAMA"
		KEY_END: return "THE END"
		KEY_LEFT: return "LEFT ARROW"
		KEY_UP: return "UP ARROW"
		KEY_RIGHT: return "RIGHT ARROW"
		KEY_DOWN: return "DOWN ARROW"
		KEY_PAGEUP: return "PAGE UP"
		KEY_PAGEDOWN: return "PAGE DOWN"
		KEY_SHIFT: return "SHIFT"
		KEY_CONTROL: return "CONTROL"
		KEY_META: return "THIS KEY IS THE META"
		KEY_ALT: return "ALT"
		KEY_CAPSLOCK: return "SCREAM LOCK"
		KEY_NUMLOCK: return "THE LOCK THATS ALWAYS ON"
		KEY_SCROLLLOCK: return "WHO EVEN USES THIS LOCK"
		KEY_F1: return "F1"
		KEY_F2: return "F2"
		KEY_F3: return "F3"
		KEY_F4: return "F4"
		KEY_F5: return "F5"
		KEY_F6: return "F6"
		KEY_F7: return "F7"
		KEY_F8: return "F8"
		KEY_F9: return "F9"
		KEY_F10: return "F10"
		KEY_F11: return "F11"
		KEY_F12: return "F12"
		KEY_F13: return "F13"
		KEY_F14: return "F14"
		KEY_F15: return "F15"
		KEY_F16: return "F16"
		KEY_KP_MULTIPLY: return "KEYPAD *"
		KEY_KP_DIVIDE: return "KEYPAD /"
		KEY_KP_SUBTRACT: return "KEYPAD -"
		KEY_KP_PERIOD: return "KEYPAD ."
		KEY_KP_ADD: return "KEYPAD +"
		KEY_KP_0: return "KEYPAD 0"
		KEY_KP_1: return "KEYPAD 1"
		KEY_KP_2: return "KEYPAD 2"
		KEY_KP_3: return "KEYPAD 3"
		KEY_KP_4: return "KEYPAD 4"
		KEY_KP_5: return "KEYPAD 5"
		KEY_KP_6: return "KEYPAD 6"
		KEY_KP_7: return "KEYPAD 7"
		KEY_KP_8: return "KEYPAD 8"
		KEY_KP_9: return "KEYPAD 9"
		KEY_SUPER_L: return "SUPER LEFT WING"
		KEY_SUPER_R: return "SUPER RIGHT WING"
		KEY_MENU: return "YOU NEED TO GIVE CONTEXT"
		KEY_HYPER_L: return "HYPER LEFT WING"
		KEY_HYPER_R: return "HYPER RIGHT WING"
		KEY_HELP: return "HELP ME GOD"
		KEY_DIRECTION_L: return "DIRECTIONAL LEFT"
		KEY_DIRECTION_R: return "DIRECTIONAL RIGHT"
		KEY_BACK: return "BACK TO THE MARK"
		KEY_FORWARD: return "FOWARD TO THE FUTURE"
		KEY_STOP: return "STOP IT"
		KEY_REFRESH: return "REFRESHING"
		KEY_VOLUMEDOWN: return "TURN IT DOWN"
		KEY_VOLUMEMUTE: return "MUTE IT PLEASE"
		KEY_VOLUMEUP: return "TURN IT UP"
		KEY_BASSBOOST: return "LOUD = FUNNY"
		KEY_BASSUP: return "BASS UP"
		KEY_BASSDOWN: return "BASS DOWN"
		KEY_TREBLEUP: return "TREBLE UP"
		KEY_TREBLEDOWN: return "TREBLE DOWN"
		KEY_MEDIAPLAY: return "PLAY THAT SONG AGAIN"
		KEY_MEDIASTOP: return "STOP THE MUSIC"
		KEY_MEDIAPREVIOUS: return "PAST ART"
		KEY_MEDIANEXT: return "ART OF THE FUTURE"
		KEY_MEDIARECORD: return "CAUGHT ON CAMERA"
		KEY_HOMEPAGE: return "HOME WITH DR. PAGE"
		KEY_FAVORITES: return "MY JAM"
		KEY_SEARCH: return "FIND THEM"
		KEY_STANDBY: return "HALT"
		KEY_OPENURL: return "BROWSER TIME"
		KEY_LAUNCHMAIL: return "MAIL TIME"
		KEY_LAUNCHMEDIA: return "MEDIA TIME"
		KEY_LAUNCH0: return "SHORTCUT 0"
		KEY_LAUNCH1: return "SHORTCUT 1"
		KEY_LAUNCH2: return "SHORTCUT 2"
		KEY_LAUNCH3: return "SHORTCUT 3"
		KEY_LAUNCH4: return "SHORTCUT 4"
		KEY_LAUNCH5: return "SHORTCUT 5"
		KEY_LAUNCH6: return "SHORTCUT 6"
		KEY_LAUNCH7: return "SHORTCUT 7"
		KEY_LAUNCH8: return "SHORTCUT 8"
		KEY_LAUNCH9: return "SHORTCUT 9"
		KEY_LAUNCHA: return "SHORTCUT A"
		KEY_LAUNCHB: return "SHORTCUT B"
		KEY_LAUNCHC: return "SHORTCUT C"
		KEY_LAUNCHD: return "SHORTCUT D"
		KEY_LAUNCHE: return "SHORTCUT E"
		KEY_LAUNCHF: return "SHORTCUT F"
		KEY_UNKNOWN: return "???"
	return "WHAT IS THIS?"

func change_level(destination : String, return_value : bool = false):
	var destination_new : String
	
	if destination == "":
		destination_new = current_level_location + current_level + ".tscn"
	elif destination == "*Menu_Level_Select":
		destination_new = "res://Scenes/Menu_Level_Select.tscn"
	elif destination == "*Level_Missing":
		destination_new = "res://Scenes/Level_Missing.tscn"
	elif destination.begins_with("*"):
		destination_new = destination.trim_prefix("*")
	else:
		destination_new = current_level_location + destination + ".tscn"
	
	var error = get_tree().change_scene(destination_new)
	if return_value:
		return error
	elif error != OK:
		# warning-ignore:return_value_discarded
		get_tree().change_scene("res://Scenes/Menu_Level_Select.tscn")

func unlock(unlock):
	if unlock != "":
		if unlock.begins_with("*"):
			unlocked[unlock] = true
		else:
			if !unlocked.has(current_level_location):
				unlocked[current_level_location] = []
			unlocked[current_level_location][unlock] = true

func check_unlock(unlock):
	if unlock != "":
		if unlock.begins_with("*"):
			if !unlocked.has(unlock):
				unlocked[unlock] = false
			return unlocked[unlock]
		else:
			if !unlocked.has(current_level_location):
				unlocked[current_level_location] = []
			if !unlocked[current_level_location].has(unlock):
				unlocked[unlock] = false
			return unlocked[current_level_location][unlock]

enum {UNLOCK_ALWAYS, UNLOCK_BEAT, UNLOCK_PAR, UNLOCK_COMPLETION, UNLOCK_BONUS, UNLOCK_CUSTOM, UNLOCK_NEVER}
func check_unlock_requirements(unlock_type : int, parameter_1, parameter_2):
	
	if unlock_type == UNLOCK_NEVER:
		return false
	
	if unlock_type == UNLOCK_BEAT or unlock_type == UNLOCK_PAR or unlock_type == UNLOCK_COMPLETION:
		if !level_completion.has(parameter_1):
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
				collectible_amount += Global.level_completion["*collectibles"][i].size()
		if parameter_2 > collectible_amount:
			return false
	
	if unlock_type == UNLOCK_CUSTOM:
		return check_unlock("*" + parameter_2 + "*" + parameter_1)
	
	return true

func convert_float_to_time(timer : float, limit_size : bool = true):
	var minutes : int = int(floor(timer) / 60)
	var seconds : int = int(floor(timer)) - minutes * 60
	var decimal : int = int(floor(timer * 100 + 0.1)) % 100
	if timer >= 6000 and limit_size:
		return "too much"
	else:
		# warning-ignore:integer_division
		# warning-ignore:integer_division
		return String(minutes)+":"+String(seconds/10)+String(seconds%10)+"."+String(decimal/10)+String(decimal%10)

func scale_down_sprite(sprite : Sprite, final_scale : Vector2 = Vector2(1, 1), desired_rect : Vector2 = Vector2(64, 64)):
	sprite.scale = Vector2(1, 1)
	var sprite_rect : Vector2 = sprite.get_rect().size
	if sprite_rect.x > sprite_rect.y:
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
		file.open(path, File.READ)
		var buffer = file.get_buffer(file.get_len())
		image.load_png_from_buffer(buffer)
		texture.create_from_image(image, texture.STORAGE_COMPRESS_LOSSLESS)
		#print(ResourceSaver.get_recognized_extensions(texture))
		return texture
	return null

func save_game(timer : float = 0, par : float = 0, collectible : Array = [], level = null, recording : Dictionary = {}):
	var savefile = File.new()
	var temp = {}
	
	temp = level_completion.duplicate()
	
	if !temp.has(current_level_location): temp[current_level_location] = {}
	if temp[current_level_location].has(level):
		if temp[current_level_location][level].size() < 3: temp[current_level_location][level].resize(3)
		if temp[current_level_location][level][0] == null:
			temp[current_level_location][level][0] = timer
		elif temp[current_level_location][level][0] > timer:
			temp[current_level_location][level][0] = timer
		temp[current_level_location][level][1] = par
	elif level != null:
		temp[current_level_location][level] = [timer, par, 0]
	
	if !temp.has("*collectibles"): temp["*collectibles"] = {}
	if !temp["*collectibles"].has(current_level_location): temp["*collectibles"][current_level_location] = []
	if typeof(temp["*collectibles"][current_level_location]) == TYPE_DICTIONARY: temp["*collectibles"][current_level_location] = []
	for collect in collectible:
		if collect != "" and !temp["*collectibles"][current_level_location].has(collect):
			temp["*collectibles"][current_level_location].append(collect)
	
	var temp_full = {
		"level_completion" : {},
		"options" : {},
		"unlocked" : {},
	}
	level_completion = temp.duplicate()
	temp_full["level_completion"] = temp.duplicate()
	temp_full["options"] = options.duplicate()
	temp_full["unlocked"] = unlocked.duplicate()
	
	temp_full = update_old_save(VERSION, temp_full.duplicate())
	
	#print("save: ", temp_full)
	
	savefile.open(user_directory, File.WRITE)
	savefile.store_line(to_json(temp_full))
	savefile.close()
	
	if level != null: condicional_save_replay(current_level_location + level + "_Best", recording)

func load_game():
	
	var loadfile = File.new()
	var temp = {}
	
	if not loadfile.file_exists(user_directory): # does file exist
		save_game()
		return
	
	loadfile.open(user_directory, File.READ)
	
	while loadfile.get_position() < loadfile.get_len():
		var parsedData = parse_json(loadfile.get_line())
		
		temp = parsedData
	
	loadfile.close()
	
	#print("load: ", temp)
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
	if false: #loadfile.file_exists(mod_user_directory): # does file exist
		loadfile.open(mod_user_directory, File.READ)
		
		while loadfile.get_position() < loadfile.get_len():
			var parsedData = parse_json(loadfile.get_line())
			
			temp = parsedData
		
		loadfile.close()
	
	mods_installed = temp["*mods"].duplicate()

func update_old_save(version : String, save : Dictionary):
	var settings : Dictionary = {}
	var unlocks : Dictionary = {}
	var levels : Dictionary = {}
	#print(version)
	if version == "0.X":
		
		settings = {}
		levels = {}
		
		for i in default_options.keys():
			if save.has(i):
				settings[i] = save[i]
				# warning-ignore:return_value_discarded
				save.erase(i)
			else:
				settings[i] = default_options[i]
		
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
			if !save["level_completion"]["*collectibles"].has(level_location):
				save["level_completion"]["*collectibles"][level_location] = []
			save["level_completion"]["*collectibles"][level_location].append(level_name)
		# warning-ignore:return_value_discarded
		levels.erase("*collectibles")
		
		for i in levels.keys():
			var level_name = i.substr(i.find_last("/") + 1, i.length() - i.find_last("/"))
			var level_location = i.substr(0, i.find_last("/") + 1)
			if !save["level_completion"].has(level_location):
				save["level_completion"][level_location] = {}
			save["level_completion"][level_location][level_name] = levels[i]
		
		version = "1.1.0"
	
	if !save["unlocked"].has("*char_select_active"): save["unlocked"]["*char_select_active"] = false
	for i in default_options.keys():
		if !save["options"].has(i):
			save["options"][i] = default_options[i]
			#print(i)
	if !save["level_completion"].has("*collectibles"):  save["level_completion"]["*collectibles"] = []
	
	save["options"]["*version"] = VERSION
	
	return save

func condicional_save_replay(replay_name, recording : Dictionary):
	if load_replay(replay_name, true):
		var temp = load_replay(replay_name, false)
		if recording["timer"] < temp["timer"]:
			save_replay(replay_name, recording.duplicate())
	else:
		save_replay(replay_name, recording.duplicate())

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

func load_replay(new_name, existance_check : bool = false, level : bool = true):
	var replay_name : String = new_name
	if level: replay_name = replay_filename(new_name, false)
	
	replay_name = "user://SRReplays/" + replay_name
	
	#print("load: " + replay_name)
	
	var loadfile = File.new()
	var temp = {}
	
	if not loadfile.file_exists(replay_name): # does file exist
		if existance_check: return false
		else: return temp
	
	if !existance_check:
		loadfile.open(replay_name, File.READ)
		
		while loadfile.get_position() < loadfile.get_len():
			var parsedData = parse_json(loadfile.get_line())
			
			temp = parsedData
		loadfile.close()
		
		#print("load: ", temp)
		
		if !temp.has("character"): temp["character"] = "S1"
		
		return temp
	else: return true

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
			if create_dir: directory.make_dir_recursive("user://SRReplays/res/" + folder_name)
		"user:":
			if folder_path == "user://SRLevels":
				folder_name = ""
			replay_name = "user/" + folder_name + replay_name
			# warning-ignore:return_value_discarded
			if create_dir: directory.make_dir_recursive("user://SRReplays/user/" + folder_name)
		"Mods":
			folder_path = folder_path.replace("/Scenes/", "/")
			folder_path = folder_path.substr(folder_path.find("/") + 1, folder_path.length() - folder_path.find("/")) + "/"
			replay_name = "mods/" + folder_path + replay_name
			# warning-ignore:return_value_discarded
			if create_dir: directory.make_dir_recursive("user://SRReplays/mods/" + folder_path)
	
	return replay_name

func save_level_dat_file(data : Dictionary, filename_ : String, official : bool = true):
	var file_prefix : String
	if official:
		file_prefix = "Scenes/"
	else:
		file_prefix = "Mods/Scenes/"
	
	var savefile = File.new()
	var temp = {}
	
	temp = data.duplicate()
	
	#print("save: ", temp)
	
	savefile.open(file_prefix + filename_ + ".dat", File.WRITE)
	savefile.store_line(to_json(temp))
	savefile.close()

func load_level_dat_file(filename_ : String, _official : bool = true):
	print(filename_)
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

func load_level_group():
	var loadfile = File.new()
	var temp = {}
	
	#print(current_level_location + "level_group.dat")
	
	if not loadfile.file_exists(current_level_location + "level_group.dat"): # does file exist
		level_group = {}
		return false
	
	loadfile.open(current_level_location + "level_group.dat", File.READ)
	
	while loadfile.get_position() < loadfile.get_len():
		var parsedData = parse_json(loadfile.get_line())
		
		temp = parsedData
	
	loadfile.close()
	
	#print("load: ", temp)
	
	level_group = temp.duplicate()
	return true

func load_data():
	scan_for_directories("res://Scenes/", loaded_level_groups, "group")
	for mod_name in mods_installed:
		scan_for_directories("Mods/" + mod_name + "/Scenes/", loaded_level_groups, "group")
	scan_for_directories("user://SRLevels/", loaded_level_groups, "group")
	
	var temp_level_groups = loaded_level_groups.duplicate()
	var group_unlocks : Array = []
	for group in range(loaded_level_groups.size()):
		var level_dat = load_dat_file(loaded_level_groups[group][1] + loaded_level_groups[group][0] + "/level_group")
		var depend_test = true
		for i in level_dat["dependencies"]:
			if !mods_installed.has(i):
				temp_level_groups.remove(group)
				depend_test = false
		if depend_test:
			if level_dat.has("unlock"):
				group_unlocks.append(level_dat["unlock"])
			else:
				group_unlocks.append([0, "", ""])
	loaded_level_groups = temp_level_groups.duplicate()
	
	loaded_level_groups.append(["SRLevels","user://"])
	group_unlocks.append([0, "", ""])
	
	for i in range(loaded_level_groups.size()):
		loaded_level_groups[i].resize(6)
		loaded_level_groups[i][2] = null
		loaded_level_groups[i][3] = null
		loaded_level_groups[i][4] = 0
		loaded_level_groups[i][5] = group_unlocks[i]
	
	# CHARACTERS.DAT
	
	var scan_places = ["res:/"]
	for mod_name in mods_installed:
		scan_places.append("Mods/" + mod_name)
	for place in scan_places:
		var dat_file = load_dat_file(place + "/Objects/Player/characters")
		
		if dat_file.size() > 0:
			loaded_characters[place] = dat_file["*characters"].duplicate()
	
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
