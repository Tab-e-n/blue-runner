extends Node2D

onready var global : Control = $"/root/Global"
onready var parent : Node2D = get_parent()

func menu_update():
	$back.text = global.key_names(7) + " - Go Back"
	
	if Input.is_action_just_pressed("jump"):
		Global.change_level("")
