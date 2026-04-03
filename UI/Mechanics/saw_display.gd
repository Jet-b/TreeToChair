extends PanelContainer

@export var wood : Texture2D

@export var saw_delay := 0.5

var current_wood := 0


func _ready():
	$SawDelay.wait_time = saw_delay
	FundManager.resource_changed.connect(wood_update)
	display_wood(FundManager.get_amount(FundManager.ResType.WOOD))
	

func random_wood_pos():
	var wood_pos : Vector2
	wood_pos.x = randi_range(global_position.x, global_position.x + size.x)
	wood_pos.y = randi_range(global_position.y, global_position.y + size.y)
	return wood_pos

func wood_update(resType, count):
	display_wood(count)

func display_wood(count: int):
	for i in count:
		var new_wood = Sprite2D.new()
		new_wood.texture = wood
		add_child(new_wood)
		new_wood.global_position = random_wood_pos()
		new_wood.z_index = 1

func _on_chop_button_pressed() -> void:
	$ChopDelay.start()

func _on_chop_delay_timeout() -> void:
	for child in get_children():
			if child is Sprite2D:
				child.queue_free()
				FundManager.give(FundManager.ResType.PLANKS, 1)
				FundManager.take(FundManager.ResType.WOOD, 2)
				return
				
