extends Node2D

onready var player : KinematicBody2D = get_parent()

const GRAVITY_UP : int = 26
const GRAVITY_DOWN : int = 40
const GRAVITY_WALL_UP : int = 13
const GRAVITY_WALL_DOWN : int = 20
const JUMP_POWER : int = 800
const MAX_JUMP_AMOUNT : int = 1

const MAX_SPEED : int = 850
const ACCELERATION : int = 40
const DECELERATION : int = 50
const ACC_DIVIDOR : int = 40

const UNICOLOR_COLOR : Color = Color(0, 0.75, 0, 1)

export (PackedScene) var particle
var particle_disable : int = 0

var jumping = false

var jump_amount = MAX_JUMP_AMOUNT

var last_anim : String = "Default"
var last_facing : String
var wall_anim : int = 1

func _ready():
	last_facing = player.facing

func _physics_process(_delta):
	player.collisions[1].position = $col_1.position
	player.collisions[1].scale = $col_1.scale
	player.collisions[1].disabled = !$col_1.visible
	
	player.collisions[2].position = $col_2.position
	player.collisions[2].scale = $col_2.scale
	player.collisions[2].disabled = !$col_2.visible
	
	if player.is_jump_input_just_pressed():
		player.jump_buffer = player.INPUT_BUFFER_FRAMES
	
	if player.start:
		if player.jump_buffer > 0:
			player.jump_buffer -= 1
	if !player.deny_input:
		# GRAVITY / DECELERATION
		if player.is_on_ceiling(): player.momentum.y = 0
		
		var on_wall_right : bool = player.move_and_collide(Vector2(1,0), false, true, true) != null
		var on_wall_left : bool = player.move_and_collide(Vector2(-1,0), false, true, true) != null
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
			player.ground_buffer = player.GROUND_BUFFER_FRAMES
			jump_amount = MAX_JUMP_AMOUNT
			if sign(player.momentum.x) != 0:
				var temp_momentum = sign(player.momentum.x)
				if !Input.is_action_pressed("right") and sign(player.momentum.x) == 1:
					player.momentum.x -= DECELERATION
				if !Input.is_action_pressed("left") and sign(player.momentum.x) == -1:
					player.momentum.x += DECELERATION
				if temp_momentum != sign(player.momentum.x):
					player.momentum.x = 0
			if player.momentum.x > -DECELERATION and player.momentum.x < DECELERATION and !(Input.is_action_pressed("left") or Input.is_action_pressed("right")):
				player.momentum.x = 0
		
		if (player.is_on_floor() or player.move_and_collide(Vector2(0,1), false, true, true)) and player.state != "air":
			player.momentum.y = 1
		else: player.state = "air"
		
		# MOVEMENT
		if Input.is_action_pressed("left"):
			if player.momentum.x > -MAX_SPEED:
				player.momentum.x -= ACCELERATION - round(player.momentum.x / ACC_DIVIDOR)
			if !on_wall:
				player.facing = "left"
		if Input.is_action_pressed("right"):
			if player.momentum.x < MAX_SPEED:
				player.momentum.x += ACCELERATION - round(player.momentum.x / ACC_DIVIDOR)
			if !on_wall:
				player.facing = "right"
		
		# SPECIAL ABILITIES
		if Input.is_action_just_pressed("special"):
			# Whatever
			player.play_sound("example")
			pass
		
		# JUMPING
		if player.ground_buffer > 0:
			player.ground_buffer -= 1
		if player.ground_buffer == 1:
			jump_amount = MAX_JUMP_AMOUNT - 1
		
		if player.is_on_wall() and !player.punted:
			player.momentum.x = 0
			jump_amount = MAX_JUMP_AMOUNT - 1
		
		player.collision_mask = 0b11
		
		if player.jump_buffer > 0:
			player.jump_buffer -= 1
			player.ground_buffer = 0
			if player.move_and_collide(Vector2(0,4), false, true, true):
				jump_amount -= 1
				jump(JUMP_POWER)
				player.jump_buffer = 0
			elif player.move_and_collide(Vector2(4,0), false, true, true):
					jump_amount = MAX_JUMP_AMOUNT - 1
					# warning-ignore:integer_division
					player.momentum.x = -MAX_SPEED / 1.5
					player.facing = "left"
					# warning-ignore:narrowing_conversion
					jump(JUMP_POWER * 1.075)
					player.jump_buffer = 0
			elif player.move_and_collide(Vector2(-4,0), false, true, true):
					jump_amount = MAX_JUMP_AMOUNT - 1
					# warning-ignore:integer_division
					player.momentum.x = MAX_SPEED / 1.5
					player.facing = "right"
					# warning-ignore:narrowing_conversion
					jump(JUMP_POWER * 1.075)
					player.jump_buffer = 0
		if jump_amount > 0 and player.jump_buffer == 1:
				jump_amount -= 1
				jump(JUMP_POWER)
				#player.jump_buffer = 0
		if !player.is_jump_input_pressed() and jumping and !player.punted:
			jumping = false
			if player.momentum.y < -200:
				player.momentum.y = -200
		
		# COLLISION / MOVING
		# warning-ignore:return_value_discarded
		player.move_player_character()
		
		if player.is_on_floor() or player.move_and_collide(Vector2(0,1), false, true, true):
			player.state = "ground"
		
		# ANIMATION
		scale = Vector2(1, 1)
		wall_anim = 1
		
		if player.state == "air":
			if on_wall:
				if (player.facing == "left" and on_wall_left) or (player.facing == "right" and on_wall_right):
					wall_anim = -1
				"On_Wall"
			elif player.is_jump_input_pressed() and jumping:
				"Jump_Up"
			elif last_anim != "Jump_Transition" and last_anim != "":
				"Jump_Transition"
			if last_anim != "On_Wall" and $Anim.current_animation == "On_Wall":
				if on_wall_left:
					pass
					#particle_summon(Vector2(-12, -64), 1.6)
				if on_wall_right:
					pass
					#particle_summon(Vector2(12, -64), -1.6)
		else:
			if player.momentum.x != 0 and !on_wall:
				if $Anim.current_animation != "Walk" or last_facing != player.facing:
					"Walk"
			else:
				"Standing"
		
		last_anim = $Anim.current_animation
		last_facing = player.facing
		
		if player.facing == "left":
			scale = Vector2(-1 * wall_anim, scale.y)
		else:
			scale = Vector2(1 * wall_anim, scale.y)
		
		if particle_disable != 0:
			particle_disable -= 1
		
		player.record()
	
	# - - - REPLAY STATE - - -
	elif player.replay and player.timer > player.replay_timer:
			scale = Vector2(scale.x, 1)
			
			$Anim.current_animation = ""
	
	# - - - DEATH STATE - - -
	elif player.dead:
		scale = Vector2(scale.x, 1)
		if $Anim.current_animation!="Death":
			player.play_sound("example")
		$Anim.play("Death")
	
	# - - - IM DONE FOR STATE - - -
	elif player.end:
		scale = Vector2(scale.x, 1)
		
		$Anim.current_animation = ""
		if player.state == "ground":
			pass
			#$Anim.current_animation = "Concern"
	elif player.deny_input:
		if player.jump_buffer > 0:
			player.jump_buffer -= 1
		player.record()
	

#func _process(delta):
#	pass

func jump(local_jump_power : int):
	player.momentum.y = -local_jump_power
	player.state = "air"
	jumping = true
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
		player.start = false
		player.deny_input = false
