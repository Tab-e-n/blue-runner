extends Node2D

onready var level : Node2D

export var is_finish : bool = true

export var tele_destination : String = "*Menu_Level_Select"
export var par : float = 0

export(int, "XT9", "S1") var type = 0
export var unlock : String = ""

export var silent_portal : bool = false

export var automatic_set_level_node : bool = true

var zoopaway : bool = false
var portal_zoopaway_timer : float = 0

func _ready():
	
	if automatic_set_level_node:
		level = get_tree().current_scene
	
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
	if not is_finish:
		$AnimationPlayer.current_animation = "Speen"
		
	if is_finish:
		if level.get_script() != null:
			if level.unicolor_active:
				material.set_shader_param("active", true)
		
		var player_character : String = get_parent().get_node("Player").character_name
		
		if (type == 0 or player_character == "S1") and player_character != "XT9":
			$Viewport/Visual_XT9.visible = true
			$Viewport/Visual_XT9/AnimationPlayer.current_animation = "Call"
			material.set_shader_param("color", Color(0.8, 0.43, 0.67))
		
		if (type == 1 or player_character == "XT9") and player_character != "S1":
			$Viewport/Visual_S1.visible = true
			$Viewport/Visual_S1/AnimationPlayer.current_animation = "Call"
			material.set_shader_param("color", Color(0.05, 0.9, 0.95))
		
		$Visual.texture = $Viewport.get_texture()
		
		material.set_shader_param("outline_active", Global.options["*outlines_on"])


func _process(delta):
	if is_finish:
		scale.x = 1
		if get_parent().get_node("Player").position.x < position.x:
			scale.x = -1
	if zoopaway: 
		portal_zoopaway_timer += delta
		$darkner.scale = Vector2(portal_zoopaway_timer * 8, portal_zoopaway_timer * 8) * level.get_node("Camera").zoom
		$darkner.rotation_degrees = -180 * portal_zoopaway_timer
		if portal_zoopaway_timer > 1:
			zoopaway = false
			level.get_node("Camera").start_fade_out(tele_destination)
#			if !Global.race_mode:
#				Global.change_level(tele_destination)
#			else:
#				Global.change_level("")


func teleport(timer : float, collectible : Array, collectible_unlock : Array, recording : Dictionary):
	# warning-ignore:return_value_discarded
	Global.unlock(unlock)
	for i in collectible_unlock:
		Global.unlock(i)
	
	
	if is_finish:
		Global.save_game(timer, par, collectible, level.name, recording)
		
		# Victory anim
		#if type == 0: $Visual_XT9/AnimationPlayer.current_animation = "Call"
		level.get_node("Camera").end_zoom_in(self, tele_destination, timer, par)
	else:
		if not silent_portal:
			Audio.play_sound("ZoopAway")
		Global.save_game()
		
		level.player.deny_input = true
		
		if silent_portal:
			zoopaway = false
			level.get_node("Camera").start_fade_out(tele_destination)
		else:
			zoopaway = true
			
			var new_sprite : Sprite = Sprite.new()
			
			new_sprite.name = "darkner"
			new_sprite.texture = load("res://Visual/Menu/help_spiral.png")
			new_sprite.scale = Vector2(0, 0)
			new_sprite.modulate = Color(0.2, 0.06, 0.03)
			new_sprite.z_as_relative = false
			new_sprite.z_index = 99
			
			add_child(new_sprite)
