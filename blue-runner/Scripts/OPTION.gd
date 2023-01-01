extends Node2D

onready var global : Control = $"/root/Global"
onready var parent : Node2D = get_parent()


var cursor_positions = [	Vector2(-840,-416), Vector2(-840,-352), Vector2(-840,-288), Vector2(-840,-224),  Vector2(-840,-160), Vector2(-840,-96),  Vector2(-840,-32), Vector2(-840,32),
							Vector2(-840,416),]
var selected_option : int = 0
var current_page : String = "main"
# PAGES:
# main
const page_limit_main : int = 3
const page_limit_controls : int = 7
# controls
var options_limit : int = page_limit_main

var delete_confirmation : bool = false
var key_set : int = -2

func _ready():
	$menu_circle2/Anim.play("Animate")
	$menu_circle/Anim.play("Animate")
	update_key_controls()

func _physics_process(_delta):
	$menu_circle.rotation -= 0.001

func menu_update():
	# - - - OPTION SELECT - - -
	if Input.is_action_just_pressed("jump") and key_set == -2:
		$Cursor2/AnimationPlayer.play("Go_In")
	
	if key_set >= -1:
		pass
	elif delete_confirmation:
		if Input.is_action_just_pressed("reset"): option_reset()
		if Input.is_action_just_pressed("return"): option_reset()
		if Input.is_action_just_pressed("special"): option_reset()
		if Input.is_action_just_pressed("up"): option_reset()
		if Input.is_action_just_pressed("down"): option_reset()
	elif $Cursor2/AnimationPlayer.current_animation != "Go_In":
		if Input.is_action_just_pressed("return") and parent.get_node("AnimationPlayer").current_animation == "":
			if selected_option != cursor_positions.size() - 1:
				selected_option = cursor_positions.size() - 1
				$Cursor2/AnimationPlayer.stop()
				$Cursor2/AnimationPlayer.play("Spin")
			else:
				$Cursor2/AnimationPlayer.play("Go_In")
		if Input.is_action_pressed("up") and parent.move and selected_option > 0:
			selected_option -= 1
			if selected_option > options_limit: selected_option = options_limit
			$Cursor2/AnimationPlayer.stop()
			$Cursor2/AnimationPlayer.play("Spin")
		if Input.is_action_pressed("down") and parent.move and selected_option < cursor_positions.size() - 1:
			selected_option += 1
			if selected_option > options_limit: selected_option = cursor_positions.size() - 1
			$Cursor2/AnimationPlayer.stop()
			$Cursor2/AnimationPlayer.play("Spin")
	
	$main.visible = current_page == "main"
	$controls.visible = current_page == "controls"
	
	$main/ghosts/check.visible = global.options["*ghosts_on"]
	$main/timer/check.visible = global.options["*timer_on"]
	
	$Cursor2.position = cursor_positions[selected_option]
	
	if key_set == -1: key_set = -2

func _input(event):
	if event is InputEventKey:
		if key_set >= 0 and event.pressed:
			global.change_input(key_set, event)
			key_set = -1
			update_key_controls()

func option_selected():
	var last_pos = cursor_positions.size() - 1
	if delete_confirmation: 
		global.level_completion.clear()
		for i in global.unlocked.keys():
			global.unlocked[i] = false
		global.save_game()
		
		parent.get_node("SELECT").reload_all_levels()
		
		$main/delete_save.text = "DELETE SAVE"
		delete_confirmation = false
	elif current_page == "main": match(selected_option):
		0:
			global.options["*ghosts_on"] = !global.options["*ghosts_on"]
		1:
			global.options["*timer_on"] = !global.options["*timer_on"]
		2:
			current_page = "controls"
			selected_option = 0
			options_limit = page_limit_controls
		3:
			delete_confirmation = true
			$main/delete_save.text = "ARE YOU SURE?"
		last_pos:
			parent.get_node("AnimationPlayer").play("OPTION-MAIN")
			parent.menu = "MAIN"
			parent.move = true
	elif current_page == "controls": 
		if selected_option == last_pos:
			current_page = "main"
			selected_option = 0
			options_limit = page_limit_main
		else:
			match(selected_option):
				0: global.options["*left"] = KEY_UNKNOWN
				1: global.options["*right"] = KEY_UNKNOWN
				2: global.options["*up"] = KEY_UNKNOWN
				3: global.options["*down"] = KEY_UNKNOWN
				4: global.options["*a"] = KEY_UNKNOWN
				5: global.options["*b"] = KEY_UNKNOWN
				6: global.options["*reset"] = KEY_UNKNOWN
				7: global.options["*return"] = KEY_UNKNOWN
			key_set = selected_option
			update_key_controls()

func update_key_controls():
	var full_text : String = ""
	for i in range(8):
		var key_string_converted : String = global.key_names(i)
		full_text += key_string_converted
		full_text += "\n"
	$controls/variable.text = full_text

func option_reset(cursor_reset : bool = false):
	$main/delete_save.text = "DELETE SAVE"
	delete_confirmation = false
	if cursor_reset: selected_option = 0
