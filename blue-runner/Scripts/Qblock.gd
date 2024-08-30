extends StaticBody2D


export var hidden : bool = false


func _ready():
	$block.visible = not hidden
	$coll.set_deferred("disabled", hidden)


func _on_detect_body_entered(body):
	if body is Player and not $anim.is_playing():
		$anim.play("hit")
		Audio.play_sound("BirdUP")
		if hidden:
			Global.unlock("*mario_maker")
			$coll.set_deferred("disabled", false)


func _on_animation_finished(_anim_name):
	pass
#	$coll.set_deferred("disabled", hidden)
