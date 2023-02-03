extends Sprite

var timer : int = 0

func _ready():
	pass

func _physics_process(_delta):
	timer += 1
	if timer == 3:
		if frame == 11: frame = 0
		else: frame += 1
		timer = 0
