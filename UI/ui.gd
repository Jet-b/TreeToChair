extends Window

func _ready() -> void:
	size = get_visible_rect().size
	
func _process(delta: float) -> void:
	size = get_visible_rect().size
