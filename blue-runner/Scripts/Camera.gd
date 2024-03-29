extends Camera2D

var color_timer : float = 0

export var compatibility_mode : bool = false
export var limit_x : Vector2 = Vector2(0,0)
export var limit_y : Vector2 = Vector2(0,0)

onready var bg : Node2D
var scrolling_objects : Array = []
onready var cam_target : Node2D
var tele_destination : String

var end_zoom : bool = false
const end_timer_const : int = 60
var end_timer : float = end_timer_const

var end_zoom_begin : float
var end_pos_begin : Vector2
# Color(0.87451, 0.909804, 0.905882)

var replay_saved : bool = true
var speedometer_active : bool = false
var visible_timer : bool = false

func _ready():
	$Fade.visible = true
	$border.visible = true
	visible_timer = $"/root/Global".options["*timer_on"]
	
	if get_parent().has_node("BG"):
		bg = get_parent().get_node("BG")
	
	cam_target = get_parent().find_node("Player")
	if cam_target == null:
		cam_target = get_parent().find_node("CamTarget")
		speedometer_active = false
		visible_timer = false
	if cam_target == null:
		cam_target = self
	
	if speedometer_active: visible_timer = false
	$info.visible = speedometer_active or visible_timer
	$speed.visible = speedometer_active
	
	$camera_inputs/continue.text = $"/root/Global".key_names(4)
	$camera_inputs/reset.text = $"/root/Global".key_names(6)
	
	if Global.compatibility_mode: compatibility_mode = true
	
	if compatibility_mode:
		$border.polygon[0].x = -512
		$border.polygon[1].x = 512
		$border.polygon[2].x = 512
		$border.polygon[7].x = -512

func _physics_process(_delta):
	if color_timer < 12:
		var color = $Fade.color
		$Fade.color = Color(color.r,color.g,color.b,(10-color_timer)/10)
		
		color_timer += 1
		if color_timer == 11: $Fade.visible = false
	if color_timer > 13:
		var color = $Fade.color
		color_timer -= 1
		
		# warning-ignore:return_value_discarded
		if color_timer == 13: 
			if Global.race_mode:
				Global.change_level("*Menu_Level_Select")
			else: 
				Global.change_level(tele_destination)
		else:
			$Fade.color = Color(color.r,color.g,color.b,(24-color_timer)/10)
	
	if !end_zoom:
		position.x = int(cam_target.position.x / 2) * 2
		if position.x < limit_x.x: position.x = limit_x.x
		if position.x > limit_x.y: position.x = limit_x.y
		
		position.y = int(cam_target.position.y / 2) * 2
		if position.y < limit_y.x: position.y = limit_y.x
		if position.y > limit_y.y: position.y = limit_y.y
		if speedometer_active:
			var temp_calc = (abs(cam_target.momentum.x) + abs(cam_target.momentum.y)) / 10
			$speed.rotation_degrees = temp_calc / 2
			$info/text.text = String(temp_calc)
		if visible_timer and (cam_target.timer <= cam_target.replay_timer + 0.016 or !cam_target.replay):
			var minutes : int = int(floor(cam_target.timer) / 60)
			var seconds : int = int(floor(cam_target.timer)) - minutes * 60
			var decimal : int = int(floor(cam_target.timer * 100 + 0.1)) % 100
			
			# warning-ignore:integer_division
			# warning-ignore:integer_division
			$info/text.text = String(minutes)+":"+String(seconds/10)+String(seconds%10)+"."+String(decimal/10)+String(decimal%10)
	else:
		$info.visible = false
		$speed.visible = false
		
		zoom.x = 1 + (end_zoom_begin - 1) / end_timer_const * end_timer
		zoom.y = 1 + (end_zoom_begin - 1) / end_timer_const * end_timer
		
		$border_thing.scale.x = zoom.x + (zoom.x * 0.5) / end_timer_const * end_timer
		$border_thing.scale.y = zoom.y + (zoom.y * 0.5) / end_timer_const * end_timer
		
		$camera_inputs.scale = $border_thing.scale
		
		$camera_inputs.position.y = 80.0 / end_timer_const * end_timer
		
		position.x = cam_target.position.x + (end_pos_begin.x - cam_target.position.x) / end_timer_const * end_timer
		position.y = cam_target.position.y + (end_pos_begin.y - cam_target.position.y) / end_timer_const * end_timer
		
		
		if end_timer > 0: end_timer -= end_timer / 20
		if end_timer < 0.1: end_timer = 0
		
		if end_timer < 10 and color_timer < 13:
			if Input.is_action_pressed("jump"):
				color_timer = 24
				$Fade.visible = true
			if Input.is_action_just_pressed("special") and replay_saved:
				var date = OS.get_datetime()
				
				Global.save_replay(get_parent().name
				+"_"+String(date["year"])
				+"-"+String(date["month"])
				+"-"+String(date["day"])
				+"_"+String(date["hour"])
				+"-"+String(date["minute"])
				+"-"+String(date["second"]),
				get_parent().get_node("Player").recording.duplicate())
				
				$border_thing/replay.text = "REPLAY SAVED"
				replay_saved = false
				
	if scrolling_objects != []:
		for i in scrolling_objects:
			i.update_self(position)
	if bg != null: bg.update_self(position)
	$Fade.scale = zoom
	$border.scale = zoom
	$info.scale = zoom

func end_zoom_in(target : Node2D, tele, timer : float, par : float):
	end_zoom = true
	cam_target = target
	tele_destination = tele
	end_zoom_begin = zoom.x
	end_pos_begin = position
	$border_thing.visible = true
	$camera_inputs.visible = true
	$border_thing.scale = zoom * 4
	$camera_inputs.scale = zoom * 4
	
	$border_thing/replay.text = "SAVE REPLAY - " + Global.key_names(5)
	
	$border_thing/camera_square/timer.text = Global.convert_float_to_time(timer)
	if par == 0:
		$border_thing/camera_square/par.text = "no par\ntime"
	else:
		$border_thing/camera_square/par.text = "par\n" + Global.convert_float_to_time(par)
	
