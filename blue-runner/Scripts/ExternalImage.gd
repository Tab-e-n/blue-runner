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
	
	Global.load_external_picture(level_location + "Sprites/" + texture_filename, sprite)
	
	add_child(sprite)