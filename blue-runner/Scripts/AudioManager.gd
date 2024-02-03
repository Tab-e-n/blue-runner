extends Node


const SOUND_EFFECT_LIMIT : int = 32
const FADE_TIME : float = 2.0


var current_music : AudioStreamPlayer
var last_music : AudioStreamPlayer


var fading : float = 0.0


func _physics_process(delta):
	if fading > 0:
		fade_music(delta)


func play_sound(soundname : String, pitch : float = 1, random_pitch_range : float = -1):
	
	if Global.options["*audio_sfx"] == 0:
		return
	
	if get_child_count() > SOUND_EFFECT_LIMIT:
		return
	
	var f : File = File.new()
	
	if not f.file_exists("res://Sound/" + soundname + ".wav.import"):
		return
	
	var sound : AudioStreamPlayer = AudioStreamPlayer.new()
	sound.stream = load("res://Sound/" + soundname + ".wav")
	# warning-ignore:return_value_discarded
	sound.connect("finished", sound, "queue_free")
	
	if random_pitch_range != -1:
		sound.pitch_scale = Global.rand.randf_range(pitch, random_pitch_range)
	else:
		sound.pitch_scale = pitch
	
	sound.volume_db = volume_conversion(Global.options["*audio_sfx"])
	
	add_child(sound)
	sound.play()


func play_music(musicname : String):
	
	if Global.options["*audio_music"] == 0:
		return
	
	var f : File = File.new()
	
	if not f.file_exists("res://Sound/Music/" + musicname + ".wav.import"):
		return
	
	last_music = current_music
	current_music = AudioStreamPlayer.new()
	current_music.stream = load("res://Sound/Music/" + musicname + ".wav")
	
	current_music.volume_db = -24
	
	add_child(current_music)
	fading = FADE_TIME
	current_music.play()


func volume_conversion(opt_volume) -> float:
	return (opt_volume - 60) / 2.5


func fade_music(delta):
	fading -= delta
	var volume = volume_conversion(Global.options["*audio_music"])
	if fading > 0:
		if last_music:
			last_music.volume_db = Global.fade_float(-24, volume, fading / FADE_TIME)
		current_music.volume_db = Global.fade_float(-24, volume, 1.0 - fading / FADE_TIME)
	else:
		last_music.queue_free()
		current_music.volume_db = volume
	
