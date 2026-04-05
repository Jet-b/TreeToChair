extends Node

var _music_player: AudioStreamPlayer = null

func _ready() -> void:
	pass

func register_music_player(player: AudioStreamPlayer) -> void:
	_music_player = player

func set_music_volume(linear: float) -> void:
	if _music_player == null:
		return
	if linear <= 0.001:
		_music_player.volume_db = -80.0
	else:
		_music_player.volume_db = linear_to_db(linear) - 20.0
