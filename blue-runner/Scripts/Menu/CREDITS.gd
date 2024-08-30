extends Node2D


onready var parent : Node2D = get_parent()

export var end_credits : bool = false

var line_lenght : int

func _ready():
	if Global.playtesting:
		Global.change_level("*MENU")
		return
	
	line_lenght = 32 * $credits.text.count("\n")
#	print(line_lenght)
	
	$credits/S1X.visible = Global.check_unlock("*character_S1X")
	$credits/MXT9.visible = Global.check_unlock("*character_MXT9")
	$credits/Greenbox.visible = Global.check_unlock("*character_greenbox")
	$credits/Granddad.visible = Global.check_unlock("*character_granddad")
	$credits/car.visible = Global.check_unlock("*character_car")
	$credits/Disco.visible = Global.check_unlock("*groovy")
	
	if end_credits:
		$back.text = ""
		if Global.check_unlock("*end_credits"):
			Global.unlock("*character_S1X")
		if Global.check_unlock("*end_credits_2"):
			Global.unlock("*character_MXT9")
	else:
		$back.text = "GO BACK - " + Global.key_names(13)


func _physics_process(_delta):
	$credits.rect_position.y -= 0.5
	if Input.is_action_pressed("menu_down"):
		$credits.rect_position.y -= 1.5
	
	if $credits.rect_position.y < -384 - line_lenght:
		if end_credits:
			exit_end_credits()
		else:
			$credits.rect_position.y = 384


func exit_end_credits():
	Global.select_menu = false
	Global.replay_menu = false
	Global.in_load_previously = true
	Global.change_level("*MENU")


func menu_update():
	if Input.is_action_just_pressed("deny"):
		parent.switch_menu("MAIN", "CREDITS")
		$mainAnim.play("exit")
