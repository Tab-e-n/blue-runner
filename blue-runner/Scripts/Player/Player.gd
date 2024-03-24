extends KinematicBody2D
class_name Player


signal boosted(boost)


onready var level : Node2D
onready var character : Node2D
onready var collisions : Array = [$col_0, $col_1, $col_2]

export var character_name : String = ""
export var character_location : String = "res:/"

var state : String = "air"

export var facing : String = "right"

var momentum : Vector2 = Vector2(0, 0)
var extra_momentum : Vector2 = Vector2(0, 0)

var deny_input : bool = true
var start : bool = true
var end : bool = false
var dead : bool = false
var death_wait : int = 0

var start_timer : bool = false
var timer : float = 0
var collectibles : Array = []
var unlocks : Array = []

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
var boosted : bool = false
var launched : bool = false
var stylish : bool = false
#var speeding : bool = false

var moving_ground : Node2D = null

const INPUT_BUFFER_FRAMES : int = 4
var jump_buffer : int = 0
var special_buffer : int = 0

const GROUND_BUFFER_FRAMES : int = 4
var ground_buffer : int = 0

export var increment_timer : bool = true
export var reset_increment_timer : bool = false
export var loop_replay : bool = false
export var load_replay : bool = true
export var automatic_set_level_node : bool = true
export var silent : bool = false

onready var trail : Line2D = get_node("trail")
var trail_points : PoolVector2Array = []
var trail_converted : PoolVector2Array = []


func _ready():
#	print("Player")
	$character_texture.texture = $character_viewport.get_texture()
	
	for i in range(8):
		if Input.is_action_pressed(Global.KEYBIND_NAMES[i].trim_prefix("*")):
			start_timer = true
	
	visible = true
	Global.current_level = get_parent().name
	
	material = ShaderMaterial.new()
	material.shader = preload("res://Scripts/single_color.shader")
	
	#recording.clear()
	
	if load_replay:
		replay = Global.replay
	
	if facing != "right" and facing != "left":
		facing = "right"
	
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
		
		silent = true
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
	
	load_current_character()
	
	if automatic_set_level_node:
		level = get_tree().current_scene
	
	if level.get_script() == null:
		level.set_script(load("res://Scripts/Level_Control.gd"))
	
	material.set_shader_param("active", false)
#	print(get_tree().current_scene)
	if level.unicolor_active and !ghost:
		material.set_shader_param("active", true)
	if !ghost:
		level.player = self
	
	material.set_shader_param("outline_active", Global.options["*outlines_on"])
	
#	print("R " + name)


func load_current_character(change_unicolor : bool = true):
	if character != null:
		character.queue_free()
	
	var char_load : PackedScene = load(character_location + "/Objects/Player/" + character_name + "_Character.tscn")
	if char_load == null:
		char_load = preload("res://Objects/Player/missing_Character.tscn")
	var char_node = char_load.instance()
	char_node.player = self
	$character_viewport.add_child(char_node)
	char_node.position = $character_viewport.size * Vector2(0.5, 0.5)
	character = char_node
	
	if replay:
		play_loaded_recording(0, false)
		if character.get_node("Anim").has_animation("_RESET"):
			character.get_node("Anim").current_animation = "_RESET"
	else:
		if character.get_node("Anim").has_animation("Enter"):
			character.get_node("Anim").current_animation = "Enter"
		else:
			enter_anim_end()
	
	$stylish.position = character.STYLISH_POSITION
	$stylish.emission_rect_extents = character.STYLISH_RECT + Vector2(8, 8)
	
	if !ghost and change_unicolor:
		shader_color()


func shader_color():
	material.set_shader_param("color", character.UNICOLOR_COLOR)


func _input(event):
	if !replay:
		if event is InputEventKey or event is InputEventJoypadButton:
			if event.pressed:
				if start:
					start_timer = true
				else:
					level.timers_active = true
		if event is InputEventJoypadMotion:
			if start:
				start_timer = true
			else:
				level.timers_active = true


func _physics_process(delta):
	if level.player.replay and ghost:
		queue_free()
	
	if !start and start_timer and !ghost:
		level.timers_active = true
		start_timer = false
	
	if replay and timer >= 0 and !ghost and increment_timer:
		level.timers_active = true
	
	if level.timers_active or (replay and !ghost):
		if !replay and !end:
			if timer == 0:
				record()
			call_deferred("record")
		if increment_timer:
			timer += delta
	
	if reset_increment_timer:
		reset_increment_timer = false
		increment_timer = false
		level.set_deferred("timers_active", false)
	
	#print(deny_input, replay, dead, end, level.timer_active)
	
	if !deny_input:
		if Input.is_action_just_pressed("save_replay"):
			add_recording_data()
			Global.save_replay_with_date(get_parent().name, recording.duplicate())
		if stylish and state == "ground":
			if get_horizontal_axis() != 0:
				call_deferred("boost", Vector2(get_horizontal_axis() * 200, 0))
#				boost(Vector2(get_horizontal_axis() * 200, 0))
			stylish = false
		
#		if !level.unicolor_active and false:
#			var speed : float = sqrt(pow(momentum.x, 2) + pow(momentum.y, 2))
#			material.set_shader_param("active", speed > 1500)
#			if speed > 1500:
#				var blend : float = (speed - 1500) / 1000
#				if blend > 1:
#					blend = 1
#				material.set_shader_param("blend", blend)
		
	# - - - REPLAY STATE - - -
	elif replay:
		stylish = false
		if Input.is_action_just_pressed("jump") and Global.replay_menu and not Global.race_mode:
			increment_timer = !increment_timer
			level.set_deferred("timers_active", increment_timer)
			var camera = level.get_node("Camera")
			if camera != null:
				camera.get_node("info/camera_pause").visible = !increment_timer
			if increment_timer:
				character.get_node("Anim").playback_speed = 1
			else:
				character.get_node("Anim").playback_speed = 0
		
		if Input.is_action_just_pressed("special") and Global.replay_menu and not Global.race_mode and not increment_timer:
#			timer += delta
			reset_increment_timer = true
			increment_timer = true
			level.set_deferred("timers_active", true)
		
		if !play_loaded_recording(int(timer * 1000)):
			if timer > replay_timer + 2 and !ghost:
				if loop_replay:
					timer = -1
					play_loaded_recording(0, false)
					if character.get_node("Anim").has_animation("_RESET"):
						character.get_node("Anim").current_animation = "_RESET"
					if level.has_method("_on_replay_looped"):
						level._on_replay_looped(self)
					clear_trail_history()
				else:
					Global.change_level("*Menu_Level_Select")
	# - - - DEATH STATE - - -
	elif dead:
		stylish = false
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
		if death_wait >= 16:
			Global.change_level_fade_out("")
	elif end:
		stylish = false
	
	$stylish.emitting = stylish


func is_jump_input_pressed():
	var jump = Input.is_action_pressed("jump")
	if Global.options["*up_key_jump"] and Input.is_action_pressed("up"):
		jump = true
	return jump


func is_jump_input_just_pressed():
	var jump = Input.is_action_just_pressed("jump")
	if Global.options["*up_key_jump"] and Input.is_action_just_pressed("up"):
		jump = true
	return jump


func is_jump_input_just_released():
	var jump = Input.is_action_just_released("jump")
	if Global.options["*up_key_jump"] and Input.is_action_just_released("up"):
		jump = true
	return jump


func get_horizontal_axis() -> float:
	var axis = 0
	if Input.is_action_pressed("right"):
		axis += 1
	if Input.is_action_pressed("left"):
		axis -= 1
	return axis


func should_jump() -> bool:
	return jump_buffer > 0


func is_starting() -> bool:
	return start and not Global.replay_menu


func start_jump_buffer():
	jump_buffer = INPUT_BUFFER_FRAMES


func decrement_jump_buffer():
	if jump_buffer > 0:
		jump_buffer -= 1


func should_special() -> bool:
	return special_buffer > 0


func start_special_buffer():
	special_buffer = INPUT_BUFFER_FRAMES


func decrement_special_buffer():
	if special_buffer > 0:
		special_buffer -= 1


func start_ground_buffer():
	ground_buffer = GROUND_BUFFER_FRAMES


func decrement_ground_buffer():
	if ground_buffer > 0:
		ground_buffer -= 1


func get_facing_axis() -> float:
	if facing == "left":
		return -1.0
	else:
		return 1.0


func face_towards(direction : float):
	direction = sign(direction)
	if direction == -1.0:
		facing = "left"
	elif direction == 1.0:
		facing = "right"


func below_max_speed(number : float, direction : float, threshold : float) -> bool:
	if direction == 1:
		return number < threshold
	if direction == -1:
		return number > -threshold
	return false


func cap_momentum_x(max_speed : float):
	if momentum.x > max_speed:
		momentum.x = max_speed
	if momentum.x < -max_speed:
		momentum.x = -max_speed


func move_player_character():
	collision_mask = 0b1111_1111_1111_1111_1111
	# warning-ignore:return_value_discarded
	move_and_slide(momentum, Vector2(0, -1))
	collision_mask = 0b1
	
	break_just_happened = false
	set_deferred("punted", false)
	set_deferred("boosted", false)
	set_deferred("launched", false)
	
	var collision = move_and_collide(Vector2(0, 2), false, true, true)
	if collision:
		var platform = collision.collider
		if moving_ground != platform:
			exit_moving_ground()
	else:
		exit_moving_ground()
	
	
	for i in get_slide_count():
		collision_default_effects(get_slide_collision(i).collider.collision_layer, i)


func exit_moving_ground():
	if moving_ground:
		extra_momentum = moving_ground.momentum
		momentum += moving_ground.momentum
		moving_ground = null


func collision_default_effects(type : int, collider):
	# SHARED PROPERTIES
	# 0b0001 / GROUND
	# Solid thing you can stand on and wall jump off of
	# 0b0010 / SEMI-SOLID
	# thing you can wall jump off of but not stand on
	# 0b0100 / HURT
	# it hurts
	# 0b1000 / EFFECT
	# it do shit
	
	# other layers are specifing what the collider is
	
	# Hurt
	if bit_include(type, 0b0100):
		if not (bit_include(type, 0b0010) and jump_buffer != 0):
			dead = true
			deny_input = true
	
	# Breakable
	if bit_include(type, 0b0011) and break_breakables:
		var object = instance_from_id(get_slide_collision(collider).collider_id)
		object.break_active = true
		object.break_position = position
		break_just_happened = true
	
	# Moving Ground
	if bit_include(type, 0b1001):
		moving_ground = get_slide_collision(collider).collider
		moving_ground.player = self
	
	# Teleporter
	if bit_match(type, 0b11000):
		finish(get_slide_collision(collider).collider)


func bit_match(num : int, pattern : int) -> bool:
	return num ^ pattern == 0


func bit_include(num : int, pattern : int) -> bool:
	return num & pattern == pattern


func jump(jump_power : int):
	momentum.y = -jump_power
	state = "air"
	jump_buffer = 0


func punt(boost : Vector2, overwrite_momentum : bool, make_airborn : bool = true):
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
	
	extra_momentum = boost
	
	boosted = true
	if make_airborn:
		state = "air"
		punted = true
		if momentum.y < -1500:
			launched = true


func boost(boost_amount : Vector2):
	boosted = true
	momentum += boost_amount
	if boost_amount.x != 0:
		make_speed_ring(sign(boost_amount.x))
	emit_signal("boosted", boost_amount)


func play_sound(sound_name : String, random_pitch : bool = false):
	var pitch = 1
	var pitch_end = -1
	if random_pitch:
		pitch = 0.8
		pitch_end = 1.2
	
	if sound_name != "" and !silent:
		Audio.play_sound(sound_name, pitch, pitch_end)
		current_sound = sound_name


func enter_anim_end():
	if !replay:
		start = false
		deny_input = false


func record():
	recording[int(timer * 1000)] = [position.x, position.y, character.scale.x, character.scale.y, character.get_node("Anim").current_animation, current_sound]
	current_sound = ""


func add_recording_data():
	recording["timer"] = timer
	recording["character"] = character_name
	recording["character_location"] = character_location
	recording["level"] = Global.current_level_location + get_parent().name
	#Global.current_recording = recording.duplicate()


func play_loaded_recording(time : int, sound : bool = true):
	if recording.has(String(time)):
		var replay_data = recording[String(time)]
		position = Vector2(replay_data[0], replay_data[1])
		character.get_node("Anim").current_animation = replay_data[4]
		character.scale = Vector2(replay_data[2], replay_data[3])
		if replay_data.size() > 5 and increment_timer and sound:
			play_sound(replay_data[5])
		return true
	else:
		return false


func finish(collider):
	add_recording_data()
	deny_input = true
	end = true
	collider.teleport(
			stepify(timer, 0.01),
			collectibles,
			unlocks,
			recording.duplicate()
	)


func setup_trail(trail_color : Color, amount_of_points : int = 40):
	trail.visible = true
	trail.modulate = trail_color
	trail_points.resize(amount_of_points)
	trail_converted.resize(amount_of_points)
	for i in range(trail_points.size()):
		trail_points[i] = position


func animate_trail(visual_offset : Vector2 = Vector2(0, 0), position_offset : Vector2 = Vector2(0, 0)):
	for i in range(trail_points.size() - 1):
		trail_points[i] = trail_points[i+1]
	
	trail_points[trail_points.size() - 1] = position + position_offset
	trail.position = visual_offset
	
	trail_converted[trail_points.size() - 1] = Vector2(0, 0)
	
	for i in range(trail_points.size() - 1):
		var temp = trail_points[trail_points.size() - 2 - i] - trail_points[trail_points.size() - 1 - i]
		trail_converted[trail_points.size() - 2 - i] = trail_converted[trail_points.size() - 1 - i] + temp
	
	trail.points = trail_converted


func clear_trail_history():
	for i in range(trail_points.size()):
		trail_points[i] = position
		trail_converted[i] = Vector2(0, 0)
	trail.points = trail_converted


func been_stylish(style : String = "Nice!"):
	var new_callout : Node2D = preload("res://Objects/Decor/StyleCallout.tscn").instance()
	new_callout.text = style
	new_callout.position = position
	get_tree().current_scene.call_deferred("add_child", new_callout)
	
	stylish = true


func make_speed_ring(direction : float = 1):
	var ring : Node2D = preload("res://Objects/Decor/SpeedRing.tscn").instance()
	ring.position = position - character.STYLISH_RECT * Vector2(0, 0.5)
	ring.scale.x = direction
	get_tree().current_scene.add_child(ring)
	
