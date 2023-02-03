extends Node2D

onready var global : Control = $"/root/Global"
onready var parent : Node2D = get_parent()

var unlocked_characters : Array = []

var selected_char : int = 0

enum {PREVIOUS, CURRENT, NEXT, BONUS}
var updated_textures : Array = [null, null, null, null]

func check_character_unlocks():
	
	unlocked_characters = []
	for place in Global.loaded_characters.keys():
		for character in Global.loaded_characters[place].keys():
			
			var unlock_type : int = Global.loaded_characters[place][character][0]
			var parameter_1 = Global.loaded_characters[place][character][1]
			var parameter_2 = Global.loaded_characters[place][character][2]
			
			var check : bool = false
			
			if unlock_type == 5:
				check = Global.check_unlock_requirements(unlock_type, parameter_1, place)
			else:
				check = Global.check_unlock_requirements(unlock_type, parameter_1, parameter_2)
			
			if check:
				unlocked_characters.append([character, place, ""])
				
				if unlocked_characters.size() > 1: Global.unlock("*char_select_active")
	
	change_text()

func change_text():
	if Global.loaded_characters[unlocked_characters[selected_char][1]][unlocked_characters[selected_char][0]].size() > 3:
		$name.bbcode_text = Global.loaded_characters[unlocked_characters[selected_char][1]][unlocked_characters[selected_char][0]][3]
		$description.bbcode_text = Global.loaded_characters[unlocked_characters[selected_char][1]][unlocked_characters[selected_char][0]][4]
	else:
		$name.bbcode_text = unlocked_characters[selected_char][0]
		$description.bbcode_text = ""

func shift_renders(direction : int):
	direction = float(sign(direction))
	selected_char += direction
	if selected_char < 0:
		selected_char += unlocked_characters.size()
	if selected_char >= unlocked_characters.size():
		selected_char -= unlocked_characters.size()
	
	change_text()
	
	if direction == -1:
		updated_textures[BONUS] = $char_next/sprite.texture
		updated_textures[NEXT] = $char_current/sprite.texture
		updated_textures[CURRENT] = $char_previous/sprite.texture
		load_render(PREVIOUS, selected_char - 1)
		$anim.stop()
		$anim.play("Up")
	elif direction == 1:
		updated_textures[BONUS] = $char_previous/sprite.texture
		updated_textures[PREVIOUS] = $char_current/sprite.texture
		updated_textures[CURRENT] = $char_next/sprite.texture
		load_render(NEXT, selected_char + 1)
		$anim.stop()
		$anim.play("Down")
	else:
		return

func update_textures():
	if updated_textures[PREVIOUS] != null:
		$char_previous/sprite.texture = updated_textures[PREVIOUS]
		Global.scale_down_sprite($char_previous/sprite, Vector2(1, 1), Vector2(384, 384))
	if updated_textures[CURRENT] != null:
		$char_current/sprite.texture = updated_textures[CURRENT]
		Global.scale_down_sprite($char_current/sprite, Vector2(1, 1), Vector2(384, 384))
	if updated_textures[NEXT] != null:
		$char_next/sprite.texture = updated_textures[NEXT]
		Global.scale_down_sprite($char_next/sprite, Vector2(1, 1), Vector2(384, 384))
	if updated_textures[BONUS] != null:
		$char_bonus/sprite.texture = updated_textures[BONUS]
		Global.scale_down_sprite($char_bonus/sprite, Vector2(1, 1), Vector2(384, 384))

func ready_renders():
	load_render(PREVIOUS, selected_char - 1)
	load_render(CURRENT, selected_char)
	load_render(NEXT, selected_char + 1)
	update_textures()

func load_render(sprite : int, index : int):
	if unlocked_characters.size() == 0:
		updated_textures[sprite] = preload("res://Visual/Menu/no_character_found.png")
		return
	if index < 0:
		index += unlocked_characters.size()
	if index >= unlocked_characters.size():
		index -= unlocked_characters.size()
	
	var texture : Texture
	if unlocked_characters[index][2] != "":
		texture = load(unlocked_characters[index][2])
	else:
		texture = load(unlocked_characters[index][1] + "/Visual/" + unlocked_characters[index][0] + "/portrait.png")
		unlocked_characters[index][2] = unlocked_characters[index][1] + "/Visual/" + unlocked_characters[index][0] + "/portrait.png"
		if texture == null:
			texture = preload("res://Visual/Menu/no_character_found.png")
			unlocked_characters[index][2] = "res://Visual/Menu/no_character_found.png"
	updated_textures[sprite] = texture

func menu_update():
	$back.text = global.key_names(7) + " - Go Back"
	
	if Input.is_action_just_pressed("jump"):
		Global.current_character = unlocked_characters[selected_char][0]
		Global.current_character_location = unlocked_characters[selected_char][1]
		Global.change_level("", true)
		parent.get_node("AnimationPlayer").play("CHARACTER-SELECT")
		parent.menu = "SELECT"
		parent.get_node("SELECT/fail").visible = true
	
	if (Input.is_action_pressed("up") or Input.is_action_pressed("left")) and parent.move:
		shift_renders(-1)
	
	if (Input.is_action_pressed("down") or Input.is_action_pressed("right")) and parent.move:
		shift_renders(1)
