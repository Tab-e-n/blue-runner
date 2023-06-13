extends Node2D

onready var parent : Node2D = get_parent()

func menu_update():
	if Input.is_action_just_pressed("left"):
		$levels.position.x += 192
	if Input.is_action_just_pressed("right"):
		$levels.position.x -= 192
	if Input.is_action_just_pressed("up"):
		$levels.position.y += 128
	if Input.is_action_just_pressed("down"):
		$levels.position.y -= 128
