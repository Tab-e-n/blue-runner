extends Node2D


export var text : String = "Nice!"


func _ready():
	scale = get_parent().get_node("Camera").zoom * Vector2(0.5, 0.5)
	$text.text = text


func _on_anim_animation_finished(anim_name):
	queue_free()
