extends BG


func ready_up(camera : Node2D):
	if camera != null:
		start_position = camera.position
		
		scale = camera.zoom
	
	$back.color = bg_color


func update_self(cam_target : Vector2):
	position = cam_target


