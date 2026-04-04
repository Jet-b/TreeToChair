extends Area2D

signal dropped(log)

func _process(delta: float) -> void:
	if Input.is_mouse_button_pressed(1):
		global_position = get_global_mouse_position()
	else:
		emit_signal("dropped", self)
