extends VBoxContainer

const MAX_SAMPLES = 300

@export var tracked_resource: FundManager.ResType = FundManager.ResType.WOOD

@onready var label: Label = %AmountLabel
@onready var graph: Control = %ResourceGraph

var history: Array = []
var sample_timer: float = 0.0

func _ready() -> void:
	var amount := FundManager.get_amount(tracked_resource)
	label.text = str(amount)
	_update_tab_title(amount)
	_record_sample(amount)
	FundManager.resource_changed.connect(_on_resource_changed)

func _process(delta: float) -> void:
	sample_timer += delta
	if sample_timer >= 1.0:
		sample_timer -= 1.0
		_record_sample(FundManager.get_amount(tracked_resource))

func _record_sample(amount: int) -> void:
	history.append(float(amount))
	if history.size() > MAX_SAMPLES:
		history.pop_front()
	graph.set_history(history)

func _update_tab_title(amount: int) -> void:
	var parent := get_parent()
	if parent is TabContainer:
		var idx: int = (parent as TabContainer).get_tab_idx_from_control(self)
		if idx >= 0:
			parent.set_tab_title(idx, ("%d" % amount).lpad(7))

func _on_resource_changed(type: FundManager.ResType, amount: float) -> void:
	if type == tracked_resource:
		var int_amount := int(amount)
		label.text = str(int_amount)
		_update_tab_title(int_amount)
