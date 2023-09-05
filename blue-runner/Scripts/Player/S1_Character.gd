extends Node2D

onready var g : Control = $"/root/Global"
onready var player : KinematicBody2D = get_parent()
onready var trail_node : Line2D = player.get_node("trail")
onready var col_1 : Node2D = get_parent().get_node("col_1")
onready var col_2 : Node2D = get_parent().get_node("col_2")

export (PackedScene) var particle
var particle_disable : int = 0
export var particle_start : Color = Color(0.05, 0.9, 0.95, 1)
export var particle_end : Color = Color(0.13, 0.21, 0.38, 1)
export var particle_star : Color = Color(0.05, 0.9, 0.95, 1)

var gravity_up : int = 26
var gravity_down : int = 40
var gravity_switch = true
var gravity_wall_up : int = 13
var gravity_wall_down : int = 20

var jump_power : int = 800
var jump_amount_max = 1
var jump_amount = jump_amount_max

var max_speed : int = 850
var acceleration : int = 40
var deceleration : int = 50
var acc_dividor : int = 40

var sliding : int = 0
var force_slide : bool = false
var super_slide : bool = false
var dropping : int = 0
var saved_momentum : float = 0

var last_anim : String = "Default"
var state_air : int = 0
var wall_anim : int = 1
var last_facing : String

export var trail_color : Color = Color(1, 1, 1, 1)
var trail : PoolVector2Array = []
var trail_converted : PoolVector2Array = []
export var unicolor_color : Color = Color(1, 1, 1, 1)

export var idle_anim_timer : int = -1

func _ready():
	last_facing = player.facing
	
	$Anim.current_animation = "Enter"
	
	trail_node.visible = true
	trail_node.modulate = trail_color
	trail.resize(40)
	for i in range(trail.size()):
		trail[i] = player.position
	
	if !player.ghost:
		player.call_deferred("shader_color")

func _physics_process(_delta):
	col_1.position = $col_1.position
	col_1.scale = $col_1.scale
	col_1.disabled = !$col_1.visible
	
	col_2.position = $col_2.position
	col_2.scale = $col_2.scale
	col_2.disabled = !$col_2.visible
	
	if player.is_jump_input_just_pressed():
		player.jump_buffer = player.JUMP_BUFFER_FRAMES
	
	if player.start:
		if player.jump_buffer > 0:
			player.jump_buffer -= 1
		if Input.is_action_just_pressed("special"):
			sliding = 15
			player.play_sound("dash")
	if !player.deny_input:
		# GRAVITY / DECELERATION
		if player.is_on_ceiling(): player.momentum.y = 0
		
		var on_wall_right : bool = player.move_and_collide(Vector2(1,0), false, true, true) != null
		var on_wall_left : bool = player.move_and_collide(Vector2(-1,0), false, true, true) != null
		var on_wall : bool = on_wall_right or on_wall_left
		
		if (player.momentum.y > 0):
			gravity_switch = true
		if !on_wall:
			if !gravity_switch:
				player.momentum.y += gravity_up
			else:
				player.momentum.y += gravity_down
		else:
			if !gravity_switch:
				player.momentum.y += gravity_wall_up
			else:
				player.momentum.y += gravity_wall_down
		if player.state == "ground":
			player.ground_buffer = player.GROUND_BUFFER_FRAMES
			jump_amount = jump_amount_max
			if sign(player.momentum.x) != 0:
				var temp_momentum = sign(player.momentum.x)
				if !Input.is_action_pressed("right") and sign(player.momentum.x) == 1:
					player.momentum.x -= deceleration
				if !Input.is_action_pressed("left") and sign(player.momentum.x) == -1:
					player.momentum.x += deceleration
				if temp_momentum != sign(player.momentum.x):
					player.momentum.x = 0
			if player.momentum.x > -deceleration and player.momentum.x < deceleration and !(Input.is_action_pressed("left") or Input.is_action_pressed("right")):
				player.momentum.x = 0
			if !player.break_just_happened:
				if Input.is_action_pressed("special") and dropping > 0:
					sliding = 15
					if dropping == 1:
						super_slide = true
						player.play_sound("dropSlide")
					else:
						player.play_sound("dash")
				dropping = 0
			else:
				player.state = "air"
		if player.state == "air" and $Anim.current_animation != "Enter":
			sliding = 0
			#if is_on_ceiling() and dropping: sliding = dropping
		
		if (player.is_on_floor() or player.move_and_collide(Vector2(0,1), false, true, true)) and player.state != "air":
			player.momentum.y = 1
		else: player.state = "air"
		
		# MOVEMENT
		if Input.is_action_pressed("left") and sliding == 0 and dropping == 0:
			if player.momentum.x > -max_speed:
				player.momentum.x -= acceleration - round(player.momentum.x / acc_dividor)
			if dropping == 0 and !on_wall:
				player.facing = "left"
		if Input.is_action_pressed("right") and sliding == 0 and dropping == 0:
			if player.momentum.x < max_speed:
				player.momentum.x += acceleration - round(player.momentum.x / acc_dividor)
			if dropping == 0 and !on_wall:
				player.facing = "right"
		
		# SPECIAL ABILITIES
		if sliding > 0: sliding -= 1
		else: super_slide = false
		if dropping > 2: dropping -= 1
		
		if Input.is_action_just_pressed("special"):
			if player.state == "ground":
				sliding = 15
				player.play_sound("dash")
			else:
				dropping = 15
				saved_momentum = abs(player.momentum.x)
		if Input.is_action_pressed("special"):
			if player.state == "ground" and !on_wall:
				if sliding == 1: sliding = 2
			elif player.state == "air":
				if dropping == 2:
					player.play_sound("ding")
					dropping = 1
					particle_summon(Vector2(0, -64), 0, 1)
			if dropping > 0: player.break_breakables = true
			elif sliding > 0: player.break_breakables = false
		else:
			if dropping == 1: dropping = 2
			player.break_breakables = false
		
		force_slide = false
		if sliding > 0:
			if player.move_and_collide(Vector2(player.momentum.x, 0), false, true, true) and on_wall and sliding < 13:
				sliding = 0
			
			var facing_multiplier : int
			if player.facing == "left":
				facing_multiplier = -1
			if player.facing == "right":
				facing_multiplier = 1
			
			if super_slide and saved_momentum > max_speed * 1.35:
				player.momentum.x = saved_momentum * facing_multiplier
			elif super_slide:
				player.momentum.x = round(max_speed * 1.35) * facing_multiplier
			else:
				player.momentum.x = round(max_speed * 1.2) * facing_multiplier
			
			if player.move_and_collide(Vector2(0,-40), false, true, true) and !on_wall:
				sliding = 7
				force_slide = true
			
		if dropping > 0:
			if player.facing == "left":
				player.momentum.x = -round(max_speed * 0.5)
			if player.facing == "right":
				player.momentum.x = round(max_speed * 0.5)
			player.momentum.y += gravity_down
		
		# JUMPING
		if player.ground_buffer != 0:
			player.ground_buffer -= 1
		if player.ground_buffer == 1:
			jump_amount = jump_amount_max - 1
		
		if player.is_on_wall() and !player.punted:
			player.momentum.x = 0
			jump_amount = jump_amount_max - 1
		
		player.collision_mask = 3
		if player.jump_buffer > 0 and !force_slide:
			player.jump_buffer -= 1
			player.ground_buffer = 0
			if player.move_and_collide(Vector2(0,4), false, true, true) or sliding > 0:
				jump_amount -= 1
				jump(jump_power)
				player.jump_buffer = 0
				particle_summon(Vector2(0, 0), 0)
			elif player.move_and_collide(Vector2(4,0), false, true, true):
					jump_amount = jump_amount_max - 1
					# warning-ignore:integer_division
					player.momentum.x = -max_speed / 1.5
					player.facing = "left"
					# warning-ignore:narrowing_conversion
					jump(jump_power * 1.075)
					player.jump_buffer = 0
					particle_summon(Vector2(12, -64), -1.6)
			elif player.move_and_collide(Vector2(-4,0), false, true, true):
					jump_amount = jump_amount_max - 1
					# warning-ignore:integer_division
					player.momentum.x = max_speed / 1.5
					player.facing = "right"
					# warning-ignore:narrowing_conversion
					jump(jump_power * 1.075)
					player.jump_buffer = 0
					particle_summon(Vector2(-12, -64), 1.6)
		if jump_amount > 0 and player.jump_buffer == 1:
				jump_amount -= 1
				jump(jump_power)
				#player.jump_buffer = 0
		if !player.is_jump_input_pressed() and !gravity_switch and !player.punted and sliding == 0:
			gravity_switch = true
			if player.momentum.y < -200:
				player.momentum.y = -200
		
		# COLLISION / MOVING
		# warning-ignore:return_value_discarded
		player.move_player_character()
		
		if player.is_on_floor() or player.move_and_collide(Vector2(0,1), false, true, true):
			player.state = "ground"
		
		# ANIMATION
		scale = Vector2(0.5, 0.5)
		wall_anim = 1
		
		if sliding > 0:
			$Anim.current_animation = "Slide"
		elif player.state == "air":
			if dropping > 0:
				$Anim.current_animation = "Drop"
			elif on_wall:
				if (player.facing == "left" and on_wall_left) or (player.facing == "right" and on_wall_right):
					wall_anim = -1
				$Anim.current_animation = "On_Wall"
			elif player.launched or $Anim.current_animation == "Jump_Spin":# or (last_anim == "Jump_Spin" and player.momentum.y < 0):
				$Anim.current_animation = "Jump_Spin"
			elif last_anim == "Jump_Spin" and $Anim.current_animation == "":#last_anim == "Jump_Up" or last_anim == "On_Wall" or player.ground_buffer > 0:
				$Anim.play("Jump_Transition")
			elif player.is_jump_input_pressed() and !gravity_switch:
				$Anim.current_animation = "Jump_Up"
			elif last_anim != "Jump_Transition" and last_anim != "" and last_anim != "Jump_Spin":
				$Anim.play("Jump_Transition")
			
			if last_anim != "On_Wall" and $Anim.current_animation == "On_Wall":
				if particle_disable == 0:
					player.play_sound("land")
				if on_wall_left:
					particle_summon(Vector2(-12, -64), 1.6)
				if on_wall_right:
					particle_summon(Vector2(12, -64), -1.6)
		else:
			if state_air > 0:
				scale = Vector2(0.6, 0.4)
				state_air -= 1
			if state_air == 4:
				particle_summon(Vector2(0, 0), 0)
				player.play_sound("land")
			if player.momentum.x != 0 and !on_wall:
				if $Anim.current_animation != "Walk" or last_facing != player.facing:
					$Anim.stop()
					$Anim.current_animation = "Walk"
			else:
				if idle_anim_timer != 0:
					idle_anim_timer -= 1
				if idle_anim_timer == 0:
					var rand = g.rand.randi_range(1, 2)
					match(rand):
						1:
							$Anim.current_animation = "Idle_1"
						2:
							$Anim.current_animation = "Idle_2"
					idle_anim_timer -= 1
				elif($Anim.current_animation != "Default"
				and $Anim.current_animation != "Idle_1"
				and $Anim.current_animation != "Idle_2"
				and $Anim.current_animation != "Enter"):
					$Anim.current_animation = "Default"
					idle_anim_timer = 30 * g.rand.randi_range(7, 11)
		
		last_anim = $Anim.current_animation
		last_facing = player.facing
		
		if player.facing == "left":
			scale = Vector2(-0.5 * wall_anim, scale.y)
		else:
			scale = Vector2(0.5 * wall_anim, scale.y)
		
		if player.state == "air":
			state_air = 5
		if particle_disable != 0:
			particle_disable -= 1
	
	# - - - REPLAY STATE - - -
	elif player.replay and player.timer > player.replay_timer:
			scale = Vector2(scale.x, 0.5)
			
			$Anim.current_animation = ""
	
	# - - - DEATH STATE - - -
	elif player.dead:
		scale = Vector2(scale.x, 0.5)
		if $Anim.current_animation!="Death":
			player.play_sound("elExplose")
		$Anim.play("Death")
		
		
		#position.y -= (10 - player.death_wait) * 2
	
	# - - - IM DONE FOR STATE - - -
	elif player.end:
		scale = Vector2(scale.x, 0.5)
		
		$Anim.current_animation = ""
		if player.state == "ground":
			pass
			#$Anim.current_animation = "Concern"
	
	# Trail code
	for i in range(trail.size() - 1):
		trail[i] = trail[i+1]
	if $Anim.current_animation != "Slide":
		trail[trail.size() - 1] = player.position
		trail_node.position.y = -88
	else:
		trail[trail.size() - 1] = player.position + Vector2(0, 80)
		trail_node.position.y = -8
	
	trail_converted.resize(trail.size())
	
	trail_converted[trail.size() - 1] = Vector2(0, 0)
	
	for i in range(trail.size() - 1):
		var temp = trail[trail.size() - 2 - i] - trail[trail.size() - 1 - i]
		trail_converted[trail.size() - 2 - i] = trail_converted[trail.size() - 1 - i] + temp
	
	trail_node.points = trail_converted
	
	if $Anim.current_animation != "Enter":
		position.y = 0

#func _process(delta):
#	pass

func jump(local_jump_power : int):
	player.momentum.y = -local_jump_power
	player.state = "air"
	gravity_switch = false
	dropping = 0
	player.play_sound("jump")

func particle_summon(particle_position : Vector2, particle_rotation : float, type : int = 0):
	if particle_disable == 0:
		var node_creator
		node_creator = particle.instance()
		player.get_parent().add_child(node_creator)
		node_creator.position = player.position + particle_position
		node_creator.rotation = particle_rotation
		node_creator.color_start = particle_start
		node_creator.color_end = particle_end
		node_creator.color_star = particle_star
		node_creator.start(type)
		particle_disable = 6

func enter_anim_end():
	if !player.replay:
		player.start = false
		player.deny_input = false
