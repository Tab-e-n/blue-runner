extends Area2D


var player : Player


func _physics_process(_delta):
	if player:
		if player.should_jump():
			Audio.play_sound("GreenboxAttack")
			punt_player()


func force_boost():
	punt_player()


func punt_player():
	player.punt(Vector2(0, -1000), false)
	player = null


func _on_body_entered(body):
	if body is Player:
		player = body


func _on_body_exited(body):
	if body is Player:
		player = null
