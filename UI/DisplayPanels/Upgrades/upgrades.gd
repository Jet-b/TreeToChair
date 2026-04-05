extends PanelContainer

@export var upgrade_panel : PackedScene
@onready var vbox := $CenterContainer/HBoxContainer

func _ready() -> void:
	for upgrade in FundManager.UPGRADES:
		var new_upgrade_panel = upgrade_panel.instantiate()
		vbox.add_child(new_upgrade_panel)
		new_upgrade_panel.init(upgrade, FundManager.UPGRADES[upgrade].description, FundManager.get_upgrade_count(upgrade))
