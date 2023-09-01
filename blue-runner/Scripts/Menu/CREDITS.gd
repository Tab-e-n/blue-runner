extends Node2D

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
	
	
	
	Thanks for playing!"""

func menu_update():
	$credits.rect_position.y -= 0.5
