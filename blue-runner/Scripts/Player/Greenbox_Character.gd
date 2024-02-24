extends Node2D


const UNICOLOR_COLOR : Color = Color(0, 0.75, 0, 1)
const STYLISH_POSITION : Vector2 = Vector2(0, -28)
const STYLISH_RECT : Vector2 = Vector2(32, 32)

const MAX_SPEED : float = 12.0
const TERMINAL_VELOCITY : float = 12.0
const JUMP_STRENGH : float = 14.0
const BOUNCE_STRENGH : float = 12.0
const ATTACK_TIME : int = 6

var player : KinematicBody2D
onready var attack : Area2D = preload("res://Objects/Player/Greenbox_Attack.tscn").instance()

var momentum : Vector2 = Vector2(0, 0)
var air_break : int = 0
var wall_jump : int = 0
var attack_timer : int = 0
var can_attack : bool = true

var frame_skip : bool = true

var jumping : bool = false
var punted : bool = false


func _ready():
	player.collisions[1].position = $col_1.position
	player.collisions[1].scale = $col_1.scale
	player.collisions[1].disabled = false
	player.material.set_shader_param("pattern", 2)
	player.material.set_shader_param("active", false)
	player.enter_anim_end()
	player.add_child(attack)
	# warning-ignore:return_value_discarded
	attack.connect("body_entered", self, "_on_attack_connected")


func _physics_process(delta):
	if player.boosted:
		punted = true
		can_attack = true
	frame_skip = not frame_skip
	
	if player.is_jump_input_just_pressed(): # Check Jump Key
		player.jump_buffer = player.INPUT_BUFFER_FRAMES 
	if Input.is_action_just_pressed("special"):
		player.special_buffer = player.INPUT_BUFFER_FRAMES
	
	if player.ground_buffer > 0:
		player.ground_buffer -= 1
	if player.jump_buffer > 0:
		player.jump_buffer -= 1
	if player.special_buffer > 0:
		player.special_buffer -= 1
	if attack_timer > 0:
		attack_timer -= 1
	
	if player.is_starting():
		pass
	if player.deny_input:
		attack.visible = false
		attack.get_node("coll").disabled = true
	if !player.deny_input:
		if frame_skip:
			if punted:
				momentum.x = player.momentum.x * delta
				momentum.y = round(player.momentum.y * delta)
				punted = false
			
			# Variables needing to be before something
			# warning-ignore:narrowing_conversion
			wall_jump -= sign(wall_jump)
			
			if momentum.y > 0:
				jumping = false
			
			# Check Keyboard
			var key_left = Input.is_action_pressed("left") # Check Left Key
			var key_right = Input.is_action_pressed("right") # Check Right Key
			var key_up = Input.is_action_pressed("up") # etc.
			var key_down = Input.is_action_pressed("down")
			
			
			# Check Danger
			
			var Direction : int = 0
			if key_left:
				Direction -= 1
			if key_right:
				Direction += 1
			
			momentum.x += float(Direction) - min(momentum.x / MAX_SPEED, 1) # Set SPEED
			
			if round(abs(momentum.x)) == 1 and Direction == 0:
				momentum.x = 0
			
			if Direction != 0:
				scale = Vector2(Direction, 1)
				attack.scale.x = Direction
			match(Direction):
				1:
					player.facing = "right"
				-1:
					player.facing = "left"
			if attack_timer == 0:
				if round(abs(momentum.x)) >= MAX_SPEED:
					$Anim.play("SpeedMove")
				else:
					$Anim.play("Move")
			
			player.momentum.x = round(momentum.x) / delta
			
			if player.move_and_collide(Vector2(round(momentum.x),0), false, true, true):
				momentum.x = 0
			
			# Vertical movement
			
			momentum.y += 1 # increase gravity
			
			if player.move_and_collide(Vector2(0,1), false, true, true): # ground check
				player.ground_buffer = player.GROUND_BUFFER_FRAMES
				can_attack = true
				player.state = "ground"
			if player.ground_buffer == 0:
				player.state = "air"
			
			if player.move_and_collide(Vector2(3,0), false, true, true): # check for walls, if there are walls near, enable wall jumping
				air_break = 6
				wall_jump = -4
			
			if player.move_and_collide(Vector2(-3,0), false, true, true):
				air_break = 6
				wall_jump = 4
			
			if momentum.y > float(TERMINAL_VELOCITY - air_break): # limit gravity
				momentum.y = TERMINAL_VELOCITY - air_break
			
			# jump
			if player.jump_buffer > 0: # if jump key pressed
				if player.ground_buffer > 0: # If you are/were on the ground
					momentum.y = -JUMP_STRENGH # Jump
					attack_timer = 0
					can_attack = true
					player.play_sound("GreenboxJump")
					player.ground_buffer = 0
					player.jump_buffer = 0
					jumping = true
				else:
					if wall_jump != 0:  # If you are able to wall jump
						momentum.y = -BOUNCE_STRENGH # Wall Jump
						momentum.x = MAX_SPEED * 0.75 * sign(wall_jump)
						attack_timer = 0
						can_attack = true
						player.play_sound("GreenboxJump")
						player.ground_buffer = 0
						player.jump_buffer = 0
						jumping = true
			if player.special_buffer > 0 and can_attack and player.ground_buffer == 0: # else if you can, attack.
				player.special_buffer = 0
				attack_timer = ATTACK_TIME
				attack.get_node("coll").disabled = false
				can_attack = false
				# This isn't very pretty, but i did it so attacks can be seen in replays
				var key_hori = key_left != key_right
				var key_veri = key_up != key_down
				if key_hori and not key_veri:
					$Anim.play("Attack_H")
				elif key_hori:
					if key_up:
						$Anim.play("Attack_UH")
					if key_down:
						$Anim.play("Attack_DH")
				elif key_veri:
					if key_up:
						$Anim.play("Attack_U")
					if key_down:
						$Anim.play("Attack_D")
				else:
					$Anim.play("Attack_N")
				player.play_sound("GreenboxAttack")
			# Collision Test vertical
			if !player.is_jump_input_pressed() and jumping and !player.punted:
				jumping = false
				if momentum.y < -2:
					momentum.y = -2
			
			
			player.momentum.y = round(momentum.y) / delta
			
			if player.move_and_collide(Vector2(0,momentum.y), false, true, true):
				momentum.y = 0
			
			# Variables needing to be after something
			air_break = 0
		
		player.move_player_character()
		#print("After: ", player.momentum)
		
		attack.visible = attack_timer > 0 and attack_timer != ATTACK_TIME
		if attack_timer == 0:
			attack.get_node("coll").disabled = true
		
	elif player.replay and player.timer > player.replay_timer:
		pass
	elif player.dead:
		if $Anim.current_animation != "Dead":
			$Anim.play("Dead")
			player.play_sound("GreenboxHit")
			player.momentum.y -= BOUNCE_STRENGH / delta
		player.momentum.y += 1 / delta
		position += player.momentum * delta
	elif player.end:
		pass


func set_attack():
	attack.get_node("coll").position = $attack.position
	attack.get_node("attack").position = $attack.position


func _on_attack_connected(body):
	if !player.deny_input:
		momentum.y = -BOUNCE_STRENGH
		attack.get_node("coll").disabled = true
#		attack_timer = 0
		player.jump_buffer = 0
		can_attack = true
		if body.collision_layer % 2 and (body.collision_layer / 2) % 2:
			body.break_active = true
			body.break_position = player.position + attack.get_node("attack").position
			player.break_just_happened = true
