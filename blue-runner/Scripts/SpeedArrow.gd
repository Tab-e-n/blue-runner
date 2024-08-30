extends Area2D
class_name SpeedArrow


export var linked_arrows : Array = []

var got_overwritten : bool = false

var disabled : int = 0


func _ready():
	if not got_overwritten:
		for i in linked_arrows:
			if not i is NodePath:
				continue
			var arrow = get_node(i)
			var linked = linked_arrows.duplicate()
			linked.erase(i)
			linked.append(get_path())
			arrow.linked_arrows = linked
			arrow.got_overwritten = true
	
	$SpeedArrowBack.play("Move")


func _physics_process(delta):
	if disabled > 0:
		disabled -= 1


func _on_body_entered(body):
	if disabled > 0 or $SpeedArrow/anim.is_playing():
		return
	if body is Player:
		Audio.play_sound("Blip")
		passed_though()
		for i in linked_arrows:
			if not i is NodePath:
				continue
			var arrow = get_node(i)
			arrow.passed_though()


func passed_though():
	$SpeedArrow/anim.play("PassThrough")
	disabled = 3
