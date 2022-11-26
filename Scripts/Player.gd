extends KinematicBody2D

onready var global : Control = $"/root/Global"
onready var character : Node2D

export var character_name : String = ""

var state : String = "air"

export var facing : String = "right"

var momentum : Vector2 = Vector2(0, 0)

export var deny_input : bool = true
var end : bool = false
var dead : bool = false
var death_wait : int = 0

var timer : float = 0
var collectible : int = 0
export var ghost : bool = false

var replay : bool = false
var replay_timer : float = 3
var recording = {}
var current_sound : String = ""

var break_breakables : bool = false
var break_just_happened : bool = false
var punted : bool = false

func _ready():
	$pointer.visible = false
	visible = true
	global.current_level = get_parent().name
	
	recording.clear()
	
	replay = global.replay
	if ghost:
		if !global.race_mode:
			if !global.load_replay(global.current_level + "_Best", true) or !global.level_completion["*ghosts_on"]:
				queue_free()
				return
		replay = true
		
		modulate = Color(0, 0, 0, 0.5)
		#$trail.visible = false
		
		position = get_parent().get_node("Player").position
		
		if global.replay_menu: recording = global.current_recording.duplicate()
		else: recording = global.load_replay(global.current_level + "_Best")
		replay_timer = recording["timer"]
		character_name = recording["character"]
		
		collision_layer = 0
		collision_mask = 0
		
	elif replay: 
		recording = global.current_recording.duplicate()
		replay_timer = recording["timer"]
		character_name = recording["character"]
	else:
		if character_name == "":
			character_name = global.current_character
	
	var char_node = load("res://Objects/Player/" + character_name + "_Character.tscn").instance()
	add_child(char_node)
	character = char_node
	character.get_node("Anim").current_animation = "Enter"
	#if get_parent().name == "Main": position = $"/root/Global".tele_pos # HUB WORLD CODE

func _physics_process(delta):
	if get_parent().get_node("Player").replay and ghost:
		queue_free()
	
	timer += delta
	
	if !deny_input:
		pass
	# - - - REPLAY STATE - - -
	elif replay:
		var timer_converted : int = int(timer * 1000)
		if recording.has(String(timer_converted)):
			var replay_data = recording[String(timer_converted)]
			position = Vector2(replay_data[0], replay_data[1])
			character.get_node("Anim").current_animation = replay_data[4]
			character.scale = Vector2(replay_data[2], replay_data[3])
			if replay_data.size() > 5: play_sound(replay_data[5])
		else:
			if timer > replay_timer + 2 and !ghost:
				# warning-ignore:return_value_discarded
				get_tree().change_scene("res://Scenes/Menu_Level_Select.tscn")
	# - - - DEATH STATE - - -
	elif dead:
		death_wait += 1
		if death_wait >= 20:
			# warning-ignore:return_value_discarded
			#get_tree().change_scene("res://Scenes/" + get_tree().current_scene.name + ".tscn")
			get_tree().change_scene(get_tree().current_scene.filename)
			var _name : String = get_parent().name
			if global.level_completion.has(_name):
				if global.level_completion[_name].size() > 2:
					global.level_completion[_name][2] += 1
				else:
					global.level_completion[_name].resize(3)
					global.level_completion[_name][2] = 1
			else:
				global.level_completion[_name] = [null, null, 1]

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
	
	if Layers[0] and Layers[4] and break_breakables:
		instance_from_id(get_slide_collision(collider).collider_id).break_active = true
		break_just_happened = true
	
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

func play_sound(sound_name : String):
	if sound_name != "" and !ghost:
		get_node("Character/Sound/" + sound_name).play()
		current_sound = sound_name

func record():
	recording[int(timer * 1000)] = [position.x, position.y, character.scale.x, character.scale.y, $Character/Anim.current_animation, current_sound]
	current_sound = ""

func finish(collision):
	recording["timer"] = timer
	recording["character"] = character_name
	recording["level"] = get_parent().name
	#global.current_recording = recording.duplicate()
	deny_input = true
	end = true
	get_slide_collision(collision).collider.teleport(float(int(timer * 100)) / 100, collectible)
