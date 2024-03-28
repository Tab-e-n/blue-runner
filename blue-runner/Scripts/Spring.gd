extends Area2D


const DISABLE_TIME : float = 0.2


var player : Player
var disable : float = 0


func _physics_process(delta):
	if player:
		if player.should_jump() and disable <= 0:
			Audio.play_sound("GreenboxAttack")
			punt_player()
	if disable > 0:
		disable -= delta


func apply_effect(_player : Player = player):
	player = _player
	if disable <= 0:
		punt_player()


func punt_player():
	player.punt(Vector2(0, -1000), false)
	player = null
	disable = DISABLE_TIME


func _on_body_entered(body):
	if body is Player:
		player = body


func _on_body_exited(body):
	if body is Player:
		player = null
