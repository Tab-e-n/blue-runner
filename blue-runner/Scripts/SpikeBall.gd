extends StaticBody2D


export var stylish : bool = false


func _ready():
	$StylishCheck.monitoring = stylish
	$StylishCheck.monitorable = stylish
	if stylish:
		$spike.texture = preload("res://Visual/April/spr_MoveSpike_stylish.png")
		$StylishCheck.scale.y =  1 + 1.25 / scale.y
