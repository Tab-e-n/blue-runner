extends Node

const SOUND_EFFECT_LIMIT : int = 32

func play_sound(soundname : String, pitch : float = 1, random_pitch_range : float = -1):
	
	if Global.options["*audio_sfx"] == 0:
		return
	
	if get_child_count() > SOUND_EFFECT_LIMIT:
		return
	
	var f : File = File.new()
	
	if not f.file_exists("res://Sound/" + soundname + ".wav"):
		return
	
	var sound : AudioStreamPlayer = AudioStreamPlayer.new()
	sound.stream = load("res://Sound/" + soundname + ".wav")
	# warning-ignore:return_value_discarded
	sound.connect("finished", sound, "queue_free")
	
	if random_pitch_range != -1:
		sound.pitch_scale = Global.rand.randf_range(pitch, random_pitch_range)
	else:
		sound.pitch_scale = pitch
	
	sound.volume_db = (Global.options["*audio_sfx"] - 60) / 2.5
	
	add_child(sound)
	sound.play()
