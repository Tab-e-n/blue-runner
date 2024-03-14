extends StaticBody2D


export var icy : bool = false

var wait_time : float = 0

func _ready():
	if icy:
		$sprite.texture = preload("res://Visual/April/spr_FrozenGround.png")
		$sprite.hframes = 1
	else:
		var pos : int = 0 + int(position.x) * 2 + int(position.y) * 1
		pos = pos % 800
		wait_time = float(pos) * 0.001
	


func _process(delta):
	if not icy:
		if not $anim.is_playing():
			wait_time -= delta
			if wait_time <= 0:
				$anim.play("melt")
