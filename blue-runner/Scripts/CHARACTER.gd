extends Node2D

onready var global : Control = $"/root/Global"
onready var parent : Node2D = get_parent()

var selected_level

func menu_update():
	$back.text = global.key_names(7) + " - Go Back"
	
	if Input.is_action_just_pressed("jump"):
		global.current_level = selected_level
		# warning-ignore:return_value_discarded
		get_tree().change_scene("res://Scenes/" + selected_level + ".tscn")
