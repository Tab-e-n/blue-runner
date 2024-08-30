extends StaticBody2D


enum {ACTIVATE_ALWAYS, ACTIVATE_UNLOCK, ACTIVATE_NEVER}

const SPEED = 3.0


onready var level : LevelControl = get_tree().current_scene as LevelControl

var target : Node2D
var active : bool = false
export var activation_type : int = ACTIVATE_UNLOCK


func _ready():
	match(activation_type):
		ACTIVATE_ALWAYS:
			active = true
		ACTIVATE_UNLOCK:
			if Global.check_unlock("*last_bug"):
				active = true
			else:
				active = false
		ACTIVATE_NEVER:
			active = false
	call_deferred("set_target")


func set_target():
	if level:
		target = level.player


func _physics_process(_delta):
	if level.timers_active:
		var target_pos = target.position - Vector2(0, 32)
		if active:
			var direction : Vector2 = position.direction_to(target_pos)
			var distance : float = position.distance_to(target_pos)
			
			$visual.rotation = direction.angle()
			
			if distance > 1280:
				$visual/anim.stop()
			elif distance > 160:
				position += direction * SPEED
				$visual/anim.play("walk")
			else:
				$visual/anim.play("heart")
		else:
			if activation_type == ACTIVATE_UNLOCK:
				if position.distance_to(target_pos) < 192:
					active = true
					Global.unlock("*last_bug")
					play_sound()
			$visual/anim.stop()


func play_sound():
	Audio.play_sound("MiniBug", 0.8, 1.2)
