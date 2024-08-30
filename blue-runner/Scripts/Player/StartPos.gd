extends Node2D


export var playtesting_required : bool = true

onready var level : LevelControl = get_tree().current_scene


func _ready():
	if (Global.playtesting or not playtesting_required) and level is LevelControl:
		if level.player:
			level.player.position = position
	
	queue_free()
