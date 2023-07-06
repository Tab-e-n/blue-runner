extends Node2D

onready var global : Control = $"/root/Global"

var current_key : int = 0

var booting = true

var text = [
	"MOTRBIOS (C) 2022 Luke Adams\n",
	"BIOS date 29/2/00 14:10:32\n",
	"CPU:",
	" VVIDYA Jetstream Nano\n",
	"Memory:",
	" SD/CCMN 4096MB\n",
	"WARNING: Machine has been tampered with\n\n",
	
	"Press F12 to reset motor settings.\n",
	"Checking motor settings",
	".",
	".",
	". ",
	"",
	"",
	"",
	"",
	["no motor settings found\n", "motor settings found\n", "F12 pressed, doing new bindings\n", "looks like someone had a little fun :)\n"],
	"",
	"",
	"",
	"",
	["Use defaults? (y/n): ", "Use current bindings? (y/n): "],
	
	"LEFT - ",
	"RIGHT - ",
	"UP - ",
	"DOWN - ",
	"JUMP - ",
	"SPECIAL - ",
	"RESET - ",
	"RETURN - ",
	"MENU LEFT - ",
	"MENU RIGHT - ",
	"MENU UP - ",
	"MENU DOWN - ",
	"ACCEPT - ",
	"DECLINE - ",
	
	
	"If you are unhappy with these, you can change them in the options.\n",
	["press any key to continue... \n"],
	"Booting system",
	".",
	".",
	". ",
	"done\n",
	"Unlocking servos",
	".",
	".",
	". ",
	"done\n",
	"Starting camera",
	".",
	".",
	". ",
	"done\n",
]

var sentence : int = 0

var delay_timer : int = 0
var LINE_DELAY = 8

var timer_going : bool = true

var duplicates : bool = false
var rebind : bool = false

var dont_bind : bool = false

var section : int = 0

func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta):
	if timer_going:
		delay_timer += 1
	if delay_timer >= LINE_DELAY:
		delay_timer = 0
		if sentence < text.size():
			if typeof(text[sentence]) == TYPE_ARRAY:
				timer_going = false
				if section == 0:
					checking_motor()
					timer_going = true
				if section == 1:
					if duplicates:
						$t/boot.text += text[sentence][1]
					elif global.options["*first_time_load"]:
						$t/boot.text += text[sentence][0]
					elif rebind:
						$t/boot.text += text[sentence][0]
					else:
						$t/boot.text += text[sentence][1]
				if section == 3:
					$t/boot.text += text[sentence][0]
				section += 1
				
				if dont_bind:
					timer_going = true
					if section == 2:
						sentence += 1
						bind_skip()
			else:
				$t/boot.text += text[sentence]
		else:
			global.options["*first_time_load"] = false
			$t/anim.play("out")
		sentence += 1

func checking_motor():
	for key in range(Global.keybind_names.size()):
		var key_number = Global.options[Global.keybind_names[key]]
		for i in range(8 - key - 1):
			var key_check = Global.options[Global.keybind_names[i + key + 1]]
			if key_check == key_number:
				duplicates = true
				break
	if duplicates:
		$t/boot.text += text[sentence][3]
	elif global.options["*first_time_load"]:
		$t/boot.text += text[sentence][0]
	elif rebind:
		$t/boot.text += text[sentence][2]
	else:
		$t/boot.text += text[sentence][1]
		dont_bind = true
		LINE_DELAY = 2

func _input(event):
	if event is InputEventKey and event.pressed:
		if event.scancode == KEY_F12:
			rebind = true
		elif section == 4:
			timer_going = true
		elif section == 2 and !timer_going:
			if event.scancode == KEY_Y:
				bind_skip()
			elif event.scancode == KEY_N:
				$t/boot.text += "N\n\n"
				$t/boot.text += text[sentence]
				sentence += 1
				booting = false
				section += 1
		elif !booting:
			if current_key < Global.keybind_names.size():
				global.change_input(current_key, event)
				$t/boot.text += global.key_names(current_key)
				current_key += 1
				$t/boot.text += "\n"
				if current_key == Global.keybind_names.size():
					#$t/boot.text += text[sentence][0]
					#sentence += 1
					$t/boot.text += "\n"
					current_key += 1
					timer_going = true
				$t/boot.text += text[sentence]
				sentence += 1
				#$t/anim.play("out")
					#$t/anim.play("prompt")
		else:
			LINE_DELAY = 2

func bind_skip():
	$t/boot.text += "Y\n\n"
	for i in range(Global.keybind_names.size()):
		$t/boot.text += text[sentence]
		sentence += 1
		$t/boot.text += global.key_names(i)
		$t/boot.text += "\n"
	$t/boot.text += "\n"
	timer_going = true
	section += 1

func anim_end():
	Global.change_level("*MENU")
