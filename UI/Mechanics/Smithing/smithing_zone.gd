extends PanelContainer

var at_start := true
var at_end := false

# Upgrades
var _nails_per_smelt: int = 1    # BULK_SMITH doubles this
var _auto_smiths: Array = []
var _smith_delay: float = 3.0

var _nail_sound := preload("res://Sound/Nails/nail.mp3")
var _nail_player: AudioStreamPlayer

func _play_nail_sound() -> void:
	_nail_player.play()

func _ready() -> void:
	_nail_player = AudioStreamPlayer.new()
	add_child(_nail_player)
	_nail_player.stream = _nail_sound
	$HBoxContainer/VSlider.scale.y = -1
	FundManager.upgrade_unlocked.connect(_on_upgrade_unlocked)
	# Apply already-purchased upgrades on load
	if FundManager.has_upgrade("BULK_SMITH"):
		_nails_per_smelt = 2
	_smith_delay = max(0.5, 3.0 - FundManager.get_upgrade_count("SMITH_SPEED") * 0.2)
	for i in FundManager.get_upgrade_count("AUTO_SMITH"):
		_add_auto_smith()

func _on_upgrade_unlocked(name: String) -> void:
	match name:
		"BULK_SMITH":
			_nails_per_smelt = 2
		"SMITH_SPEED":
			_smith_delay = max(0.5, _smith_delay - 0.2)
		"AUTO_SMITH":
			_add_auto_smith()

func _add_auto_smith() -> void:
	var timer := Timer.new()
	timer.wait_time = _smith_delay
	timer.autostart = false
	timer.timeout.connect(_auto_smelt)
	add_child(timer)
	timer.start()
	_auto_smiths.append(timer)

func _auto_smelt() -> void:
	if FundManager.has_amount(FundManager.ResType.METAL, 1):
		FundManager.take(FundManager.ResType.METAL, 1)
		FundManager.give(FundManager.ResType.NAILS, _nails_per_smelt)
		_play_nail_sound()

func _process(delta: float) -> void:
	if FundManager.get_amount(FundManager.ResType.METAL) > 0:
		$HBoxContainer/AnimatedSprite2D.visible = true

		if $HBoxContainer/VSlider.value == 0:
			at_start = true

		if $HBoxContainer/VSlider.value == 100:
			at_end = true

			if at_start and at_end:
				$HBoxContainer/AnimatedSprite2D.frame += 1
				at_start = false
				at_end = false

				if $HBoxContainer/AnimatedSprite2D.frame >= 3:
					FundManager.give(FundManager.ResType.NAILS, _nails_per_smelt)
					FundManager.take(FundManager.ResType.METAL, 1)
					_play_nail_sound()
					$HBoxContainer/AnimatedSprite2D.frame = 0
	else:
		$HBoxContainer/AnimatedSprite2D.visible = false
