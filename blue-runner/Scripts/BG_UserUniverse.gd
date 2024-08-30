extends BG


func ready_up(camera : Node2D):
	if camera != null:
		start_position = camera.position
		
		scale = camera.zoom * 0.5
	$vis.modulate = bg_color


func update_self(cam_target : Vector2):
	position = cam_target
	
	for line in range(15):
		for i in range(2):
			# warning-ignore:integer_division
			get_node("vis/line_" + String(line)).points[i + 1].x = (int(start_position.x - position.x) % 384) * 0.25 + 512
		for i in range(2):
			get_node("vis/line_" + String(line)).points[i * 3].x = (int(start_position.x - position.x) % 384) * 0.4 + 64 + 64 * line
