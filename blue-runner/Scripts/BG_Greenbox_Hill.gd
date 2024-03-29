extends BG


func ready_up(camera : Node2D):
	if camera != null:
		start_position = camera.position
		
		scale = camera.zoom * 0.5
	
	$back.color = bg_color
	$bg_clouds1.self_modulate = darken_color(bg_color, 0.8)
	$bg_clouds2.self_modulate = darken_color(bg_color, 0.6)
	$bg_clouds3.self_modulate = darken_color(bg_color, 0.4)
	$bg_mountains1.self_modulate = darken_color(bg_color, 0.8)
	$bg_mountains2.self_modulate = darken_color(bg_color, 0.6)


func update_self(cam_target : Vector2):
	position = cam_target
	
	$bg_clouds3.position.x = (start_position.x - position.x) * 0.2
	$bg_clouds3.position.y = (start_position.y - position.y) * 0.05 - 1728
	
	$bg_clouds2.position.x = (start_position.x - position.x) * 0.1
	$bg_clouds2.position.y = (start_position.y - position.y) * 0.025 - 1200
	$bg_mountains2.position = $bg_clouds2.position + Vector2(0, 1724)
	
	$bg_clouds1.position.x = (start_position.x - position.x) * 0.05
	$bg_clouds1.position.y = (start_position.y - position.y) * 0.0125 - 768
	$bg_mountains1.position = $bg_clouds1.position + Vector2(0, 1280)
