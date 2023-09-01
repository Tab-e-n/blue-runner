extends Node2D

var image : Image = Image.new()

export var texture_filename : String = ""
export var flip_h : bool = false
export var flip_v : bool = false

func _ready():
	reload()

func reload():
	for i in get_children():
		i.queue_free()
	
	var sprite : Sprite = Sprite.new()
	sprite.flip_h = flip_h
	sprite.flip_v = flip_v
	
	var level_location : String = Global.current_level_location
	
	if level_location == "user://SRLevels/" or level_location == "":
		sprite.texture = preload("res://Visual/no_image.png")
		add_child(sprite)
		return
	
	var pngf = File.new()
	if not pngf.file_exists(level_location + "Sprites/" + texture_filename):
		sprite.texture = preload("res://Visual/no_image.png")
		add_child(sprite)
		return
	
	pngf.open(level_location + "Sprites/" + texture_filename, File.READ)
	var pnglen = pngf.get_len()
	var pngdata = pngf.get_buffer(pnglen)
	pngf.close()
	
	image.load_png_from_buffer(pngdata)
	var image_texture : ImageTexture = ImageTexture.new()
	image_texture.create_from_image(image.get_rect(image.get_used_rect()))
	
	sprite.texture = image_texture
	
	if sprite.texture == null:
		sprite.texture = preload("res://Visual/no_image.png")
	add_child(sprite)
