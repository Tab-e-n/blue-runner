extends Area2D

export(int, 1, 3) var id : int = 1


func _ready():
	if $"/root/Global".level_completion["*collectibles"].has($"/root/Global".current_level + "*" + String(id)):
		queue_free()
		pass
	$Anim.play("Idle")

func _process(_delta):
	pass

func _on_area_entered(area):
	if area.name == "Player":
		area.collectible = $"/root/Global".current_level + "*" + String(id)
		set_deferred("monitoring", false)
		set_deferred("monitorable", false)
		$Anim.play("Collect")
