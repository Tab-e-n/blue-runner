extends KinematicBody2D

var momentum : Vector2 = Vector2(0, 0)

var gravity_up : int = 26
var gravity_down : int = 40
var gravity_switch = true
var gravity_wall_up : int = 13
var gravity_wall_down : int = 20

var jump_power : int = 750
var jump_amount_max = 1
var jump_amount = jump_amount_max

var max_speed : int = 800
var acceleration : int = 40
var deceleration : int = 40
var acc_dividor : int = 40

var state : String = "air"
var sliding : int = 0
var force_slide : bool = false
var dropping : int = 0
export var facing : String = "right"

var dead : bool = false
var death_wait : int = 0

const jump_buffer_constant : int = 5
var jump_buffer : int = 0

const ground_buffer_constant : int = 5
var ground_buffer : int = 0

var timer : int = 0

func _ready():
	pass
	#if get_parent().name == "Main": position = $"/root/Global".tele_pos # HUB WORLD CODE

func _process(_delta):
	if !dead:
		if is_on_ceiling(): momentum.y = 0
		
		var on_wall_right : bool = move_and_collide(Vector2(2,0), false, true, true) != null
		var on_wall_left : bool = move_and_collide(Vector2(-2,0), false, true, true) != null
		var on_wall : bool = on_wall_right or on_wall_left
		
		if (momentum.y > 0):
			gravity_switch = true
		if !on_wall:
			if !gravity_switch:
				momentum.y += gravity_up
			else:
				momentum.y += gravity_down
		else:
			if !gravity_switch:
				momentum.y += gravity_wall_up
			else:
				momentum.y += gravity_wall_down
		if state == "ground":
			ground_buffer = ground_buffer_constant
			jump_amount = jump_amount_max
			if sign(momentum.x) != 0:
				var temp_momentum = sign(momentum.x)
				if !Input.is_action_pressed("right") and sign(momentum.x) == 1:
					momentum.x -= deceleration
				if !Input.is_action_pressed("left") and sign(momentum.x) == -1:
					momentum.x += deceleration
				if temp_momentum != sign(momentum.x):
					momentum.x = 0
			if momentum.x > -40 and momentum.x < 40:
				momentum.x = 0
			if Input.is_action_pressed("special") and dropping > 0: sliding = dropping
			dropping = 0
		if state == "air":
			sliding = 0
			if is_on_ceiling() and dropping: sliding = dropping
		
		
		if ground_buffer != 0: ground_buffer -= 1
		if ground_buffer == 1: jump_amount -= 1
		
		if is_on_floor(): momentum.y = 1
		else: state = "air"
		
		if Input.is_action_pressed("left") and momentum.x > -max_speed and sliding == 0 and dropping == 0:
			momentum.x -= acceleration - round(momentum.x / acc_dividor)
			facing = "left"
		if Input.is_action_pressed("right") and momentum.x < max_speed and sliding == 0 and dropping == 0:
			momentum.x += acceleration - round(momentum.x / acc_dividor)
			if dropping == 0: facing = "right"
		
		if sliding > 0: sliding -= 1
		
		if Input.is_action_just_pressed("special"):
			if state == "ground":
				sliding = 15
			else:
				dropping = 15
		if Input.is_action_pressed("special"):
			if state == "ground":
				if sliding == 1: sliding = 2
			else:
				if dropping == 1: dropping = 2
		
		force_slide = false
		if sliding > 0:
			if facing == "left":
				momentum.x = -round(max_speed * 1.2)
			if facing == "right":
				momentum.x = round(max_speed * 1.2)
			if move_and_collide(Vector2(0,-8), false, true, true):
				sliding = 7
				force_slide = true
		if dropping > 0:
			if facing == "left":
				momentum.x = -round(max_speed * 0.5)
			if facing == "right":
				momentum.x = round(max_speed * 0.5)
			momentum.y += gravity_down
		
		if is_on_wall():
			momentum.x = 0
			jump_amount = jump_amount_max - 1
		
		if Input.is_action_just_pressed("jump"): jump_buffer = jump_buffer_constant
		if jump_buffer != 0 and !force_slide:
			jump_buffer -= 1
			ground_buffer = 0
			if move_and_collide(Vector2(0,4), false, true, true):
				jump_amount -= 1
				jump()
				jump_buffer = 0
			elif move_and_collide(Vector2(4,0), false, true, true):
					# warning-ignore:integer_division
					momentum.x = -max_speed / 2
					facing = "left"
					jump()
					jump_buffer = 0
			elif move_and_collide(Vector2(-4,0), false, true, true):
					# warning-ignore:integer_division
					momentum.x = max_speed / 2
					facing = "right"
					jump()
					jump_buffer = 0
		if jump_amount > 0 and jump_buffer == 1:
				jump_amount -= 1
				jump()
		if Input.is_action_just_released("jump"):
			gravity_switch = true
			if momentum.y < -200: momentum.y = -200
		
		# warning-ignore:return_value_discarded
		move_and_slide(momentum, Vector2(0, -1))
		for i in get_slide_count():
			if get_slide_collision(i).collider.collision_layer == 2:
				dead = true
			if get_slide_collision(i).collider.collision_layer == 4:
				$"/root/Global".tele_pos = get_slide_collision(i).collider.tele_pos # HUB WORLD CODE
				
				var temp_prog = get_slide_collision(i).collider.progress # GREENBOX CODE
				if temp_prog > $"/root/Global".progress: $"/root/Global".progress = temp_prog # GREENBOX CODE
				
				var temp_comp = get_slide_collision(i).collider.completion
				if temp_comp != 0: if $"/root/Global".completion[temp_comp] > timer or $"/root/Global".completion[temp_comp] == 0: $"/root/Global".completion[temp_comp] = timer
				
				$"/root/Global".save_game()
				# warning-ignore:return_value_discarded
				get_tree().change_scene(get_slide_collision(i).collider.tele_destination)
		
		
		if is_on_floor(): state = "ground"
		
		$Old/spr_PlayerRight.scale = Vector2(2, 2)
		$Old/spr_PlayerRight.position.y = -28
		if sliding > 0:
			$Old/spr_PlayerRight.scale = Vector2(2.25, 1.5)
			$Old/spr_PlayerRight.position.y = -21
		
		$Old/spr_PlayerRight.visible = !dropping > 0
		$Old/spr_PlayerRight_Alt.visible = dropping > 0
		$col_stand.disabled = sliding > 0
		$col_slide.disabled = !sliding > 0
		
		$Old/spr_PlayerRight.flip_h = facing == "left"
		$Old/spr_PlayerRight_Alt.flip_h = facing == "left"
		
		timer += 1
	else:
		$Old/spr_PlayerRight.visible = false
		$Old/spr_PlayerRight_Alt.visible = false
		$Old/spr_PlayerRight_Dead.visible = true
		$Old/spr_PlayerRight_Dead.flip_h = facing == "left"
		
		position.y -= (10 - death_wait) * 2
		
		death_wait += 1
		if death_wait >= 20:
			# warning-ignore:return_value_discarded
			get_tree().change_scene("res://Scenes/" + get_tree().current_scene.name + ".tscn")

func jump():
	momentum.y = -jump_power
	state = "air"
	gravity_switch = false
	dropping = 0
