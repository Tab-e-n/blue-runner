extends Node2D

var editor_properties : Dictionary = {
	"description" : "An external image.",
	"object_path" : "res://Objects/ExternalImage.tscn",
	"object_type" : "normal",
	"layer" : "selected",
	"rect" : Rect2(0, 0, 64, 64),
	"editable_properties" : {
		"texture_filename" : [TYPE_STRING, 0, 0, 0],
		"flip_h" : [TYPE_BOOL, 0, 0, 0],
		"flip_v" : [TYPE_BOOL, 0, 0, 0],
	},
	"unchangeable_properties" : {
		"scale" : false,
		"rotation" : false,
		"z_index" : false,
		"color" : false,
		"order" : false,
	},
	"attachable" : false,
}

var image : Image = Image.new()

export var texture_filename : String = ""
export var flip_h : bool = false
export var flip_v : bool = false

func editor_ready():
	reload()

func reload():
	for i in get_children():
		i.queue_free()
	
	var sprite : Sprite = Sprite.new()
	sprite.flip_h = flip_h
	sprite.flip_v = flip_v
	
	var level_location : String = get_tree().current_scene.level_path
	level_location = level_location.substr(0, level_location.find_last("/") + 1)
	
	print(level_location)
	
	if level_location == "user://SRLevels/" or level_location == "":
		sprite.texture = preload("res://Visual/no_image.png")
		add_child(sprite)
		return
	
	print(level_location + "Sprites/" + texture_filename)
	
	var pngf = File.new()
	if not pngf.file_exists(level_location + "Sprites/" + texture_filename):
		sprite.texture = preload("res://Visual/no_image.png")
		add_child(sprite)
		return
	
	pngf.open(level_location + "Sprites/" + texture_filename, File.READ)
	var pnglen = pngf.get_len()
	var pngdata = pngf.get_buffer(pnglen)
	pngf.close()
	
# warning-ignore:return_value_discarded
	image.load_png_from_buffer(pngdata)
	var image_texture : ImageTexture = ImageTexture.new()
	image_texture.create_from_image(image.get_rect(image.get_used_rect()))
	
	sprite.texture = image_texture
	
	if sprite.texture == null:
		sprite.texture = preload("res://Visual/no_image.png")
	add_child(sprite)

func edit_left_just_pressed(_mouse_pos, _cursor_pos, _level_scale):
	reload()
