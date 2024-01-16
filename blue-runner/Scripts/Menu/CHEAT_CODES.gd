extends Node2D


const CODE_CHARACTER_LIMIT : int = 16


onready var parent : Node2D = get_parent()

var current_key : int = 0

export var code_text : String = ""

export var keyboard_anim_progress : float = 0


func _ready():
	$keyboard_outline.modulate.a = 0
	$keyboard/cursor.modulate.a = 0
	$code_outline.modulate.a = 0
	$fill.modulate.a = 0
	keyboard_anim_progress = 0
	keyboard_anim()
	$Anim.play("Enter")


func _physics_process(_delta):
	if $Anim.current_animation == "Enter" or $Anim.current_animation == "Exit":
		keyboard_anim()


func menu_update():
	if !$Anim.is_playing():
		if Input.is_action_pressed("menu_left") and parent.move:
			move_cursor(-1)
		if Input.is_action_pressed("menu_right") and parent.move:
			move_cursor(1)
		if Input.is_action_pressed("menu_up") and parent.move:
			move_cursor(-9)
		if Input.is_action_pressed("menu_down") and parent.move:
			move_cursor(9)
		
		if Input.is_action_just_pressed("accept"):
			add_character()
		if Input.is_action_just_pressed("deny"):
			parent.switch_menu("MAIN", "CHEAT_CODES")
			$Anim.play("Exit")


func move_cursor(move_amount : int):
	if sign(move_amount) == -1:
		if current_key == 37 and move_amount == -1:
			current_key = 36
		elif current_key == 37:
			current_key = 32
		elif current_key == 36:
			current_key = 30
		elif current_key + move_amount >= 0: # - sign(move_amount))
			current_key += move_amount
	
	if sign(move_amount) == 1:
		if current_key + move_amount < 36: # - sign(move_amount))
			current_key += move_amount
		elif current_key > 31:
			current_key = 37
		else:
			current_key = 36
	
	$keyboard/cursor.rect_position = $keyboard.get_children()[current_key].rect_position
	$keyboard/cursor.rect_size = $keyboard.get_children()[current_key].rect_size


func add_character():
	var key = $keyboard.get_children()[current_key].name
	if key == "enter":
		code_interpretor()
	elif key == "back":
		code_text = code_text.substr(0, code_text.length() - 1)
	elif code_text.length() < CODE_CHARACTER_LIMIT:
		code_text += key
	
	$code.bbcode_text = "[center]" + code_text + "[/center]"


func code_interpretor():
	$Anim.play("Success")
	$did_it.modulate = Color(0.25, 0.75, 0.5, 1)
	match code_text:
		"GRANDDAD":
			$did_it.text = "GRANDDAD????????"
		"NULL":
			show_unlock("*character_missing")
		"PLATFORMERKAT":
			show_unlock("*character_greenbox")
		"PLATTHEVIDEOGAME":
			$did_it.text = "\'KAT\' IS INTENCIONAL"
		"PLAT":
			$did_it.text = "\'KAT\' IS INTENCIONAL"
		"PLATKAT":
			$did_it.text = "CLOSE, BUT TOO SHORT"
		"TABIN":
			$did_it.text = "HEY, THATS ME!"
		_:
			$Anim.stop()
			$Anim.play("Fail")


func show_unlock(unlock : String, first_text : String = "YOU GOT SOMETHING", after_text : String = "ALREADY GOT THIS"):
	$did_it.modulate = Color(0.75, 0.5, 0.25, 1)
	if !Global.check_unlock(unlock):
		$did_it.text = first_text
		Global.unlock(unlock)
	else:
		$did_it.text = after_text


func keyboard_anim():
	for i in range($keyboard.get_child_count() - 1):
		var current : Control = $keyboard.get_child(i)
		var key_offset : float
		if i < 36:
			key_offset = (64 * float(i % 9))
		elif i == 36:
			key_offset = 128
		elif i == 37:
			key_offset = 288
		current.rect_position.x = -832 + (min(keyboard_anim_progress - (37 - i) * 0.05, 1) * 832) + key_offset
		
