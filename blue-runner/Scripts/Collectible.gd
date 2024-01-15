extends Area2D

export(int, 1, 3) var id : int = 1
export var unlock : String = ""

export var decorative : bool = false

var collected : bool = false

func _ready():
	if decorative:
		monitoring = false
		monitorable = false
	if unlock != "":
		$collect.texture = preload("res://Visual/keycollect.png")
		if Global.check_unlock(unlock):
			collected = true
			modulate = Color(0, 0, 0, 0.5)
	elif !Global.level_completion["*collectibles"].has(Global.current_level_location):
		$Anim.play("Idle")
	elif Global.level_completion["*collectibles"][Global.current_level_location].has(Global.current_level + "*" + String(id)):
		collected = true
		modulate = Color(0, 0, 0, 0.5)
	else:
		$Anim.play("Idle")

func _process(_delta):
	pass

func _on_area_entered(area):
	if area.name == "Player":
		if !collected: 
			if unlock == "" and !area.collectibles.has(Global.current_level + "*" + String(id)):
				area.collectibles.append(Global.current_level + "*" + String(id))
			elif !area.unlocks.has(unlock):
				area.unlocks.append(unlock)
			$Anim.play("Collect")
		else:
			$Anim.play("Collect Alt")
		set_deferred("monitoring", false)
		set_deferred("monitorable", false)
