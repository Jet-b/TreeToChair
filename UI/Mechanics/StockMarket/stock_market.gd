extends MarginContainer

const SELLABLE_RESOURCES = [
	FundManager.ResType.WOOD,
	FundManager.ResType.PLANKS,
	FundManager.ResType.METAL,
	FundManager.ResType.NAILS,
	FundManager.ResType.CHAIRS,
]

const RESOURCE_NAMES = {
	FundManager.ResType.WOOD: "Wood",
	FundManager.ResType.PLANKS: "Planks",
	FundManager.ResType.METAL: "Metal",
	FundManager.ResType.NAILS: "Nails",
	FundManager.ResType.CHAIRS: "Chairs",
}

const BASE_PRICES = {
	FundManager.ResType.WOOD: 5,
	FundManager.ResType.PLANKS: 8,
	FundManager.ResType.METAL: 3,
	FundManager.ResType.NAILS: 6,
	FundManager.ResType.CHAIRS: 100,
}

@export var BUY_MARKUP = 1.2
@export var MAX_HISTORY = 150
@export var debug: bool = false
@export var TICK_INTERVAL: float = 1
@export var PRESSURE_PER_BUY = 0.002
@export var PRESSURE_PER_SELL = 0.002
@export var PRESSURE_DECAY = 0.98
@export var MAX_PRESSURE = 2.0

var price_graph: Control
var own_label: Label
var buy_price_label: Label
var sell_price_label: Label
var buy_button: Button
var sell_button: Button
var stock_tabs: HBoxContainer

var selected_resource: FundManager.ResType = FundManager.ResType.WOOD
var price_history: Dictionary = {}
var current_prices: Dictionary = {}
var time_offsets: Dictionary = {}
var demand_pressure: Dictionary = {}
var tick: float = 0.0
var tab_buttons: Dictionary = {}

var _holding_buy := false
var _holding_sell := false
var _hold_time := 0.0
var _hold_interval := 0.0
const HOLD_START_INTERVAL := 0.4
const HOLD_MIN_INTERVAL := 0.02
const HOLD_RAMP_SPEED := 0.85

var _money_sound := preload("res://Sound/UI/Money.mp3")
var _money_player: AudioStreamPlayer

func _ready() -> void:
	add_to_group("stock_market_node")
	_money_player = AudioStreamPlayer.new()
	add_child(_money_player)
	_money_player.stream = _money_sound
	_money_player.volume_db = -5.0
	price_graph = %PriceGraph
	own_label = %OwnLabel
	buy_price_label = %BuyLabel
	sell_price_label = %SellLabel
	buy_button = %BuyButton
	sell_button = %SellButton
	stock_tabs = %StockTabs

	for res in SELLABLE_RESOURCES:
		price_history[res] = [] as Array[float]
		current_prices[res] = float(BASE_PRICES[res])
		time_offsets[res] = randf() * 100.0
		demand_pressure[res] = 0.0

		var btn = Button.new()
		btn.text = RESOURCE_NAMES[res]
		btn.toggle_mode = true
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn.pressed.connect(on_tab_pressed.bind(res))
		stock_tabs.add_child(btn)
		tab_buttons[res] = btn

	tab_buttons[selected_resource].button_pressed = true

	buy_button.button_down.connect(func(): _holding_buy = true; _hold_time = 0.0; _hold_interval = HOLD_START_INTERVAL; on_buy_pressed())
	buy_button.button_up.connect(func(): _holding_buy = false)
	sell_button.button_down.connect(func(): _holding_sell = true; _hold_time = 0.0; _hold_interval = HOLD_START_INTERVAL; on_sell_pressed())
	sell_button.button_up.connect(func(): _holding_sell = false)
	FundManager.resource_changed.connect(on_resource_changed)
	FundManager.upgrade_unlocked.connect(_on_upgrade_unlocked)

	# Apply already-purchased market upgrades
	if FundManager.has_upgrade("MARKET_INSIGHT"):
		debug = true
	var insider_count := FundManager.get_upgrade_count("INSIDER_TRADING")
	if insider_count > 0:
		BUY_MARKUP = maxf(1.01, BUY_MARKUP - insider_count * 0.01)

	update_ui()

func _on_upgrade_unlocked(name: String) -> void:
	match name:
		"MARKET_INSIGHT":
			debug = true
		"INSIDER_TRADING":
			BUY_MARKUP = maxf(1.01, BUY_MARKUP - 0.01)
	update_ui()

func _process(delta: float) -> void:
	if _holding_buy or _holding_sell:
		_hold_time += delta
		if _hold_time >= _hold_interval:
			_hold_time = 0.0
			_hold_interval = max(HOLD_MIN_INTERVAL, _hold_interval * HOLD_RAMP_SPEED)
			if _holding_buy:
				on_buy_pressed()
			else:
				on_sell_pressed()

	for res in price_history:
		while price_history[res].size() > MAX_HISTORY:
			price_history[res].pop_front()
	tick += delta
	if tick >= TICK_INTERVAL:
		tick -= TICK_INTERVAL
		update_prices()

func update_prices() -> void:
	for res in SELLABLE_RESOURCES:
		var base = float(BASE_PRICES[res])
		time_offsets[res] += 0.15
		var t: float = time_offsets[res]

		var wave1 = sin(t * 0.3) * base * 0.3
		var wave2 = sin(t * 0.7 + 2.0) * base * 0.15
		var wave3 = sin(t * 1.5 + 5.0) * base * 0.08
		var noise = (randf() - 0.5) * base * 0.1

		demand_pressure[res] *= PRESSURE_DECAY
		var pressure_effect = base * demand_pressure[res]
		var price = base + wave1 + wave2 + wave3 + noise + pressure_effect
		price = max(1.0, price)
		current_prices[res] = price

		if debug and res == selected_resource:
			print("[%s] base=%.1f w1=%.2f w2=%.2f w3=%.2f noise=%.2f => $%.1f" % [
				RESOURCE_NAMES[res], base, wave1, wave2, wave3, noise, price
			])

		price_history[res].append(price)
		if price_history[res].size() > MAX_HISTORY:
			price_history[res].pop_front()

	update_ui()

func update_ui() -> void:
	var sell_price: float = current_prices[selected_resource]
	var buy_price: float = snappedf(sell_price * BUY_MARKUP, 0.01)
	var shift_qty: int = 25 if FundManager.has_upgrade("BULK_DEAL") else 10
	buy_price_label.text = "Buy Price: $%.2f" % (buy_price * (shift_qty if Input.is_key_pressed(KEY_SHIFT) else 1))
	sell_price_label.text = "Sell Price: $%.2f" % (sell_price * (shift_qty if Input.is_key_pressed(KEY_SHIFT) else 1))
	own_label.text = "You Own: %d" % FundManager.get_amount(selected_resource)

	if debug:
		price_graph.set_wave(build_wave_curve(selected_resource))
	else:
		price_graph.set_wave([])

	price_graph.set_history(price_history[selected_resource])

func build_wave_curve(res: FundManager.ResType) -> Array:
	var base = float(BASE_PRICES[res])
	var t_now: float = time_offsets[res]
	var history_count: int = price_history[res].size()
	if history_count < 2:
		return []
	var t_start: float = t_now - (history_count - 1) * 0.15
	var samples = 200
	var curve: Array = []
	for i in range(samples + 1):
		var frac = float(i) / float(samples)
		var t: float = t_start + frac * (t_now - t_start)
		var val = base + sin(t * 0.3) * base * 0.3 + sin(t * 0.7 + 2.0) * base * 0.15 + sin(t * 1.5 + 5.0) * base * 0.08
		curve.append(max(1.0, val))
	return curve

func on_tab_pressed(res: FundManager.ResType) -> void:
	selected_resource = res
	for r in tab_buttons:
		tab_buttons[r].button_pressed = (r == res)
	update_ui()

func _recalculate_price(res: FundManager.ResType) -> void:
	var base = float(BASE_PRICES[res])
	var t: float = time_offsets[res]
	var wave1 = sin(t * 0.3) * base * 0.3
	var wave2 = sin(t * 0.7 + 2.0) * base * 0.15
	var wave3 = sin(t * 1.5 + 5.0) * base * 0.08
	current_prices[res] = max(1.0, base + wave1 + wave2 + wave3 + base * demand_pressure[res])

func on_buy_pressed() -> void:
	var shift_qty: int = 25 if FundManager.has_upgrade("BULK_DEAL") else 10
	var amount: int = shift_qty if Input.is_key_pressed(KEY_SHIFT) else 1
	var buy_price: float = snappedf(current_prices[selected_resource] * BUY_MARKUP, 0.01) * amount
	if FundManager.take_money(buy_price):
		FundManager.give(selected_resource, amount)
		demand_pressure[selected_resource] = min(
			demand_pressure[selected_resource] + PRESSURE_PER_BUY * amount,
			MAX_PRESSURE
		)
		_recalculate_price(selected_resource)
		_money_player.stop()
		_money_player.play()
	update_ui()

func on_sell_pressed() -> void:
	var shift_qty: int = 25 if FundManager.has_upgrade("BULK_DEAL") else 10
	var amount: int = shift_qty if Input.is_key_pressed(KEY_SHIFT) else 1
	var owned: int = FundManager.get_amount(selected_resource)
	var actual: int = mini(amount, owned)
	if actual > 0 and FundManager.take(selected_resource, actual):
		FundManager.give_money(snappedf(current_prices[selected_resource] * actual, 0.01))
		demand_pressure[selected_resource] -= PRESSURE_PER_SELL * actual
		_recalculate_price(selected_resource)
		_money_player.stop()
		_money_player.play()
	update_ui()

func on_resource_changed(type, amount) -> void:
	if type == selected_resource or type == FundManager.ResType.MONEY:
		update_ui()

func get_current_price(res: FundManager.ResType) -> float:
	return current_prices.get(res, 1.0)

func auto_sell(res: FundManager.ResType, amount: int) -> void:
	var owned: int = FundManager.get_amount(res)
	var actual: int = mini(amount, owned)
	if actual <= 0:
		return
	if FundManager.take(res, actual):
		FundManager.give_money(snappedf(current_prices.get(res, 1.0) * actual, 0.01))
		demand_pressure[res] = max(-MAX_PRESSURE, demand_pressure[res] - PRESSURE_PER_SELL * actual)
		_recalculate_price(res)
	if res == selected_resource:
		update_ui()

func auto_buy(res: FundManager.ResType, amount: int) -> void:
	if amount <= 0:
		return
	var buy_price: float = snappedf(current_prices.get(res, 1.0) * BUY_MARKUP, 0.01) * amount
	if FundManager.take_money(buy_price):
		FundManager.give(res, amount)
		demand_pressure[res] = min(MAX_PRESSURE, demand_pressure[res] + PRESSURE_PER_BUY * amount)
		_recalculate_price(res)
	if res == selected_resource:
		update_ui()
