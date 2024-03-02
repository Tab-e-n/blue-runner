extends StaticBody2D


export var icy : bool = false


func _ready():
	if icy:
		$sprite.texture = preload("res://Visual/April/spr_FrozenGround.png")
		$sprite.hframes = 1
		$anim.stop()
