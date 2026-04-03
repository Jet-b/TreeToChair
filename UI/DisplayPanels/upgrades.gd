extends PanelContainer

@export var upgrade_panel : PackedScene
@onready var vbox := $ScrollContainer/MarginContainer/VBoxContainer

func _ready() -> void:
	for upgrade in FundManager.Upgrade:
		var new_upgrade_panel = upgrade_panel.instantiate()
		new_upgrade_panel.get_child(0).get_child(0).text = upgrade
		vbox.add_child(new_upgrade_panel)
