extends Window

@export var padding: int = 16

func _ready() -> void:
	position = Vector2i(padding, padding)
	size = DisplayServer.screen_get_size() - Vector2i(padding * 2, padding * 2)
