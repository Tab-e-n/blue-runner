extends Node2D

export var world : int = 1
export var level : int = 0
export var level_name : String
export var level_symbol : Texture
export var locked : bool = false
export var level_normal : Texture
export var level_locked : Texture
export var level_done : Texture
export var level_perfect : Texture

onready var global : Control = $"/root/Global"

var time : float = 0
var par : float = 0
var level_base : Array = ["",""]

func _ready():
	#reload()
	pass

func _process(_delta):
	pass

func reload():
	var temp : Dictionary = global.load_level_dat_file(level_name, true)
	var type : int = typeof(temp["level_icon"])
	var temp_level_symbol
	
	if type == TYPE_ARRAY:
		temp_level_symbol = load(temp["level_icon"][1] + "/Visual/Level/" + temp["level_icon"][0])
	elif type == TYPE_STRING:
		temp_level_symbol = load("res://Visual/Level/" + temp["level_icon"] + ".png")
	if temp_level_symbol != null: level_symbol = temp_level_symbol
	$symbol.texture = level_symbol
	
	if temp.has("level_base"): if level_base[1]+level_base[0] != temp["level_base"][1]+temp["level_base"][0]:
		var loadfile = File.new()
		var loaded = {}
		
		if loadfile.file_exists(temp["level_base"][1] + "/Visual/Level/base.dat"): # does file exist
			loadfile.open(temp["level_base"][1] + "/Visual/Level/base.dat", File.READ)
			
			while loadfile.get_position() < loadfile.get_len():
				var parsedData = parse_json(loadfile.get_line())
				
				loaded = parsedData
			
			loadfile.close()
		
		level_normal = load(temp["level_icon"][1] + "/Visual/Level/" + loaded[temp["level_base"][0]][0])
		level_locked = load(temp["level_icon"][1] + "/Visual/Level/" + loaded[temp["level_base"][0]][1])
		level_done = load(temp["level_icon"][1] + "/Visual/Level/" + loaded[temp["level_base"][0]][2])
		level_perfect = load(temp["level_icon"][1] + "/Visual/Level/" + loaded[temp["level_base"][0]][3])
	
	$icon.texture = level_normal
	$boltcollect.visible = false
	if locked:
		$icon.texture = level_locked
	elif global.level_completion.has(level_name): if global.level_completion[level_name][0] != null:
		time = global.level_completion[level_name][0]
		par = global.level_completion[level_name][1]
		
		$boltcollect/Anim.stop()
		if global.level_completion.has(String((world - 1) * 20 + level)):
			$boltcollect.visible = true
			$boltcollect/Anim.play("Idle")
		
		$icon.texture = level_done
		if time < par or par == 0:
			$icon.texture = level_perfect


