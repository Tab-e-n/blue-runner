# thank you cak4_lover and Theraot
# however i found out that i'm stupid and didn't need this at all
tool
extends Sprite

export (Vector2) var img_size setget set_img_size
export (String) var img_path = "res://MergeImg.png"
export (bool) var generate_img = false setget set_generate_img

var ep_filesystem=EditorPlugin.new().get_editor_interface().get_resource_filesystem()

func set_img_size(new_val):
	img_size=new_val
	update()

func _draw():
	var origin_x=0
	var origin_y=0
	if(centered):
		origin_x=-img_size.x/2
		origin_y=-img_size.y/2
	print("Redrawing")
	draw_rect(Rect2(origin_x,origin_y,img_size.x,img_size.y), Color(0,200,0), false, 1.0)

func set_generate_img(new_val=true):
	if(not new_val):
		return
	
	var screenshot_viewport=Viewport.new()
	screenshot_viewport.size=img_size
	screenshot_viewport.hdr=false
	screenshot_viewport.transparent_bg=true
	screenshot_viewport.render_target_v_flip=true
	if(centered):
		screenshot_viewport.global_canvas_transform.origin=Vector2(img_size.x/2,img_size.y/2)
	
	for child in get_children():
		remove_child(child)
		screenshot_viewport.add_child(child)
	
	add_child(screenshot_viewport)
	
	screenshot_viewport.set_update_mode(Viewport.UPDATE_ONCE)
	yield(VisualServer,"frame_post_draw")
	
	var mergeImg=screenshot_viewport.get_texture().get_data()
	### unmultiplication ###
	mergeImg.lock()
	for y in mergeImg.get_size().y:
		for x in mergeImg.get_size().x:
			var color:Color = mergeImg.get_pixel(x, y)
			if color.a != 0:
				mergeImg.set_pixel(x, y, Color(color.r / color.a, color.g / color.a, color.b / color.a, color.a))
	mergeImg.unlock()
	###
	mergeImg.save_png(img_path)
	
	for child in screenshot_viewport.get_children():
		screenshot_viewport.remove_child(child)
		add_child(child)
		child.set_owner(get_tree().get_edited_scene_root())
	screenshot_viewport.queue_free()
	
	ep_filesystem.scan()
	yield(ep_filesystem,"filesystem_changed")
	
	texture=load(img_path)

func _init():
	self_modulate=Color("#74646464")
