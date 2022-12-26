
extends Control

#Tool stuff
export var create_level_dat_file : bool = false
export var loadup_level_dat_file : bool = false
export var set_official : bool = true

export var set_filename : String = "Level_"

export var set_data = {
	"level_name" : "[name]",
	"creator" : "Tabin",
	"official" : true,
	"level_icon" : "0",
	"dependencies" : [""],
}

#game Stuff
var user_directory : String = "user://sonicRunner"
var level_completion = {
}
var unlocked = {
	"*char_select_active" : false,
	"Level_1-A" : false,
	"Level_1-B" : false,
	"Level_1-C" : false,
	"Level_1--1" : false,
}
var options = {
}
var default_options = {
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

var replay : bool = false
var current_recording = {}
var replay_menu : bool = false
var replay_save : Array = [0, 0]
var race_mode : bool = false

var current_page : int = 0
var current_level : String = ""

var last_input_events : Array = range(8)

func _ready():
	if !Engine.editor_hint:
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
	else:
		pass

func _process(_delta):
	if !Engine.editor_hint: 
		var curr_scene = get_tree().current_scene.name
		if Input.is_action_just_pressed("return") and !(curr_scene == "Menu_Level_Select" or curr_scene == "Load"):
				# warning-ignore:return_value_discarded
				get_tree().change_scene("res://Scenes/Menu_Level_Select.tscn")
		if Input.is_action_just_pressed("reset") and !(curr_scene == "Menu_Level_Select" or curr_scene == "Load"):
			# warning-ignore:return_value_discarded
			get_tree().change_scene(get_tree().current_scene.filename)
	else:
		if loadup_level_dat_file:
			loadup_level_dat_file = false
			var temp = load_level_dat_file(set_filename, set_official)
			if temp != null: set_data = temp.duplicate()
		if create_level_dat_file:
			create_level_dat_file = false
			save_level_dat_file(set_data, set_filename, set_official)

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
		KEY_CAPSLOCK: return "SCREW YOUR CHATTING LOCK"
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

func unlock_check():
	var test : int = 0
	if !unlocked["Level_1--1"]:
		test = 0
		for i in range(15):
			if level_completion.has("Level_1-" + String(i)): if level_completion["Level_1-" + String(i)][0] != null:
				test+=1
		if test>=15: unlocked["Level_1--1"] = true

func save_game(timer : float = 0, par : float = 0, collectible : int = 0, level = null, recording : Dictionary = {}):
	
	var savefile = File.new()
	var temp = {}
	
	temp = level_completion.duplicate()
	
	if temp.has(level):
		if temp[level].size() < 3: temp[level].resize(3)
		if temp[level][0] == null:
			temp[level][0] = timer
		elif temp[level][0] > timer:
			temp[level][0] = timer
		temp[level][1] = par
	elif level != null:
		temp[level] = [timer, par, 0]
	
	if collectible != 0:
		temp[String(collectible)] = 0
	
	var temp_full = {
		"level_completion" : {},
		"options" : {},
		"unlocked" : {},
	}
	level_completion = temp.duplicate()
	temp_full["level_completion"] = temp.duplicate()
	temp_full["options"] = options.duplicate()
	temp_full["unlocked"] = unlocked.duplicate()
	
	temp_full = update_old_save(temp_full.duplicate())
	
	#print("save: ", temp_full)
	
	savefile.open(user_directory, File.WRITE)
	savefile.store_line(to_json(temp_full))
	savefile.close()
	
	if level != null: condicional_save_replay(level + "_Best", recording)

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
	
	temp = update_old_save(temp.duplicate())
	level_completion = temp["level_completion"].duplicate()
	options = temp["options"].duplicate()
	unlocked = temp["unlocked"].duplicate()

func update_old_save(save : Dictionary):
	if !save.has("options"):
		var settings : Dictionary = {}
		for i in default_options.keys():
			settings[i] = save[i]
			save.erase(i)
		var unlocks : Dictionary = save["*unlocked"].duplicate()
		save.erase("*unlocked")
		unlocks["*char_select_active"] = save["*char_select_active"]
		save.erase("*char_select_active")
		var levels : Dictionary = save.duplicate()
		save.clear()
		save["level_completion"] = levels.duplicate()
		save["unlocked"] = unlocks.duplicate()
		save["options"] = settings.duplicate()
		
	if !save["options"].has("*ghosts_on"): save["options"]["*ghosts_on"] = false
	if !save["options"].has("*timer_on"): save["options"]["*timer_on"] = false
	if !save["options"].has("*left"): save["options"]["*left"] = null
	if !save["options"].has("*right"): save["options"]["*right"] = null
	if !save["options"].has("*up"): save["options"]["*up"] = null
	if !save["options"].has("*down"): save["options"]["*down"] = null
	if !save["options"].has("*jump"): save["options"]["*jump"] = null
	if !save["options"].has("*special"): save["options"]["*special"] = null
	if !save["options"].has("*reset"): save["options"]["*reset"] = null
	if !save["options"].has("*return"): save["options"]["*return"] = null
	if !save["options"].has("*first_time_load"): save["options"]["*first_time_load"] = false
	return save

func condicional_save_replay(replay_name, recording : Dictionary):
	if load_replay(replay_name, true):
		var temp = load_replay(replay_name, false)
		if recording["timer"] < temp["timer"]:
			save_replay(replay_name, recording.duplicate())
	else:
		save_replay(replay_name, recording.duplicate())

func save_replay(replay_name, recording : Dictionary):
	replay_name = "user://SRReplays/" + replay_name
	
	var savefile = File.new()
	var temp = recording.duplicate()
	
	#print("save: ", temp)
	
	savefile.open(replay_name, File.WRITE) #res://Visual/bg_hills.png
	savefile.store_line(to_json(temp))
	savefile.close()

func load_replay(replay_name, existance_check : bool = false, outside_reasource : bool = false):
	
	if !outside_reasource: replay_name = "user://SRReplays/" + replay_name
	
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

func delete_replay(replay_name):
	replay_name = "user://SRReplays/" + replay_name
	
	var deletefile = Directory.new()
	
	deletefile.remove(replay_name)

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

func load_level_dat_file(filename_ : String, official : bool = true):
	var file_prefix : String
	if official:
		file_prefix = "Scenes/"
	else:
		file_prefix = "Mods/Scenes/"
	
	var loadfile = File.new()
	var temp = {}
	
	if not loadfile.file_exists(file_prefix + filename_ + ".dat"): # does file exist
		return null
	
	loadfile.open(file_prefix + filename_ + ".dat", File.READ)
	
	while loadfile.get_position() < loadfile.get_len():
		var parsedData = parse_json(loadfile.get_line())
		
		temp = parsedData
	
	loadfile.close()
	
	#print("load: ", temp)
	
	return temp.duplicate()
