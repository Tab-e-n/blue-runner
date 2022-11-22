extends Area2D

export var boost_strenght : int = 1200

var boost : Vector2 = Vector2(0, 0)

func _ready():
	boost.y = round(boost_strenght * cos(rotation) * -1)
	boost.x = round(boost_strenght * sin(rotation))

func _physics_process(delta):
	pass

func _on_Mushroom_body_entered(body):
	if body.name == "Player":
		body.punt(boost)
