extends Area2D


export var style : String = "Nice!"


func _on_body_exited(body):
	if body is Player:
		body.been_stylish(style)
