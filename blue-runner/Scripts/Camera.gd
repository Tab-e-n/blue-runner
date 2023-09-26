extends Camera2D

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

var fade_in : bool = true
var fade_in_timer : float = 0
export var fade_in_darkness_lenght : int = 0
export var fade_in_end : int = 12

var fade_out : bool = false
var fade_out_timer : float = 0
export var fade_out_darkness_lenght : int = 0
export var fade_out_end : int = 12

func _ready():
	$Fade.visible = true
	$border.visible = true
	$border_thing.visible = false
	$complete_dark.visible = true
	if $"/root/Global".options["*timer_on"] == 1:
		visible_timer = true
	elif $"/root/Global".options["*timer_on"] == 2:
		visible_timer = Global.check_unlock_requirements(Global.UNLOCK_BEAT, Global.current_level_location, Global.current_level)
	
	if get_parent().has_node("BG"):
		bg = get_parent().get_node("BG")
	
	cam_target = get_parent().find_node("Player")
	if cam_target == null:
		cam_target = get_parent().find_node("CamTarget")
		speedometer_active = false
		visible_timer = false
	if cam_target == null:
		cam_target = self
	
	if speedometer_active:
		visible_timer = false
	$info/text.visible = speedometer_active or visible_timer
	$info/speed.visible = speedometer_active
	
	$border_thing/continue.text = $"/root/Global".key_names(4)
	$border_thing/reset.text = $"/root/Global".key_names(6)
	
	if Global.compatibility_mode:
		compatibility_mode = true
	
	if compatibility_mode:
		$border.polygon[0].x = -512
		$border.polygon[1].x = 512
		$border.polygon[2].x = 512
		$border.polygon[7].x = -512
		
		$border_thing/camera_input_continue.position.x = 480
		$border_thing/camera_input_reset.position.x = -480
		$border_thing/continue.rect_size.x = 512
		$border_thing/reset.rect_size.x = 512
		$border_thing/reset.rect_position.x = -416

func _physics_process(_delta):
	if has_node("complete_dark"):
		$complete_dark.call_deferred("queue_free")
	
	if fade_in_timer < fade_in_end + fade_in_darkness_lenght and fade_in:
		fade_in_timer += 1
		if fade_in_timer == fade_in_end + fade_in_darkness_lenght:
			$Fade.visible = false
		elif fade_in_timer > fade_in_darkness_lenght:
			var color = $Fade.color
			var max_fade = fade_in_end - 2
			var fade_timer = fade_in_timer - fade_in_darkness_lenght
			$Fade.color = Color(color.r,color.g,color.b,(max_fade-fade_timer)/max_fade)
	
	if fade_out_timer < fade_out_end + fade_out_darkness_lenght and fade_out:
		fade_out_timer += 1
		if fade_out_timer == fade_out_end + fade_out_darkness_lenght:
			if Global.race_mode:
				Global.change_level("*MENU")
			else: 
				Global.change_level(tele_destination)
		elif fade_out_timer < fade_out_end:
			var color = $Fade.color
			var max_fade = fade_out_end - 2
			$Fade.color = Color(color.r,color.g,color.b,fade_out_timer/max_fade)
			
		# warning-ignore:return_value_discarded
	
	if !end_zoom:
		position.x = int(cam_target.position.x / 2) * 2
		if position.x < limit_x.x: position.x = limit_x.x
		if position.x > limit_x.y: position.x = limit_x.y
		
		position.y = int(cam_target.position.y / 2) * 2
		if position.y < limit_y.x: position.y = limit_y.x
		if position.y > limit_y.y: position.y = limit_y.y
		if speedometer_active:
			var temp_calc = (abs(cam_target.momentum.x) + abs(cam_target.momentum.y)) / 10
			$info/speed.rotation_degrees = temp_calc / 2
			$info/text.text = String(temp_calc)
		if visible_timer and (cam_target.timer <= cam_target.replay_timer + 0.016 or !cam_target.replay):
			$info/text.text = Global.convert_float_to_time(cam_target.timer)
	else:
		$info.visible = false
		
		zoom.x = 1 + (end_zoom_begin - 1) / end_timer_const * end_timer
		zoom.y = 1 + (end_zoom_begin - 1) / end_timer_const * end_timer
		
		$border_thing.scale.x = zoom.x + (zoom.x * 0.5) / end_timer_const * end_timer
		$border_thing.scale.y = zoom.y + (zoom.y * 0.5) / end_timer_const * end_timer
		
#		$camera_inputs.scale = $border_thing.scale
		
#		$camera_inputs.position.y = 80.0 / end_timer_const * end_timer
		
		position.x = cam_target.position.x + (end_pos_begin.x - cam_target.position.x) / end_timer_const * end_timer
		position.y = cam_target.position.y + (end_pos_begin.y - cam_target.position.y) / end_timer_const * end_timer
		
		
		if end_timer > 0:
			end_timer -= end_timer / 20
		if end_timer < 0.1:
			end_timer = 0
		
		if end_timer < 10 and not fade_out:
			if Input.is_action_pressed("jump"):
				start_fade_out(tele_destination)
			if Input.is_action_just_pressed("special") and replay_saved:
				Global.save_replay_with_date(get_parent().name, get_parent().get_node("Player").recording.duplicate())
				
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
#	$camera_inputs.visible = true
	$border_thing.scale = zoom * 4
#	$camera_inputs.scale = zoom * 4
	
	$border_thing/replay.text = "SAVE REPLAY - " + Global.key_names(5)
	
	$border_thing/timer.text = Global.convert_float_to_time(timer)
	if par == 0:
		$border_thing/par.text = "no par time"
	else:
		$border_thing/par.text = "par " + Global.convert_float_to_time(par)
	
	$anim.play("end_zoom_in")
	$border_thing/anim.play("shift")

func start_fade_out(tele : String = "*MENU"):
	fade_out = true
	$Fade.visible = true
	tele_destination = tele
	$info.visible = false
