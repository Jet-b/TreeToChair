extends PanelContainer

@export var upgrade_panel : PackedScene
@onready var vbox := $CenterContainer/HBoxContainer

var _added: Dictionary = {}

func _ready() -> void:
	FundManager.upgrade_unlocked.connect(_on_upgrade_unlocked)
	_refresh_panels()

func _refresh_panels() -> void:
	for upgrade in FundManager.UPGRADES:
		if _added.has(upgrade):
			continue
		if not FundManager.is_upgrade_visible(upgrade):
			continue
		var new_upgrade_panel = upgrade_panel.instantiate()
		vbox.add_child(new_upgrade_panel)
		new_upgrade_panel.init(upgrade, FundManager.UPGRADES[upgrade].description, FundManager.get_upgrade_count(upgrade))
		_added[upgrade] = true

func _on_upgrade_unlocked(_name: String) -> void:
	_refresh_panels()
