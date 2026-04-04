extends PanelContainer

var swing_left := false

var swings := 0
@export var swings_required := 4

func _on_swing_left_pressed() -> void:
	if not swing_left:
		swings += 1
	swing_left = true
	$VBoxContainer/ProgressBar.max_value = swings_required
	$VBoxContainer/ProgressBar.value = swings


func _on_swing_right_button_down() -> void:
	if swing_left:
		swing_left = false
		swings += 1

		$VBoxContainer/ProgressBar.value = swings
		if swings == swings_required:
			swings = 0
			$VBoxContainer/ProgressBar.value = swings
			break_ore()
	
func break_ore():
	FundManager.give(FundManager.ResType.METAL, 1)
