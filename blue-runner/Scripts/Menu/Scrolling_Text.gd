extends Control

export var default_text : String = ""
export var scroll_speed : float = 1
export var pause_time : int = 60

var direction : int = -1
var size_difference : float

onready var paused_timer : int = pause_time

func _ready():
	set_text(default_text)

func _physics_process(_delta):
	if size_difference > 0 and paused_timer == 0:
		$text.rect_position.x += scroll_speed * direction
		if $text.rect_position.x <= -size_difference:
			direction = 1
			paused_timer = pause_time
		if $text.rect_position.x >= 0:
			direction = -1
			paused_timer = pause_time
	if paused_timer > 0:
		paused_timer -= 1

func set_text(text, rect_pos = 0, paused = pause_time, new_direction = -1):
	$text.text = text
	$text.rect_size.x = $text.get_font("normal_font").get_string_size($text.text).x
	size_difference = ($text.rect_size.x * $text.rect_scale.x) - rect_size.x
	$text.rect_position.x = rect_pos
	paused_timer = paused
	direction = new_direction
