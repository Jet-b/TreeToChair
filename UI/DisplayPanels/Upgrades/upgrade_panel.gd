extends PanelContainer

var name_label: Label
var description_label: Label
var count_label: Label
var price_label: Label
var buy_button: Button

var _upgrade_name: String

func init(upgrade_name: String, description: String, count: int) -> void:
	_upgrade_name = upgrade_name
	name_label = $MarginContainer/VBoxContainer/Label
	description_label = $MarginContainer/VBoxContainer/DescriptionLabel
	count_label = $MarginContainer/VBoxContainer/CountLabel
	price_label = $MarginContainer/VBoxContainer/PriceLabel
	buy_button = $MarginContainer/VBoxContainer/Button
	name_label.text = upgrade_name.replace("_", " ").capitalize()
	description_label.text = description
	count_label.text = "Purchased: %d" % count
	_refresh_price()
	buy_button.pressed.connect(_on_buy_pressed)
	FundManager.upgrade_unlocked.connect(_on_upgrade_unlocked)

func _refresh_price() -> void:
	price_label.text = "Price: $%d" % FundManager.get_next_price(_upgrade_name)

func _on_buy_pressed() -> void:
	FundManager.unlock_upgrade(_upgrade_name)

func _on_upgrade_unlocked(name: String) -> void:
	if name != _upgrade_name:
		return
	var def = FundManager.UPGRADES[_upgrade_name]
	var count := FundManager.get_upgrade_count(_upgrade_name)
	count_label.text = "Purchased: %d" % count
	if def.max_count > 0 and count >= def.max_count:
		buy_button.disabled = true
		buy_button.text = "MAXED"
	else:
		_refresh_price()
