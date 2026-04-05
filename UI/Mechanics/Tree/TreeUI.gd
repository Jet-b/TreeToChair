extends PanelContainer

@export var tree : Texture2D

@export var max_trees := 10
@export var tree_delay := 3.0
@export var chop_delay := 1.5
@export var plant_delay := 2.0

@export var progress_bar : ProgressBar
@export var chop_button : Button
@export var auto_chop_bars : VBoxContainer
@export var plant_button : Button

var current_trees := 0
var _auto_choppers: Array = []
var _auto_planters: Array = []


func _ready():
	$TreeDelay.wait_time = tree_delay
	$ChopDelay.wait_time = chop_delay
	$PlantDelay.wait_time = plant_delay
	progress_bar.max_value = chop_delay
	FundManager.upgrade_unlocked.connect(_on_upgrade_unlocked)

	var chop_count := FundManager.get_upgrade_count("AUTO_CHOP")
	for i in chop_count:
		_add_auto_chopper()
	if chop_count > 0:
		chop_button.visible = false
		progress_bar.visible = false
	_apply_chop_speed()

	var plant_count := FundManager.get_upgrade_count("AUTO_PLANT")
	for i in plant_count:
		_add_auto_planter()
	if plant_count > 0:
		plant_button.visible = false
	_apply_plant_speed()

	max_trees *= int(pow(2, FundManager.get_upgrade_count("MAX_TREES")))

func _process(delta: float) -> void:
	if $ChopDelay.time_left > 0:
		progress_bar.value = chop_delay - $ChopDelay.time_left
	else:
		progress_bar.value = 0
	for entry in _auto_choppers:
		var timer: Timer = entry["timer"]
		var bar: ProgressBar = entry["bar"]
		if timer.time_left > 0:
			bar.value = timer.wait_time - timer.time_left
		else:
			bar.value = 0

func _apply_chop_speed() -> void:
	var speed_count := FundManager.get_upgrade_count("AUTO_CHOP_SPEED")
	var new_wait: float = chop_delay / pow(1.2, speed_count)
	for entry in _auto_choppers:
		var timer: Timer = entry["timer"]
		var bar: ProgressBar = entry["bar"]
		timer.wait_time = new_wait
		bar.max_value = new_wait

func _apply_plant_speed() -> void:
	var speed_count := FundManager.get_upgrade_count("AUTO_PLANT_SPEED")
	var new_wait: float = plant_delay / pow(1.2, speed_count)
	for timer in _auto_planters:
		timer.wait_time = new_wait

func _add_auto_chopper() -> void:
	var bar := ProgressBar.new()
	bar.max_value = chop_delay
	bar.value = 0
	auto_chop_bars.add_child(bar)

	var timer := Timer.new()
	timer.wait_time = chop_delay
	add_child(timer)
	timer.timeout.connect(_on_auto_chop_timeout.bind(timer))
	timer.start()

	_auto_choppers.append({"timer": timer, "bar": bar})

func _add_auto_planter() -> void:
	var timer := Timer.new()
	timer.wait_time = plant_delay
	add_child(timer)
	timer.timeout.connect(_on_auto_plant_timeout)
	timer.start()
	_auto_planters.append(timer)

func _on_upgrade_unlocked(name: String) -> void:
	if name == "AUTO_CHOP":
		_add_auto_chopper()
		if _auto_choppers.size() == 1:
			chop_button.visible = false
			progress_bar.visible = false
	elif name == "AUTO_PLANT":
		_add_auto_planter()
		if _auto_planters.size() == 1:
			plant_button.visible = false
	elif name == "AUTO_CHOP_SPEED":
		_apply_chop_speed()
	elif name == "AUTO_PLANT_SPEED":
		_apply_plant_speed()
	elif name == "MAX_TREES":
		max_trees *= 2

func _plant_tree() -> void:
	if current_trees >= max_trees:
		return
	var new_tree = Sprite2D.new()
	new_tree.texture = tree
	add_child(new_tree)
	new_tree.global_position = random_tree_pos()
	new_tree.z_index = 1
	current_trees += 1

func random_tree_pos():
	var tree_pos : Vector2
	tree_pos.x = randi_range(global_position.x, global_position.x + size.x)
	tree_pos.y = randi_range(global_position.y, global_position.y + size.y)
	return tree_pos

func _on_tree_delay_timeout() -> void:
	_plant_tree()

func _on_plant_button_pressed() -> void:
	plant_button.disabled = true
	plant_button.flat = true
	$PlantDelay.start()

func _on_plant_delay_timeout() -> void:
	_plant_tree()
	plant_button.disabled = false
	plant_button.flat = false

func _on_auto_plant_timeout() -> void:
	_plant_tree()

func _on_chop_button_pressed() -> void:
	$ChopDelay.start()

func _on_chop_delay_timeout() -> void:
	progress_bar.value = 0
	for child in get_children():
		if child is Sprite2D:
			child.queue_free()
			FundManager.give(FundManager.ResType.WOOD, 2)
			current_trees -= 1
			return

func _on_auto_chop_timeout(timer: Timer) -> void:
	for child in get_children():
		if child is Sprite2D:
			child.queue_free()
			FundManager.give(FundManager.ResType.WOOD, 2)
			current_trees -= 1
			return
