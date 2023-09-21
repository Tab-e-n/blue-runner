extends Node2D

onready var parent : Node2D = get_parent()

func _ready():
	Global.options["*first_time_load"] = false
	$prompt.text = "Press\n" + Global.key_names(12) + "\nto start!"

func menu_update():
	if Input.is_action_just_pressed("accept"):
		parent.switch_menu("MAIN", "TITLE")
		queue_free()

func start_move_anim():
	$moveAnim.play("move")
