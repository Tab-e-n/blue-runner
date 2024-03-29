extends Node2D


onready var level : LevelControl = get_tree().current_scene


func _ready():
	if Global.playtesting and level is LevelControl:
		if level.player:
			level.player.position = position
	
	queue_free()
