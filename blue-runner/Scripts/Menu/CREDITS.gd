extends Node2D

onready var parent : Node2D = get_parent()

func _ready():
	$credits.text = """SONIC RUNNER
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
	(More to be added since i def forgot some)
	
	- Blue Runner Best Fan -
	Vitor
	
	
	
	- Special Thanks -
	Edmund McMillen
	Hakita
	
	
	
	Thanks for playing!
	:D"""

func _physics_process(delta):
	$credits.rect_position.y -= 0.5

func menu_update():
	if Input.is_action_just_pressed("deny"):
		parent.switch_menu("MAIN", "CREDITS")
		$mainAnim.play("exit")
