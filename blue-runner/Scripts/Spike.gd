extends StaticBody2D

func _ready():
	#$AnimationPlayer.play("Spin")
	pass

func _physics_process(_delta):
	$saw_1.rotation_degrees += 6
	$saw_2.rotation_degrees -= 6
