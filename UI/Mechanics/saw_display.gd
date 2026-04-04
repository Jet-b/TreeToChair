extends PanelContainer

@export var wood : Texture2D
@export var log : PackedScene

@export var saw_delay := 0.5

var current_wood := 0

var holding_wood := false

var clickable_sprites = [] 


func _ready():
	$SawDelay.wait_time = saw_delay
	FundManager.resource_changed.connect(wood_update)
	display_wood(FundManager.get_amount(FundManager.ResType.WOOD))
	

func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var mouse_pos = get_global_mouse_position()
		var nearest_sprite = null
		var min_distance = 50
		
		for sprite in clickable_sprites:
			# Use global position of the sprite
			var sprite_pos = sprite.global_position
			var distance = mouse_pos.distance_to(sprite_pos)
			
			if distance < min_distance:
				min_distance = distance
				nearest_sprite = sprite
		
		if nearest_sprite:
			# Call a function on the nearest sprite
			clickable_sprites.erase(nearest_sprite)
			nearest_sprite.queue_free()
			var new_log = log.instantiate()
			add_child(new_log)

func random_wood_pos():
	var wood_pos : Vector2
	wood_pos.x = randi_range(global_position.x, global_position.x + size.x)
	wood_pos.y = randi_range(global_position.y, global_position.y + size.y)
	return wood_pos

func wood_update(resType, count):
	display_wood(count)

func display_wood(count: int):
	if holding_wood:
		count -= 1
	for i in count - clickable_sprites.size():
		var new_wood = Sprite2D.new()
		new_wood.texture = wood
		add_child(new_wood)
		clickable_sprites.append(new_wood)
		new_wood.global_position = random_wood_pos()
		new_wood.z_index = 1

func _on_saw_delay_timeout() -> void:
	for child in get_children():
			if child is Sprite2D:
				child.queue_free()
				FundManager.give(FundManager.ResType.PLANKS, 1)
				FundManager.take(FundManager.ResType.WOOD, 2)
				return
				
