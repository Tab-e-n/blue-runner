extends StaticBody2D



var wait_time : float = 0


func _ready():
	var pos : int = 0 + int(position.x) * 6 + int(position.y) * 2
	pos = pos % 80
	if pos < 0:
		pos = 80 + pos
	wait_time = float(pos) * 0.01


func _process(delta):
	if not $sprite/anim.is_playing():
		wait_time -= delta
		if wait_time <= 0:
			$sprite/anim.play("animate")

