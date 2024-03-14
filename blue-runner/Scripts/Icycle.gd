extends StaticBody2D


var wait_time : float = 0


func _ready():
	var pos : int = 0 + int(position.x) * 3 + int(position.y) * 5
	pos = pos % 80
	wait_time = float(pos) * 0.01


func _process(delta):
	if not $anim.is_playing():
		wait_time -= delta
		if wait_time <= 0:
			$anim.play("twinkle")
