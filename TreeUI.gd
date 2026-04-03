extends PanelContainer

@export var tree : Texture2D

@export var max_trees := 10
@export var tree_delay := 3.0
@export var chop_delay := 1.5

@export var progress_bar : ProgressBar

var current_trees := 0


func _ready():
	$TreeDelay.wait_time = tree_delay
	$ChopDelay.wait_time = chop_delay
	progress_bar.max_value = chop_delay

func _process(delta: float) -> void:
	if $ChopDelay.time_left != 0:
		progress_bar.value = chop_delay - $ChopDelay.time_left
	else:
		progress_bar.value = 0

func random_tree_pos():
	var tree_pos : Vector2
	tree_pos.x = randi_range(global_position.x, global_position.x + size.x)
	tree_pos.y = randi_range(global_position.y, global_position.y + size.y)
	return tree_pos

func _on_tree_delay_timeout() -> void:
	if current_trees > max_trees:
		return
		
	var new_tree = Sprite2D.new()
	new_tree.texture = tree
	add_child(new_tree)
	new_tree.global_position = random_tree_pos()
	new_tree.z_index = 1
	current_trees += 1

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
				
