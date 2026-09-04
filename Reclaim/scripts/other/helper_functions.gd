class_name HelperFunctions
extends RefCounted

# =============================================================================
# CONSTANTS
# =============================================================================

# Groups & Data Keys
const ROOT_NODES_GROUP: String = "root_nodes"
const DEFAULT_BULLET_TRAIL_KEY: String = "default"

# Numeric & Sizing Limits
const MAX_SOUNDS: int = 50
const MAX_DAMAGE_INDICATIONS: int = 100
const DEFAULT_ITEM_AMOUNT: int = 0
const DEFAULT_ITEM_CHANGE: int = 1

# Formatting & Shorthand
const MAX_TEXT: String = "MAX"
const ORDER_OF_MAGNITUDE: int = 10
const HUNDRED_THRESHOLD: int = 3
const COMMA_FREQUENCY: int = 3
const SHORT_HAND_NUDGE: float = 1e-9
const MAX_SHORTHAND_MAGNITUDE: int = 12

const BILLION_SUFFIX: String = "B"
const MILLION_SUFFIX: String = "M"
const THOUSAND_SUFFIX: String = "K"

const SHORTHAND_THRESHOLDS: Dictionary = {
	9: BILLION_SUFFIX,
	6: MILLION_SUFFIX,
	3: THOUSAND_SUFFIX,
}

# String Symbols & Formats
const EMPTY_STRING: String = ""
const UNDERSCORE_SEPARATOR: String = "_"
const SPACE_SEPARATOR: String = " "
const MINUS_SIGN: String = "-"
const COMMA_SEPARATOR: String = ","
const DECIMAL_FORMAT: String = "%d.%d"

# Preloaded Scenes
const TEMP_SOUND_SCENE: PackedScene = preload("res://scenes/other/temp_sound_scene.tscn")
const TEMP_SOUND_SCENE_3D: PackedScene = preload("res://scenes/other/temp_sound_scene_3D.tscn")
const BULLET_TRAIL_SCENE: PackedScene = preload("res://scenes/turrets/bullet_trail.tscn")
const DAMAGE_INDICATOR_SCENE: PackedScene = preload("res://scenes/other/damage_indicator.tscn")

# Other 
const TIERS := 5

# =============================================================================
# STATIC STATE (shared counters)
# =============================================================================

static var sounds: int = 0
static var damage_indications: int = 0


## Sets the mouse of the player to be unlocked or locked bassed on its last value
static func set_mouse_captured(set_mode : bool = false, set_value : bool = false) -> void:
	if set_mode:
		Global.mouse_captured = set_value
	else:
		Global.mouse_captured = not Global.mouse_captured
	
	if Global.mouse_captured:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


# =============================================================================
# ROOT / SPAWN HELPERS
# =============================================================================
## Adds the node to the root node of the current scene or the node that is in the group
## of root nodes in the current scene
static func add_to_root_node(node: Node) -> void:
	if node == null:
		return
	
	var tree := Engine.get_main_loop() as SceneTree
	if tree == null:
		return
	
	var root_node := tree.get_first_node_in_group(ROOT_NODES_GROUP)
	if root_node:
		root_node.add_child(node)


## spawns a sound at a position or a flat sound bassed on a position pramater
static func spawn_temp_sound(sound: SoundInfo, pos: Vector3 = Vector3.ZERO) -> void:
	if sound == null or sound.stream == null or sounds >= MAX_SOUNDS:
		return
	
	sounds += 1

	if pos != Vector3.ZERO:
		var new_sound: AudioStreamPlayer3D = TEMP_SOUND_SCENE_3D.instantiate()
		new_sound.stream = sound.stream
		add_to_root_node(new_sound)
		new_sound.global_position = pos
		new_sound.volume_db = sound.volume
		new_sound.max_db = sound.max_db
		new_sound.max_distance = sound.max_distance
		new_sound.play()
	else:
		var new_sound: AudioStreamPlayer = TEMP_SOUND_SCENE.instantiate()
		new_sound.stream = sound.stream
		add_to_root_node(new_sound)
		new_sound.volume_db = sound.volume
		new_sound.play()


## creates a bullet trail between 2 positions with alot of paramaters
static func create_bullet_trail(
	from: Vector3,
	to: Vector3,
	trail: Resource = null
) -> void:
	if trail == null:
		if not DataRegistry.bullet_trail.has(DEFAULT_BULLET_TRAIL_KEY):
			return
		trail = DataRegistry.bullet_trail[DEFAULT_BULLET_TRAIL_KEY]

	var new_bullet_trail = BULLET_TRAIL_SCENE.instantiate()
	new_bullet_trail.trail = trail
	add_to_root_node(new_bullet_trail)
	new_bullet_trail.create_bullet_trail(from, to)


## creates a amage indicator for when enemies get hit
static func create_damage_indicator(pos: Vector3, damage: float, crit: bool) -> void:
	if damage <= DEFAULT_ITEM_AMOUNT or damage_indications >= MAX_DAMAGE_INDICATIONS or Global.at_ship:
		return

	damage_indications += 1
	var new_indication = DAMAGE_INDICATOR_SCENE.instantiate()
	new_indication.damage = damage
	add_to_root_node(new_indication)
	new_indication.global_position = pos
	new_indication.crit = crit
	new_indication.init()

# =============================================================================
# DISPLAY / UI HELPERS
# =============================================================================

## returns a shorthand version of the inputed number 
static func return_amount_shorthand(value: float) -> String:
	if value <= 0:
		return str(int(value))
	
	var magnitude: int = floori(log(value) / log(ORDER_OF_MAGNITUDE) + SHORT_HAND_NUDGE)
	var magnitude_divisor: int = DEFAULT_ITEM_AMOUNT
	var suffix: String = EMPTY_STRING
	var decimal_point_needed: bool = false
	
	if magnitude < HUNDRED_THRESHOLD:
		return str(int(value))
	
	if magnitude >= MAX_SHORTHAND_MAGNITUDE:
		return MAX_TEXT
	
	for x in SHORTHAND_THRESHOLDS:
		if x <= magnitude:
			suffix = SHORTHAND_THRESHOLDS[x]
			magnitude_divisor = x
			if magnitude == x:
				decimal_point_needed = true
			break

	if decimal_point_needed:
		var tenth: int = roundi(value / (ORDER_OF_MAGNITUDE ** magnitude_divisor) * 10.0)
		var whole: int = roundi(float(tenth) / 10.0)
		var remainder: int = tenth % 10
		if remainder == 0:
			return str(whole) + suffix
		return DECIMAL_FORMAT % [whole, remainder] + suffix
	
	return str(floori(value / (ORDER_OF_MAGNITUDE ** magnitude_divisor))) + suffix


## removed underscores and captlizes the next letter
static func get_display_name(input: String) -> String:
	if input.is_empty():
		return EMPTY_STRING
	
	var words := input.split(UNDERSCORE_SEPARATOR)
	for i in words.size():
		words[i] = words[i].capitalize()
	return SPACE_SEPARATOR.join(words)


## puts commas every 3 numbers
static func comma_number(num: int) -> String:
	if num >= (ORDER_OF_MAGNITUDE ** MAX_SHORTHAND_MAGNITUDE):
		return MAX_TEXT
	
	var if_negetive := MINUS_SIGN if num < 0 else EMPTY_STRING
	var text := str(absi(num))
	var result := EMPTY_STRING
	
	while text.length() > COMMA_FREQUENCY:
		result = COMMA_SEPARATOR + text.substr(text.length() - COMMA_FREQUENCY) + result
		text = text.substr(0, text.length() - COMMA_FREQUENCY)
	
	return if_negetive + text + result

# =============================================================================
# STORAGE HELPERS
# =============================================================================

## gets the current active storage bassed on where the player is
static func get_current_storage() -> Dictionary:
	if Global.at_ship:
		return Global.ship_storage
	return Global.sector_storage


## checks if the item resource is not null and has a valid key and tier
static func is_valid_item(item_resource: ItemData) -> bool:
	return (
		item_resource != null
		and not item_resource.key.is_empty()
		and Global.TIER_CONFIG.has(item_resource.tier)
	)


## gets the amount of a specific item in the target storage
static func get_item_amount(item_resource: ItemData, storage: Dictionary = {}) -> int:
	if not is_valid_item(item_resource):
		# fall back
		return DEFAULT_ITEM_AMOUNT
	
	var target_storage := _get_storage(storage)
	
	if not target_storage.has(item_resource.tier):
		return DEFAULT_ITEM_AMOUNT
	
	return max(
		int(target_storage[item_resource.tier].get(item_resource.key, DEFAULT_ITEM_AMOUNT)),
		DEFAULT_ITEM_AMOUNT
	)


## checks if the target storage contains at least a certain amount of an item
static func has_item_amount(
	item_resource: ItemData,
	amount: int = DEFAULT_ITEM_CHANGE,
	storage: Dictionary = {}
) -> bool:
	if amount <= DEFAULT_ITEM_AMOUNT:
		return false
	return get_item_amount(item_resource, storage) >= amount


## adds a specific amount of an item to the target storage
static func add_item_to_storage(
	item_resource: ItemData,
	amount: int = DEFAULT_ITEM_CHANGE,
	storage: Dictionary = {}
) -> bool:
	if not is_valid_item(item_resource) or amount <= DEFAULT_ITEM_AMOUNT or storage.is_read_only():
		return false
	
	var target_storage := _get_storage(storage)
	
	if not target_storage.has(item_resource.tier):
		target_storage[item_resource.tier] = {}
	
	target_storage[item_resource.tier][item_resource.key] = (
		get_item_amount(item_resource, target_storage) + amount
	)
	
	return true


## removes a specific amount of an item from the target storage if there is enough
## storage defaults to current if not provided
static func remove_item_from_storage(
	item_resource: ItemData,
	amount: int = DEFAULT_ITEM_CHANGE,
	storage: Dictionary = {}
) -> bool:
	if not has_item_amount(item_resource, amount, storage):
		return false
	
	var target_storage := _get_storage(storage)
	var remaining := get_item_amount(item_resource, target_storage) - amount
	
	if remaining > DEFAULT_ITEM_AMOUNT:
		target_storage[item_resource.tier][item_resource.key] = remaining
	else:
		target_storage[item_resource.tier].erase(item_resource.key)
	
	return true


## returns the current storage if the the inputed storage is empty
static func _get_storage(storage : Dictionary) -> Dictionary:
	if storage.is_empty():
		return get_current_storage()
	return storage


## gets all items of a certain type with all their amounts
static func get_items_from_type(item_type) -> Dictionary:
	var current_storage = get_current_storage()
	var items: Dictionary = {}
	
	for tier in current_storage:
		items[tier] = {}
		for item_key in current_storage[tier]:
			if not DataRegistry.items.has(item_key):
				continue
			
			if DataRegistry.items[item_key].type == item_type:
				items[tier][item_key] = current_storage[tier][item_key]
	
	return items


## returns item value pairs from a storage
static func get_item_from_storage(storage : Dictionary) -> Dictionary:
	if not storage:
		storage = get_current_storage()
	
	var item_value_pairs : Dictionary
	
	for tier in storage:
		for item_name in storage[tier]:
			item_value_pairs[item_name] = storage[tier][item_name]
	
	return item_value_pairs


## returns a fresh editable/writable dictionary for when clearing storages
static func get_clean_storage() -> Dictionary:
	var storage : Dictionary
	for x in range(1, TIERS + 1):
		storage[x] = {}
	
	return storage


## returns the 2 inputed storages merged into one.
static func merge_storage(first, second) -> Dictionary:
	if not first or not second:
		return {}
	
	if not first:
		return second
	
	if not second:
		return first
	
	var merged : Dictionary = first
	
	for tier in second:
		for item_name in second[tier]:
			if item_name not in DataRegistry.items:
				continue
			
			if merged[tier].has(item_name):
				merged[tier][item_name] += second[tier][item_name]
			else:
				merged[tier][item_name] = second[tier][item_name]
	
	return merged
