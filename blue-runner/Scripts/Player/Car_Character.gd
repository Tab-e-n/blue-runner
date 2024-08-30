extends Node2D


const UNICOLOR_COLOR : Color = Color("76d8ed")
const STYLISH_POSITION : Vector2 = Vector2(0, -12)
const STYLISH_RECT : Vector2 = Vector2(96, 24)

const GRAVITY : int = 50
const JUMP_POWER : int = 1400

var MAX_SPEED : int = 1200
var ACCELERATION : int = 40
var DECELERATION : int = 40
var AIR_MAX_SPEED : int = 800
var AIR_ACCELERATION : int = 20

var player : Player


var can_jump : bool = true
var jumping : bool = false

onready var last_position : Vector2 = player.position

func _ready():
	$Anim.current_animation = "Enter"
	player.play_sound("honkhonk")


func _physics_process(_delta):
	if player.is_jump_input_just_pressed():
		player.start_jump_buffer()
	
	if player.is_starting():
		player.decrement_jump_buffer()
		
	if !player.deny_input:
		
		player.collisions[1].position = $col_1.position
		player.collisions[1].disabled = !$col_1.visible
		player.collisions[1].scale = $col_1.scale
		
		var on_wall_right : bool = player.move_and_collide(Vector2(1,0), false, true, true) != null
		var on_wall_left : bool = player.move_and_collide(Vector2(-1,0), false, true, true) != null
		var on_wall : bool = on_wall_right or on_wall_left
		
		player.momentum.y += GRAVITY
		
		if (player.momentum.y > 0):
			jumping = false
		
		if player.state == "ground":
			player.start_ground_buffer()
			can_jump = true
			
			if player.momentum.x != 0:
				var previous_direction : float = sign(player.momentum.x)
				var held_direction = player.get_horizontal_axis()
				
				if held_direction != previous_direction:
					player.momentum.x -= DECELERATION * previous_direction
				
				if previous_direction != sign(player.momentum.x):
					player.momentum.x = 0
		
		if (player.is_on_floor() or player.move_and_collide(Vector2(0,1), false, true, true)) and player.state != "air":
			player.momentum.y = 1
		else:
			player.state = "air"
		
		if on_wall and player.momentum.x != 0:
			player.momentum.x = 0
		
		if player.get_horizontal_axis():
			var acceleration = ACCELERATION
			var max_speed = MAX_SPEED
			if player.state == "air":
				acceleration = AIR_ACCELERATION
				max_speed = AIR_MAX_SPEED
				
			if player.below_max_speed(player.momentum.x, player.get_horizontal_axis(), max_speed):
				player.momentum.x += acceleration * player.get_horizontal_axis()
			
			if !on_wall:
				if player.get_horizontal_axis() == -1:
					player.facing = "left"
				if player.get_horizontal_axis() == 1:
					player.facing = "right"
		
		player.break_breakables = player.state == "air"
		
		player.decrement_ground_buffer()
		if player.ground_buffer == 1:
			can_jump = false
		
		player.collision_mask = 0b11
		
		if player.is_on_ceiling():
			player.momentum.y = 0
		
		if player.should_jump():
			player.decrement_jump_buffer()
			player.ground_buffer = 0
			
			if player.move_and_collide(Vector2(0,4), false, true, true) or player.ground_buffer > 0:
				player.jump(JUMP_POWER)
				jumping = true
				player.play_sound("GreenboxJump")
			elif player.move_and_collide(Vector2(4,0), false, true, true):
				player.momentum.x = int(-MAX_SPEED * 0.4)
				player.facing = "left"
				# warning-ignore:narrowing_conversion
				player.jump(JUMP_POWER * 0.75)
				jumping = true
				player.play_sound("GreenboxJump")
			elif player.move_and_collide(Vector2(-4,0), false, true, true):
				player.momentum.x = int(MAX_SPEED * 0.4)
				player.facing = "right"
				# warning-ignore:narrowing_conversion
				player.jump(JUMP_POWER * 0.75)
				jumping = true
				player.play_sound("GreenboxJump")
		
		if !player.is_jump_input_pressed() and jumping and !player.punted:
			jumping = false
			if player.momentum.y < -200:
				player.momentum.y = -200
		
		player.move_player_character()
		
		if player.is_on_floor() or player.move_and_collide(Vector2(0,1), false, true, true):
			player.state = "ground"
		
		scale.y = 1
		if player.facing == "left":
			scale.x = -1
		if player.facing == "right":
			scale.x = 1
		
		if player.state == "air":
			if $Anim.current_animation != "Air":
				$Anim.play("Air")
		else:
			var sign_momentum = sign(player.momentum.x)
			if sign_momentum == 0:
				$Anim.play("Stand")
			else:
				$Anim.play("Moving")
		
	elif player.replay and player.timer > player.replay_timer:
		$Anim.current_animation = ""
		
	elif player.dead:
		if $Anim.current_animation != "Death":
			player.play_sound("cardeath")
		$Anim.play("Death")
		
		scale.y = 1
	elif player.end:
		$Anim.current_animation = ""
		
	elif player.deny_input:
		player.decrement_jump_buffer()


func _on_animation_finished(anim_name):
	if anim_name == "Enter":
		player.enter_anim_end()

