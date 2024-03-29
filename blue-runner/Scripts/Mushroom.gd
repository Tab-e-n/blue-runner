extends Area2D

const DISABLE_TIME : float = 0.2

onready var level : Node2D = get_tree().current_scene

export var boost_strenght : int = 0
export var overwrite_momentum : bool = false

var boost : Vector2 = Vector2(0, 0)
var pause_timer : int = cos(position.x + position.y) * 100
var pause_timer_ticking : int = 0

var last_playback_speed : float = 0

var disable : float = 0
var boost_later : Player = null


func _ready():
	if level.unicolor_active:
		for i in range(5):
			get_node("mushroom_star" + String(i + 1)).modulate = Color.white
	if boost_strenght == 0:
		boost_strenght = int(scale.y * 1200)
	boost.y = round(boost_strenght * cos(rotation) * -1)
	boost.x = round(boost_strenght * sin(rotation))
	$anim.playback_speed += cos(position.x + position.y)
	
	if overwrite_momentum:
		$mushroom.texture = preload("res://Visual/mushroom_overwrite.png")
		for i in range(5):
			get_node("mushroom_star" + String(i + 1)).modulate = Color("7faf3c")
	


func _physics_process(delta):
	monitoring = level.timers_active
	if pause_timer_ticking == pause_timer:
		if $anim.current_animation != "Bounce":
			$anim.play("Glow")
		pause_timer_ticking += 1
	else:
		pause_timer_ticking += 1
	
	if disable > 0:
		disable -= delta
		if disable <= 0:
			if boost_later:
				boost_player(boost_later)
				boost_later = null

func bounce_start():
	last_playback_speed = $anim.playback_speed
	$anim.playback_speed = 1


func bounce_end():
	$anim.playback_speed = last_playback_speed
	$anim.stop()
	$anim.play("Glow")


func boost_player(body):
	body.punt(boost, overwrite_momentum)
	$anim.stop()
	$anim.play("Bounce")
	Audio.play_sound("MushBounce", 0.8, 1.2)
	disable = DISABLE_TIME


func _on_body_entered(body):
	if body is Player:
		if disable <= 0:
			boost_player(body)
		else:
			boost_later = body


func _on_body_exited(body):
	if body is Player:
		boost_later = null
