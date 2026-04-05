extends Node

# --- Emitters for retrieving signals ---

## Emitted when any resource amount changes: (resource_type, new_amount)
signal resource_changed(type: ResType, amount: float)
## Emitted when an upgrade is unlocked: (upgrade_name)
signal upgrade_unlocked(name: String)

# --- Enums ---

enum ResType {
	MONEY,
	WOOD,
	PLANKS,
	METAL,
	NAILS,
	CHAIRS,
}

# temp upgrades, change as required

class UpgradeDef:
	var description: String
	var price: int
	var price_scale: float  # multiplier per purchase, e.g. 1.5 = 50% more each time
	var max_count: int  # 0 = unlimited
	var hide_when_maxed: bool  # remove the upgrade card from UI once bought
	var requires: String   # name of upgrade that must be purchased first ("" = always visible)

	func _init(p_description: String, p_price: int, p_price_scale: float, p_max_count: int, p_hide_when_maxed: bool = false, p_requires: String = "") -> void:
		description = p_description
		price = p_price
		price_scale = p_price_scale
		max_count = p_max_count
		hide_when_maxed = p_hide_when_maxed
		requires = p_requires

var UPGRADES: Dictionary = {}

# --- State ---

var debug: bool = false  # Set true to make all upgrades free

var _resources: Dictionary = {}
var _upgrades: Dictionary = {}
var _money: float = 0.0

var _button_sound := preload("res://Sound/UI/buttonPress.mp3")
var _button_player: AudioStreamPlayer

func _ready() -> void:
	_button_player = AudioStreamPlayer.new()
	add_child(_button_player)
	_button_player.stream = _button_sound
	# Initialise upgrade definitions — name is the key
	UPGRADES = {
		# Progression: buy anything in a tier to reveal the next tier
		# name                description                                        price   scale  max   hide   requires

		# --- Tree zone (always visible at start) ---
		"AUTO_CHOP":          UpgradeDef.new("+1 automatic wood harvester",          30, 1.5, 16,  false, ""),
		"AUTO_PLANT":         UpgradeDef.new("+1 automatic tree planter",            50, 1.5,  0,  false, "AUTO_CHOP"),
		"AUTO_CHOP_SPEED":    UpgradeDef.new("Automatic wood harvesters work faster",75, 1.5, 100, false, "AUTO_CHOP"),
		"MAX_TREES":          UpgradeDef.new("Multiplies maximum trees by 2",       100, 2.0, 25,  false, "AUTO_PLANT"),
		"AUTO_PLANT_SPEED":   UpgradeDef.new("Automatic tree planters work faster", 100, 1.5, 100, false, "AUTO_PLANT"),

		# --- Sawmill zone unlock & upgrades ---
		"UNLOCK_SAWMILL":     UpgradeDef.new("Unlock the sawmill zone",             150, 1.0,  1,  true,  "AUTO_CHOP"),
		"LOG_GRAVITY":        UpgradeDef.new("Logs fall into the sawmill faster",   120, 2.0, 40,  false, "UNLOCK_SAWMILL"),
		"SAWMILL_SPEED":      UpgradeDef.new("Sawmill processes logs faster",       150, 1.5, 20,  false, "UNLOCK_SAWMILL"),
		"DOUBLE_PLANKS":      UpgradeDef.new("Each log yields 2 planks",            400, 1.0,  1,  false, "SAWMILL_SPEED"),

		# --- Mining zone unlock & upgrades ---
		"UNLOCK_MINING":      UpgradeDef.new("Unlock the mining zone",              250, 1.0,  1,  true,  "UNLOCK_SAWMILL"),
		"MINING_SPEED":       UpgradeDef.new("Reduces the mining cooldown",         200, 1.5, 20,  false, "UNLOCK_MINING"),
		"MINING_YIELD":       UpgradeDef.new("Each mine strike yields +1 extra metal", 300, 1.5, 10, false, "UNLOCK_MINING"),
		"AUTO_MINE":          UpgradeDef.new("+1 automatic miner",                  400, 1.5, 16,  false, "MINING_SPEED"),

		# --- Smithing zone unlock & upgrades ---
		"UNLOCK_SMITHING":    UpgradeDef.new("Unlock the smithing zone",            500, 1.0,  1,  true,  "UNLOCK_MINING"),
		"SMITH_SPEED":        UpgradeDef.new("Reduces smithing cooldown",           350, 1.5, 20,  false, "UNLOCK_SMITHING"),
		"BULK_SMITH":         UpgradeDef.new("Each smelt produces 2x nails",        600, 1.0,  1,  false, "SMITH_SPEED"),
		"AUTO_SMITH":         UpgradeDef.new("+1 automatic smelter",                700, 1.5, 16,  false, "SMITH_SPEED"),

		# --- Assembling zone unlock & upgrades ---
		"UNLOCK_ASSEMBLING":  UpgradeDef.new("Unlock the assembling zone",          800, 1.0,  1,  true,  "UNLOCK_SMITHING"),
		"FASTER_ASSEMBLY":    UpgradeDef.new("Reduces time to build a chair",       400, 1.5, 20,  false, "UNLOCK_ASSEMBLING"),
		"BULK_ASSEMBLY":      UpgradeDef.new("Produce 2 chairs per assembly",      1000, 1.0,  1,  false, "FASTER_ASSEMBLY"),
		"AUTO_ASSEMBLE":      UpgradeDef.new("+1 automatic assembler",             1500, 1.5, 16,  false, "FASTER_ASSEMBLY"),

		# --- Market upgrades ---
		"INSIDER_TRADING":    UpgradeDef.new("Reduces the buy price markup",        500, 1.5, 10,  false, "UNLOCK_SAWMILL"),
		"BULK_DEAL":          UpgradeDef.new("Shift key buys/sells 25x instead of 10x", 800, 1.0, 1, false, "INSIDER_TRADING"),
		"MARKET_INSIGHT":     UpgradeDef.new("Shows the underlying price wave on the market graph", 300, 1.0, 1, false, "UNLOCK_SAWMILL"),

		# --- Auto seller / buyer ---
		"AUTO_SELL":          UpgradeDef.new("Unlock auto seller",                  700, 1.0,  1,  true,  "LOG_GRAVITY"),
		"AUTO_BUY":           UpgradeDef.new("Unlock auto buyer",                  1000, 1.0,  1,  true,  "AUTO_SELL"),
	}

	# Initialise ResTypes to 0 (MONEY handled separately as float)
	for r in ResType.values():
		if r != ResType.MONEY:
			_resources[r] = 0
	# Initialise upgrades to not purchased
	for u in UPGRADES:
		_upgrades[u] = 0

# --- Resource Interfaces ---

func get_amount(type: ResType) -> int:
	return _resources.get(type, 0)

func has_amount(type: ResType, amount: int) -> bool:
	return get_amount(type) >= amount

# Float money interface
func get_money() -> float:
	return _money

func has_money(amount: float) -> bool:
	return _money >= amount

func give_money(amount: float) -> float:
	_money = snappedf(_money + amount, 0.01)
	resource_changed.emit(ResType.MONEY, _money)
	return _money

func take_money(amount: float) -> bool:
	if not has_money(amount):
		return false
	_money = snappedf(_money - amount, 0.01)
	resource_changed.emit(ResType.MONEY, _money)
	return true

# Upgrade logic can go here e.g. (+2 wood per tree)
# Add to a resource. Returns the new total.
func give(type: ResType, amount: int) -> int:
	_resources[type] = get_amount(type) + amount
	resource_changed.emit(type, _resources[type])
	return _resources[type]

# Remove from a resource. Returns false if insufficient.
func take(type: ResType, amount: int) -> bool:
	if not has_amount(type, amount):
		return false
	_resources[type] = get_amount(type) - amount
	resource_changed.emit(type, _resources[type])
	return true

# Set a resource to an exact value.
func set_amount(type: ResType, amount: int) -> void:
	_resources[type] = amount
	resource_changed.emit(type, _resources[type])

# --- Upgrade Interfaces ---

func has_upgrade(name: String) -> bool:
	return _upgrades.get(name, 0) > 0

func get_upgrade_count(name: String) -> int:
	return _upgrades.get(name, 0)

# Returns the cost of the next purchase of this upgrade
func get_next_price(name: String) -> int:
	if debug:
		return 0
	if not UPGRADES.has(name):
		return 0
	var def: UpgradeDef = UPGRADES[name]
	return int(def.price * pow(def.price_scale, _upgrades.get(name, 0)))

# Returns true if this upgrade's prerequisite has been purchased (or it has none)
func is_upgrade_visible(name: String) -> bool:
	if not UPGRADES.has(name):
		return false
	var req: String = UPGRADES[name].requires
	return req == "" or get_upgrade_count(req) > 0

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_button_player.stop()
		_button_player.play()

func unlock_upgrade(name: String) -> bool:
	if not UPGRADES.has(name):
		push_error("Unknown upgrade: %s" % name)
		return false
	var def: UpgradeDef = UPGRADES[name]
	if def.max_count > 0 and _upgrades[name] >= def.max_count:
		return false
	if not take_money(get_next_price(name)):
		return false
	print("Upgrade unlocked: %s" % name)
	_upgrades[name] += 1
	upgrade_unlocked.emit(name)
	return true
