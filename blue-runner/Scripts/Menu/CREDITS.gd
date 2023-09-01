extends Node2D

func _ready():
	$credits.text = """SONIC RUNNER
	v2.0.0
	
	- Lead Designer -
	Tabin
	
	- Lead Artist -
	Tabin
	
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
	
	
	
	Thanks for playing!"""

func menu_update():
	$credits.rect_position.y -= 1
