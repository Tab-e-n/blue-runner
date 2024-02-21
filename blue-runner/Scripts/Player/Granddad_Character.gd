extends Node2D


const UNICOLOR_COLOR : Color = Color("ffffff")
const GRAVITY : int = 26
const JUMP_POWER : int = 1000

var MAX_SPEED : int = 1200
var ACCELERATION : int = 5
var DECELERATION : int = 50
var AIR_MAX_SPEED : int = 800
var AIR_ACCELERATION : int = 100

var player : KinematicBody2D


var can_jump : bool = true
var jumping : bool = false
var crouching : bool = false

onready var last_position : Vector2 = player.position

func _ready():
	$Anim.current_animation = "Enter"
	player.play_sound("AirBaloonExplosion")


func _physics_process(_delta):
	if player.is_jump_input_just_pressed():
		player.start_jump_buffer()
	
	if player.start:
		player.decrement_jump_buffer()
		
	if !player.deny_input:
		
		crouching = Input.is_action_pressed("down") and player.state != "air"
		
		player.collisions[1].position = $col_1.position
		player.collisions[1].disabled = !$col_1.visible
		player.collisions[1].scale = $col_1.scale
		
		if crouching:
			player.collisions[1].position -= player.collisions[1].position * 0.5
			player.collisions[1].scale.y *= 0.5
		
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
		
		if player.get_horizontal_axis():
			var acceleration = ACCELERATION
			var max_speed = MAX_SPEED
			if player.state == "air":
				acceleration = AIR_ACCELERATION
				max_speed = AIR_MAX_SPEED
				
			if player.below_max_speed(player.momentum.x, player.get_horizontal_axis(), max_speed):
#			if abs(player.momentum.x) < max_speed:
				player.momentum.x += acceleration * player.get_horizontal_axis()
			
			if !on_wall:
				if player.get_horizontal_axis() == -1:
					player.facing = "left"
				if player.get_horizontal_axis() == 1:
					player.facing = "right"
		
		if on_wall and abs(player.momentum.x) > AIR_MAX_SPEED:
			player.momentum.x = AIR_MAX_SPEED * sign(player.momentum.x)
		
		player.break_breakables = player.state == "air"
		
		player.decrement_ground_buffer()
		if player.ground_buffer == 1:
			can_jump = false
		
		player.collision_mask = 0b11
		
		if player.should_jump():
			player.decrement_jump_buffer()
			player.ground_buffer = 0
			
			if player.move_and_collide(Vector2(0,4), false, true, true) or player.ground_buffer > 0:
				player.jump(JUMP_POWER)
				jumping = true
			elif player.move_and_collide(Vector2(4,0), false, true, true):
				player.momentum.x = int(-MAX_SPEED * 0.4)
				player.facing = "left"
				player.jump(JUMP_POWER * 0.75)
				jumping = true
			elif player.move_and_collide(Vector2(-4,0), false, true, true):
				player.momentum.x = int(MAX_SPEED * 0.4)
				player.facing = "right"
				player.jump(JUMP_POWER * 0.75)
				jumping = true
		
		if !player.is_jump_input_pressed() and jumping and !player.punted:
			jumping = false
			if player.momentum.y < -200:
				player.momentum.y = -200
		
		player.move_player_character()
		
		if player.is_on_floor() or player.move_and_collide(Vector2(0,1), false, true, true):
			player.state = "ground"
		
		if crouching:
			scale.y = 0.5
		else:
			scale.y = 1
		
		if player.state == "air":
			if $Anim.current_animation != "Air":
				$Anim.play("Air")
		else:
			var sign_momentum = sign(player.momentum.x)
			if sign_momentum == 0:
				if player.facing == "left":
					$Anim.play("Stand Left")
				else:
					$Anim.play("Stand Right")
			if sign_momentum == -1 and $Anim.current_animation != "Moving Left":
				$Anim.play("Moving Left")
			if sign_momentum == 1 and $Anim.current_animation != "Moving Right":
				$Anim.play("Moving Right")
		
	elif player.replay and player.timer > player.replay_timer:
		$Anim.current_animation = ""
		
	elif player.dead:
		if $Anim.current_animation != "Death":
			player.play_sound("example")
		$Anim.play("Death")
		
		scale.y = 1
		$spriteshit.rotation = 0
	elif player.end:
		if abs(scale.x) < 1000:
			scale.x += 0.001 * sign(scale.x)
		
		$Anim.current_animation = ""
		
	elif player.deny_input:
		player.decrement_jump_buffer()
	
	if $Anim.current_animation == "Air":
		point_sprite()
	else:
		$spriteshit.rotation = 0


func _on_animation_finished(anim_name):
		if anim_name == "Enter":
			$explosion.visible = false
			player.enter_anim_end()


func point_sprite():
	var pyth = player.position.distance_to(last_position)
	var difference = player.position - last_position
	var cosine = difference.x / pyth
	$spriteshit.rotation = incos(cosine, difference.y) + PI * 0.5
	last_position = player.position


func incos(cosine : float, y : float) -> float:
	return acos(cosine) * sign(y)
