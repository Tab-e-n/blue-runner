extends Node2D

onready var parent : Node2D = get_parent()

var replays : Dictionary = {}
var directories : Array = []
var current_directory : String = ""
var current_replay : int = 0
var last_replay : int = 0
var next_replay : int = 0
var replay_amount : int = 0

export var rack_time : float = 1
export var rack_idle : bool = true
var rack_anim_ended : bool = false
var rack_anim_direction : int = 0

var is_selecting_replay : bool = true

export var select_transition : float = 0
var current_mode : int = 0
var delete_confirmation : bool = false

func _ready():
	load_replays()

func menu_update():
	
	rack_anim_ended = false
	if rack_time == 1 and !rack_idle:
		last_replay = current_replay
		rack_idle = true
		rack_anim_ended = true
	
	if is_selecting_replay:
		info_inputs()
	else:
		interactions_inputs()
	
	rack_visuals()
	
	var rc = 1 - 0.5 * select_transition
	$rack.modulate = Color(rc, rc, rc)

func info_inputs():
	if Input.is_action_pressed("menu_left") and parent.move and next_replay > 0:
		next_replay -= 1
	if Input.is_action_pressed("menu_right") and parent.move and next_replay < replay_amount - 1:
		next_replay += 1
	if Input.is_action_just_pressed("accept"):
		is_selecting_replay = false
		$bottom_anim.play("to_interactions")
		current_mode = 1

func interactions_inputs():
	if !delete_confirmation:
		if Input.is_action_pressed("menu_left") and parent.move and current_mode > 0:
			current_mode -= 1
		if Input.is_action_pressed("menu_right") and parent.move and current_mode < 3:
			current_mode += 1
		if Input.is_action_just_pressed("deny"):
			is_selecting_replay = true
			$bottom_anim.play("to_info")
	else:
		if Input.is_action_just_pressed("deny"):
			delete_confirmation = false
	if Input.is_action_just_pressed("accept"):
		match current_mode:
			0:
				is_selecting_replay = true
				$bottom_anim.play("to_info")
			1:
				play_replay_level()
			2:
				play_replay_level()
			3:
				erase_replay()
	
	if current_mode == 0:
		$interactions/back.rect_scale = Vector2(1, 1)
		$interactions/back.modulate = Color(1, 1, 1)
	else:
		$interactions/back.rect_scale = Vector2(0.75, 0.75)
		$interactions/back.modulate = Color(0.5, 0.5, 0.5)
	
	if current_mode == 1:
		$interactions/view.rect_scale = Vector2(1, 1)
		$interactions/view.modulate = Color(1, 1, 1)
	else:
		$interactions/view.rect_scale = Vector2(0.75, 0.75)
		$interactions/view.modulate = Color(0.5, 0.5, 0.5)
	
	if current_mode == 2:
		$interactions/race.rect_scale = Vector2(1, 1)
		$interactions/race.modulate = Color(1, 1, 1)
	else:
		$interactions/race.rect_scale = Vector2(0.75, 0.75)
		$interactions/race.modulate = Color(0.5, 0.5, 0.5)
	
	if current_mode == 3:
		$interactions/erase.rect_scale = Vector2(1, 1)
		$interactions/erase.modulate = Color(1, 1, 1)
	else:
		$interactions/erase.rect_scale = Vector2(0.75, 0.75)
		$interactions/erase.modulate = Color(0.5, 0.5, 0.5)
	
	$interactions/sure.visible = delete_confirmation

func play_replay_level():
	Global.replay_save[0] = next_replay
	Global.replay_save[1] = current_mode
	Global.replay_save[2] = current_directory
	#print("dir in global: ", Global.replay_save[2])
	
	Global.current_recording = Global.load_replay(current_directory + replays[current_directory][next_replay], false, false)
	
	if Global.current_recording.has("level"): 
		if current_mode == 1:
			Global.replay = true
		if current_mode == 2: 
			Global.race_mode = true
		
		Global.replay_menu = true
		
		# warning-ignore:return_value_discarded
		var level_file = Global.current_recording["level"]
		if level_file.find("/") == -1:
			level_file = "res://Scenes/waterway/" + level_file
		
		Global.change_level("*" + level_file + ".tscn")

func erase_replay():
	if delete_confirmation:
		Global.delete_replay(current_directory + replays[current_directory][next_replay])
		replays[current_directory].remove(next_replay)
		
		if next_replay > replay_amount - 1:
			next_replay = replay_amount - 1
		
		delete_confirmation = false
		
		set_cassette_labes()
	else:
		delete_confirmation = true
	print(delete_confirmation)

func setup_rack(reset_selection : bool = true):
	var new_replay_amount : int = replays[current_directory].size()
	
	if reset_selection:
		current_replay = 0
		last_replay = 0
		next_replay = 0
	
	$rack/anim.stop()
	rack_time = 1
	rack_idle = true
	
	replay_amount = new_replay_amount
	
	$rack/replay_rack.position.x = 0
	
	$rack/replay_cassette.visible = replay_amount > 0
	$rack/replay_cassette_next.visible = replay_amount > 0
	$rack/replay_rack.visible = replay_amount > 0
	
	set_cassette_labes()

func rack_visuals():
	if replay_amount > 0:
		if rack_anim_ended:
			set_cassette_labes()
		
		if next_replay != current_replay and !$rack/anim.is_playing():
			$rack/anim.play("shift")
			rack_time = 0
			rack_anim_direction = sign(next_replay - current_replay)
		
		if rack_idle == true and rack_time != 1:
			# warning-ignore:narrowing_conversion
			current_replay += sign(next_replay - current_replay)
			rack_idle = false
		
		$rack/replay_rack.position.x = -92 * (current_replay - last_replay) * rack_time
		$rack/cassettes.rect_position.x = -640 - 92 * (current_replay - last_replay) * rack_time
		
		$rack/replay_rack/replay_rack_start.position.x = -92 * last_replay
		$rack/replay_rack/replay_rack_end.position.x = 92 * (replay_amount - last_replay - 1)
		
		$rack/replay_cassette.position.x = 92 * (last_replay - current_replay) * rack_time
		$rack/replay_cassette.modulate.a = (1 - rack_time)
		
		$rack/replay_cassette_next.position.x = -92 * (last_replay - current_replay) * (1 - rack_time)
		$rack/replay_cassette_next.modulate.a = rack_time
		
		if last_replay - current_replay == -1:
			$"rack/cassettes/9".modulate.a = rack_time * 0.5 + 0.5
		if last_replay - current_replay == 1:
			$"rack/cassettes/7".modulate.a = rack_time * 0.5 + 0.5
		if last_replay - current_replay == 0:
			$"rack/cassettes/7".modulate.a = 0.5
			$"rack/cassettes/8".modulate.a = 1
			$"rack/cassettes/9".modulate.a = 0.5
		else:
			$"rack/cassettes/8".modulate.a = (1 - rack_time) * 0.5 + 0.5

func set_cassette_labes():
	
	var recording : Dictionary = Global.load_replay(current_directory + replays[current_directory][current_replay])
	$replay_name.set_text(replays[current_directory][current_replay])
	$info/time.set_text(String(Global.convert_float_to_time(recording["timer"])))
	$info/level.set_text(String(recording["level"]))
	$info/character.set_text(String(recording["character"]))
	
	for i in range(17):
		var current_cassette : Control
		var cassettes_replay : int
		
		if rack_anim_direction == -1:
			current_cassette = get_node("rack/cassettes/" + String(16 - i))
			cassettes_replay = 8 - i + current_replay
		else:
			current_cassette = get_node("rack/cassettes/" + String(i))
			cassettes_replay = i - 8 + current_replay
		
		if cassettes_replay >= 0 and cassettes_replay < replay_amount:
			if i == 16 or rack_anim_direction == 0:
				current_cassette.set_text(replays[current_directory][cassettes_replay])
			else:
				var last_cassette : Control
				if rack_anim_direction == -1:
					last_cassette = get_node("rack/cassettes/" + String(16 - i - 1))
				else:
					last_cassette = get_node("rack/cassettes/" + String(i + 1))
				
				current_cassette.set_text(replays[current_directory][cassettes_replay],
					last_cassette.get_node("text").rect_position.x,
					last_cassette.paused_timer,
					last_cassette.direction)
		else:
			current_cassette.set_text("")

func load_replays():
	replays = {}
	
	# dir shenanigans
	var dir = Directory.new()
	
	var directories_to_visit = ["user://SRReplays/"]
	while directories_to_visit.size() > 0:
		dir.open(directories_to_visit[0])
		replays[directories_to_visit[0].trim_prefix("user://SRReplays/")] = []
		directories.append(directories_to_visit[0].trim_prefix("user://SRReplays/"))
		
		dir.list_dir_begin(true, false)
		var _last_replay : String = "*"
		
		_last_replay = dir.get_next()
		while _last_replay != "":
			if dir.current_is_dir():
				var dont_skip : bool = true
				var directory : String = directories_to_visit[0] + _last_replay + "/"
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
				replays[directories_to_visit[0].trim_prefix("user://SRReplays/")].append(_last_replay)
			_last_replay = dir.get_next()
		
		directories_to_visit.pop_front()
	
	if Global.replay_menu:
		current_replay = Global.replay_save[0]
		last_replay = Global.replay_save[0]
		next_replay = Global.replay_save[0]
		
		current_mode = Global.replay_save[1]
		
		for i in range(directories.size()):
			if directories[i] == Global.replay_save[2]:
				current_directory = Global.replay_save[2]
				break
	
	setup_rack(false)
