extends Node2D

onready var global : Control = $"/root/Global"
onready var parent : Node2D = get_parent()

var selected_option : int = 4

var exit_confirmation : bool = false

var move_interupt : int = -1
onready var option_target_play : Node2D = $menu_button1
onready var option_target_replay : Node2D = $menu_button2
onready var option_target_option : Node2D = $menu_button3
onready var option_target_help : Node2D = $menu_button4
onready var option_target_exit : Node2D = $menu_button5

func _ready():
	pass

func _physics_process(_delta):
	$menu_circle.rotation += 0.001

func menu_update():
	if move_interupt >= 0:
		buttons_targets(move_interupt)
		move_interupt = -1
	
	if exit_confirmation:
		if Input.is_action_just_pressed("reset"): exit_confirmation = false
		if Input.is_action_just_pressed("special"): exit_confirmation = false
		if Input.is_action_just_pressed("up"): exit_confirmation = false
		if Input.is_action_just_pressed("down"): exit_confirmation = false
		if Input.is_action_just_pressed("jump") or Input.is_action_just_pressed("return"):
			global.save_game()
			get_tree().quit()
	if !exit_confirmation:
		if Input.is_action_just_pressed("return") and parent.get_node("AnimationPlayer").current_animation == "":
			exit_confirmation = true
		if Input.is_action_just_pressed("jump"):
			match(selected_option):
				0:
					exit_confirmation = true
				1:
					parent.get_node("AnimationPlayer").play("MAIN-REPLAY")
					parent.menu = "REPLAY"
					parent.move = true
				2:
					parent.get_node("AnimationPlayer").play("MAIN-OPTION")
					parent.menu = "OPTION"
					parent.move = true
				3:
					parent.get_node("AnimationPlayer").play("MAIN-HELP")
					parent.menu = "HELP"
					parent.move = true
				4:
					parent.get_node("AnimationPlayer").play("MAIN-SELECT")
					parent.menu = "SELECT"
					parent.move = true
		
		if Input.is_action_pressed("up") and parent.move:
			if $AnimationPlayer.current_animation != "StandBy":
				$AnimationPlayer.stop()
				move_interupt = selected_option
			selected_option -= 1
			if selected_option < 0: selected_option = 4
			$AnimationPlayer.play("Up")
		
		if Input.is_action_pressed("down") and parent.move:
			if $AnimationPlayer.current_animation != "StandBy":
				$AnimationPlayer.stop()
				move_interupt = selected_option
			selected_option += 1
			if selected_option > 4: selected_option = 0
			$AnimationPlayer.play("Down")
	
	if !$AnimationPlayer.is_playing():
		$AnimationPlayer.play("StandBy")
		buttons_targets(selected_option)
	else:
		update_button_text($menu_button_play, option_target_play)
		update_button_text($menu_button_replay, option_target_replay)
		update_button_text($menu_button_option, option_target_option)
		update_button_text($menu_button_help, option_target_help)
		update_button_text($menu_button_exit, option_target_exit)
	
	if $menu_confirmation.visible != exit_confirmation:
		if exit_confirmation: $menu_confirmation/AnimationPlayer.play("popup")
		else: $menu_confirmation/AnimationPlayer.play("popdown")

func update_button_text(text : Node2D, target : Node2D):
	text.position = target.position
	text.rotation_degrees = target.rotation_degrees
	text.scale = target.scale

func buttons_targets(_match):
	match _match:
		0:
			option_target_exit = $menu_button1
			option_target_play = $menu_button2
			option_target_option = $menu_button4
			option_target_help = $menu_button3
			option_target_replay = $menu_button5
		1:
			option_target_replay = $menu_button1
			option_target_exit = $menu_button2
			option_target_play = $menu_button3
			option_target_help = $menu_button4
			option_target_option = $menu_button5
		2:
			option_target_option = $menu_button1
			option_target_replay = $menu_button2
			option_target_exit = $menu_button3
			option_target_play = $menu_button4
			option_target_help = $menu_button5
		3:
			option_target_help = $menu_button1
			option_target_option = $menu_button2
			option_target_replay = $menu_button3
			option_target_exit = $menu_button4
			option_target_play = $menu_button5
		4:
			option_target_play = $menu_button1
			option_target_help = $menu_button2
			option_target_option = $menu_button3
			option_target_replay = $menu_button4
			option_target_exit = $menu_button5
