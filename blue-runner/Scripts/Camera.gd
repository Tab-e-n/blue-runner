extends Camera2D


const FADE_IN_OUT_DEFAULT : int = 12

export var compatibility_mode : bool = false
export var limit_x : Vector2 = Vector2(0,0)
export var limit_y : Vector2 = Vector2(0,0)

onready var bg : Node2D
var scrolling_objects : Array = []
onready var cam_target : Node2D
var tele_destination : String

var end_zoom : bool = false
const END_TIMER_DEFAULT : int = 60
var end_timer : float = END_TIMER_DEFAULT

var end_zoom_begin : Vector2
var end_pos_begin : Vector2
# Color(0.87451, 0.909804, 0.905882)

var replay_saved : bool = true
var speedometer_active : bool = false
var visible_timer : bool = false

var fade_in : bool = true
var fade_in_timer : float = 0
export var fade_in_darkness_lenght : int = 0
export var fade_in_end : int = FADE_IN_OUT_DEFAULT

var fade_out : bool = false
var fade_out_timer : float = 0
export var fade_out_darkness_lenght : int = 0
export var fade_out_end : int = FADE_IN_OUT_DEFAULT

var unlock_fade : bool = false


export var in_main_menu : bool = false


func _ready():
	$Fade.visible = true
	$border.visible = true
	$finish.visible = false
	$complete_dark.visible = true
	if Global.options["*timer_on"] == 1:
		visible_timer = true
	elif Global.options["*timer_on"] == 2:
		visible_timer = Global.check_unlock_requirements(Global.UNLOCK_BEAT, Global.current_level_location, Global.current_level)
	
	speedometer_active = Global.speedometer_active
	
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
#	$info/speed.visible = speedometer_active
	
	$finish/continue.text = Global.key_names(4)
	$finish/reset.text = Global.key_names(6)
	
	if Global.compatibility_mode:
		compatibility_mode = true
	
	if compatibility_mode:
		$border.polygon[0].x = -512
		$border.polygon[1].x = 512
		$border.polygon[2].x = 512
		$border.polygon[7].x = -512
		
		$finish/camera_input_continue.position.x = 480
		$finish/camera_input_reset.position.x = -480
		$finish/continue.rect_size.x = 512
		$finish/reset.rect_size.x = 512
		$finish/reset.rect_position.x = -416
	
	if not in_main_menu:
		$info/level/data.text = Global.text_interpretor(
"""%level level_name%
%current_level_location%%current_level%
By: %level creator%"""
#As: %current_character%
)


func _physics_process(_delta):
	if has_node("complete_dark"):
		$complete_dark.call_deferred("queue_free")
	
	if fade_in:
		fade_in_timer += 1
		if fade_in_timer > fade_in_end + fade_in_darkness_lenght:
			$Fade.visible = false
			fade_in = false
		elif fade_in_timer > fade_in_darkness_lenght:
			var fade_timer : float = fade_in_timer - fade_in_darkness_lenght
			$Fade.color.a = (fade_in_end - fade_timer) / fade_in_end
		else:
			$Fade.color.a = 0.0
	
	if fade_out:
		fade_out_timer += 1
		if fade_out_timer > fade_out_end + fade_out_darkness_lenght:
			$Fade.color.a = 1.0
			if Global.race_mode:
				Global.change_level("*MENU")
			else: 
				Global.change_level(tele_destination)
		elif fade_out_timer < fade_out_end:
			$Fade.color.a = fade_out_timer / fade_out_end
		else:
			$Fade.color.a = 1.0
			
		# warning-ignore:return_value_discarded
	
	if !end_zoom:
		position.x = int(cam_target.position.x * 0.5) * 2
		if position.x < limit_x.x:
			position.x = limit_x.x
		if position.x > limit_x.y:
			position.x = limit_x.y
		
		position.y = int(cam_target.position.y * 0.5) * 2
		if position.y < limit_y.x:
			position.y = limit_y.x
		if position.y > limit_y.y:
			position.y = limit_y.y
		if speedometer_active:
			var temp_calc = round(abs(cam_target.momentum.x)) # + abs(cam_target.momentum.y))
			if temp_calc <= 10:
				temp_calc = 0
			$info/text.text = String(temp_calc)
#			$info/speed.rotation_degrees = temp_calc * 0.05
		if visible_timer and (cam_target.timer <= cam_target.replay_timer + 0.016 or !cam_target.replay):
			$info/text.text = Global.convert_float_to_time(cam_target.timer)
	else:
		$info.visible = false
		
		zoom.x = 1 + (end_zoom_begin.x - 1) / END_TIMER_DEFAULT * end_timer
		zoom.y = 1 + (end_zoom_begin.y - 1) / END_TIMER_DEFAULT * end_timer
		
		$finish.scale.x = zoom.x + (zoom.x * 0.5) / END_TIMER_DEFAULT * end_timer
		$finish.scale.y = zoom.y + (zoom.y * 0.5) / END_TIMER_DEFAULT * end_timer
		
#		$camera_inputs.scale = $finish.scale
		
#		$camera_inputs.position.y = 80.0 / END_TIMER_DEFAULT * end_timer
		
		position.x = cam_target.position.x + (end_pos_begin.x - cam_target.position.x) / END_TIMER_DEFAULT * end_timer
		position.y = cam_target.position.y + (end_pos_begin.y - cam_target.position.y) / END_TIMER_DEFAULT * end_timer
		
		
		if end_timer > 0:
			end_timer -= end_timer / 20
		if end_timer < 0.1:
			end_timer = 0
		
		if end_timer < 10 and not fade_out:
			if Input.is_action_pressed("jump"):
				start_fade_out(tele_destination)
			if Input.is_action_just_pressed("special") and replay_saved:
				Global.save_replay_with_date(get_parent().name, get_parent().get_node("Player").recording.duplicate())
				
				$finish/replay.text = "REPLAY SAVED"
				replay_saved = false
				
	if scrolling_objects != []:
		for i in scrolling_objects:
			i.update_self(position)
	if bg != null:
		bg.update_self(position)
	$Fade.scale = zoom
	$border.scale = zoom
	$info.scale = zoom
	if unlock_fade:
		$unlock_fade.scale = zoom
	
	if not in_main_menu:
		$info/level.visible = Input.is_action_pressed("info")


func end_zoom_in(target : Node2D, tele, timer : float, par : float):
	end_zoom = true
	cam_target = target
	tele_destination = tele
	end_zoom_begin = zoom
	end_pos_begin = position
	$finish.visible = true
#	$camera_inputs.visible = true
	$finish.scale = zoom * 4
#	$camera_inputs.scale = zoom * 4
	
	$finish/replay.text = "SAVE REPLAY - " + Global.key_names(5)
	
	$finish/timer.text = Global.convert_float_to_time(timer)
	if par == 0:
		$finish/par.text = "no par time"
	else:
		$finish/par.text = "par " + Global.convert_float_to_time(par)
	
	$anim.play("end_zoom_in")
	$finish/anim.play("shift")


func start_fade_out(tele : String = "*MENU", reset_fade : bool = false, fast : bool = false):
	if reset_fade:
		fade_out_end = FADE_IN_OUT_DEFAULT
		fade_out_darkness_lenght = 0
	if fast:
		fade_out_end *= 0.5
	fade_out = true
	$Fade.visible = true
	tele_destination = tele
	$info.visible = false


func unlock_fade_in():
	$anim.play("unlock_fade_in")
	unlock_fade = true


func unlock_fade_out():
	$anim.play("unlock_fade_out")
	unlock_fade = false
