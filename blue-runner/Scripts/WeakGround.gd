extends StaticBody2D


var break_active : bool = false
var break_position : Vector2

export var stability : int = 29

var crumbleling : bool = false


func _physics_process(_delta):
	if crumbleling:
		stability -= 1
	if stability == 0 or break_active:
		queue_free()
	
	$sprite.frame = stability * 0.5


func _on_player_check_entered(body):
	if body is Player:
		crumbleling = true


func _on_player_check_exited(body):
	if body is Player:
		crumbleling = false
