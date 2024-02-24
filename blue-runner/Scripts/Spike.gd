extends StaticBody2D


export var stylish : bool = false


func _ready():
	$StylishCheck.monitoring = stylish
	$StylishCheck.monitorable = stylish
	if stylish:
		$saw_2.texture = preload("res://Visual/saw_3.png")
		$StylishCheck.scale.y =  1 + 1.25 / scale.y


func _physics_process(_delta):
	$saw_1.rotation_degrees += 6
	$saw_2.rotation_degrees -= 6
