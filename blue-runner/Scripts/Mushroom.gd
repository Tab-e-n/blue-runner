extends Area2D

onready var level : Node2D = get_tree().current_scene

export var boost_strenght : int = 0
export var overwrite_momentum : bool = false

var boost : Vector2 = Vector2(0, 0)
var pause_timer : int = cos(position.x + position.y) * 100
var pause_timer_ticking : int = 0

var last_playback_speed : float = 0


func _ready():
	if boost_strenght == 0:
		boost_strenght = int(scale.y * 1200)
	boost.y = round(boost_strenght * cos(rotation) * -1)
	boost.x = round(boost_strenght * sin(rotation))
	$anim.playback_speed += cos(position.x + position.y)


func _physics_process(_delta):
	monitoring = level.timers_active
	if pause_timer_ticking == pause_timer:
		if $anim.current_animation != "Bounce":
			$anim.play("Glow")
		pause_timer_ticking += 1
	else:
		pause_timer_ticking += 1


func bounce_start():
	last_playback_speed = $anim.playback_speed
	$anim.playback_speed = 1


func bounce_end():
	$anim.playback_speed = last_playback_speed
	$anim.stop()
	$anim.play("Glow")


func _on_body_entered(body):
	if body.name == "Player":
		body.punt(boost, overwrite_momentum)
		$anim.stop()
		$anim.play("Bounce")
		Audio.play_sound("MushBounce", 0.8, 1.2)
