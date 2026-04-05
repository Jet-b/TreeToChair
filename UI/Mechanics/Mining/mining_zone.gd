extends PanelContainer

var swing_left := false
var swings := 0
@export var swings_required := 4

# Upgrades
var _yield_bonus: int = 0        # extra metal per break (MINING_YIELD)
var _auto_miners: Array = []

var _metal_sound := preload("res://Sound/Metal/metalhit.mp3")
var _metal_player: AudioStreamPlayer

func _play_metal_sound() -> void:
	_metal_player.stop()
	_metal_player.play()

func _ready() -> void:
	_metal_player = AudioStreamPlayer.new()
	add_child(_metal_player)
	_metal_player.stream = _metal_sound
	_metal_player.volume_db = -5.0
	_metal_player.bus = Settings.BUS_METAL
	FundManager.upgrade_unlocked.connect(_on_upgrade_unlocked)
	# Apply already-purchased upgrades on load
	_yield_bonus = FundManager.get_upgrade_count("MINING_YIELD")
	var speed_count := FundManager.get_upgrade_count("MINING_SPEED")
	if speed_count > 0:
		swings_required = max(1, swings_required - speed_count)
	for i in FundManager.get_upgrade_count("AUTO_MINE"):
		_add_auto_miner()

func _on_upgrade_unlocked(name: String) -> void:
	match name:
		"MINING_YIELD":
			_yield_bonus += 1
		"MINING_SPEED":
			swings_required = max(1, swings_required - 1)
		"AUTO_MINE":
			_add_auto_miner()

func _add_auto_miner() -> void:
	var timer := Timer.new()
	timer.wait_time = 2.0
	timer.autostart = false
	timer.timeout.connect(_auto_mine)
	add_child(timer)
	timer.start()
	_auto_miners.append(timer)

func _auto_mine() -> void:
	FundManager.give(FundManager.ResType.METAL, 1 + _yield_bonus)
	_play_metal_sound()

func _on_swing_left_pressed() -> void:
	if not swing_left:
		swings += 1
	swing_left = true
	$VBoxContainer/ProgressBar.max_value = swings_required
	$VBoxContainer/ProgressBar.value = swings

func _on_swing_right_button_down() -> void:
	if swing_left:
		swing_left = false
		swings += 1
		$VBoxContainer/ProgressBar.value = swings
		if swings >= swings_required:
			swings = 0
			$VBoxContainer/ProgressBar.value = swings
			break_ore()

func break_ore():
	FundManager.give(FundManager.ResType.METAL, 1 + _yield_bonus)
	_play_metal_sound()
