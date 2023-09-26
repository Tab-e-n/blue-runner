extends Area2D

export var text : String = "empty"
export var offset : Vector2 = Vector2(0, 0)
export var text_size : Vector2 = Vector2(341, 85)
export var text_scale : Vector2 = Vector2(0.75, 0.75)
export var text_color : Color = Color(1, 1, 1, 1)
export var follow_player : bool = false
export var delay_until_appearing : int = 0
export var appear_time : int = 60
export var font_path : String = "res://Text/Lacrimae.tres"

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
	$Text.text = Global.text_interpretor(text)
	if !follow_player:
		$Text.rect_position = offset
	var font = load(font_path)
	if font != null:
		$Text.add_font_override("normal_font", font)

func _physics_process(_delta):
	if appearing:
		if delay_timer >= delay_until_appearing:
			if visibility_timer < appear_time:
				visibility_timer += 1
		if visibility_timer == 0:
			delay_timer += 1
		else:
			delay_timer = delay_until_appearing
	elif visibility_timer > 0:
		visibility_timer -= 1
	$Text.modulate = Color(text_color.r,text_color.b,text_color.g,float(visibility_timer) / appear_time)
	
	if follow_player and visibility_timer > 0 and following_body != null:
		$Text.rect_position = following_body.position - position + offset

func _on_HoverText_body_entered(body):
	if body.name == "Player":
		appearing = true
		following_body = body

func _on_HoverText_body_exited(body):
	if body.name == "Player":
		appearing = false
		delay_timer = 0
