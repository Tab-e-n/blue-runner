extends Node


const SOUND_EFFECT_LIMIT : int = 32
const FADE_TIME : float = 2.0
const FAST_FADE_TIME : float = 0.1
const FAKE_SILENCE : float = -32.0


var song_name : String = ""
var current_music : AudioStreamPlayer
var last_music : AudioStreamPlayer


var fading : float = 0.0
var fast_fade : bool = false


func _physics_process(delta):
	if fading > 0:
		fade_music(delta)


func play_sound(soundname : String, pitch : float = 1, random_pitch_range : float = -1, custom_volume : int = -1):
	
	var volume : int
	if custom_volume >= 0:
		volume = custom_volume
	elif Global.options["*audio_sfx"] == 0:
		return
	else:
		volume = Global.options["*audio_sfx"]
	
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
	
	sound.volume_db = volume_conversion(volume)
	
	add_child(sound)
	sound.play()


func play_music(musicname : String, fast : bool = true):
	change_music(musicname, false, fast)


func stop_music(fast : bool = true):
	change_music("", true, fast)


func change_music(musicname : String, stop : bool = false, fast : bool = true):
	if song_name == musicname:
		return
	song_name = musicname
	
	
	if not stop:
		var f : File = File.new()
		
		if not f.file_exists("res://Sound/Music/" + musicname + ".wav.import"):
			return
		
	last_music = current_music
	
	if not stop:
		current_music = AudioStreamPlayer.new()
		current_music.stream = load("res://Sound/Music/" + musicname + ".wav")
		
		current_music.volume_db = FAKE_SILENCE
		
		add_child(current_music)
	else:
		current_music = null
	
	if Global.options["*audio_music"] > 0:
		fast_fade = fast
		if fast:
			fading = FAST_FADE_TIME
		else:
			fading = FADE_TIME
		
		if current_music:
			current_music.play()
	elif last_music:
		last_music.queue_free()


func volume_conversion(opt_volume) -> float:
	return (opt_volume - 60) / 2.5


func fade_music(delta):
	fading -= delta
	var volume = volume_conversion(Global.options["*audio_music"])
	var fade_progress : float
	if fast_fade:
		fade_progress = fading / FAST_FADE_TIME
	else:
		fade_progress = fading / FADE_TIME
	if fading > 0:
		if last_music:
			last_music.volume_db = Global.fade_float(FAKE_SILENCE, volume, fade_progress)
		if current_music:
			current_music.volume_db = Global.fade_float(FAKE_SILENCE, volume, 1.0 - fade_progress)
	else:
		if last_music:
			last_music.queue_free()
		if current_music:
			current_music.volume_db = volume


func change_music_status(preset_volume : int = -1):
	if not current_music:
		return
	
	var volume
	if preset_volume >= 0:
		volume = preset_volume
	else:
		volume = Global.options["*audio_music"]
	
	current_music.volume_db = volume_conversion(volume)
	
	if volume > 0 and not current_music.playing:
		current_music.play()
	elif volume == 0 and current_music.playing:
		current_music.stop()
