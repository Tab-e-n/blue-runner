extends StaticBody2D

export var completely_invisible : bool = false

var player : Node2D = null

func _ready():
	if completely_invisible:
		$Control.queue_free()
	else:
		$Control/light.scale = Vector2(2, 2) / scale
		call_deferred("get_player")

func get_player():
	player = get_tree().current_scene.player

func _physics_process(_delta):
	if not completely_invisible:
		$Control/light.position = (player.position - position) / scale + Vector2(32, 32)
