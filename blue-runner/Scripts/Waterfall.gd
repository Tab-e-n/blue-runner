extends Sprite

var rand : RandomNumberGenerator = RandomNumberGenerator.new()

export(float, 0, 1, 0.05) var advance : float = 0

func _ready():
	$Anim.play("Fall Normal")
	$Anim.advance(advance)

func _process(_delta):
	pass
