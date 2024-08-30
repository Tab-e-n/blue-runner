extends Area2D


export(int, 1, 2) var half : int = 1

onready var unlock : String = "*half_a_car_" + String(half)

var collected : bool = false


func _ready():
	if Global.check_unlock(unlock):
		collected = true
		modulate = Color(0, 0, 0, 0.5)
	$Anim.play("Idle")


func _on_body_entered(body):
	if body.name == "Player":
		if !collected: 
			Global.unlock(unlock)
			if Global.check_unlock("*half_a_car_1") and Global.check_unlock("*half_a_car_2"):
				Global.unlock("*character_car")
		$Anim.play("Collect")
		set_deferred("monitoring", false)
		set_deferred("monitorable", false)
		Audio.play_sound("halfacar")
