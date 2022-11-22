extends Node2D

export var world : int = 1
export var level : int = 0
export var level_name : String
export var level_symbol : Texture
export var locked : bool = false
export var level_normal : Texture
export var level_locked : Texture
export var level_done : Texture
export var level_perfect : Texture

var time : float = 0
var par : float = 0

func _ready():
	reload()

func _process(_delta):
	pass

func reload():
	$symbol.texture = level_symbol
	$icon.texture = level_normal
	$boltcollect.visible = false
	if locked:
		$icon.texture = level_locked
	elif $"/root/Global".level_completion.has(level_name): if $"/root/Global".level_completion[level_name][0] != null:
		time = $"/root/Global".level_completion[level_name][0]
		par = $"/root/Global".level_completion[level_name][1]
		
		$boltcollect/Anim.stop()
		if $"/root/Global".level_completion.has(String((world - 1) * 20 + level)):
			$boltcollect.visible = true
			$boltcollect/Anim.play("Idle")
		
		$icon.texture = level_done
		if time < par or par == 0:
			$icon.texture = level_perfect


