extends Node2D


export var song : String = ""
export var stop_music : bool = false
export var fast_transition : bool = true


func _ready():
	Audio.change_music(song, stop_music, fast_transition)
	queue_free()
