extends Node2D

#var loaded_menu : PackedScene = preload("res://Scenes/MAIN.tscn")
var current_menu : Node2D

var hold : int = 0
var move : bool = true

var menu : String = "MAIN"

var return_delay : int = 2

func _ready():
	Global.replay = false
	Global.race_mode = false
	var _start : bool = true
	
	#print(current_menu.position)
	
	if _start or Global.replay_menu:
		
		if Global.replay_menu:
			menu = "REPLAY"
		else:
			#menu = "MAIN"
			menu = "SELECT"
	
	switch_menu(menu)
	
	#if Global.new_version_alert:
		#$NewVersionPopup.visible = true
		#Global.new_version_alert = false

func _process(_delta):
	if return_delay > 0: return_delay -= 1
	# MENU SWITCHING
	#if Input.is_action_just_pressed("deny") and $AnimationPlayer.current_animation == "" and menu != "MAIN" and return_delay == 0:
	#	match menu:
	#		"SELECT":
	#			$AnimationPlayer.play("SELECT-MAIN")
	#			menu = "MAIN"
	#		"CHARACTER":
	#			$AnimationPlayer.play("CHARACTER-SELECT")
	#			menu = "SELECT"
	#		"OPTION":
	#			pass
	#		"HELP":
	#			$AnimationPlayer.play("HELP-MAIN")
	#			menu = "MAIN"
	#		"REPLAY":
	#			$AnimationPlayer.play("REPLAY-MAIN")
	#			menu = "MAIN"
	#if $AnimationPlayer.current_animation != "ENTERING":
	#	$dim.color = Color(0.02, 0.02, 0.13, 0)
	#if $AnimationPlayer.current_animation == "MAIN-SELECT" and move == true:
	#	$SELECT.change_controls()
	
	
	# MENU INPUT
	if Input.is_action_just_pressed("menu_left") or Input.is_action_just_pressed("menu_right") or Input.is_action_just_pressed("menu_up") or Input.is_action_just_pressed("menu_down"):
		move = true
	
	if Input.is_action_pressed("menu_left") or Input.is_action_pressed("menu_right") or Input.is_action_pressed("menu_up") or Input.is_action_pressed("menu_down"):
		hold += 1
	else:
		hold = 0
	
	if hold >= 20:
		var hold_shift : int = 6
		if menu == "REPLAY": hold_shift = 9
		#if menu == "MAIN" or menu == "HELP" or menu == "CHARACTER": hold_shift = 10
		hold -= hold_shift
		move = true
	
	current_menu.menu_update()
	#match(menu):
	#	"SELECT":
	#		$SELECT.menu_update()
	#	"CHARACTER":
	#		$CHARACTER.menu_update()
	#	"MAIN":
	#		$MAIN.menu_update()
	#	"OPTION":
	#		$OPTION.menu_update()
	#	"HELP":
	#		$HELP.menu_update()
	#	"REPLAY":
	#		$REPLAY.menu_update()
	
	if move == true:
	#	$NewVersionPopup.visible = false
		move = false

func switch_menu(menu : String, comming_from : String = ""):
	var load_menu : PackedScene = load("res://Scenes/" + menu + ".tscn") 
	var new_menu = load_menu.instance()
	add_child(new_menu)
	current_menu = new_menu
	
	if current_menu.has_method("menu_ready"):
		current_menu.menu_ready(comming_from)
