extends BG


func ready_up(camera : Node2D):
	if camera != null:
		start_position = camera.position
		
		scale = camera.zoom * 0.5
	
	$back.color = darken_color(bg_color, 0.4)
	$bg_cave1.self_modulate = darken_color(bg_color, 0.6)
	$bg_cave2.self_modulate = darken_color(bg_color, 0.8)
	$bg_cave3.self_modulate = bg_color


func update_self(cam_target : Vector2):
	position = cam_target
	
	$bg_cave3.position.x = (start_position.x - position.x) * 0.2
	$bg_cave3.position.y = (start_position.y - position.y) * 0.05
	
	$bg_cave2.position.x = (start_position.x - position.x) * 0.1
	$bg_cave2.position.y = (start_position.y - position.y) * 0.025
	
	$bg_cave1.position.x = (start_position.x - position.x) * 0.05
	$bg_cave1.position.y = (start_position.y - position.y) * 0.0125

