extends Sprite

export var start_pos : int = -1280
export var end_pos : int = 1280

var b : bool = true


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.



func _process(_delta):
	
	b = !b
	
	if b: position.x += 1
	if position.x >= end_pos:
		position.x = start_pos
