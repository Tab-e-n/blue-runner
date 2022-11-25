extends StaticBody2D

var break_active : bool = false

func _ready():
	pass

func _physics_process(_delta):
	if break_active:
		$CollisionShape2D.disabled = true
		$wekgrund.visible = false
		break_active = false
