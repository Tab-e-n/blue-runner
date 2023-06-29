extends Node2D


func set_color(color : Color):
	$completion_filling.modulate = color * Color(0.5, 0.5, 0.5, 1)
	$bar.modulate = color
	$completion_outline.modulate = color

func set_completion(percent : float):
	$text.bbcode_text = "[center]" + String(stepify(percent, 1)) + "%[/center]"
	$bar.scale.x = percent / 100
