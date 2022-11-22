extends Node2D

func start(type : int):# set_target : Node2D):
	if type == 0:
		$AnimationPlayer.play("Particle")
	else:
		$AnimationPlayer.play("Star")
		#target = set_target

#func _physics_process(_delta):
#	if type == 1:
#		position = target.position + Vector2(0, -128)
