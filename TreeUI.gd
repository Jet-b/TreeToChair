extends PanelContainer

@export var tree : Texture2D

@export var max_trees := 10
@export var tree_delay := 3.0

var current_trees := 0


func _ready():
	$TreeDelay.wait_time = tree_delay

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
