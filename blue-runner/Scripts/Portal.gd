extends Node2D

onready var level : Node2D = get_tree().current_scene

export var tele_destination : String = "*Menu_Level_Select"
export var par : float = 0

export(int, "XT9", "S1") var type = 0
export var unlock : String = ""

func _ready():
	call_deferred("_ready_deferred")
	
	# Pretty Portal Colors
	#$Visual/portal_1.modulate = Color(1,1,0,1)
	#$Visual/portal_2.modulate = Color(1,1,0,1)
	#$Visual/portal_3.modulate = Color(1,1,0,1)
	
	# Frame amount into minutes and seconds conversion
	#var temp : int = $"/root/Global".completion[portal_type]
	#var temp1 : int = temp%3600/60
	#var temp2 : int = temp%3600%60
	#$Text.text = String(temp/3600)+":"+String(temp1/10)+String(temp1%10)+"."+String(temp2/10)+String(temp2%10)

func _ready_deferred():
	if name == "Portal":
		$AnimationPlayer.current_animation = "Speen"
	if name == "Finish":
		if level.get_script() != null:
			if level.unicolor_active:
				material.set_shader_param("active", true)
		var player_character : String = get_parent().get_node("Player").character_name
		if (type == 0 or player_character == "S1") and player_character != "XT9":
			$Visual_XT9.visible = true
			$Visual_XT9/AnimationPlayer.current_animation = "Call"
			material.set_shader_param("color", Color(0.8, 0.43, 0.67))
		if (type == 1 or player_character == "XT9") and player_character != "S1":
			$Visual_S1.visible = true
			$Visual_S1/AnimationPlayer.current_animation = "Call"
			material.set_shader_param("color", Color(0.05, 0.9, 0.95))

func _process(_delta):
	if name == "Finish":
		scale.x = 1
		if get_parent().get_node("Player").position.x < position.x:
			scale.x = -1

func teleport(timer : float, collectible : Array, collectible_unlock : Array, recording : Dictionary):
	# warning-ignore:return_value_discarded
	Global.unlock(unlock)
	for i in collectible_unlock:
		Global.unlock(i)
	
	if name == "Portal":
		Global.save_game()
		
		if !Global.race_mode:
			Global.change_level(tele_destination)
		else:
			Global.change_level("")
	
	if name == "Finish":
		Global.save_game(timer, par, collectible, get_parent().name, recording)
		
		# Victory anim
		#if type == 0: $Visual_XT9/AnimationPlayer.current_animation = "Call"
		get_parent().get_node("Camera").end_zoom_in(self, tele_destination, timer, par)
