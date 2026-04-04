extends Area2D

func _process(delta: float) -> void:
	if Input.is_mouse_button_pressed(1):
		global_position = get_global_mouse_position()
	else:
		get_parent().wood_update(FundManager.ResType.WOOD, FundManager.get_amount(FundManager.ResType.WOOD))
		queue_free()
