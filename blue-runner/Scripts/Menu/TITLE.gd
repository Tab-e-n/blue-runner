extends Node2D

onready var parent : Node2D = get_parent()

var is_leaving : bool = false

func _ready():
#	Audio.play_music("caving-remix")
	Global.options["*first_time_load"] = false
	Global.in_load_previously = false
	$prompt.text = "Press\n" + Global.key_names(12) + "\nto start!"


func menu_update():
	if Input.is_action_just_pressed("accept"):
		is_leaving = true
	if is_leaving and !$anim.is_playing():
		$moveAnim.stop()
		$anim.play("Exit")


func switch_to_main():
	parent.switch_menu("MAIN", "TITLE")


func start_move_anim():
	$moveAnim.play("move")


func _on_moveAnim_animation_finished(_anim_name):
	if !is_leaving:
		$moveAnim.play("move")
