extends Node2D

onready var parent : Node2D = get_parent()

var achivements_definition : Dictionary = {
	#"ID" : ["Achievement Name", "Achievement Description", is_hidden, unlock_type, parameter_1, parameter_2]
	"complete_waterway" : ["Complete WaterWay", "Get 100% completion on WaterWay.", false, 3, "res://Scenes/waterway/", 100],
	"code_missing" : ["missing", "code nothing", false, 5, "*character_missing", ""],
	"greenbox" : ["Simple fun plat-", "This ain`t no kat!", false, 5, "*character_greenbox", ""],
}
var row_amount : int = 0
var cursor_pos : Vector2 = Vector2(0, 0)

func _ready():
	make_the_achivements()
	move_cursor()
	$bg.self_modulate.a = 0
	$achieve_checkerboard.self_modulate.a = 0
	$achieve_checkerboard2.self_modulate.a = 0
	$selection.self_modulate.a = 0
	$achivements.modulate.a = 0
	$achieve_description.modulate.a = 0
	$mainAnim.play("Enter")

func menu_update():
	if Input.is_action_just_pressed("deny"):
		parent.switch_menu("MAIN", "ACHIEVEMENTS")
		$mainAnim.play("Exit")
	
	
	if Input.is_action_pressed("menu_left") and parent.move:
		move_cursor(Vector2(-1, 0))
	if Input.is_action_pressed("menu_right") and parent.move:
		move_cursor(Vector2(1, 0))
	if Input.is_action_pressed("menu_up") and parent.move:
		move_cursor(Vector2(0, -1))
	if Input.is_action_pressed("menu_down") and parent.move:
		move_cursor(Vector2(0, 1))

func move_cursor(movement : Vector2 = Vector2(0, 0)):
#	print(cursor_pos)
	if movement.x != 0:
		if cursor_pos.x + movement.x >= 0 and cursor_pos.x + movement.x < 3:
			cursor_pos.x += movement.x
	if movement.y != 0:
		if cursor_pos.y + movement.y >= 0 and cursor_pos.y + movement.y < row_amount:
			cursor_pos.y += movement.y
	if cursor_pos.y == row_amount - 1 and achivements_definition.size() % 3:
		if cursor_pos.x >= achivements_definition.size() % 3:
			cursor_pos.x = achivements_definition.size() % 3 - 1
	
	$selection.position.x = -384 + 384 * cursor_pos.x
	$achivements.position.y = -96 * cursor_pos.y
	var ach_name = achivements_definition.keys()[cursor_pos.y * 3 + cursor_pos.x]
	if not achivements_definition[ach_name][2]:
		$achieve_description/description.text = achivements_definition[ach_name][1]

func make_the_achivements():
	var ach_amount = achivements_definition.size()
	row_amount = (ach_amount - 1) / 3 + 1
	
	var ach_names : Array = achivements_definition.keys()
	for i in range(achivements_definition.size()):
		# warning-ignore:integer_division
		var new_pos : Vector2 = Vector2((-1 + (i % 3)) * 384, ((i) / 3) * 96)
		create_achievement(ach_names[i], new_pos)

func create_achievement(ach_name : String, new_pos : Vector2):
	var completed : bool = Global.check_unlock_requirements(achivements_definition[ach_name][3], achivements_definition[ach_name][4], achivements_definition[ach_name][5])
	var hidden : bool = achivements_definition[ach_name][2]
	
	var new_achivement : Sprite = Sprite.new()
	if completed:
		new_achivement.texture = preload("res://Visual/Achievement/completed.png")
	else:
		new_achivement.texture = preload("res://Visual/Achievement/unfinished.png")
	new_achivement.position = new_pos
	$achivements.add_child(new_achivement)
	
	var ach_icon : Sprite = Sprite.new()
	var texture : Texture = null
	if hidden:
		if completed:
			texture = load("res://Visual/Achievement/" + ach_name + ".png")
		else:
			texture = preload("res://Visual/Achievement/missing.png")
	else:
		if completed:
			texture = load("res://Visual/Achievement/" + ach_name + "_completed.png")
		if texture == null:
			texture = load("res://Visual/Achievement/" + ach_name + ".png")
	if texture == null:
		texture = preload("res://Visual/Achievement/missing.png")
	ach_icon.texture = texture
	ach_icon.position.x = -144
	new_achivement.add_child(ach_icon)
	
	var label : Label = Label.new()
	label.rect_position = Vector2(-104, -32)
	label.rect_size = Vector2(280, 64)
	label.add_font_override("font", preload("res://Text/Shixel_Small.tres"))
	if hidden and !completed:
		label.text = "Hidden Achievement"
	else:
		label.text = achivements_definition[ach_name][0]
	label.align = Label.ALIGN_CENTER
	label.valign = Label.VALIGN_CENTER
	if completed:
		label.add_color_override("font_color", Color(0.24, 0.89, 0.57))
	else:
		label.add_color_override("font_color", Color(0.24, 0.35, 0.29))
	label.autowrap = true
	new_achivement.add_child(label)
