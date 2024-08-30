extends BG


export var star_color : Color = Color(0.9, 0.9, 0.9)


func ready_up(camera : Node2D):
	if camera != null:
		start_position = camera.position
		
		scale = camera.zoom * 0.5
	
	for i in range(3):
		var stars : CPUParticles2D = get_node("stars" + String(i + 1))
		stars.emitting = true
		stars.self_modulate = star_color
	$back.color = bg_color


func update_self(cam_target : Vector2):
	position = cam_target
