extends Node2D

onready var global : Control = $"/root/Global"

var current_key : int = 0

func _ready():
	if !global.level_completion["*first_time_load"]:
		# warning-ignore:return_value_discarded
		get_tree().change_scene("res://Scenes/Menu_Level_Select.tscn")
	$t/anim.play("in")


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _input(event):
	if event is InputEventKey and event.pressed and $t/anim.current_animation != "in":
		if current_key < 8:
			global.change_input(current_key, event)
			current_key += 1
			$t/keys2.text = ""
			for i in range(current_key):
				$t/keys2.text += global.key_names(i)
				$t/keys2.text += "\n"
			if current_key < 8: $t/keys2.text += "???"
			else:
				global.level_completion["*first_time_load"] = false
				$t/anim.play("prompt")
		elif current_key == 8:
			current_key += 1
			$t/anim.play("out")

func anim_end():
	# warning-ignore:return_value_discarded
	get_tree().change_scene("res://Scenes/Menu_Level_Select.tscn")
