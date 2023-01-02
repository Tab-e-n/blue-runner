extends Node2D

export var world : int = 1
export var level : int = 0
export var level_name : String
export var level_symbol : Texture
export var locked : bool = false

onready var global : Control = $"/root/Global"

var time : float = 0
var par : float = 0
var level_base : Array = ["",""]

var level_dat : Dictionary 
var base : Dictionary

func _ready():
	pass

func _process(_delta):
	pass

func load_base():
	level_dat = global.load_level_dat_file(level_name, true)
	if typeof(level_dat) == TYPE_NIL:
		level_dat = {
			"level_base" : ["base","res:/"],
			"level_icon" : ["questionmark","res:/"],
		}
	if level_dat.has("level_base"): if level_base[1]+level_base[0] != level_dat["level_base"][1]+level_dat["level_base"][0]:
		var loadfile = File.new()
		
		if loadfile.file_exists(level_dat["level_base"][1] + "/Visual/Level/base.dat"): # does file exist
			loadfile.open(level_dat["level_base"][1] + "/Visual/Level/base.dat", File.READ)
			
			while loadfile.get_position() < loadfile.get_len():
				var parsedData = parse_json(loadfile.get_line())
				
				base = parsedData
			
			loadfile.close()

func reload():
	load_base()
	
	var type : int = typeof(level_dat["level_icon"])
	
	if type == TYPE_ARRAY:
		level_symbol = load(level_dat["level_icon"][1] + "/Visual/Level/" + level_dat["level_icon"][0])
	elif type == TYPE_STRING:
		level_symbol = load("res://Visual/Level/" + level_dat["level_icon"] + ".png")
	if level_symbol == null: 
		level_symbol = load("res://Visual/Level/questionmark.png")
	$symbol.texture = level_symbol
	
	$boltcollect.visible = false
	if locked:
		$icon.texture = load(level_dat["level_icon"][1] + "/Visual/Level/" + base[level_dat["level_base"][0]][1])
	elif global.level_completion.has(level_name): if global.level_completion[level_name][0] != null:
		time = global.level_completion[level_name][0]
		par = global.level_completion[level_name][1]
		
		$boltcollect/Anim.stop()
		if global.level_completion.has(String((world - 1) * 20 + level)):
			$boltcollect.visible = true
			$boltcollect/Anim.play("Idle")
		
		if time < par or par == 0:
			$icon.texture = load(level_dat["level_icon"][1] + "/Visual/Level/" + base[level_dat["level_base"][0]][3])
		else:
			$icon.texture = load(level_dat["level_icon"][1] + "/Visual/Level/" + base[level_dat["level_base"][0]][2])
	else:
		$icon.texture = load(level_dat["level_icon"][1] + "/Visual/Level/" + base[level_dat["level_base"][0]][0])
