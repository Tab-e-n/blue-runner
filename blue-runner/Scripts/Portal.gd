extends Node2D

export var tele_destination : String = "res://Scenes/Menu_Level_Select.tscn"
export var par : float = 0

export(int, "XT9", "S1") var type = 0
export var unlock : String = ""

func _ready():
	if name == "Portal":
		$AnimationPlayer.current_animation = "Speen"
	if name == "Finish" and type == 0:
		$Visual_XT9.visible = true
		$Visual_XT9/AnimationPlayer.current_animation = "Call"
	if name == "Finish" and type == 1:
		$Visual_S1.visible = true
		$Visual_S1/AnimationPlayer.current_animation = "Call"
	
	# Pretty Portal Colors
	#$Visual/portal_1.modulate = Color(1,1,0,1)
	#$Visual/portal_2.modulate = Color(1,1,0,1)
	#$Visual/portal_3.modulate = Color(1,1,0,1)
	
	# Frame amount into minutes and seconds conversion
	#var temp : int = $"/root/Global".completion[portal_type]
	#var temp1 : int = temp%3600/60
	#var temp2 : int = temp%3600%60
	#$Text.text = String(temp/3600)+":"+String(temp1/10)+String(temp1%10)+"."+String(temp2/10)+String(temp2%10)

func _process(_delta):
	if name == "Finish":
		scale.x = 1
		if get_parent().get_node("Player").position.x < position.x:
			scale.x = -1

func teleport(timer : float, collectible : int):
	# warning-ignore:return_value_discarded
	if unlock != "": $"/root/Global".level_completion["*unlocked"][unlock] = true
	
	if name == "Portal":
		$"/root/Global".save_game()
		
		get_tree().change_scene(tele_destination)
	
	if name == "Finish":
		$"/root/Global".save_game(timer, par, collectible, get_parent().name, get_parent().get_node("Player").recording.duplicate())
		
		if type == 0: $Visual_XT9/AnimationPlayer.current_animation = "Call"
		get_parent().get_node("Camera").end_zoom_in(self, tele_destination, timer)
