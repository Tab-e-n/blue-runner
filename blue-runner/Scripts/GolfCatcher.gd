extends Area2D


const REMOVE_TIME_START : float = 1.0
const REMOVE_TIME_START_INVERTED : float = 1.0 / REMOVE_TIME_START


export var wall_scale : Vector2 = Vector2(1, 0.5)
export var wall_offset : Vector2 = Vector2(0, 32)

var remove_wall : bool = false
var remove_time : float = REMOVE_TIME_START


func _ready():
	$wall.scale = wall_scale
	$wall.position = wall_offset


func _physics_process(delta):
	
	if remove_wall and remove_time >= 0:
		remove_time -= delta
		$wall.modulate.a = remove_time * REMOVE_TIME_START_INVERTED
		if remove_time < 0:
			$wall.queue_free()


func _on_area_entered(area):
	if area is GolfDisk:
		var new_callout : Node2D = preload("res://Objects/Decor/StyleCallout.tscn").instance()
		new_callout.text = String(area.points)
		new_callout.position = position - Vector2(0, 128)
		get_tree().current_scene.call_deferred("add_child", new_callout)
		
		set_deferred("monitoring", false)
		
		remove_wall = true
		
		area.queue_free()
