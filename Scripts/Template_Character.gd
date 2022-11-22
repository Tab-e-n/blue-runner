extends Node2D

onready var g : Control = $"/root/Global"
onready var player : KinematicBody2D = get_parent()
onready var col_1 : Node2D = get_parent().get_node("col_1")
onready var col_2 : Node2D = get_parent().get_node("col_2")

var momentum : Vector2 = Vector2(0, 0)

export (PackedScene) var particle
var particle_disable : int = 0

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

var state : String = "air"
var facing : String

const jump_buffer_constant : int = 5
var jump_buffer : int = 0

const ground_buffer_constant : int = 6
var ground_buffer : int = 0

var last_anim : String = "Default"
var last_facing : String = facing
var wall_anim : int = 1

func _ready():
	facing = player.facing

func _physics_process(_delta):
	col_1.position = $col_1.position
	col_1.scale = $col_1.scale
	col_1.disabled = !$col_1.visible
	
	col_2.position = $col_2.position
	col_2.scale = $col_2.scale
	col_2.disabled = !$col_2.visible
	
	if Input.is_action_just_pressed("jump"): jump_buffer = jump_buffer_constant
	
	if !player.deny_input:
		# GRAVITY / DECELERATION
		if player.is_on_ceiling(): momentum.y = 0
		
		var on_wall_right : bool = player.move_and_collide(Vector2(1,0), false, true, true) != null
		var on_wall_left : bool = player.move_and_collide(Vector2(-1,0), false, true, true) != null
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
			if momentum.x > -deceleration and momentum.x < deceleration and !(Input.is_action_pressed("left") or Input.is_action_pressed("right")):
				momentum.x = 0
		
		if player.is_on_floor() or player.move_and_collide(Vector2(0,1), false, true, true): momentum.y = 1
		else: state = "air"
		
		# MOVEMENT
		if Input.is_action_pressed("left") and momentum.x > -max_speed:
			momentum.x -= acceleration - round(momentum.x / acc_dividor)
			if !on_wall: facing = "left"
		if Input.is_action_pressed("right") and momentum.x < max_speed:
			momentum.x += acceleration - round(momentum.x / acc_dividor)
			if !on_wall: facing = "right"
		
		# SPECIAL ABILITIES
		if Input.is_action_just_pressed("special"):
			# Whatever
			player.play_sound("example")
			pass
		
		# JUMPING
		if ground_buffer != 0: ground_buffer -= 1
		if ground_buffer == 1: jump_amount = jump_amount_max - 1
		
		if player.is_on_wall():
			momentum.x = 0
			jump_amount = jump_amount_max - 1
		
		player.collision_mask = 3
		if jump_buffer > 0:
			jump_buffer -= 1
			ground_buffer = 0
			if player.move_and_collide(Vector2(0,4), false, true, true):
				jump_amount -= 1
				jump(jump_power)
				jump_buffer = 0
			elif player.move_and_collide(Vector2(4,0), false, true, true):
					jump_amount = jump_amount_max - 1
					# warning-ignore:integer_division
					momentum.x = -max_speed / 1.5
					facing = "left"
					# warning-ignore:narrowing_conversion
					jump(jump_power * 1.075)
					jump_buffer = 0
			elif player.move_and_collide(Vector2(-4,0), false, true, true):
					jump_amount = jump_amount_max - 1
					# warning-ignore:integer_division
					momentum.x = max_speed / 1.5
					facing = "right"
					# warning-ignore:narrowing_conversion
					jump(jump_power * 1.075)
					jump_buffer = 0
		if jump_amount > 0 and jump_buffer == 1:
				jump_amount -= 1
				jump(jump_power)
				#jump_buffer = 0
		if Input.is_action_just_released("jump"):
			gravity_switch = true
			if momentum.y < -200: momentum.y = -200
		
		# COLLISION / MOVING
		# warning-ignore:return_value_discarded
		player.collision_mask = 1048575
		player.move_and_slide(momentum, Vector2(0, -1))
		player.collision_mask = 1
		
		player.break_just_happened = false
		for i in player.get_slide_count(): player.collision_default_effects(player.get_slide_collision(i).collider.collision_layer, i)
		
		if player.is_on_floor() or player.move_and_collide(Vector2(0,1), false, true, true): state = "ground"
		
		
		# ANIMATION
		scale = Vector2(1, 1)
		wall_anim = 1
		
		if state == "air":
			if on_wall:
				if (facing == "left" and on_wall_left) or (facing == "right" and on_wall_right):
					wall_anim = -1
				#$Anim.current_animation = "On_Wall"
			elif Input.is_action_pressed("jump") and !gravity_switch:
				pass
				#$Anim.current_animation = "Jump_Up"
			elif last_anim != "Jump_Transition" and last_anim != "":
				pass
				#$Anim.current_animation = "Jump_Transition"
			if last_anim != "On_Wall" and $Anim.current_animation == "On_Wall":
				if on_wall_left:
					pass
					#particle_summon(Vector2(-12, -64), 1.6)
				if on_wall_right:
					pass
					#particle_summon(Vector2(12, -64), -1.6)
		else:
			if momentum.x != 0 and !on_wall:
				if $Anim.current_animation != "Walk" or last_facing != facing:
					pass
					#$Anim.stop()
					#$Anim.current_animation = "Walk"
			else:
				pass
				#$Anim.current_animation = "Default"
		
		last_anim = $Anim.current_animation
		last_facing = facing
		
		if facing == "left":
			scale = Vector2(-1 * wall_anim, scale.y)
		else:
			scale = Vector2(1 * wall_anim, scale.y)
		
		if particle_disable != 0: particle_disable -= 1
		
		player.record()
	
	# - - - REPLAY STATE - - -
	elif player.replay and player.timer > player.replay_timer:
			scale = Vector2(scale.x, 1)
			
			$Anim.current_animation = ""
	
	# - - - DEATH STATE - - -
	elif player.dead:
		scale = Vector2(scale.x, 1)
		if $Anim.current_animation!="Death": player.play_sound("example")
		$Anim.play("Death")
	
	# - - - IM DONE FOR STATE - - -
	elif player.end:
		scale = Vector2(scale.x, 1)
		
		$Anim.current_animation = ""
		if state == "ground":
			pass
			#$Anim.current_animation = "Concern"
	elif player.deny_input:
		if jump_buffer > 0:
			jump_buffer -= 1
		player.record()
	

#func _process(delta):
#	pass

func jump(local_jump_power : int):
	momentum.y = -local_jump_power
	state = "air"
	gravity_switch = false
	player.play_sound("example")

func particle_summon(particle_position : Vector2, particle_rotation : float, type : int = 0):
	if particle_disable == 0:
		var node_creator
		node_creator = particle.instance()
		player.get_parent().add_child(node_creator)
		node_creator.position = player.position + particle_position
		node_creator.rotation = particle_rotation
		node_creator.start(type)
		particle_disable = 6

func enter_anim_end():
	if !player.replay:
		player.deny_input = false
