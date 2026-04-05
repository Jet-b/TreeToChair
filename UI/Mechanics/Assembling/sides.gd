extends Control

var click_count := 0
@export var required_clicks: int = 4

signal buttons_pressed

func _process(delta: float) -> void:
	if click_count >= required_clicks:
		click_count = 0
		emit_signal("buttons_pressed")

func _ready():
	reset_buttons()

func reset_buttons():
	click_count = 0
	for child in get_children():
		if child is Button:
			child.disabled = false

# Called by auto-assembler to instantly complete this side
func auto_complete() -> void:
	click_count = required_clicks

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
