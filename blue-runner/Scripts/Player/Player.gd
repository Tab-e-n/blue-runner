extends KinematicBody2D

onready var level : Node2D
onready var character : Node2D

export var character_name : String = ""
export var character_location : String = "res:/"

var state : String = "air"

export var facing : String = "right"

var momentum : Vector2 = Vector2(0, 0)

var _last_on_moving_ground : bool = false
var on_moving_ground : bool = false
var extra_momentum : Vector2 = Vector2(0, 0)

var deny_input : bool = true
var start : bool = true
var end : bool = false
var dead : bool = false
var death_wait : int = 0

var start_timer : bool = false
var timer : float = 0
var collectible : Array = []
var unlock : Array = []

export var replay : bool = false
var replay_timer : float = 3
var recording = {
	"timer" : 0,
	"character" : "",
	"character_location" : "",
}
var current_sound : String = ""
export var ghost : bool = false

var break_breakables : bool = false
var break_just_happened : bool = false
var punted : bool = false
var launched : bool = false
var speeding : bool = false

export var increment_timer : bool = true
export var loop_replay : bool = false
export var load_replay : bool = true
export var automatic_set_level_node : bool = true

func _ready():
	for i in range(8):
#		print(Global.keybind_names[i].trim_prefix("*"))
#		print(Input.is_action_pressed(Global.keybind_names[i].trim_prefix("*")))
		Input.action_release(Global.keybind_names[i].trim_prefix("*"))
#		print(Input.is_action_pressed(Global.keybind_names[i].trim_prefix("*")))
	
	visible = true
	Global.current_level = get_parent().name
	
	#recording.clear()
	
	if load_replay:
		replay = Global.replay
	
	if facing != "right" and facing != "left": facing = "right"
	
	if ghost:
		if !Global.race_mode:
			if !Global.load_replay(Global.current_level_location + Global.current_level + "_Best", true) or !Global.options["*ghosts_on"]:
				queue_free()
				return
		replay = true
		deny_input = true
		
		modulate = Color(0, 0, 0, 0.5)
		#$trail.visible = false
		
		position = get_parent().get_node("Player").position
		
		if Global.replay_menu: 
			recording = Global.current_recording.duplicate()
		else: 
			recording = Global.load_replay(Global.current_level_location + Global.current_level + "_Best")
		replay_timer = recording["timer"]
		character_name = recording["character"]
		if recording.has("character_location"): 
			character_location = recording["character_location"]
		
		collision_layer = 0
		collision_mask = 0
		
	elif replay: 
		timer = -1
		if load_replay:
			recording = Global.current_recording.duplicate()
		replay_timer = recording["timer"]
		character_name = recording["character"]
		if recording.has("character_location"):
			character_location = recording["character_location"]
	else:
		if character_name == "":
			character_name = Global.current_character
			character_location = Global.current_character_location
	
	var char_load : PackedScene = load(character_location + "/Objects/Player/" + character_name + "_Character.tscn")
	if char_load == null: char_load = preload("res://Objects/Player/missing_Character.tscn")
	var char_node = char_load.instance()
	add_child(char_node)
	character = char_node
	
	if replay:
		play_loaded_recording(0)
		if character.get_node("Anim").has_animation("_RESET"):
			character.get_node("Anim").current_animation = "_RESET"
	else:
		if character.get_node("Anim").has_animation("Enter"):
			character.get_node("Anim").current_animation = "Enter"
	
	if automatic_set_level_node:
		level = get_tree().current_scene
	
#	print(get_tree().current_scene)
	if level.get_script() != null:
		if level.unicolor_active and !ghost:
			material.set_shader_param("active", true)
		if !ghost:
			level.player = self

func shader_color():
	material.set_shader_param("color", character.unicolor_color)

func _input(event):
	if event is InputEventKey and event.pressed and !replay:
		if !start:
			level.timers_active = true
		else:
			start_timer = true

func _physics_process(delta):
	if level.get_script() == null:
		if level.get_node("Player").replay and ghost:
			queue_free()
	else:
		if level.player.replay and ghost:
			queue_free()
	
	
	if !start and start_timer and !ghost:
		level.timers_active = true
		start_timer = false
	
	if replay and timer >= 0 and !ghost:
		level.timers_active = true
	
	if level.timers_active or (replay and !ghost):
		if !replay and !end:
			if timer == 0:
				record()
			call_deferred("record")
		if increment_timer:
			timer += delta
	
	#print(deny_input, replay, dead, end, level.timer_active)
	
	if !deny_input:
		if Input.is_action_just_pressed("save_replay"):
			add_recording_data()
			Global.save_replay_with_date(get_parent().name, recording.duplicate())
		if !level.unicolor_active and false:
			var speed : float = sqrt(pow(momentum.x, 2) + pow(momentum.y, 2))
			material.set_shader_param("active", speed > 1500)
			if speed > 1500:
				var blend : float = (speed - 1500) / 1000
				if blend > 1:
					blend = 1
				material.set_shader_param("blend", blend)
	# - - - REPLAY STATE - - -
	elif replay:
		if !play_loaded_recording(int(timer * 1000)):
			if timer > replay_timer + 2 and !ghost:
				if loop_replay:
					timer = -1
					play_loaded_recording(0)
					if character.get_node("Anim").has_animation("_RESET"):
						character.get_node("Anim").current_animation = "_RESET"
					if level.has_method("_on_replay_looped"):
						level._on_replay_looped()
				else:
					Global.change_level("*Menu_Level_Select")
	# - - - DEATH STATE - - -
	elif dead:
		if death_wait == 0:
			var _name : String = get_parent().name
			if Global.level_completion[Global.current_level_location].has(_name):
				if Global.level_completion[Global.current_level_location][_name].size() > 2:
					Global.level_completion[Global.current_level_location][_name][2] += 1
				else:
					Global.level_completion[Global.current_level_location][_name].resize(3)
					Global.level_completion[Global.current_level_location][_name][2] = 1
			else:
				Global.level_completion[Global.current_level_location][_name] = [null, null, 1]
#			print(Global.level_completion[Global.current_level_location][_name])
		death_wait += 1
		if death_wait >= 20:
			Global.change_level("")

func move_player_character():
	collision_mask = 1048575
	# warning-ignore:return_value_discarded
	move_and_slide(momentum + extra_momentum, Vector2(0, -1))
	collision_mask = 1
	
	break_just_happened = false
	on_moving_ground = false
	set_deferred("launched", false)
	for i in get_slide_count(): collision_default_effects(get_slide_collision(i).collider.collision_layer, i)
	if on_moving_ground != _last_on_moving_ground and on_moving_ground == false:
		momentum += extra_momentum
		extra_momentum = Vector2(0, 0)
	_last_on_moving_ground = on_moving_ground

func collision_default_effects(collider_type : int, collider):
	punted = false
	
	var Layers : Array = []
	Layers.resize(20)
	var l : int = 0
	while collider_type > 0:
		Layers[l] = collider_type % 2 == 1
		# warning-ignore:integer_division
		collider_type = collider_type / 2
		l += 1
	while l < 20:
		Layers[l] = false
		l += 1
	# SHARED PROPERTIES
	# Layers[0] / GROUND
	# Solid thing you can stand on and wall jump off of
	# Layers[1] / SEMI-SOLID
	# thing you can wall jump off of but not stand on
	# Layers[2] / HURT
	# it hurts
	# Layers[3] / EFFECT
	# it do shit
	
	# other layers are for specifications on what thing the collider is
	
	if Layers[0] and Layers[1] and break_breakables:
		var object = instance_from_id(get_slide_collision(collider).collider_id)
		object.break_active = true
		object.break_position = position
		break_just_happened = true
	
	if Layers[0] and Layers[3]:
		on_moving_ground = true
		extra_momentum = get_slide_collision(collider).collider.momentum
	
	if Layers[2]:
		dead = true
		deny_input = true
	
	if Layers[3]:
		if Layers[4]:
			finish(collider)

func punt(boost : Vector2, overwrite_momentum : bool):
	#var sign_ = sign(boost.x)
	#if boost.x * sign_ > momentum.x * sign_:
	#	momentum.x = boost.x
	#else:
	#	momentum.x += round(boost.x / 4)
	#
	#sign_ = sign(boost.y)
	#if boost.y * sign_ > momentum.y * sign_:
	#	momentum.y = boost.y
	#else:
	#	momentum.y += round(boost.y / 4)
	
	if overwrite_momentum:
		momentum.x = boost.x
	elif sign(momentum.x) == sign(boost.x):
		if abs(boost.x) - 20 > abs(momentum.x):
			momentum.x = boost.x
		elif abs(boost.x) - 20 < abs(momentum.x):
			momentum.x += round(boost.x / 3)
	elif sign(boost.x) != 0:
		momentum.x = boost.x
	
	if overwrite_momentum:
		momentum.y = boost.y
	elif sign(momentum.y) == sign(boost.y):
		if abs(boost.y) - 20 > abs(momentum.y):
			momentum.y = boost.y
		elif abs(boost.y) - 20 < abs(momentum.y):
			momentum.y += round(boost.y / 3)
	elif sign(boost.y) != 0:
		momentum.y = boost.y
	
	state = "air"
	punted = true
	if momentum.y < -1500:
		launched = true

func play_sound(sound_name : String):
	if sound_name != "" and !ghost:
		get_node("Character/Sound/" + sound_name).play()
		current_sound = sound_name

func record():
	recording[int(timer * 1000)] = [position.x, position.y, character.scale.x, character.scale.y, $Character/Anim.current_animation, current_sound]
	current_sound = ""

func add_recording_data():
	recording["timer"] = timer
	recording["character"] = character_name
	recording["character_location"] = character_location
	recording["level"] = Global.current_level_location + get_parent().name
	#Global.current_recording = recording.duplicate()

func play_loaded_recording(time : int):
	if recording.has(String(time)):
		var replay_data = recording[String(time)]
		position = Vector2(replay_data[0], replay_data[1])
		character.get_node("Anim").current_animation = replay_data[4]
		character.scale = Vector2(replay_data[2], replay_data[3])
		if replay_data.size() > 5:
			play_sound(replay_data[5])
		return true
	else:
		return false

func finish(collision):
	add_recording_data()
	deny_input = true
	end = true
	get_slide_collision(collision).collider.teleport(float(int(timer * 100)) / 100, collectible, unlock, recording.duplicate())
