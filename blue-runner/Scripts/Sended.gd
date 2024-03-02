extends AttackDestroyable


export var green : bool = false


onready var level : Node2D = get_tree().current_scene

var lifetime : float = 5
var target : Vector2

var momentum : Vector2 = Vector2(0, 0)
var exploding : bool = false


func _ready():
	connect("destroy_self", self, "queue_free")
	
	target = level.get_node("Player").position
	if green:
		$projectile.texture = preload("res://Visual/April/spr_Sended1_strip12.png")
		$explosion.texture = preload("res://Visual/April/spr_RoomTransport4_strip3.png")


func _physics_process(delta):
	lifetime -= delta
	if lifetime <= 0:
		explode()
	
	if not exploding:
		if not green:
			target = level.get_node("Player").position
		
		momentum.x += sign(target.x - position.x) - momentum.x * 0.111
		momentum.y += sign(target.y - position.y) - momentum.y * 0.111
		
		position += Vector2(round(momentum.x), round(momentum.y))


func explode():
	$explosion.visible = true
	$coll.scale = Vector2(2, 2)
	$anim.play("explode")
	exploding = true


func _on_animation_finished(anim_name):
	if anim_name == "explode":
		queue_free()
