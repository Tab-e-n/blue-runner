extends Area2D


export var text : String = "empty"
export var offset : Vector2 = Vector2(0, 0)
export var text_size : Vector2 = Vector2(341, 85)
export var text_scale : Vector2 = Vector2(0.75, 0.75)
export var text_color : Color = Color(1, 1, 1, 1)
export var follow_player : bool = false
export var delay_until_appearing : int = 0
export var appear_time : int = 60

var delay_timer : int = 0
var visibility_timer : int = 0
var appearing : bool = false

onready var following_body : Node2D = null

func _ready():
	var temp_scale : Vector2 = scale
	scale = Vector2(1, 1)
	$Collision.scale = temp_scale
	$Text.rect_size = text_size
	$Text.rect_scale = text_scale
	$Text.text = text

func _physics_process(_delta):
	if appearing:
		if delay_timer >= delay_until_appearing:
			if visibility_timer < appear_time:
				visibility_timer += 1
		else:
			delay_timer += 1
	elif visibility_timer > 0:
		visibility_timer -= 1
	$Text.modulate = Color(text_color.r,text_color.b,text_color.g,float(visibility_timer) / appear_time)
	
	if follow_player and visibility_timer > 0 and following_body != null:
		$Text.rect_position = following_body.position - position + offset


func _on_HoverText_body_entered(body):
	appearing = true
	following_body = body

func _on_HoverText_body_exited(_body):
	appearing = false
	delay_timer = 0
