extends Area2D


signal been_stylish


export var style : String = "Nice!"


func _on_body_exited(body):
	if body is Player:
		body.been_stylish(style)
		emit_signal("been_stylish")
