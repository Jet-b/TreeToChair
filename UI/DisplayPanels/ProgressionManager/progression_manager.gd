extends Control

@export var sawmill : MarginContainer
@export var mining : PanelContainer
@export var smithing : PanelContainer
@export var assembling : Control

func _ready() -> void:
	sawmill.visible = FundManager.has_upgrade("UNLOCK_SAWMILL")
	mining.visible = FundManager.has_upgrade("UNLOCK_MINING")
	smithing.visible = FundManager.has_upgrade("UNLOCK_SMITHING")
	assembling.visible = FundManager.has_upgrade("UNLOCK_ASSEMBLING")
	FundManager.upgrade_unlocked.connect(_on_upgrade_unlocked)

func _on_upgrade_unlocked(name: String) -> void:
	match name:
		"UNLOCK_SAWMILL":    sawmill.visible = true
		"UNLOCK_MINING":     mining.visible = true
		"UNLOCK_SMITHING":   smithing.visible = true
		"UNLOCK_ASSEMBLING": assembling.visible = true
