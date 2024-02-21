extends Node2D

onready var parent : Node2D = get_parent()

enum {MENU_TOP, MENU_PLAY, MENU_EXTRAS}
var current_menu : int = MENU_TOP

export var switch_time : float = 1

onready var submenus : Array = [$top, $sub/play, $sub/extras]

var unicolor_active : bool = true
var timers_active : bool = false
var player : Node2D

var dat : Dictionary


func _init():
	dat = Global.load_dat_file(Global.current_level_location + Global.current_level)


func _ready():
	pass

func menu_ready(comming_from : String = ""):
	$top.position.x = 736
	$sub.position.x = 736
	
	match(comming_from):
		"", "OPTIONS", "HELP":
			current_menu = MENU_TOP
			$mainAnim.play("enter_top")
		"SELECT", "VS", "REPLAY":
			current_menu = MENU_PLAY
			$mainAnim.play("enter_sub")
			$sub/play.visible = true
		"ACHIEVEMENTS", "CREDITS", "CHEAT_CODES":
			current_menu = MENU_EXTRAS
			$mainAnim.play("enter_sub")
			$sub/extras.visible = true
		"TITLE":
			current_menu = MENU_TOP
			$mainAnim.play("enter_title")
	match(comming_from):
		"OPTIONS":
			$top.reset(2)
		"HELP":
			$top.reset(4)
		"TITLE":
			$top.reset(1)
		"SELECT":
			$top.reset(1)
			$sub/play.reset(1)
		"REPLAY":
			$top.reset(1)
			$sub/play.reset(2)
		"VS":
			$top.reset(1)
			$sub/play.reset(3)
		"ACHIEVEMENTS":
			$top.reset(3)
			$sub/extras.reset(1)
		"CREDITS":
			$top.reset(3)
			$sub/extras.reset(2)
		"CHEAT_CODES":
			$top.reset(3)
			$sub/extras.reset(3)
	
	$Corridor/Level.color = $top.menu_colors[$top.current_button] * Color(0.5, 0.5, 0.5)

func _physics_process(_delta):
	$Disclaimer.visible = $sub/play.visible and $sub/play.current_button == 3 and !$mainAnim.is_playing()
	if $top/anim.is_playing():
		$Corridor/Level.color = $top.material.get_shader_param("color") * Color(0.5, 0.5, 0.5)


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
			$mainAnim.stop()
			$mainAnim.play("move_back")
		BUTTON_MENU_PLAY:
			current_menu = MENU_PLAY
			$mainAnim.stop()
			$mainAnim.play("move_next")
			$sub/play.visible = true
			$sub/play.reset()
		BUTTON_MENU_EXTRAS:
			current_menu = MENU_EXTRAS
			$mainAnim.stop()
			$mainAnim.play("move_next")
			$sub/extras.visible = true
			$sub/extras.reset()
		BUTTON_OPTIONS:
			parent.switch_menu("OPTIONS", "MAIN")
			$mainAnim.stop()
			$mainAnim.play("exit_top")
		BUTTON_HELP:
			parent.switch_menu("HELP", "MAIN")
			$mainAnim.stop()
			$mainAnim.play("exit_top")
		BUTTON_PLAY:
			parent.switch_menu("SELECT", "MAIN")
			$mainAnim.stop()
			$mainAnim.play("exit_sub")
		BUTTON_VS:
			print("incomplete")
		BUTTON_REPLAY:
			parent.switch_menu("REPLAY", "MAIN")
			$mainAnim.stop()
			$mainAnim.play("exit_sub")
		BUTTON_ACHIEVEMENTS:
			parent.switch_menu("ACHIEVEMENTS", "MAIN")
			$mainAnim.stop()
			$mainAnim.play("exit_sub")
		BUTTON_CREDITS:
			parent.switch_menu("CREDITS", "MAIN")
			$mainAnim.stop()
			$mainAnim.play("exit_sub")
		BUTTON_CHEATCODES:
			parent.switch_menu("CHEAT_CODES", "MAIN")
			$mainAnim.stop()
			$mainAnim.play("exit_sub")
		_:
			print("undefined")


func _on_replay_looped(_player : Node2D = null):
	$Corridor._on_replay_looped(_player)
