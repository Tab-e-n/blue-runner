extends Node2D


export var trail_color : Color = Color(1, 1, 1, 1)
export var UNICOLOR_COLOR : Color = Color(1, 1, 1, 1)
const STYLISH_POSITION : Vector2 = Vector2(0, -60)
const STYLISH_RECT : Vector2 = Vector2(16, 60)

const GRAVITY_UP : int = 26
const GRAVITY_DOWN : int = 40
const GRAVITY_WALL_UP : int = 13
const GRAVITY_WALL_DOWN : int = 20
const JUMP_POWER : int = 800

const MAX_SPEED : int = 850
const ACCELERATION : int = 40
const DECELERATION : int = 50
const ACC_DIVIDOR : float = 0.025


var player : KinematicBody2D

export (PackedScene) var particle
export var particle_start : Color = Color(0.05, 0.9, 0.95, 1)
export var particle_end : Color = Color(0.13, 0.21, 0.38, 1)
export var particle_star : Color = Color(0.05, 0.9, 0.95, 1)
var particle_disable : int = 0

var jumping : bool = false
export var max_jump_amount : int = 1
var jump_amount : int = max_jump_amount

var sliding : int = 0
var force_slide : bool = false
var super_slide : bool = false
var dropping : int = 0
var saved_momentum : float = 0
var previous_speeds : Array = [0, 0, 0, 0]
var drop_grace_turn : bool = false

var last_anim : String = "Default"
var state_air : int = 0
var wall_anim : int = 1
var last_facing : String

export var idle_anim_timer : int = -1

func _ready():
	last_facing = player.facing
	
	$Anim.current_animation = "Enter"
	
	player.setup_trail(trail_color)
	
	# warning-ignore:return_value_discarded
	player.connect("boosted", self, "_on_boosted")


func _physics_process(_delta):
	save_speed_to_previous(player.momentum.x)
	
	player.collisions[1].position = $col_1.position
	player.collisions[1].scale = $col_1.scale
	player.collisions[1].disabled = !$col_1.visible
	
	player.collisions[2].position = $col_2.position
	player.collisions[2].scale = $col_2.scale
	player.collisions[2].disabled = !$col_2.visible
	
	if player.is_jump_input_just_pressed():
		player.start_jump_buffer()
	
	if Input.is_action_just_pressed("special"):
		player.start_special_buffer()
	
	if player.is_starting():
		player.decrement_jump_buffer()
		if player.should_special():
			player.special_buffer = 0
			sliding = 15
			player.play_sound("dash")
		
	if !player.deny_input:
		# GRAVITY / DECELERATION
		if player.is_on_ceiling():
			player.momentum.y = 0
		
		var on_wall_right : bool = player.move_and_collide(Vector2(3,0), false, true, true) != null
		var on_wall_left : bool = player.move_and_collide(Vector2(-3,0), false, true, true) != null
		var on_wall : bool = on_wall_right or on_wall_left
		
		if (player.momentum.y > 0):
			jumping = false
		if !on_wall:
			if jumping:
				player.momentum.y += GRAVITY_UP
			else:
				player.momentum.y += GRAVITY_DOWN
		else:
			if jumping:
				player.momentum.y += GRAVITY_WALL_UP
			else:
				player.momentum.y += GRAVITY_WALL_DOWN
		if player.state == "ground":
			player.start_ground_buffer()
			jump_amount = max_jump_amount
			
			if player.momentum.x != 0:
				var previous_direction : float = sign(player.momentum.x)
				var held_direction = player.get_horizontal_axis()
				
				if held_direction != previous_direction:
					player.momentum.x -= DECELERATION * previous_direction
				
				if previous_direction != sign(player.momentum.x):
					player.momentum.x = 0
			
			if player.momentum.x > -DECELERATION and player.momentum.x < DECELERATION and not player.get_horizontal_axis():
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
		else:
			player.state = "air"
		
		# MOVEMENT
		if player.get_horizontal_axis() and sliding == 0 and dropping == 0:
			if player.below_max_speed(player.momentum.x, player.get_horizontal_axis(), MAX_SPEED):
				player.momentum.x += (ACCELERATION - round(player.momentum.x * ACC_DIVIDOR)) * player.get_horizontal_axis()
				if sign(player.momentum.x) == player.get_horizontal_axis():
					player.cap_momentum_x(MAX_SPEED)
			if !on_wall:
				player.face_towards(player.get_horizontal_axis())
		
		# SPECIAL ABILITIES
		if sliding > 0:
			sliding -= 1
		else:
			super_slide = false
		if dropping > 2:
			dropping -= 1
		
		if Input.is_action_just_pressed("special"):
			if player.state == "ground":
				player.special_buffer = 0
				sliding = 15
				player.play_sound("dash")
			else:
				if dropping == 0:
					drop_grace_turn = true
				else:
					drop_grace_turn = false
				dropping = 15
				saved_momentum = abs(fastest_previous_speed())
			
		if player.special_buffer == 1 and dropping > 0 and drop_grace_turn:
			player.face_towards(player.get_horizontal_axis())
		if player.should_special():
			player.decrement_special_buffer()
		
		if Input.is_action_pressed("special"):
			if player.state == "ground" and !on_wall:
				if sliding == 1:
					sliding = 2
			elif player.state == "air":
				if dropping == 2:
					player.play_sound("ding")
					dropping = 1
					particle_summon(Vector2(0, -64), 0, 1)
			if dropping > 0: 
				player.break_breakables = true
			elif sliding > 0: 
				player.break_breakables = false
		else:
			if dropping == 1: 
				dropping = 2
			if player.punted and dropping > 0:
				dropping = 0
			player.break_breakables = false
		
		force_slide = false
		if sliding > 0:
			if player.move_and_collide(Vector2(player.momentum.x, 0), false, true, true) and on_wall and sliding < 13:
				sliding = 0
			
			var facing_multiplier : int = player.get_facing_axis()
			
			if super_slide and saved_momentum > MAX_SPEED * 1.35:
				player.momentum.x = saved_momentum * facing_multiplier
			elif super_slide:
				player.momentum.x = round(MAX_SPEED * 1.35) * facing_multiplier
			else:
				player.momentum.x = round(MAX_SPEED * 1.2) * facing_multiplier
			
			if player.move_and_collide(Vector2(0,-40), false, true, true) and !on_wall:
				sliding = 7
				force_slide = true
			
		if dropping > 0:
			player.momentum.x = round(MAX_SPEED * 0.5) * player.get_facing_axis()
			player.momentum.y += GRAVITY_DOWN
		
		# JUMPING
		player.decrement_ground_buffer()
		if player.ground_buffer == 1:
			jump_amount = max_jump_amount - 1
		
		if player.is_on_wall() and !player.punted:
			player.momentum.x = 0
			jump_amount = max_jump_amount - 1
		
		player.collision_mask = 0b11
		
		if player.should_jump() and !force_slide:
			player.decrement_jump_buffer()
			player.ground_buffer = 0
			if player.move_and_collide(Vector2(0,4), false, true, true) or sliding > 0:
				jump_amount = max_jump_amount - 1
				jump(JUMP_POWER)
				particle_summon(Vector2(0, 0), 0)
			elif player.move_and_collide(Vector2(4,0), false, true, true):
				jump_amount = max_jump_amount - 1
				player.momentum.x = int(-MAX_SPEED * 0.66)
				player.facing = "left"
				# warning-ignore:narrowing_conversion
				jump(JUMP_POWER * 1.075)
				particle_summon(Vector2(12, -64), -1.6)
			elif player.move_and_collide(Vector2(-4,0), false, true, true):
				jump_amount = max_jump_amount - 1
				player.momentum.x = int(MAX_SPEED * 0.66)
				player.facing = "right"
				# warning-ignore:narrowing_conversion
				jump(JUMP_POWER * 1.075)
				particle_summon(Vector2(-12, -64), 1.6)
		
		if jump_amount > 0 and player.jump_buffer == 1:
			jump_amount -= 1
			jump(JUMP_POWER)
			#player.jump_buffer = 0
		
		if !player.is_jump_input_pressed() and jumping and !player.punted and sliding == 0:
			jumping = false
			if player.momentum.y < player.extra_momentum.y - 200:
				player.momentum.y = player.extra_momentum.y - 200
		
		# COLLISION / MOVING
		# warning-ignore:return_value_discarded
		player.move_player_character()
		
		if player.is_on_floor() or (player.move_and_collide(Vector2(0,1), false, true, true) and dropping == 0):
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
			elif player.is_jump_input_pressed() and jumping:
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
				scale = Vector2(0.6 * player.get_facing_axis(), 0.4)
				state_air -= 1
			if state_air == 4:
				particle_summon(Vector2(0, 0), 0)
				player.play_sound("land")
			if (player.momentum.x != 0 or player.get_horizontal_axis()) and !on_wall:
				if $Anim.current_animation != "Walk" or last_facing != player.facing:
					$Anim.stop()
					$Anim.current_animation = "Walk"
			else:
				if idle_anim_timer != 0:
					idle_anim_timer -= 1
				if idle_anim_timer == 0:
					var rand = Global.rand.randi_range(1, 2)
					match(rand):
						1:
							$Anim.current_animation = "Idle_1"
						2:
							$Anim.current_animation = "Idle_2"
					idle_anim_timer -= 1
				elif not $Anim.current_animation in ["Default", "Idle_1", "Idle_2", "Enter"]:
					$Anim.current_animation = "Default"
					idle_anim_timer = 30 * Global.rand.randi_range(7, 11)
		
		last_anim = $Anim.current_animation
		last_facing = player.facing
		
		if state_air == 0 or player.state == "air" or sliding > 0:
			scale = Vector2(0.5 * wall_anim * player.get_facing_axis(), scale.y)
		
		if player.state == "air":
			state_air = 5
		if particle_disable != 0:
			particle_disable -= 1
	
	# - - - END OF REPLAY - - -
	elif player.replay and player.timer > player.replay_timer:
		scale = Vector2(scale.x, 0.5)
		
		$Anim.current_animation = ""
	
	# - - - DEATH STATE - - -
	elif player.dead:
		scale = Vector2(0.5 * player.get_facing_axis(), 0.5)
		if $Anim.current_animation != "Death":
			player.play_sound("elExplose")
			$Anim.play("Death")
	
	# - - - IM DONE FOR STATE - - -
	elif player.end:
		scale = Vector2(scale.x, 0.5)
		
		$Anim.current_animation = ""
		if player.state == "ground":
			pass
			#$Anim.current_animation = "Concern"
	
	# Trail code
	if $Anim.current_animation != "Slide":
		player.animate_trail(Vector2(0, -88))
	else:
		player.animate_trail(Vector2(0, -8), Vector2(0, 80))
#
#	if $Anim.current_animation != "Enter":
#		position.y = 0

#func _process(delta):
#	pass

func jump(jump_power : int):
	player.jump(jump_power)
	jumping = true
	dropping = 0
	player.play_sound("jump")
	player.extra_momentum = Vector2(0, 0)


func particle_summon(particle_position : Vector2, particle_rotation : float, type : int = 0):
	if particle_disable == 0:
		var new_particle
		new_particle = particle.instance()
		get_tree().current_scene.add_child(new_particle)
		new_particle.position = player.position + particle_position
		new_particle.rotation = particle_rotation
		new_particle.color_start = particle_start
		new_particle.color_end = particle_end
		new_particle.color_star = particle_star
		new_particle.z_index = player.z_index + 1
		new_particle.start(type)
		particle_disable = 6


func _on_boosted(boost):
	if sliding > 0:
		saved_momentum = player.momentum.x + boost.x
		super_slide = true


func enter_anim_end():
	player.enter_anim_end()


func save_speed_to_previous(speed : float):
	for i in range(previous_speeds.size() - 1):
		previous_speeds[i + 1] = previous_speeds[i]
	previous_speeds[0] = speed


func fastest_previous_speed() -> float:
	var speed = 0
	for i in range(previous_speeds.size()):
		if abs(previous_speeds[i]) > abs(speed):
			speed = previous_speeds[i]
	return speed
