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

	func _init(p_description: String, p_price: int, p_price_scale: float, p_max_count: int) -> void:
		description = p_description
		price = p_price
		price_scale = p_price_scale
		max_count = p_max_count

var UPGRADES: Dictionary = {}

# --- State ---

var _resources: Dictionary = {}
var _upgrades: Dictionary = {}
var _money: float = 0.0

func _ready() -> void:
	# Initialise upgrade definitions — name is the key
	UPGRADES = {
		#  name 							description                   price, price_scale, max_count (0 = unlimited)
		"AUTO_PLANT":        UpgradeDef.new("+1 automatic tree planter",   0,  1.5,  0),
		"AUTO_PLANT_SPEED": UpgradeDef.new("Automatic tree planters work faster",   0,  1.5,  10),
		"MAX_TREES":         UpgradeDef.new("Multiplies maximum trees by 2",       0,  2.0,  10),
		"AUTO_CHOP":        UpgradeDef.new("+1 automatic wood harvester",   0,  1.5,  16),
		"AUTO_CHOP_SPEED": UpgradeDef.new("Automatic wood harvesters work faster",   0,  1.5,  10),
		"LOG_GRAVITY":      UpgradeDef.new("Logs fall faster",   0,  2.0,  25),
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
	if not UPGRADES.has(name):
		return 0
	var def: UpgradeDef = UPGRADES[name]
	return int(def.price * pow(def.price_scale, _upgrades.get(name, 0)))

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
