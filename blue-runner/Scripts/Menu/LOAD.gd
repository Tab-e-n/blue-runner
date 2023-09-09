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

var delay_timer_is_going : bool = true
var delay_timer : int = 0
var current_line_delay = 30

enum {SECTION_LOADING, SECTION_REBIND, SECTION_FIRST_TIME}
var current_section : int = 0
var text_current_line : int = 0

var user_wants_to_rebind : bool = false
var avaiting_keybind_press : bool = false
var current_key : int = 7

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

func _physics_process(delta):
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

func change_scene_to_menu():
#	get_tree().reload_current_scene()
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
