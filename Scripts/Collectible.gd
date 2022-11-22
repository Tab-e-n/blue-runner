extends Area2D

export var world : int = 1
export var level : int = 0


func _ready():
	if $"/root/Global".level_completion.has(String((world - 1) * 20 + level)):
		queue_free()
		pass
	$Anim.play("Idle")

func _process(_delta):
	pass

func _on_area_entered(area):
	if area.name == "Player":
		area.collectible = (world - 1) * 20 + level
		set_deferred("monitoring", false)
		set_deferred("monitorable", false)
		$Anim.play("Collect")
