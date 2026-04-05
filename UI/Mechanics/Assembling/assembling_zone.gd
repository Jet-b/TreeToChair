extends Control

@export var chairSprite : AnimatedSprite2D

const PLANKS_PER_CHAIR := 4
const NAILS_PER_CHAIR  := 8

# Manual assembly state
var currentSide := 0
var _chairs_per_assembly: int = 1
var _clicks_per_side: int = 4

# Auto assembly — completely separate from the side system
var _assembler_count: int = 0
var _auto_timer: Timer = null
const AUTO_BASE_INTERVAL := 8.0  # seconds per chair at 1 assembler

func _ready() -> void:
	FundManager.upgrade_unlocked.connect(_on_upgrade_unlocked)
	if FundManager.has_upgrade("BULK_ASSEMBLY"):
		_chairs_per_assembly = 2
	_clicks_per_side = max(1, 4 - FundManager.get_upgrade_count("FASTER_ASSEMBLY"))
	_apply_clicks_to_sides()
	_assembler_count = FundManager.get_upgrade_count("AUTO_ASSEMBLE")
	if _assembler_count > 0:
		_start_auto_timer()

func _on_upgrade_unlocked(name: String) -> void:
	match name:
		"BULK_ASSEMBLY":
			_chairs_per_assembly = 2
		"FASTER_ASSEMBLY":
			_clicks_per_side = max(1, _clicks_per_side - 1)
			_apply_clicks_to_sides()
		"AUTO_ASSEMBLE":
			_assembler_count += 1
			_start_auto_timer()

func _apply_clicks_to_sides() -> void:
	for side in [$Side1, $Side2, $Side3, $Side4]:
		side.required_clicks = _clicks_per_side

# ── Auto assembly ────────────────────────────────────────────────────────────

func _start_auto_timer() -> void:
	var interval := AUTO_BASE_INTERVAL / float(_assembler_count)
	if _auto_timer == null:
		_auto_timer = Timer.new()
		_auto_timer.autostart = false
		_auto_timer.timeout.connect(_auto_produce_chair)
		add_child(_auto_timer)
	_auto_timer.wait_time = interval
	# Drive the animation at a matching speed (full loop per interval)
	chairSprite.speed_scale = chairSprite.sprite_frames.get_frame_count(
		chairSprite.animation) / interval
	if _auto_timer.is_stopped():
		_auto_timer.start()

func _auto_produce_chair() -> void:
	if _can_afford():
		_consume_resources()
		FundManager.give(FundManager.ResType.CHAIRS, _chairs_per_assembly)

# ── Shared resource helpers ──────────────────────────────────────────────────

func _can_afford() -> bool:
	return FundManager.has_amount(FundManager.ResType.PLANKS, PLANKS_PER_CHAIR) \
		and FundManager.has_amount(FundManager.ResType.NAILS, NAILS_PER_CHAIR)

func _consume_resources() -> void:
	FundManager.take(FundManager.ResType.PLANKS, PLANKS_PER_CHAIR)
	FundManager.take(FundManager.ResType.NAILS, NAILS_PER_CHAIR)

# ── Manual assembly (side system) ────────────────────────────────────────────

func resume_chair() -> void:
	if currentSide == 0:
		if not _can_afford():
			return
		_consume_resources()
	chairSprite.speed_scale = 1.0
	chairSprite.play()

func _process(delta: float) -> void:
	# Only drive the side system when assembling manually (no auto timer running)
	if _assembler_count > 0:
		return
	if chairSprite.frame == 0 and currentSide != 1:
		side_1()
		currentSide = 1
		chairSprite.pause()
		$Side1.reset_buttons()
	if chairSprite.frame == 6 and currentSide != 2:
		side_2()
		currentSide = 2
		chairSprite.pause()
		$Side2.reset_buttons()
	if chairSprite.frame == 12 and currentSide != 3:
		side_3()
		currentSide = 3
		chairSprite.pause()
		$Side3.reset_buttons()
	if chairSprite.frame == 19 and currentSide != 4:
		side_4()
		currentSide = 4
		chairSprite.pause()
		$Side4.reset_buttons()
	# Chair complete: animation stopped at last frame after side 4 was done
	if currentSide == 4 and not chairSprite.is_playing():
		var last_frame := chairSprite.sprite_frames.get_frame_count(chairSprite.animation) - 1
		if chairSprite.frame >= last_frame:
			FundManager.give(FundManager.ResType.CHAIRS, _chairs_per_assembly)
			currentSide = 0

func side_1() -> void:
	$Side1.modulate.a = 255
	$Side1.reset_buttons()

func side_2() -> void:
	$Side2.modulate.a = 255
	$Side2.reset_buttons()

func side_3() -> void:
	$Side3.modulate.a = 255
	$Side3.reset_buttons()

func side_4() -> void:
	$Side4.modulate.a = 255
	$Side4.reset_buttons()

func resume_animation() -> void:
	chairSprite.frame += 1
	chairSprite.play()

func _on_side_1_buttons_pressed() -> void:
	$Side1.modulate.a = 0
	resume_animation()

func _on_side_2_buttons_pressed() -> void:
	$Side2.modulate.a = 0
	resume_animation()

func _on_side_3_buttons_pressed() -> void:
	$Side3.modulate.a = 0
	resume_animation()

func _on_side_4_buttons_pressed() -> void:
	$Side4.modulate.a = 0
	resume_animation()
