extends Control

var click_count := 0

signal buttons_pressed

func _process(delta: float) -> void:
	if click_count >= 4:
		click_count = 0
		emit_signal("buttons_pressed")
	

func reset_buttons():
	$Button.disabled = false
	$Button2.disabled = false
	$Button3.disabled = false
	$Button4.disabled = false

func _on_button_pressed() -> void:
	click_count += 1
	$Button.disabled = true

func _on_button_2_pressed() -> void:
	click_count += 1
	$Button2.disabled = true

func _on_button_3_pressed() -> void:
	click_count += 1
	$Button3.disabled = true

func _on_button_4_pressed() -> void:
	click_count += 1
	$Button4.disabled = true
