extends StaticBody2D


export var stylish : bool = false


func _ready():
	$StylishCheck.monitoring = stylish
	$StylishCheck.monitorable = stylish
	if stylish:
		$Sprite/Middle.color = Color("ff0080")
		$StylishCheck.scale.y = 1 + 1.25 / scale.y


func _physics_process(delta):
	$Sprite.rotation += 0.2
