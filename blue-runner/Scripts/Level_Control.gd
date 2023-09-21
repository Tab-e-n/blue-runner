extends Node2D

export var unicolor_active : bool = false
var timers_active : bool = false
var player : Node2D

var dat : Dictionary

func _init():
	dat = Global.load_dat_file(Global.current_level_location + Global.current_level)

func _ready():
	pass
#	print("level ready")

#func _physics_process(_delta):
#	print(timer_active)
