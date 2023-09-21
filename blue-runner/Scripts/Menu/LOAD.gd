extends Node2D

var text = [
	"\nMENU LEFT - ",
	"\nMENU RIGHT - ",
	"\nMENU UP - ",
	"\nMENU DOWN - ",
	"\nACCEPT - ",
	"\nDECLINE - ",
]

var lore_text = [
	"starting machine...\n",
	"MOTRBIOS (C) 2022 Luke Adams\n",
	"BIOS date 29/2/00 14:10:32\n",
	"CPU:",
	" VVIDYA Jetstream Nano\n",
	"Memory:",
	" SD/CCMN 48\n",
	"WARNING: Machine has been tampered with\n\n",
	"AUDIO CALIBRATION",
]

var tut_text = [
	"",
	"\n\n\n\n\n\n\n\n\nStarting Motors",
	".",
	".",
	".",
	"Done.",
	"\nStarting Visual",
	".",
	".",
	".",
	"Done.",
	"",
	"",
	"",
]

var delay_timer_is_going : bool = true
var delay_timer : int = 0
var current_line_delay = 30

enum {SECTION_LOADING, SECTION_REBIND, SECTION_FIRST_TIME, SECTION_GOING_TO_TUTORIAL}
var current_section : int = 0
var text_current_line : int = 0

var user_wants_to_rebind : bool = false
var avaiting_keybind_press : bool = false
var current_key : int = 7

var is_changing_audio : bool = false
var hold : int = 0
var move : bool = true
var held_for_amount : int = 0

var current_audio : int = 0

func _ready():
	if Global.options["*first_time_load"]:
		current_section = SECTION_FIRST_TIME
		$console/lines.text = lore_text[0]

func _input(event):
	if event is InputEventKey and event.pressed:
		current_line_delay = 15
		if event.scancode == KEY_F12:
			user_wants_to_rebind = true
		if avaiting_keybind_press:
			Global.change_input(current_key, event)
			$console/lines.text += Global.key_names(current_key)
			avaiting_keybind_press = false
			new_keybind()

func _physics_process(_delta):
	if delay_timer_is_going:
		delay_timer += 1
	if delay_timer > current_line_delay:
		text_current_line += 1
		delay_timer = 0
		if current_section == SECTION_LOADING and text_current_line < 4:
			$console/lines.text += "."
		if current_section == SECTION_REBIND and text_current_line < 6:
			$console/lines.text += String(6 - text_current_line) + "..."
		if current_section == SECTION_FIRST_TIME and text_current_line < lore_text.size():
			$console/lines.text += lore_text[text_current_line]
		if current_section == SECTION_GOING_TO_TUTORIAL and text_current_line < tut_text.size():
			$console/lines.text += tut_text[text_current_line]
	
	if current_section == SECTION_LOADING and text_current_line == 4:
		if user_wants_to_rebind:
			current_section = SECTION_REBIND
			text_current_line = 0
			delay_timer_is_going = false
			$console/lines.text += "\nF12 pressed, doing new menu keybinds:\n"
			new_keybind()
		else:
			$anim.play("exit")
	if current_section == SECTION_REBIND and text_current_line == 6:
		$anim.play("exit")
	if current_section == SECTION_FIRST_TIME and text_current_line == lore_text.size():
		$audio_text.visible = true
		$sfx.visible = true
#		$music.visible = true
#		$cursor.visible = true
		is_changing_audio = true
#		audio_cursor()
	if current_section == SECTION_GOING_TO_TUTORIAL and text_current_line == tut_text.size():
		# *TUTORIAL*
		Global.change_level("*res://Scenes/waterway/Level_1-0.tscn")
	
	if is_changing_audio:
		if Input.is_action_just_pressed("accept"):
			is_changing_audio = false
			current_section = SECTION_GOING_TO_TUTORIAL
			text_current_line = 0
			delay_timer_is_going = true
			$cursor.visible = false
			Global.options["*audio_sfx"] = $sfx.value
			Global.options["*audio_music"] = $music.value
		if Input.is_action_just_pressed("menu_left") or Input.is_action_just_pressed("menu_right") or Input.is_action_just_pressed("menu_up") or Input.is_action_just_pressed("menu_down"):
			move = true
			held_for_amount = 0
		
		if Input.is_action_pressed("menu_left") or Input.is_action_pressed("menu_right") or Input.is_action_pressed("menu_up") or Input.is_action_pressed("menu_down"):
			hold += 1
		else:
			hold = 0
		
		if hold >= 20:
			var hold_shift : int = 6
			# warning-ignore:integer_division
			hold -= hold_shift - held_for_amount / 3
			move = true
			if held_for_amount < 15:
				held_for_amount += 1
		
		var slider : HSlider
		var slider_text : String
		match current_audio:
			0:
				slider = $sfx
				slider_text = "SFX   "
			1:
				slider = $music
				slider_text = "MUSIC "
		
		if Input.is_action_pressed("menu_left") and move:
			if slider.value != slider.min_value:
				slider.value -= 1
				slider.get_node("text").text = slider_text + String(slider.value)
		if Input.is_action_pressed("menu_right") and move:
			if slider.value != slider.max_value:
				slider.value += 1
				slider.get_node("text").text = slider_text + String(slider.value)
#		if Input.is_action_just_pressed("menu_up") and current_audio != 0:
#			current_audio -= 1
#			audio_cursor()
#		if Input.is_action_just_pressed("menu_down") and current_audio != 1:
#			current_audio += 1
#			audio_cursor()
		
		move = false

func audio_cursor():
	$cursor.position = Vector2(392, 208 + current_audio * 32)

func change_scene_to_menu():
#	get_tree().reload_current_scene()
	Global.in_load_previously = true
	Global.change_level("*MENU")

func new_keybind():
	current_key += 1
	if current_key <= 13:
		$console/lines.text += text[current_key - 8]
		avaiting_keybind_press = true
	else:
		$console/lines.text += "\n\nOther keybinds can be changed in the options.\n\nGoing to menu in..."
		delay_timer = 0
		delay_timer_is_going = true
		current_line_delay = 30
