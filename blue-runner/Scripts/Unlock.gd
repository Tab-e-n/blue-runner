extends Node2D


signal going_away


var texture : Texture


func _input(event):
	if event is InputEventKey or event is InputEventJoypadButton:
		stop_existing()


func _ready():
	$unlock.texture = texture
	Global.scale_down_sprite($unlock, Vector2(1, 1), Vector2(512, 256))


func menu_update():
	pass


func stop_existing():
	if $anim.current_animation != "popup":
		$anim.play("hide")
#	print("stop")


func set_text(text : String):
	$text.text = text


func _on_animation_finished(anim_name):
	if anim_name == "hide":
		print("leaving")
		queue_free()
		emit_signal("going_away")
