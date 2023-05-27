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
var disabled : bool = false

var main_buttons : Array = [
	["GAME OPTIONS", "submenu", "game"],
	["CONTROLS", "submenu", "controls"],
	["AUDIO", "disabled", "audio"],
	["", "label"],
	["RESET OPTIONS", "globalaction", "reset_options", true],
]

var game_buttons : Array = [
	["OUTLINES", "checkbox", "*outlines_on"],
	["GHOSTS", "checkbox", "*ghosts_on"],
	["TIMER", "enum", "*timer_on", ["OFF", "ON", "LEVEL BEAT"]],
	["DELETE SAVE", "globalaction", "delete_save", true],
]

var controls_buttons : Array = [
	["=== LEVEL CONTROLS ===", "label"],
	["LEFT", "keybind", 0],
	["RIGHT", "keybind", 1],
	["UP", "keybind", 2],
	["DOWN", "keybind", 3],
	["JUMP", "keybind", 4],
	["SPECIAL", "keybind", 5],
	["RESET", "keybind", 6],
	["RETURN", "keybind", 7],
	["=== MENU CONTROLS ===", "label"],
	["LEFT", "keybind", 8],
	["RIGHT", "keybind", 9],
	["UP", "keybind", 10],
	["DOWN", "keybind", 11],
	["ACCEPT", "keybind", 12],
	["DENY", "keybind", 13],
]

var audio_buttons : Array = [
	["MAIN", "slider", ""],
	["SFX", "slider", ""],
	["MUSIC", "slider", ""],
]

func make_options(menu_buttons : Array):
	var section : int = 1
	var row : int = 0
	
	buttons.clear()
	cursor_positions.clear()
	cursor_row = 0
	
	for i in $buttons.get_children():
		i.queue_free()
	
	var section_position : Vector2 = Vector2(-576, -256)
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
				buttons.append(["slider"])
			"enum":
				var new_text = text.instance()
				new_text.rect_position = pos
				new_text.text = menu_buttons[i][3][Global.options[menu_buttons[i][2]]]
				$buttons.add_child(new_text)
				
				buttons.append(["enum", new_text, menu_buttons[i][2], menu_buttons[i][3]])
			"action":
				buttons.append(["action", menu_buttons[i][2], menu_buttons[i][3]])
			"globalaction":
				buttons.append(["globalaction", menu_buttons[i][2], menu_buttons[i][3]])
			"keybind":
				var new_text = text.instance()
				new_text.rect_position = pos
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

func _input(event):
	if event is InputEventKey:
		if event.pressed and keybinds:
			Global.change_input(buttons[cursor_row][2], event)
			buttons[cursor_row][1].text = Global.key_names(buttons[cursor_row][2])
			confirmation = false
		if event.pressed and confirm_popup:
			confirmation = false
		if event.pressed and disabled:
			disabled = false

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
	if Input.is_action_just_pressed("accept") and !keybinds:
		$cursor/anim.stop()
		$cursor/anim.play("Select")
		#select()
	if Input.is_action_just_pressed("deny") and !keybinds and !confirm_popup:
		if cursor_row != cursor_positions.size() - 1:
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
	$disabled.visible = disabled
	
	material.set_shader_param("offset", pulse_time)

func change_menu(menu : String):
	current_menu = menu
	match(menu):
		"main":
			make_options(main_buttons)
		"game":
			make_options(game_buttons)
		"controls":
			make_options(controls_buttons)
		"audio":
			make_options(audio_buttons)

func select():
	match(buttons[cursor_row][0]):
		"back":
			if current_menu != "main":
				change_menu("main")
			else:
				# RETURN TO MAIN MENU
				pass
		"submenu":
			change_menu(buttons[cursor_row][1])
		"disabled":
			disabled = true
		"checkbox":
			Global.options[buttons[cursor_row][2]] = !Global.options[buttons[cursor_row][2]]
			buttons[cursor_row][1].pressed = Global.options[buttons[cursor_row][2]]
		"slider":
			pass
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
