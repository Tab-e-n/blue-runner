extends Node2D

onready var global : Control = $"/root/Global"
onready var parent : Node2D = get_parent()
onready var camera : Node2D = get_parent().get_node("Camera")

var current_world : int = 1
var selected_level : int = 0
var cursor_positions = [	Vector2(-192,0), Vector2(64,0), Vector2(320,0), Vector2(576,0), Vector2(832,0),
							Vector2(-192,192), Vector2(64,192), Vector2(320,192), Vector2(576,192), Vector2(832,192), 
							Vector2(-192,384), Vector2(64,384), Vector2(320,384), Vector2(576,384), Vector2(832,384), 
							Vector2(-192,576), Vector2(64,576), Vector2(320,576), Vector2(576,576), Vector2(832,576),]
var selected : bool = false
var selected_level_name : String

func _ready():
	camera.bg = $BG_0
	$BG_0.camera = camera
	reload_all_levels()

func menu_update():
	# - - - LEVEL SELECT - - -
	if Input.is_action_just_pressed("jump"):
		if !get_node("L/Level_" + String(selected_level)).locked:
			selected = true
			$Cursor/AnimationPlayer.play("Go_In")
			get_node("L/Level_" + String(selected_level)).get_node("Anim").play("Bump")
		else:
			$Cursor/AnimationPlayer.play("Refuse")
	
	if Input.is_action_just_pressed("special"):
		if global.load_replay(selected_level_name + "_Best", true):
			global.current_recording = global.load_replay(selected_level_name + "_Best")
			global.replay = true
			selected = true
			$Cursor/AnimationPlayer.play("Go_In")
			get_node("L/Level_" + String(selected_level)).get_node("Anim").play("Bump")
		else:
			global.replay = false
			selected = false
			$Cursor/AnimationPlayer.play("Refuse")
	
	if selected: parent.move = false
	
	if Input.is_action_pressed("left") and parent.move and selected_level > 0:
		selected_level -= 1
		$Cursor/AnimationPlayer.stop()
		$Cursor/AnimationPlayer.play("Spin")
	if Input.is_action_pressed("right") and parent.move and selected_level < 19:
		selected_level += 1
		$Cursor/AnimationPlayer.stop()
		$Cursor/AnimationPlayer.play("Spin")
	if Input.is_action_pressed("up") and parent.move and selected_level - 4 > 0:
		selected_level -= 5
		$Cursor/AnimationPlayer.stop()
		$Cursor/AnimationPlayer.play("Spin")
	if Input.is_action_pressed("down") and parent.move and selected_level + 4 < 19:
		selected_level += 5
		$Cursor/AnimationPlayer.stop()
		$Cursor/AnimationPlayer.play("Spin")
	
	selected_level_name = get_node("L/Level_" + String(selected_level)).level_name
	
	if parent.move:
		$Level_Descriptor/level_name.text = selected_level_name
		$Level_Descriptor/best_time.text = "Best time: ???"
		$Level_Descriptor/par.text = " "
		$Level_Descriptor/deaths.text = " "
		$Level_Descriptor/replay.text = " "
		if global.level_completion.has(selected_level_name):
			if global.level_completion[selected_level_name][0] != null:
				var timer : float = global.level_completion[selected_level_name][0]
				var minutes : int = int(floor(timer) / 60)
				var seconds : int = int(floor(timer)) - minutes * 60
				var decimal : int = int(floor(timer * 100 + 0.1)) % 100
				
				# warning-ignore:integer_division
				# warning-ignore:integer_division
				$Level_Descriptor/best_time.text = "Best time: " + String(minutes)+":"+String(seconds/10)+String(seconds%10)+"."+String(decimal/10)+String(decimal%10)
				
				timer = global.level_completion[selected_level_name][1]
				if timer != 0:
					minutes = int(floor(timer) / 60)
					seconds = int(floor(timer)) - minutes * 60
					decimal = int(floor(timer * 100 + 0.1)) % 100
					
					# warning-ignore:integer_division
					# warning-ignore:integer_division
					$Level_Descriptor/par.text = "Par: " + String(minutes)+":"+String(seconds/10)+String(seconds%10)+"."+String(decimal/10)+String(decimal%10)
			
			if global.level_completion[selected_level_name].size() > 2: 
				$Level_Descriptor/deaths.text = "Deaths: " + String(global.level_completion[selected_level_name][2])
		if global.load_replay(selected_level_name + "_Best", true, false):
			$Level_Descriptor/replay.text = global.key_names(5) + " - Best Replay"
	
	$Cursor.position = cursor_positions[selected_level]
	$back.text = global.key_names(7) + " - Go Back"

func reload_all_levels():
	global.unlock_check()
	$L/Level_15.locked = !global.level_completion["*unlocked"]["Level_1-A"]
	$L/Level_16.locked = !global.level_completion["*unlocked"]["Level_1-B"]
	$L/Level_18.locked = !global.level_completion["*unlocked"]["Level_1-C"]
	$L/Level_19.locked = !global.level_completion["*unlocked"]["Level_1--1"]
	for i in range(20): get_node("L/Level_" + String(i)).reload()
	
	var comp_number : int = completion_percentage()
	$completion_filling/text.text = String(comp_number * 2) + "%"
	$completion_filling/bar.scale.x = float(comp_number) / 50
	$anim.stop()
	$anim.play("WaterWay")

func start_level():
	global.current_level = selected_level_name
	# warning-ignore:return_value_discarded
	get_tree().change_scene("res://Scenes/" + selected_level_name + ".tscn")

func completion_percentage():
	var completion : int = 0
	for i in range(20):
		var level_string : String = get_node("L/Level_" + String(i)).level_name
		if global.level_completion.has(level_string): if global.level_completion[level_string][0] != null:
			completion += 1
			#print("beat " + String(i))
			if global.level_completion[level_string][1] != null:
				if global.level_completion[level_string][0] < global.level_completion[level_string][1] and global.level_completion[level_string][1] != 0:
					completion += 1
					#print("par " + String(i))
		if global.level_completion["*unlocked"].has(level_string):
			if global.level_completion["*unlocked"][level_string]:
				completion += 1
				#print("unlocked " + String(i))
		if global.level_completion.has(String((current_world-1)*20 + i)):
			completion += 1
			#print("bonus " + String(i))
	return completion
