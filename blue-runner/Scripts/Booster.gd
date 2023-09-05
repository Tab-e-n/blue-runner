extends Area2D

onready var level : Node2D = get_tree().current_scene

export var boost_strenght : int = 0
export var flip_direction : bool = false
var flip : float = 1
export var overwrite_momentum : bool = false

var boost : Vector2 = Vector2(0, 0)

var DISABLED_TIME : int = 42
var disabled_timer : int = 0

func _ready():
	if boost_strenght == 0:
		boost_strenght = 1200
	if flip_direction:
		flip = -1
	boost.x = round(boost_strenght * flip)
	$booster.flip_h = flip_direction
	$booster_effect.flip_h = flip_direction
	$booster_effect.position.x = 80 * flip

func _physics_process(_delta):
	monitoring = level.timers_active
	$CollisionShape2D.disabled = disabled_timer > 0
	if disabled_timer > 0:
		disabled_timer -= 1
		
		if (DISABLED_TIME - disabled_timer) < 12:
			$booster.position.x = (DISABLED_TIME - disabled_timer) * 16 * flip
		else:
			$booster.position.x = float(disabled_timer) / 30 * 160 * flip
		
		if (DISABLED_TIME - disabled_timer) < 20:
			# warning-ignore:integer_division
			$booster_effect.frame = (DISABLED_TIME - disabled_timer) / 2
		else:
			$booster_effect.frame = 0
	else:
		pass

func _on_Booster_body_entered(body):
	if body.name == "Player":
		body.punt(boost, overwrite_momentum)
		body.punted = false
		body.launched = false
		disabled_timer = DISABLED_TIME
