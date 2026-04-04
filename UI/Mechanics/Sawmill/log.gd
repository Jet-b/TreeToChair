extends Area2D

signal dropped(log)
signal sawed()

var sawmill: ColorRect = null
var log_zone: PanelContainer = null

func _process(_delta: float) -> void:
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		global_position = get_global_mouse_position()
		if sawmill and _is_over_rect(sawmill):
			emit_signal("sawed")
			queue_free()
			return
	else:
		_drop()

func _drop() -> void:
	if log_zone:
		var clamped = get_global_mouse_position()
		clamped.x = clamp(clamped.x, log_zone.global_position.x, log_zone.global_position.x + log_zone.size.x)
		clamped.y = clamp(clamped.y, log_zone.global_position.y, log_zone.global_position.y + log_zone.size.y)
		global_position = clamped
	emit_signal("dropped", self)

func _is_over_rect(rect_node: Control) -> bool:
	var pos = global_position
	return pos.x > rect_node.global_position.x and \
		pos.x < rect_node.global_position.x + rect_node.size.x and \
		pos.y > rect_node.global_position.y and \
		pos.y < rect_node.global_position.y + rect_node.size.y
