extends Area2D
class_name GolfDisk


const GRAVITY : float = 7.0
const DECCELERATION : float = 3.0
const TERMINAL_VELOCITY : float = 400.0


onready var level : Node2D = get_tree().current_scene


var momentum : Vector2 = Vector2(0, 0)

var points : int = 0


func _physics_process(delta):
#	print(momentum.x)
	if level.timers_active:
		if momentum.x != 0:
			momentum.x = reduce_momentum(momentum.x, DECCELERATION)
		
		momentum.y += GRAVITY
		if momentum.y < 0:
			momentum.y -= momentum.y * 0.005
		if momentum.y > TERMINAL_VELOCITY:
			momentum.y = TERMINAL_VELOCITY
		
		if colliding(FLOOR):
			momentum.y = flip_momentum(momentum.y, -1)
			momentum.y = reduce_momentum(momentum.y, 100)
			position.y -= 1
		if colliding(CEILING):
			momentum.y = flip_momentum(momentum.y, 1)
			position.y += 1
		if colliding(LEFT_WALL):
			momentum.x = flip_momentum(momentum.x, 1)
			position.x += 1
		if colliding(RIGHT_WALL):
			momentum.x = flip_momentum(momentum.x, -1)
			position.x -= 1
		
		position += momentum * delta


func reduce_momentum(velocity : float, amount : float) -> float:
	var mov_dir : float = sign(velocity)
	velocity -= amount * mov_dir
	if mov_dir != sign(velocity):
		velocity = 0
	return velocity


func flip_momentum(velocity : float, desired_dir : float) -> float:
	var mov_dir : float = sign(velocity)
	desired_dir = sign(desired_dir)
	
	if desired_dir == 0:
		velocity = 0
	elif desired_dir != mov_dir:
		velocity *= -1
	
	return velocity

enum {FLOOR, CEILING, LEFT_WALL, RIGHT_WALL}
func colliding(type : int) -> bool:
	match(type):
		FLOOR:
			var check : int = int(collision_check($check_bl))
			check += int(collision_check($check_br))
			check += int(collision_check($check_c))
			return check >= 2
		CEILING:
			var check : int = int(collision_check($check_tl))
			check += int(collision_check($check_tr))
			check += int(collision_check($check_c))
			return check >= 2
		LEFT_WALL:
			return collision_check($check_bl) and collision_check($check_tl)
		RIGHT_WALL:
			return collision_check($check_br) and collision_check($check_tr)
	return false


func collision_check(area : Area2D) -> bool:
	var ground : Array = area.get_overlapping_bodies()
	if not ground.empty():
		if ground.size() > 1 or not ground[0] is Player:
			return true
	return false


func _on_body_entered(body):
	if body is Player:
		momentum = body.momentum * Vector2(0.75, 0.75)
		momentum.y -= 400
		points += 1
