extends Node

## Background environment music (Bible §6 mood). Lives as an autoload so a single ambient track
## plays unbroken across every scene change — the journey has one continuous bed of sound.
##
## It fades out slowly at the grave (called from the final approach as the light goes dark) so
## the ending lands in silence, and comes back if the player begins again. Degrades gracefully:
## if the track file isn't present yet, the game simply runs silent — nothing breaks.

## Where the track is looked for. The first that exists is used, so the file may be .ogg / .mp3 /
## .wav as long as it is named "bamboo_serenity" under assets/audio/.
const TRACK_CANDIDATES: Array[String] = [
	"res://assets/audio/bamboo_serenity.ogg",
	"res://assets/audio/bamboo_serenity.mp3",
	"res://assets/audio/bamboo_serenity.wav",
]
## Playback level for the ambient bed. Tune to taste.
const VOLUME_DB: float = -6.0
## Seconds for the slow fade to silence at the grave.
const GRAVE_FADE: float = 6.0

var _player: AudioStreamPlayer


func _ready() -> void:
	_player = AudioStreamPlayer.new()
	add_child(_player)
	var stream: AudioStream = _load_track()
	if stream == null:
		push_warning("Music: no track at assets/audio/bamboo_serenity.(ogg|mp3|wav) — running silent.")
		return
	_enable_loop(stream)
	_player.stream = stream
	_player.volume_db = VOLUME_DB
	_player.play()


func _load_track() -> AudioStream:
	for path in TRACK_CANDIDATES:
		if ResourceLoader.exists(path):
			return load(path)
	return null


## Seamless looping, whatever the stream type.
func _enable_loop(stream: AudioStream) -> void:
	if stream is AudioStreamOggVorbis or stream is AudioStreamMP3:
		stream.loop = true
	elif stream is AudioStreamWAV:
		stream.loop_mode = AudioStreamWAV.LOOP_FORWARD


## Slow fade to silence (the grave). Safe to call when already silent.
func fade_out(duration: float = GRAVE_FADE) -> void:
	if _player == null or _player.stream == null or not _player.playing:
		return
	var tween: Tween = create_tween()
	tween.tween_property(_player, "volume_db", -60.0, duration)
	tween.tween_callback(func() -> void: _player.stop())


## Restart the bed from the top at full level — used when the player begins again from the grave.
func restart() -> void:
	if _player == null or _player.stream == null:
		return
	_player.volume_db = VOLUME_DB
	_player.play()
