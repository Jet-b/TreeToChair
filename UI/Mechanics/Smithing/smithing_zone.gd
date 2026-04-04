extends PanelContainer

var at_start := true
var at_end := false

func _ready() -> void:
	$HBoxContainer/VSlider.scale.y = -1

func _process(delta: float) -> void:
	if FundManager.get_amount(FundManager.ResType.METAL) > 0:
		$HBoxContainer/AnimatedSprite2D.visible = true
		
		if $HBoxContainer/VSlider.value == 0:
			at_start = true
			
		if $HBoxContainer/VSlider.value == 100:
			at_end = true
			
			if at_start and at_end:
				$HBoxContainer/AnimatedSprite2D.frame += 1
				at_start = false
				at_end = false
				
				if $HBoxContainer/AnimatedSprite2D.frame >= 3:
					FundManager.give(FundManager.ResType.NAILS, 1)
					FundManager.take(FundManager.ResType.METAL, 1)
					$HBoxContainer/AnimatedSprite2D.frame = 0
	else:
		$HBoxContainer/AnimatedSprite2D.visible = false
