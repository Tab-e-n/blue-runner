extends Node2D

onready var parent : Node2D = get_parent()

var text : PackedScene = preload("res://Text/Text_Options.tscn")

export var pulse_time : float = -1

var current_menu : String = "main"

onready var cursor : Node2D = $cursor
var cursor_row : int = 0

var cursor_positions : Array = []
var buttons : Array = []

var confirmation : bool = false
var confirm_popup : bool = false
var keybinds : bool = false
var disabled_popup : bool = false
var slider : bool = false

var starting_slider_pos : int = 0

const main_buttons : Array = [
	["GAME SETTINGS", "submenu", "game"],
	["CONTROLS", "submenu", "controls"],
	["AUDIO", "submenu", "audio"],
	["", "label"],
	["RESET OPTIONS", "globalaction", "reset_options", true],
]

const game_buttons : Array = [
	["== GAME SETTINGS ==", "label"],
	["", "label"],
	["OUTLINES", "checkbox", "*outlines_on"],
	["GHOSTS", "checkbox", "*ghosts_on"],
	["TIMER", "enum", "*timer_on", ["OFF", "ON", "LEVEL BEAT"]],
	["", "label"],
	["DELETE SAVE", "globalaction", "delete_save", true],
]

const controls_buttons : Array = [
	["== CONTROLS ==", "label"],
	["", "label"],
	["LEVEL CONTROLS", "submenu", "controls_level"],
	["MENU CONTROLS", "submenu", "controls_menu"],
	["META CONTROLS", "submenu", "controls_meta"],
	["", "label"],
	["UP FOR JUMP", "checkbox", "*up_key_jump"],
]
const controls_level_buttons : Array = [
	["== LEVEL CONTROLS ==", "label"],
	["", "label"],
	["LEFT", "keybind", 0],
	["RIGHT", "keybind", 1],
	["UP", "keybind", 2],
	["DOWN", "keybind", 3],
	["JUMP", "keybind", 4],
	["SPECIAL", "keybind", 5],
	["RESET", "keybind", 6],
	["RETURN", "keybind", 7],
]
const controls_menu_buttons : Array = [
	["== MENU CONTROLS ==", "label"],
	["", "label"],
	["LEFT", "keybind", 8],
	["RIGHT", "keybind", 9],
	["UP", "keybind", 10],
	["DOWN", "keybind", 11],
	["ACCEPT", "keybind", 12],
	["DENY", "keybind", 13],
	["", "label"],
	["If you can't access this menu for some reason,", "label"],
	["remember that you can change these keybinds", "label"],
	["by pressing F12 when loading into Sonic Runner.", "label"],
]
const controls_meta_buttons : Array = [
	["== META CONTROLS ==", "label"],
	["", "label"],
	["SCREENSHOT", "keybind", 15],
	["SAVE REPLAY", "keybind", 14],
]

const audio_buttons : Array = [
	["== AUDIO ==", "label"],
	["", "label"],
	["SFX", "slider", "*audio_sfx", [0, 100], ""],
	["MUSIC", "slider", "*audio_music", [0, 100], "music_slider_update"],
]

var where_to_go_back : String = "main"


func make_options(menu_buttons : Array):
	var section : int = 1
	var row : int = 0
	
	buttons.clear()
	cursor_positions.clear()
	cursor_row = 0
	
	for i in $buttons.get_children():
		i.queue_free()
	
	var section_position : Vector2 = Vector2(-576, -260)
	var section_size : Vector2 = Vector2(3072, 1024)
	var section_offset : int = 192
	
	var section_node = text.instance()
	$buttons.add_child(section_node)
	section_node.rect_position = section_position
	section_node.rect_size = section_size
	
	for i in range(menu_buttons.size()):
		var pos = Vector2(section_position.x + section_offset, 32 * row - 256)
		var should_add_cursor_pos : bool = true
		match(menu_buttons[i][1]):
			"section":
				if i != 0:
					section += 1
					row = 0
					section_node = text.instance()
					$buttons.add_child(section_node)
				if menu_buttons[i][2]:
					section_position = menu_buttons[i][3]
					section_node.rect_position = section_position
					
					section_size = menu_buttons[i][4]
					section_node.rect_size = section_size
					
					section_offset = menu_buttons[i][5]
				else:
					section_position = Vector2(-576 + 416 * (section - 1), -256)
					section_node.rect_position = section_position
					
					section_size = Vector2(3072, 1024)
					section_node.rect_size = section_size
					
					section_offset = 192
				
				section_node.rect_position = section_position
				section_node.rect_size = section_size
				
				should_add_cursor_pos = false
			"label":
				should_add_cursor_pos = false
			"submenu":
				buttons.append(["submenu", menu_buttons[i][2]])
			"disabled":
				buttons.append(["disabled"])
			"checkbox":
				var new_checkbox = CheckBox.new()
				new_checkbox.rect_position = pos - Vector2(0, 20)
				new_checkbox.rect_size = Vector2(64, 64)
				new_checkbox.disabled = true
				new_checkbox.pressed = Global.options[menu_buttons[i][2]]
				$buttons.add_child(new_checkbox)
				buttons.append(["checkbox", new_checkbox, menu_buttons[i][2]])
			"slider":
				var new_slider = HSlider.new()
				new_slider.rect_position = pos - Vector2(0, 8)
				new_slider.rect_size = Vector2(128, 32)
				new_slider.editable = false
				new_slider.min_value = menu_buttons[i][3][0]
				new_slider.max_value = menu_buttons[i][3][1]
				new_slider.value = Global.options[menu_buttons[i][2]]
				$buttons.add_child(new_slider)
				buttons.append(["slider", new_slider, menu_buttons[i][2], menu_buttons[i][4]])
			"enum":
				var new_text = text.instance()
				new_text.rect_position = pos - Vector2(0, 4)
				new_text.text = menu_buttons[i][3][Global.options[menu_buttons[i][2]]]
				$buttons.add_child(new_text)
				
				buttons.append(["enum", new_text, menu_buttons[i][2], menu_buttons[i][3]])
			"action":
				buttons.append(["action", menu_buttons[i][2], menu_buttons[i][3]])
			"globalaction":
				buttons.append(["globalaction", menu_buttons[i][2], menu_buttons[i][3]])
			"keybind":
				var new_text = text.instance()
				new_text.rect_position = pos - Vector2(0, 4)
				new_text.text = Global.key_names(menu_buttons[i][2])
				$buttons.add_child(new_text)
				
				buttons.append(["keybind", new_text, menu_buttons[i][2]])
		
		if should_add_cursor_pos:
			add_cursor_pos(pos - Vector2(section_offset, 0))
		
		section_node.text += menu_buttons[i][0] + "\n"
		
		row += 1
	
	buttons.append(["back"])
	add_cursor_pos(Vector2(-576, 304))


func add_cursor_pos(button_position : Vector2):
	cursor_positions.append(button_position + Vector2(-24, 16))


func _ready():
	change_menu(current_menu)
	scale = Vector2(0, 0)
	$mainAnim.play("enter")


func _input(event):
	if event is InputEventKey:
		if event.pressed and keybinds:
			Global.change_input(buttons[cursor_row][2], event)
			buttons[cursor_row][1].text = Global.key_names(buttons[cursor_row][2])
			confirmation = false
		if event.pressed and confirm_popup and event.scancode != Global.options["*accept"]:
			confirmation = false
		if event.pressed and disabled_popup:
			disabled_popup = false


func menu_update():
	for i in buttons:
		pass
		#match(i[0]):
		#	"keybind":
		#		i[1].text = Global.key_names(i[2])
	
	if Input.is_action_pressed("menu_up") and parent.move and cursor_row > 0 and !confirmation and !keybinds:
		cursor_row -= 1
		$cursor/anim.stop()
		$cursor/anim.play("Spin")
	if Input.is_action_pressed("menu_down") and parent.move and cursor_row < cursor_positions.size() - 1 and !confirmation and !keybinds:
		cursor_row += 1
		$cursor/anim.stop()
		$cursor/anim.play("Spin")
	if Input.is_action_pressed("menu_left") and parent.move and slider:
		move_slider(-1)
	if Input.is_action_pressed("menu_right") and parent.move and slider:
		move_slider(1)
	if Input.is_action_just_pressed("accept") and !keybinds:
		$cursor/anim.stop()
		$cursor/anim.play("Select")
		#select()
	if Input.is_action_just_pressed("deny") and !keybinds and !confirm_popup:
		if slider:
			buttons[cursor_row][1].value = starting_slider_pos
			end_slider()
		elif cursor_row != cursor_positions.size() - 1:
			$cursor/anim.stop()
			$cursor/anim.play("Spin")
			cursor_row = cursor_positions.size() - 1
		else:
			$cursor/anim.stop()
			$cursor/anim.play("Select")
			#select()
	
	if !confirmation and keybinds:
		keybinds = false
	
	if !confirmation and confirm_popup:
		confirm_popup = false
	
	cursor.position = cursor_positions[cursor_row]
	
	$confirmation.visible = confirm_popup
	$disabled.visible = disabled_popup
	
	material.set_shader_param("offset", pulse_time)


func move_slider(direction : int):
	var end_value : int
	if direction == -1:
		end_value = buttons[cursor_row][1].min_value
	else:
		end_value = buttons[cursor_row][1].max_value
	
	if buttons[cursor_row][1].value != end_value:
		buttons[cursor_row][1].value += direction
		$slider_value.text = String(buttons[cursor_row][1].value)
		slider_call()


func change_menu(menu : String):
	current_menu = menu
	match(menu):
		"main":
			make_options(main_buttons)
		"game":
			make_options(game_buttons)
			where_to_go_back = "main"
		"controls":
			make_options(controls_buttons)
			where_to_go_back = "main"
		"audio":
			make_options(audio_buttons)
			where_to_go_back = "main"
		"controls_level":
			make_options(controls_level_buttons)
			where_to_go_back = "controls"
		"controls_menu":
			make_options(controls_menu_buttons)
			where_to_go_back = "controls"
		"controls_meta":
			make_options(controls_meta_buttons)
			where_to_go_back = "controls"


func select():
	match(buttons[cursor_row][0]):
		"back":
			if current_menu != "main":
				change_menu(where_to_go_back)
			else:
				parent.switch_menu("MAIN", "OPTIONS")
				$mainAnim.play("exit")
		"submenu":
			change_menu(buttons[cursor_row][1])
		"disabled":
			disabled_popup = true
		"checkbox":
			Global.options[buttons[cursor_row][2]] = !Global.options[buttons[cursor_row][2]]
			buttons[cursor_row][1].pressed = Global.options[buttons[cursor_row][2]]
		"slider":
			if slider == false:
				confirmation = true
				slider = true
				starting_slider_pos = buttons[cursor_row][1].value
				$slider_value.visible = true
				$slider_value.rect_position = cursor.position + Vector2(352, -20)
				$slider_value.text = String(buttons[cursor_row][1].value)
			else:
				Global.options[buttons[cursor_row][2]] = buttons[cursor_row][1].value
				end_slider()
		"enum":
			Global.options[buttons[cursor_row][2]] += 1
			if Global.options[buttons[cursor_row][2]] == buttons[cursor_row][3].size():
				Global.options[buttons[cursor_row][2]] = 0
			buttons[cursor_row][1].text = buttons[cursor_row][3][Global.options[buttons[cursor_row][2]]]
		"action":
			if buttons[cursor_row][2] and !confirmation:
				confirmation = true
				confirm_popup = true
			elif (buttons[cursor_row][2] and confirmation) or !buttons[cursor_row][2]:
				call(buttons[cursor_row][1])
				confirmation = false
				confirm_popup = false
		"globalaction":
			if buttons[cursor_row][2] and !confirmation:
				confirmation = true
				confirm_popup = true
			elif (buttons[cursor_row][2] and confirmation) or !buttons[cursor_row][2]:
				Global.call(buttons[cursor_row][1])
				confirmation = false
				confirm_popup = false
		"keybind":
			buttons[cursor_row][1].text = "???"
			confirmation = true
			keybinds = true


func slider_call():
	if buttons[cursor_row][3] != "":
		call(buttons[cursor_row][3], buttons[cursor_row][1].value)


func end_slider():
	confirmation = false
	slider = false
	$slider_value.visible = false
	slider_call()


func sfx_slider_update(value):
	pass


func music_slider_update(value):
	Audio.change_music_status(value)
