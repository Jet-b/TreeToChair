extends CenterContainer

@onready var label: Label = %MoneyLabel

func _ready() -> void:
	var amount = FundManager.get_amount(FundManager.ResType.MONEY)
	label.text = "$%d" % amount
	_update_tab_title(amount)
	FundManager.resource_changed.connect(on_resource_changed)

func _update_tab_title(amount: int) -> void:
	var parent = get_parent()
	if parent is TabContainer:
		var idx = parent.get_tab_idx_from_control(self)
		if idx >= 0:
			parent.set_tab_title(idx, "$%d" % amount)

func on_resource_changed(type: FundManager.ResType, amount: int) -> void:
	if type == FundManager.ResType.MONEY:
		label.text = "$%d" % amount
		_update_tab_title(amount)
