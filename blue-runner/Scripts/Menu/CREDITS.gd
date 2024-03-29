extends Node2D


onready var parent : Node2D = get_parent()

export var end_credits : bool = false

var line_lenght : int


func _ready():
	if Global.playtesting:
		Global.change_level("*MENU")
		return
	
	var credits = """SONIC RUNNER
	v2.0.0
	
	
	
	A game by
	HowDoesOneName
	aka
	Tabin
	
	
	
	- Lead Designer -
	Tabin
	
	- Lead Art Director -
	Tabin
	
	- Lead Programmer -
	Tabin
	
	- Art Advisors -
	Maxpeeks
	Lux
	
	- UI Roaster - 
	honestAndrew
	
	- Outline Shader -
	Juulpower
	
	
	
	- Development Tools -
	Godot 3
	Gimp
	Audacity
	SoundBFXR
	FontForge
	GitHub
	
	
	
	- Playtesters -
	Lumir
	honestAndrew
	Lena-hal
	Sunny
	My Dad
	Simon Vladik
	That one girl from game club
	that played the game, you
	know who you are ;)
	
	- Blue Runner Best Fan -
	Vitor
	
	
	
	- Special Thanks -
	Edmund McMillen
	Hakita
	
	
	
	Thanks for playing!
	:D
	"""
	
	line_lenght = 32 * credits.count("\n")
#	print(line_lenght)
	
	$credits.text = credits
	if end_credits:
		$back.text = ""
	else:
		$back.text = "GO BACK - " + Global.key_names(13)


func _physics_process(_delta):
	$credits.rect_position.y -= 0.5
	if Input.is_action_pressed("menu_down"):
		$credits.rect_position.y -= 1.5
	
	if $credits.rect_position.y < -384 - line_lenght:
		if end_credits:
			exit_end_credits()
		else:
			$credits.rect_position.y = 384


func exit_end_credits():
	Global.select_menu = false
	Global.replay_menu = false
	Global.in_load_previously = true
	Global.change_level("*MENU")


func menu_update():
	if Input.is_action_just_pressed("deny"):
		parent.switch_menu("MAIN", "CREDITS")
		$mainAnim.play("exit")
