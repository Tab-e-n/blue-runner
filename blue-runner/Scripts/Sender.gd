extends Node2D


export var green : bool = false
export var start_delay : float = 1


onready var level : Node2D = get_tree().current_scene

var projectile : PackedScene = preload("res://Objects/April/Sended.tscn")

var timer_end : float = 1
var timer : float = 0


func _ready():
	if green:
		timer_end = 3
		$sprite.frame = 1
	else:
		timer_end = 6
	
	timer = timer_end - start_delay


func _physics_process(delta):
	if level.timers_active:
		timer += delta
		if timer > timer_end:
			var new_proj = projectile.instance()
			new_proj.position = position
			new_proj.green = green
			level.add_child(new_proj)
			timer = 0
