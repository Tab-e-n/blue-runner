extends Panel


signal swap_position(old, new)


export var index : int = 0


func _ready():
	pass


func setup(list_size : int, text : String = $text.text):
	if index < list_size:
		visible = true
		$up.visible = index != 0
		$down.visible = index != list_size - 1
		$text.text = text
	else:
		visible = false


func new_text(text : String):
	$text.text = text


func swap(direction : int):
	var new_index = index + direction
	emit_signal("swap_position", index, new_index)
