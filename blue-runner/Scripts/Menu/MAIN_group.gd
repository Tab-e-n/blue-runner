extends Node2D

export var button_position : Array = [
	Vector2(426, -304),
	Vector2(394, -208),
	Vector2(362, -112),
	Vector2(364, 0),
	Vector2(288, 112),
	Vector2(256, 208),
	Vector2(224, 304),
]

export var node_buttons : Array = ["button1", "button2", "button3", "button4", "button_exit"]
onready var buttons : Array = []
export var menu_colors : Array = [
	Color(0.25, 0.25, 0.75, 1),
	Color(0.25, 0.5, 0.75, 1),
	Color(0.25, 0.75, 0.75, 1),
	Color(0.25, 0.75, 0.5, 1),
	Color(0.25, 0.75, 0.25, 1)
]

export var buttons_amount : int = 4

export var node_anim : String = "anim"
onready var anim : AnimationPlayer = get_node(node_anim)

export(Array, int, "PASS", "EXIT", "MENU_TOP", "MENU_PLAY", "MENU_EXTRAS", "OPTIONS", "HELP", "PLAY", "VS", "REPLAY", "ACHIEVEMENTS", "CREDITS", "CHEATCODES") var submenu : Array = []

export var idle : bool = true
export var on_exit : bool = false
export var last_on_exit : bool = false
export var current_button : int = 1
export var last_button : int = 1
export var next_button : int = 1
export var time : float = 1
export var pulse_time : float = -1

func _ready():
	#get_node(node_anim)
	buttons.resize(node_buttons.size())
	for i in range(node_buttons.size()):
		buttons[i] = get_node(node_buttons[i])
	#buttons[node_buttons.size()] = self

#func _physics_process(_delta):
#	set_buttons()

func reset():
	on_exit = false
	last_on_exit = false
	current_button = 1
	last_button = 1
	next_button = 1

func set_buttons():
	if (next_button != current_button or on_exit != last_on_exit) and !anim.is_playing():
		anim.play("move")
		time = 0
	
	if idle == true and time != 1:
		current_button += sign(next_button - current_button)
		idle = false
	
	for i in range(buttons_amount):
		if i + 1 == current_button:
			if last_button == current_button:
				buttons[i].scale = Vector2(1.5, 1.5)
			else:
				buttons[i].scale = Vector2(1.125, 1.125) + Vector2(0.375, 0.375) * Vector2(time, time)
		elif i + 1 == last_button:
			buttons[i].scale = Vector2(1.5, 1.5) - Vector2(0.375, 0.375) * Vector2(time, time)
		else:
			buttons[i].scale = Vector2(1.125, 1.125)
		var current_pos : Vector2 = button_position[4 + i - current_button]
		var last_pos : Vector2 = button_position[4 + i - last_button]
		buttons[i].position = last_pos + (current_pos - last_pos) * Vector2(time, time)
	
	for i in range(buttons_amount):
		buttons[i].modulate = Color(0.5, 0.5, 0.5, 1)
	
	if on_exit == last_on_exit and on_exit:
		buttons[buttons_amount].modulate = Color(1, 1, 1, 1)
		
		material.set_shader_param("color", menu_colors[0])
	
	if on_exit != last_on_exit and on_exit:
		var dim : float = time / 2
		buttons[current_button - 1].modulate = Color(1 - dim, 1 - dim, 1 - dim, 1)
		buttons[buttons_amount].modulate = Color(0.5 + dim, 0.5 + dim, 0.5 + dim, 1)
		
		var color_difference : Color = menu_colors[0] - menu_colors[current_button]
		material.set_shader_param("color", menu_colors[current_button] + color_difference * time)
	
	if on_exit == last_on_exit and !on_exit:
		var dim : float = time / 2
		buttons[last_button - 1].modulate = Color(1 - dim, 1 - dim, 1 - dim, 1)
		buttons[current_button - 1].modulate = Color(0.5 + dim, 0.5 + dim, 0.5 + dim, 1)
		buttons[buttons_amount].modulate = Color(0.5, 0.5, 0.5, 1)
		
		var color_difference : Color = menu_colors[current_button] - menu_colors[last_button]
		material.set_shader_param("color", menu_colors[last_button] + color_difference * time)
	
	if on_exit != last_on_exit and !on_exit:
		var dim : float = time / 2
		buttons[current_button - 1].modulate = Color(0.5 + dim, 0.5 + dim, 0.5 + dim, 1)
		buttons[buttons_amount].modulate = Color(1 - dim, 1 - dim, 1 - dim, 1)
		
		var color_difference : Color = menu_colors[current_button] - menu_colors[0]
		material.set_shader_param("color", menu_colors[0] + color_difference * time)
	
	material.set_shader_param("offset", pulse_time)
