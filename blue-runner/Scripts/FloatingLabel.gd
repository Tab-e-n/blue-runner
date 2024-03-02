extends Area2D


const DEFAULT_TEXT_SIZE : Vector2 = Vector2(128, 128)


export(String, MULTILINE) var text : String = """empty"""
export var text_scale : Vector2 = Vector2(0.75, 0.75)
export var text_color : Color = Color(0.92, 0.93, 0.95, 1)
export var text_outline : Color = Color(0.02, 0.02, 0.13, 1)
export var font : String = "Lacrimae"
export var align : int = 1
export var valign : int = 1
export var delay : float = 0
export var fade : float = 1


var active : bool = false
var delay_timer : float = 0
var fade_timer : float = 0


func _ready():
	var target_scale = scale
	scale = Vector2(1, 1)
	$coll.scale = target_scale
	$label.rect_scale = text_scale
	$label.rect_size = (DEFAULT_TEXT_SIZE * target_scale) / text_scale
	$label.rect_position = -(DEFAULT_TEXT_SIZE * target_scale) * Vector2(0.5, 0.5)
	$label.text = Global.text_interpretor(text)
	$label.align = align
	$label.valign = valign
	
	var font_file = load("res://Text/" + font + ".tres")
	if font_file != null:
		$label.add_font_override("font", font_file)
	
	$label.add_color_override("font_color", text_color)
	$label.add_color_override("font_outline_modulate", text_outline)


func _physics_process(delta):
	if active:
		if delay_timer < delay:
			delay_timer += delta
		elif fade_timer < fade:
			fade_timer += delta
	else:
		if fade_timer > 0:
			fade_timer -= delta
		elif delay_timer > 0:
			delay_timer -= delta
	
	$label.visible = fade_timer > 0
	if fade_timer >= fade or fade == 0:
		$label.modulate.a = 1
	elif fade_timer > 0:
		$label.modulate.a = fade_timer / fade


func _on_body_entered(body):
	if body is Player:
		active = true


func _on_body_exited(body):
	if body is Player:
		active = false
