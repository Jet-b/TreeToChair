extends MarginContainer

func _ready() -> void:
	var slider: HSlider = $VBoxContainer/MusicRow/MusicSlider
	slider.min_value = 0.0
	slider.max_value = 1.0
	slider.step = 0.01
	slider.value = 1.0
	_update_music_label(1.0)

func _update_music_label(value: float) -> void:
	$VBoxContainer/MusicRow/MusicPct.text = "%d%%" % int(value * 100)

func _on_music_slider_value_changed(value: float) -> void:
	Settings.set_music_volume(value)
	_update_music_label(value)

func _on_btn_chk_toggled(pressed: bool) -> void:
	Settings.set_bus_muted(Settings.BUS_BUTTON, not pressed)

func _on_chop_chk_toggled(pressed: bool) -> void:
	Settings.set_bus_muted(Settings.BUS_CHOP, not pressed)

func _on_plant_chk_toggled(pressed: bool) -> void:
	Settings.set_bus_muted(Settings.BUS_PLANT, not pressed)

func _on_nail_chk_toggled(pressed: bool) -> void:
	Settings.set_bus_muted(Settings.BUS_NAIL, not pressed)

func _on_metal_chk_toggled(pressed: bool) -> void:
	Settings.set_bus_muted(Settings.BUS_METAL, not pressed)

func _on_saw_chk_toggled(pressed: bool) -> void:
	Settings.set_bus_muted(Settings.BUS_SAW, not pressed)

func _on_money_chk_toggled(pressed: bool) -> void:
	Settings.set_bus_muted(Settings.BUS_MONEY, not pressed)
