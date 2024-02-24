extends Node2D

onready var parent : Node2D = get_parent()

var line_lenght : int

func _ready():
	var credits = """SONIC RUNNER
	v2.0.0
	
	
	
	A game by
	HowDoesOneName
	aka
	Tabin
	
	
	
	- Lead Designer -
	Tabin
	
	- Lead Artist -
	Tabin
	
	- Lead Programmer -
	Tabin
	
	- Art Advisor -
	Lux
	
	- UI Roaster - 
	honestAndrew
	
	- Outline Shader -
	Juulpower
	
	
	
	- Development Tools -
	Godot
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
	(More to be added since i def forgot some)
	
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
	$back.text = "GO BACK - " + Global.key_names(13)

func _physics_process(_delta):
	$credits.rect_position.y -= 0.5
	if Input.is_action_pressed("menu_down"):
		$credits.rect_position.y -= 1.5
	
	if $credits.rect_position.y < -384 - line_lenght:
		$credits.rect_position.y = 384

func menu_update():
	if Input.is_action_just_pressed("deny"):
		parent.switch_menu("MAIN", "CREDITS")
		$mainAnim.play("exit")
