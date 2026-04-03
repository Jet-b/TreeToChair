extends Node

# --- Emitters for retrieving signals ---

## Emitted when any resource amount changes: (resource_type, new_amount)
signal resource_changed(type: ResType, amount: int)
## Emitted when an upgrade is unlocked: (upgrade_type)
signal upgrade_unlocked(type: Upgrade)

# --- Enums ---

enum ResType {
	MONEY,
	WOOD,
	PLANKS,
	METAL,
	NAILS,
	CHAIRS,
}

enum Upgrade {
	SHARP_AXE,        # +2 wood per tree
	FINE_SAW,         # 1 wood per plank instead of 2
	MASTER_CARPENTER, # 2 planks per chair instead of 3
	BETTER_FORGE,     # 9 nails per metal instead of 6
	FEWER_NAILS,      # 2 nails per chair instead of 4
	SALES_TRAINING,   # +5 money per chair
	FERTILE_SOIL,     # halved tree plant cost
}

# --- State ---

var _resources: Dictionary = {}
var _upgrades: Dictionary = {}

func _ready() -> void:
	# Initialise ResTypes to 0
	for r in ResType.values():
		_resources[r] = 0
	# Initialise upgrades to false
	for u in Upgrade.values():
		_upgrades[u] = false

# --- Resource Interfaces ---

func get_amount(type: ResType) -> int:
	return _resources.get(type, 0)

func has_amount(type: ResType, amount: int) -> bool:
	return get_amount(type) >= amount

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

func has_upgrade(type: Upgrade) -> bool:
	return _upgrades.get(type, false)

func unlock_upgrade(type: Upgrade) -> void:
	_upgrades[type] = true
	upgrade_unlocked.emit(type)
