extends Node2D

onready var parent : Node2D = get_parent()

export var unicolor_active : bool = false
var timers_active : bool = false
var player : Node2D

var dat : Dictionary = {
	"creator" : "Tabin",
	"dependencies" : [],
	"level_base" : ["base","res:/"],
	"level_icon" : ["H.png","res:/"],
	"level_name" : "HELP",
	"tags" : ["official"]
}

var current_tutorial : int = 1
const tutorials : Array = ["EXIT", "MOVING", "JUMPING", "SPECIAL", "GOAL", "BONUS", "TUTORIAL"]
const tutorial_text : Dictionary = {
	"EXIT" : "Press\n%deny%\nto leave this menu.",
	"MOVING" : "To move, use\n%left%\nand %right%.", 
	"JUMPING" : "To jump, use\n%jump%.\nYou can jump off of walls.", 
	"SPECIAL" : "To perform other actions, use\n%special%.", 
	"GOAL" : "You need to reach the other robot\nto win.", 
	"BONUS" : "There are bonus objectives on the way.\nThey aren't required to finish.",
	"TUTORIAL" : "Replay the tutorial?\n(%accept%)",
}

func _ready():
	$help_spiral_1.scale = Vector2(0, 0)
	$help_spiral_2.scale = Vector2(0, 0)
	$help_spiral_3.scale = Vector2(0, 0)
	$help_tv.scale = Vector2(0, 0)
	$arrow_left.self_modulate.a = 0
	$arrow_right.self_modulate.a = 0
	$Text.modulate.a = 0
	$Title.modulate.a = 0
	$Level.visible = false
	$mainAnim.play("Enter")
	
	$Title.bbcode_text = "[center]" + tutorials[current_tutorial] + "[/center]"
	set_tutorial()

func menu_update():
	if $mainAnim.current_animation != "Enter" and $mainAnim.current_animation != "Tutorial":
		if Input.is_action_just_pressed("deny"):
			parent.switch_menu("MAIN", "HELP")
			$mainAnim.play("Exit")
		if Input.is_action_pressed("menu_left") and parent.move and current_tutorial > 0:
			current_tutorial -= 1
			$Title.bbcode_text = "[center]" + tutorials[current_tutorial] + "[/center]"
			$mainAnim.stop()
			$mainAnim.play("Move")
		if Input.is_action_pressed("menu_right") and parent.move and current_tutorial < tutorials.size() - 1:
			current_tutorial += 1
			$Title.bbcode_text = "[center]" + tutorials[current_tutorial] + "[/center]"
			$mainAnim.stop()
			$mainAnim.play("Move")
		if Input.is_action_pressed("accept") and tutorials[current_tutorial] == "TUTORIAL":
			# *TUTORIAL* make it animate and change to actual tutorial level
			$mainAnim.play("Tutorial")
	$arrow_left.visible = current_tutorial != 0
	$arrow_right.visible = current_tutorial != tutorials.size() - 1

func _on_replay_looped(_player : Node2D = null):
	if not $mainAnim.is_playing():
		$mainAnim.play("Hide Replay")

func go_to_tutorial_level():
	Global.doing_tutorial = true
	Global.change_level("*res://Scenes/Tutorial.tscn")

func set_tutorial():
	var tut_name = tutorials[current_tutorial]
	$Text.bbcode_text = "[center]" + Global.text_interpretor(tutorial_text[tut_name]) + "[/center]"
	
	$Level/Wall.visible = false
	$Level/Pedestal.visible = false
	$Level/Finish.visible = false
	$Level/Collectible.visible = false
	$Level/Portal.visible = false
	match tut_name:
		"JUMPING":
			$Level/Wall.visible = true
		"GOAL":
			$Level/Pedestal.visible = true
			$Level/Finish.visible = true
		"BONUS":
			$Level/Collectible.visible = true
			$Level/Portal.visible = true
	
	if tut_name == "EXIT" or tut_name == "TUTORIAL":
		$mainAnim.play("Static")
		$Level.visible = false
		$help_tv/help_static.visible = true
	
	if Global.load_replay(tut_name, true, false, true):
		
		var recording : Dictionary = Global.load_replay(tut_name, false, false, true)
		$Level/Player.recording = recording.duplicate()
		$Level/Player.replay_timer = recording["timer"]
		$Level/Player.timer = 0
	else:
		pass
	$Level/Player.clear_trail_history()
