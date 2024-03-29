extends BG


export var hill_offset : Vector2 = Vector2(512, 512)
export var sun_position : Vector2 = Vector2(0, 0)


func ready_up(camera : Node2D):
	if camera != null:
		start_position = camera.position
		
		scale = camera.zoom * 0.5
	
	$back.color = Color(bg_color.r * 0.5, bg_color.g * 0.5, bg_color.b * 0.5, 1)
	$bg3.modulate = Color(bg_color.r, bg_color.g, bg_color.b, 1)
	$bg3/bg2.modulate = Color(bg_color.r, bg_color.g, bg_color.b, 1)
	$bg3/bg2/bg1.modulate = Color(bg_color.r, bg_color.g, bg_color.b, 1)
	
	$sun.position = sun_position


func update_self(cam_target : Vector2):
	position = cam_target
	
	$bg3.position.x = (start_position.x - position.x) * 0.25 + hill_offset.x
	$bg3.position.y = (start_position.y - position.y) * 0.125 + hill_offset.y
	
	$bg3/bg2.position.x = (start_position.x - position.x) * 0.0625 + -384
	$bg3/bg2.position.y = (start_position.y - position.y) * 0.03125 + 48
	
	$bg3/bg2/bg1.position.x = (start_position.x - position.x) * 0.0625 + -384
	$bg3/bg2/bg1.position.y = (start_position.y - position.y) * 0.03125 + 48

