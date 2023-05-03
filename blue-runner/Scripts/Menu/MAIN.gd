extends Node2D

onready var parent : Node2D = get_parent()

enum {MENU_TOP, MENU_PLAY, MENU_EXTRAS}
var current_menu : int = MENU_TOP

export var switch_time : float = 1

onready var submenus : Array = [$top, $sub/play, $sub/extras]

func _ready():
	pass
	#call_deferred("set_buttons", MENU_TOP)

func menu_update():
	var group : Node2D
	match(current_menu):
		MENU_TOP:
			group = $top
		MENU_PLAY:
			group = $sub/play
		MENU_EXTRAS:
			group = $sub/extras
	#$top.visible = current_menu == MENU_TOP
	if switch_time == 1:
		$sub/play.visible = current_menu == MENU_PLAY
		$sub/extras.visible = current_menu == MENU_EXTRAS
	
	if group.time == 1:
		group.last_on_exit = group.on_exit
		group.last_button = group.current_button
		group.idle = true
	if Input.is_action_pressed("menu_up") and parent.move and group.next_button > 1 and !group.on_exit:
		group.next_button -= 1
	if Input.is_action_pressed("menu_down") and parent.move and group.next_button < group.buttons_amount and !group.on_exit:
		group.next_button += 1
	if Input.is_action_pressed("menu_right") and parent.move:
		group.on_exit = true
	if Input.is_action_pressed("menu_left") and parent.move:
		group.on_exit = false
	if Input.is_action_just_pressed("deny"):
		if group.on_exit:
			accept(group)
		else:
			group.on_exit = true
	if Input.is_action_just_pressed("accept"):
		accept(group)
	for i in submenus:
		i.set_buttons()

enum {
	BUTTON_PASS, 
	BUTTON_EXIT, 
	BUTTON_MENU_TOP, 
	BUTTON_MENU_PLAY, 
	BUTTON_MENU_EXTRAS, 
	BUTTON_OPTIONS, 
	BUTTON_HELP, 
	BUTTON_PLAY, 
	BUTTON_VS, 
	BUTTON_REPLAY, 
	BUTTON_ACHIEVEMENTS, 
	BUTTON_CREDITS, 
	BUTTON_CHEATCODES
}
func accept(group : Node2D):
	var button : int = 0
	if !group.on_exit:
		button = group.next_button
	match(group.submenu[button]):
		BUTTON_PASS:
			print("pass")
		BUTTON_EXIT:
			get_tree().quit()
		BUTTON_MENU_TOP:
			current_menu = MENU_TOP
			$anim.play("move_back")
		BUTTON_MENU_PLAY:
			current_menu = MENU_PLAY
			$anim.play("move_next")
			$sub/play.visible = true
			$sub/play.reset()
		BUTTON_MENU_EXTRAS:
			current_menu = MENU_EXTRAS
			$anim.play("move_next")
			$sub/extras.visible = true
			$sub/extras.reset()
		BUTTON_OPTIONS:
			print("incomplete")
		BUTTON_HELP:
			print("incomplete")
		BUTTON_PLAY:
			print("incomplete")
		BUTTON_VS:
			print("incomplete")
		BUTTON_REPLAY:
			print("incomplete")
		BUTTON_ACHIEVEMENTS:
			print("incomplete")
		BUTTON_CREDITS:
			print("incomplete")
		BUTTON_CHEATCODES:
			print("incomplete")
		_:
			print("undefined")
