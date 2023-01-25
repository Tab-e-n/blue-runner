extends Area2D

export(int, 1, 3) var id : int = 1

var collected : bool = false

func _ready():
	if Global.level_completion["*collectibles"].has(Global.current_level_location + Global.current_level + "*" + String(id)):
		collected = true
		modulate = Color(0, 0, 0, 0.5)
		#queue_free()
	else:
		$Anim.play("Idle")

func _process(_delta):
	pass

func _on_area_entered(area):
	if area.name == "Player":
		if !collected: 
			area.collectible = Global.current_level_location + Global.current_level + "*" + String(id)
			$Anim.play("Collect")
		else:
			$Anim.play("Collect Alt")
		set_deferred("monitoring", false)
		set_deferred("monitorable", false)
