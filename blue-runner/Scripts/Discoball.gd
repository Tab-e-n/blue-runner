extends Node2D


export var disabled_hitbox : bool = false


func _ready():
	$Discoball.global_rotation = 0
	$light_point.visible = true
	if disabled_hitbox:
		$StylishCheck.set_deferred("monitoring", false)
		$StylishCheck.set_deferred("monitorable", false)


func _on_been_stylish():
	Global.unlock("*groovy")
