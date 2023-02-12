extends Node2D

onready var global : Control = $"/root/Global"
onready var parent : Node2D = get_parent()

var delete_confirmation : bool = false
var selected_replay : int = 0
var selected_directory : int = 0
var replay_menu_mode : int = 0

export var reset = false

var replays : Dictionary = {}
var directories : Array = []

func _ready():
	load_replays()

func _physics_process(_delta):
	if reset: reset_replays(directories[selected_directory])

func menu_update():
	# - - - OPTION SELECT - - -
	if Input.is_action_just_pressed("special"):
		replay_menu_mode += 1
		if replay_menu_mode > 2: 
			replay_menu_mode = 0
			delete_confirmation = false
	
	if Input.is_action_just_pressed("jump"):
		global.replay_save[0] = selected_replay
		global.replay_save[1] = replay_menu_mode
		global.replay_save[2] = directories[selected_directory]
		#print("dir in global: ", global.replay_save[2])
		if $replay_list.get_item_count() > 0 and $replay_list.get_item_metadata(selected_replay) != "*":
			if replay_menu_mode == 0 or replay_menu_mode == 1:
				var selected_list_replay = $replay_list.get_selected_items()[0]
				
				
				global.current_recording = global.load_replay($replay_list.get_item_metadata(selected_list_replay) + "/" + $replay_list.get_item_text(selected_list_replay), false, false)
				
				if global.current_recording.has("level"): 
					if replay_menu_mode == 1: global.race_mode = true
					else: global.replay = true
					
					global.replay_menu = true
					
					# warning-ignore:return_value_discarded
					var level_file = global.current_recording["level"]
					if level_file.find("/") == -1:
						level_file = "res://Scenes/waterway/" + level_file
					
					
					Global.change_level("*" + level_file + ".tscn")
			if replay_menu_mode == 2:
				if delete_confirmation:
					var selected_list_replay = $replay_list.get_selected_items()[0]
					global.delete_replay($replay_list.get_item_text(selected_list_replay))
					$replay_list.remove_item(selected_list_replay)
					if selected_replay > $replay_list.get_item_count() - 1:
						selected_replay = $replay_list.get_item_count() - 1
						if $replay_list.get_item_count() > 0: $replay_list.select(selected_replay)
					
					delete_confirmation = false
				else:
					delete_confirmation = true
	if Input.is_action_pressed("up") and parent.move and selected_replay > 0:
		selected_replay -= 1
		if $replay_list.get_item_metadata(selected_replay) == "*" and selected_replay > 0:
			selected_replay -= 1
		if $replay_list.get_item_count() > 0: $replay_list.select(selected_replay)
		$replay_list.ensure_current_is_visible()
		delete_confirmation = false
	if Input.is_action_pressed("down") and parent.move and selected_replay < $replay_list.get_item_count() - 1:
		selected_replay += 1
		if $replay_list.get_item_metadata(selected_replay) == "*" and selected_replay < $replay_list.get_item_count() - 1:
			selected_replay += 1
		if $replay_list.get_item_count() > 0: $replay_list.select(selected_replay)
		$replay_list.ensure_current_is_visible()
		delete_confirmation = false
	if Input.is_action_pressed("left") and parent.move and selected_directory > 0:
		selected_directory -= 1
		reset_replays(directories[selected_directory])
		selected_replay = 0
		if $replay_list.get_item_count() > 0: $replay_list.select(selected_replay)
		$replay_list.ensure_current_is_visible()
		delete_confirmation = false
	if Input.is_action_pressed("right") and parent.move and selected_directory < directories.size() - 1:
		selected_directory += 1
		reset_replays(directories[selected_directory])
		selected_replay = 0
		if $replay_list.get_item_count() > 0: $replay_list.select(selected_replay)
		$replay_list.ensure_current_is_visible()
		delete_confirmation = false
	
	if delete_confirmation: 
		$replay_text.text = "ARE YOU SURE?"
	else: match(replay_menu_mode):
		0:
			$replay_text.text = "VIEW"
		1:
			$replay_text.text = "RACE"
		2:
			$replay_text.text = "DELETE"
	
	$hint.text = "Switch mode with " + global.key_names(5)

func reset_replays(current_dir, select : bool = false):
	$replay_list.clear()
	
	#dir shenanigans
	var dir = Directory.new()
	#print("reset: ",current_dir)
	var full_directory = "user://SRReplays/" + current_dir
	#var directories_to_visit = ["user://SRReplays/"]
	dir.open(full_directory)
	$dir.text = full_directory
	#$replay_list.add_item(full_directory)
	#$replay_list.set_item_disabled($replay_list.get_item_count() - 1, true)
	#$replay_list.set_item_metadata($replay_list.get_item_count() - 1, "*")
	
	dir.list_dir_begin(true, false)
	var last_replay : String = "*"
	
	last_replay = dir.get_next()
	while last_replay != "":
		if dir.current_is_dir():
			#directories_to_visit.append(directories_to_visit[0] + "/" + last_replay)
			pass
		else:
			$replay_list.add_item(last_replay)
			$replay_list.set_item_metadata($replay_list.get_item_count() - 1, full_directory.trim_prefix("user://SRReplays/"))
		last_replay = dir.get_next()
	
	#directories_to_visit.pop_front()
	
	if select:
		if $replay_list.get_item_count() > 0: $replay_list.select(selected_replay)
		$replay_list.visible = true
		$replay_text.visible = true
	else:
		selected_replay = 0
		if $replay_list.get_item_count() > 0: $replay_list.select(0)
		$replay_list.visible = true
		$replay_text.visible = true
	
	reset = false

func load_replays():
	replays = {}
	
	#dir shenanigans
	var dir = Directory.new()
	
	var directories_to_visit = ["user://SRReplays/"]
	while directories_to_visit.size() > 0:
		dir.open(directories_to_visit[0])
		replays[directories_to_visit[0]] = []
		directories.append(directories_to_visit[0].trim_prefix("user://SRReplays/"))
		#$replay_list.add_item(directories_to_visit[0])
		#$replay_list.set_item_disabled($replay_list.get_item_count() - 1, true)
		#$replay_list.set_item_metadata($replay_list.get_item_count() - 1, "*")
		
		dir.list_dir_begin(true, false)
		var last_replay : String = "*"
		
		last_replay = dir.get_next()
		while last_replay != "":
			if dir.current_is_dir():
				var dont_skip : bool = true
				var directory : String = directories_to_visit[0] + last_replay + "/"
				if directory.find("/res/") != -1: pass
				elif directory.find("/user/") != -1: pass
				elif directory.ends_with("/res"): pass
				elif directory.ends_with("/user"): pass
				else:
					var mod = directory.substr(directory.find("mods") + 5, directory.length() - directory.find("mods"))
					mod = mod.substr(0, mod.find("/"))
					if mod == "": 
						if Global.mods_installed.size() == 0: dont_skip = false
					elif !Global.mods_installed.has(mod): 
						dont_skip = false
				if dont_skip:
					directories_to_visit.append(directory)
			else:
				replays[directories_to_visit[0]].append([last_replay, directories_to_visit[0].trim_prefix("user://SRReplays/")])
				#$replay_list.add_item(last_replay)
				#$replay_list.set_item_metadata($replay_list.get_item_count() - 1, directories_to_visit[0].trim_prefix("user://SRReplays/"))
			last_replay = dir.get_next()
		
		directories_to_visit.pop_front()
	
	#$replay_list.select(selected_replay)
	#$replay_list.visible = true
	#$replay_text.visible = true
	selected_replay = global.replay_save[0]
	replay_menu_mode = global.replay_save[1]
	for i in range(directories.size()):
		if directories[i] == global.replay_save[2]:
			selected_directory = i
			break
	#print("load: ", directories[selected_directory])
	reset_replays(directories[selected_directory], true)
