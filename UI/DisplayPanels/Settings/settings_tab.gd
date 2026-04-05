extends MarginContainer

func _ready() -> void:
	var slider: HSlider = $VBoxContainer/MusicRow/MusicSlider
	slider.min_value = 0.0
	slider.max_value = 1.0
	slider.step = 0.01
	slider.value = 1.0
	_update_music_label(1.0)

	var master_slider: HSlider = $VBoxContainer/MasterRow/MasterSlider
	master_slider.min_value = 0.0
	master_slider.max_value = 1.0
	master_slider.step = 0.01
	master_slider.value = 1.0
	_update_master_label(1.0)

func _update_music_label(value: float) -> void:
	$VBoxContainer/MusicRow/MusicPct.text = "%d%%" % int(value * 100)

func _update_master_label(value: float) -> void:
	$VBoxContainer/MasterRow/MasterPct.text = "%d%%" % int(value * 100)

func _on_music_slider_value_changed(value: float) -> void:
	Settings.set_music_volume(value)
	_update_music_label(value)

func _on_master_slider_value_changed(value: float) -> void:
	if value <= 0.001:
		AudioServer.set_bus_volume_db(0, -80.0)
	else:
		AudioServer.set_bus_volume_db(0, linear_to_db(value))
	_update_master_label(value)
