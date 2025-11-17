extends Node

# Audio manager singleton for handling music and sound effects

# Music player
var music_player: AudioStreamPlayer

# Current music track
var current_track: AudioStream

# Music volume (0.0 - 1.0)
var music_volume: float = 0.7

# SFX volume (0.0 - 1.0)
var sfx_volume: float = 0.8

func _ready():
	# Create music player
	music_player = AudioStreamPlayer.new()
	add_child(music_player)
	music_player.bus = "Master"
	
	# Set initial volume
	music_player.volume_db = linear_to_db(music_volume)
	
	# Auto-play desk work music on game start
	play_music("res://assets/audio/music/Desk Work.mp3", true)

func play_music(track_path: String, loop: bool = true):
	"""Play a music track"""
	var track = load(track_path)
	if track:
		current_track = track
		music_player.stream = track
		
		# Set loop mode if supported
		if track is AudioStreamMP3:
			track.loop = loop
		elif track is AudioStreamOggVorbis:
			track.loop = loop
		
		music_player.play()
		print("AudioManager: Playing music - ", track_path)
	else:
		push_error("AudioManager: Failed to load music track - " + track_path)

func stop_music():
	"""Stop the current music track"""
	music_player.stop()

func set_music_volume(volume: float):
	"""Set music volume (0.0 - 1.0)"""
	music_volume = clamp(volume, 0.0, 1.0)
	music_player.volume_db = linear_to_db(music_volume)

func fade_out_music(duration: float = 1.0):
	"""Fade out music over duration"""
	var tween = create_tween()
	tween.tween_property(music_player, "volume_db", -80, duration)
	tween.tween_callback(music_player.stop)

func fade_in_music(duration: float = 1.0):
	"""Fade in music over duration"""
	music_player.volume_db = -80
	music_player.play()
	var tween = create_tween()
	tween.tween_property(music_player, "volume_db", linear_to_db(music_volume), duration)

func play_sfx(sfx_path: String):
	"""Play a one-shot sound effect"""
	var sfx = load(sfx_path)
	if sfx:
		var sfx_player = AudioStreamPlayer.new()
		add_child(sfx_player)
		sfx_player.stream = sfx
		sfx_player.volume_db = linear_to_db(sfx_volume)
		sfx_player.finished.connect(sfx_player.queue_free)
		sfx_player.play()
	else:
		push_error("AudioManager: Failed to load SFX - " + sfx_path)
