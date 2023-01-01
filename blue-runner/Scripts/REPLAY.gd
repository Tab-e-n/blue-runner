extends Node2D

onready var global : Control = $"/root/Global"
onready var parent : Node2D = get_parent()

var delete_confirmation : bool = false
var selected_replay : int = 0
var replay_menu_mode : int = 0

export var reset = true

func _ready():
	pass

func _physics_process(_delta):
	if reset: reset_replays()

func menu_update():
	# - - - OPTION SELECT - - -
	if Input.is_action_just_pressed("special"):
		replay_menu_mode += 1
		if replay_menu_mode > 2: 
			replay_menu_mode = 0
			delete_confirmation = false
	
	if Input.is_action_just_pressed("jump"):
		global.replay_save[0] = selected_replay
		global.replay_save[1] = replay_menu_mode
		if $replay_list.get_item_count() > 0:
			if replay_menu_mode == 0 or replay_menu_mode == 1:
				var selected_list_replay = $replay_list.get_selected_items()[0]
				
				global.current_recording = global.load_replay($replay_list.get_item_text(selected_list_replay), false)
				
				if replay_menu_mode == 1: global.race_mode = true
				else: global.replay = true
				
				global.replay_menu = true
				
				# warning-ignore:return_value_discarded
				get_tree().change_scene("res://Scenes/" + global.current_recording["level"] + ".tscn")
			if replay_menu_mode == 2:
				if delete_confirmation:
					var selected_list_replay = $replay_list.get_selected_items()[0]
					global.delete_replay($replay_list.get_item_text(selected_list_replay))
					$replay_list.remove_item(selected_list_replay)
					if selected_replay > $replay_list.get_item_count() - 1:
						selected_replay = $replay_list.get_item_count() - 1
						$replay_list.select(selected_replay)
					
					delete_confirmation = false
				else:
					delete_confirmation = true
	if Input.is_action_pressed("up") and parent.move and selected_replay > 0:
		selected_replay -= 1
		$replay_list.select(selected_replay)
		$replay_list.ensure_current_is_visible()
		delete_confirmation = false
	if Input.is_action_pressed("down") and parent.move and selected_replay < $replay_list.get_item_count() - 1:
		selected_replay += 1
		$replay_list.select(selected_replay)
		$replay_list.ensure_current_is_visible()
		delete_confirmation = false
	
	if delete_confirmation: 
		$replay_text.text = "ARE YOU SURE?"
	else: match(replay_menu_mode):
		0:
			$replay_text.text = "VIEW"
		1:
			$replay_text.text = "RACE"
		2:
			$replay_text.text = "DELETE"
	
	$hint.text = "Switch mode with " + global.key_names(5)

func reset_replays():
	$replay_list.clear()
	
	#dir shenanigans
	var dir = Directory.new()
	dir.open("user://SRReplays")
	
	dir.list_dir_begin(true, false)
	var last_replay : String = "*"
	
	last_replay = dir.get_next()
	while last_replay != "":
		$replay_list.add_item(last_replay)
		last_replay = dir.get_next()
	
	dir.list_dir_end()
	
	$replay_list.select(selected_replay)
	$replay_list.visible = true
	$replay_text.visible = true
	
	reset = false
