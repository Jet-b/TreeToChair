extends VBoxContainer

const MAX_SAMPLES = 300

@onready var label: Label = %MoneyLabel
@onready var graph: Control = %MoneyGraph

var money_history: Array = []
var sample_timer: float = 0.0

func _ready() -> void:
	var amount = FundManager.get_amount(FundManager.ResType.MONEY)
	label.text = "$%d" % amount
	_update_tab_title(amount)
	_record_sample(amount)
	FundManager.resource_changed.connect(on_resource_changed)

func _process(delta: float) -> void:
	sample_timer += delta
	if sample_timer >= 1.0:
		sample_timer -= 1.0
		_record_sample(FundManager.get_amount(FundManager.ResType.MONEY))

func _record_sample(amount: int) -> void:
	money_history.append(float(amount))
	if money_history.size() > MAX_SAMPLES:
		money_history.pop_front()
	graph.set_history(money_history)

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
