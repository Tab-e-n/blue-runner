extends Control

export var default_text : String = ""
export var line_number : int = 1
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
	
	if line_number > 1:
		var scaling : int = ceil(($text.rect_size.x * $text.rect_scale.x) / rect_size.x)
		print(scaling)
		if scaling != 1:
			var fake_line_number : int
			if scaling < line_number:
				fake_line_number = scaling
			elif scaling >= line_number:
				fake_line_number = line_number
			
			var line_character : int = text.length() / fake_line_number
			var lines : Array = range(fake_line_number)
			var last_pos : int = 0
			for i in range(fake_line_number - 1):
				var empty_pos : int = text.find(" ", line_character * (i + 1)) + 1
				if empty_pos == -1:
					empty_pos = line_character * (i + 1)
				var line_text = text.substr(last_pos, empty_pos)
				lines[i] = line_text
				last_pos = empty_pos
			lines[fake_line_number - 1] = text.substr(last_pos, text.length() - 1)
			#print(lines)
			var longest_line = lines[0]
			text = lines[0]
			for i in range(fake_line_number - 1):
				text += "\n" + lines[i + 1]
				if lines[i + 1].length() > longest_line.length():
					longest_line = lines[i + 1]
			#print(longest_line)
			
			$text.text = text
			$text.rect_size.x = $text.get_font("normal_font").get_string_size(longest_line).x
	
	size_difference = ($text.rect_size.x * $text.rect_scale.x) - rect_size.x
	
	$text.rect_position.x = rect_pos
	paused_timer = paused
	direction = new_direction
