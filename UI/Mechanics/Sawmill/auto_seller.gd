extends PanelContainer

const SELLABLE_RESOURCES = [
	FundManager.ResType.WOOD,
	FundManager.ResType.PLANKS,
	FundManager.ResType.METAL,
	FundManager.ResType.NAILS,
	FundManager.ResType.CHAIRS,
]

const RESOURCE_NAMES = {
	FundManager.ResType.WOOD:   "Wood",
	FundManager.ResType.PLANKS: "Planks",
	FundManager.ResType.METAL:  "Metal",
	FundManager.ResType.NAILS:  "Nails",
	FundManager.ResType.CHAIRS: "Chairs",
}

var _selected_index: int = 0
# Per-resource sell amounts (0 = paused for that resource)
var _amounts: Dictionary = {}
var _timer: Timer

@onready var _resource_label: Label = $VBox/ResourceRow/ResourceLabel
@onready var _amount_label: Label    = $VBox/AmountRow/AmountLabel
@onready var _status_label: Label    = $VBox/StatusLabel

func _ready() -> void:
	for res in SELLABLE_RESOURCES:
		_amounts[res] = 0

	visible = FundManager.has_upgrade("AUTO_SELL")
	FundManager.upgrade_unlocked.connect(_on_upgrade_unlocked)

	_timer = Timer.new()
	_timer.wait_time = 1.0
	_timer.autostart = false
	_timer.timeout.connect(_on_tick)
	add_child(_timer)

	if visible:
		_timer.start()

	$VBox/ResourceRow/LeftBtn.pressed.connect(_on_left)
	$VBox/ResourceRow/RightBtn.pressed.connect(_on_right)
	$VBox/AmountRow/MinusBtn.pressed.connect(_on_minus)
	$VBox/AmountRow/PlusBtn.pressed.connect(_on_plus)

	_update_ui()

func _on_upgrade_unlocked(name: String) -> void:
	if name == "AUTO_SELL":
		visible = true
		_timer.start()
		_update_ui()

func _on_tick() -> void:
	var market = get_tree().get_first_node_in_group("stock_market_node")
	if market == null:
		return
	for res in SELLABLE_RESOURCES:
		var amt: int = _amounts[res]
		if amt > 0:
			market.auto_sell(res, amt)
	_update_ui()

func _on_left() -> void:
	_selected_index = (_selected_index - 1 + SELLABLE_RESOURCES.size()) % SELLABLE_RESOURCES.size()
	_update_ui()

func _on_right() -> void:
	_selected_index = (_selected_index + 1) % SELLABLE_RESOURCES.size()
	_update_ui()

func _on_minus() -> void:
	var res: FundManager.ResType = SELLABLE_RESOURCES[_selected_index]
	_amounts[res] = max(0, _amounts[res] - 1)
	_update_ui()

func _on_plus() -> void:
	var res: FundManager.ResType = SELLABLE_RESOURCES[_selected_index]
	_amounts[res] += 1
	_update_ui()

func _update_ui() -> void:
	var res: FundManager.ResType = SELLABLE_RESOURCES[_selected_index]
	_resource_label.text = RESOURCE_NAMES[res]
	_amount_label.text = "%d" % _amounts[res]

	var market = get_tree().get_first_node_in_group("stock_market_node")
	var price_text: String = "???"
	if market != null:
		price_text = "$%.2f" % market.get_current_price(res)

	var owned: int = FundManager.get_amount(res)
	var amt: int = _amounts[res]
	if amt == 0:
		_status_label.text = "%s: paused  (own: %d)" % [RESOURCE_NAMES[res], owned]
	else:
		_status_label.text = "Selling %d/s  @  %s ea  (own: %d)" % [amt, price_text, owned]
