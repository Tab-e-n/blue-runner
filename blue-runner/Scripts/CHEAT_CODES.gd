extends Node2D

onready var parent : Node2D = get_parent()

var current_key : int = 0

export var code_text : String = ""

func _ready():
	pass

func menu_update():
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

func move_cursor(move_amount : int):
	if sign(move_amount) == -1:
		if current_key == 37 and move_amount == -1:
			current_key = 36
		elif current_key == 37:
			current_key = 32
		elif current_key == 36:
			current_key = 30
		elif current_key + (move_amount - sign(move_amount)) >= 0:
			current_key += move_amount
	
	if sign(move_amount) == 1:
		if current_key + (move_amount - sign(move_amount)) < 36:
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
	elif code_text.length() < 16:
		code_text += key
	
	$code.bbcode_text = "[center]" + code_text + "[/center]"

func code_interpretor():
	$Anim.play("Success")
	match code_text:
		"GRANDDAD":
			$did_it.text = "GRANDDAD????????"
		"NULL":
			if !Global.check_unlock("*character_missing"):
				$did_it.text = "YOU GOT SOMETHING"
				Global.unlock("*character_missing")
			else:
				$did_it.text = "ALREADY GOT THIS"
		_:
			$Anim.stop()
			$Anim.play("Fail")
