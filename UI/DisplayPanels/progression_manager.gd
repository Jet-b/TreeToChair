extends Control

@export var sawmill : MarginContainer
@export var mining : PanelContainer
@export var smithing : PanelContainer
@export var assembling : Control

func _ready() -> void:
	sawmill.modulate.a = 0
	mining.modulate.a = 0
	smithing.modulate.a = 0
	assembling.modulate.a = 0

func _process(delta: float) -> void:
	if FundManager.get_amount(FundManager.ResType.WOOD) > 1:
		sawmill.modulate.a = 255
		if FundManager.get_amount(FundManager.ResType.PLANKS) > 1:
			mining.modulate.a = 255
			if FundManager.get_amount(FundManager.ResType.METAL) > 1:
				smithing.modulate.a = 255
				if FundManager.get_amount(FundManager.ResType.NAILS) > 1:
					assembling.modulate.a = 255
