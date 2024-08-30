extends Area2D


onready var Anim : AnimationPlayer = $AnimationPlayer


func play_sound(sound : String):
	Audio.play_sound(sound)


func _on_body_entered(body):
	if body is Player:
#		body.been_stylish("New Year!")
		Anim.play("Explode")
		Audio.play_sound("Boioioing")
		set_deferred("monitoring", false)
