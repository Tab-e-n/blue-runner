extends Area2D

var editor_properties : Dictionary = {
	"description" : "A trampoline mushroom.\nWhenever the player touches it, it launches the player into the direction its facing. The launches strenght is either determined by the size of the mushroom, or you can set it to a specific amount with boost strenght. The mushroom will add to the players current momentum, unless overwrite_momentum is toggled on.",
	"object_path" : "res://Objects/Mushroom.tscn",
	"object_type" : "normal",
	"layer" : "selected",
	"rect" : Rect2(0, -36, 96, 80),
	"editable_properties" : {
		"boost_strenght" : [TYPE_INT, 0, 0, 1],
		"overwrite_momentum" : [TYPE_BOOL, 0, 0, 0],
	},
	"unchangeable_properties" : {
		"scale" : false,
		"rotation" : false,
		"z_index" : false,
		"color" : false,
		"order" : false,
	},
	"attachable" : false,
}

export var boost_strenght : int = 0
export var overwrite_momentum : bool = false

const CHARACTER_GRAVITIES : Dictionary = {
	"S1" : 40,
	"Greenbox" : 30,
}
var current_gravity : int = 0
var grav_char : Sprite = Sprite.new()
var grav_timer : int = 0

func _ready():
	call_deferred("_selected_process", 0)
	add_child(grav_char)
	grav_char.visible = false


func _selected_process(_delta):
	$launch.rotation_degrees = -rotation_degrees
	$launch.scale = Vector2(1, 1) / scale
	grav_char.rotation_degrees = -rotation_degrees
	grav_char.scale = Vector2(1, 1) / scale
	if collision_mask == 0 or collision_layer == 0:
		$launch.visible = false
		$collision.visible = false
	else:
		$launch.visible = true
		$collision.visible = true
		calculate_launch_angle()
	if grav_timer > 0:
		grav_timer -= 1
		if grav_timer == 0:
			grav_char.visible = false


func calculate_launch_angle():
	var boost : Vector2 = Vector2(0, 0)
	var temp_boost_strenght = boost_strenght
	
	if temp_boost_strenght == 0:
		temp_boost_strenght = int(scale.y * 1200)
	boost.y = round(temp_boost_strenght * cos(rotation) * -1)
	boost.x = round(temp_boost_strenght * sin(rotation))
	
	var gravity = CHARACTER_GRAVITIES[CHARACTER_GRAVITIES.keys()[current_gravity]]
	var ascend_frames : int = int(ceil(temp_boost_strenght / gravity))
	var pos_y = 0
	var momentum_y = boost.y
	var intersect_array : PoolIntArray = range($launch.points.size())
	var skips : float = (ascend_frames / $launch.points.size())
	for i in range($launch.points.size()):
		intersect_array[i] = int(skips * i)
#		intersect_array[$launch.points.size() - 1] = ascend_frames - 1
	var l : int = 0
	for i in range(ascend_frames):
		var pos_x = boost.x * i / 60
		while l != 16 and i == intersect_array[l]:
			$launch.points[l].x = pos_x
			$launch.points[l].y = pos_y
			l += 1
			if l == 16:
				break
		momentum_y += gravity
		pos_y += momentum_y / 60
#		print($launch.points)


func edit_right_just_pressed(_mouse_pos, _cursor_position, _level_scale):
	current_gravity += 1
	if current_gravity == CHARACTER_GRAVITIES.size():
		current_gravity = 0
	grav_char.texture = load("res://Visual/" + CHARACTER_GRAVITIES.keys()[current_gravity] + "/icon.png")
	grav_char.visible = true
	grav_timer = 60

