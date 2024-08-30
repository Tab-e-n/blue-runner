extends CPUParticles2D


const TIMER = 1.0


var timer = TIMER


func _ready():
	emitting = true
	if rotation != 0:
		direction = Vector2(1, 0).rotated(rotation) 
		rotation = 0


func _physics_process(delta):
	if timer > 0.0:
		timer -= delta
	else:
		queue_free()
