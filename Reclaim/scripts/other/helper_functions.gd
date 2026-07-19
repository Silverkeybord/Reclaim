class_name HelperFunctions
extends RefCounted

# =============================================================================
# CONSTANTS
# =============================================================================

const ROOT_NODES_GROUP: String = "root_nodes"
const DEFAULT_BULLET_TRAIL_KEY: String = "default"

const MAX_SOUNDS: int = 50
const MAX_DAMAGE_INDICATIONS: int = 100

const MAX_TEXT: String = "MAX"
const ORDER_OF_MAGNITUDE: int = 10
const HUNDRED_THRESHOLD: int = 3
const COMMA_FREQUENCY: int = 3
const SHORT_HAND_NUDGE: float = 1e-9
const MAX_SHORTHAND_MAGNITUDE: int = 12

const SHORTHAND_THRESHOLDS: Dictionary = {
	9: "B",
	6: "M",
	3: "K",
}

const TEMP_SOUND_SCENE: PackedScene = preload("res://scenes/other/temp_sound_scene.tscn")
const TEMP_SOUND_SCENE_3D: PackedScene = preload("res://scenes/other/temp_sound_scene_3D.tscn")
const BULLET_TRAIL_SCENE: PackedScene = preload("res://scenes/turrets/bullet_trail.tscn")
const DAMAGE_INDICATOR_SCENE: PackedScene = preload("res://scenes/other/damage_indicator.tscn")

# =============================================================================
# STATIC STATE (shared counters)
# =============================================================================

static var sounds: int = 0
static var damage_indications: int = 0

# =============================================================================
# ROOT / SPAWN HELPERS
# =============================================================================
## adds the node to the root node of the current scene or the node that is in the group
## of root nodes in the current scene
static func add_to_root_node(node: Node) -> void:
	var tree := Engine.get_main_loop() as SceneTree
	if tree == null:
		return
	var root_node := tree.get_first_node_in_group(ROOT_NODES_GROUP)
	if root_node:
		root_node.add_child(node)


## spawns a sound at a position or a flat sound bassed on a position pramater
static func spawn_temp_sound(sound: SoundInfo, pos: Vector3 = Vector3.ZERO) -> void:
	if sounds >= MAX_SOUNDS:
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
		trail = DataRegistry.bullet_trail[DEFAULT_BULLET_TRAIL_KEY]

	var new_bullet_trail = BULLET_TRAIL_SCENE.instantiate()
	new_bullet_trail.trail = trail
	add_to_root_node(new_bullet_trail)
	new_bullet_trail.create_bullet_trail(from, to)


## creates a amage indicator for when enemies get hit
static func create_damage_indicator(pos: Vector3, damage: float, crit: bool) -> void:
	if damage_indications >= MAX_DAMAGE_INDICATIONS or Global.at_ship:
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
	var magnitude: int = floori(log(value) / log(ORDER_OF_MAGNITUDE) + SHORT_HAND_NUDGE)
	var magnitude_divisor: int
	var suffix: String
	var decimal_point_needed: bool = false
	
	if value <= 0:
		return str(int(value))
	
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
		return "%d.%d" % [whole, remainder] + suffix
	
	return str(floori(value / (ORDER_OF_MAGNITUDE ** magnitude_divisor))) + suffix


## removed underscores and captlizes the next letter
static func get_display_name(input: String) -> String:
	var words := input.split("_")
	for i in words.size():
		words[i] = words[i].capitalize()
	return " ".join(words)


## puts commas every 3 numbers
static func comma_number(num: int) -> String:
	if num >= (ORDER_OF_MAGNITUDE ** MAX_SHORTHAND_MAGNITUDE):
		return MAX_TEXT
	
	var text := str(num)
	var result := ""
	
	while text.length() > COMMA_FREQUENCY:
		result = "," + text.substr(text.length() - COMMA_FREQUENCY) + result
		text = text.substr(0, text.length() - COMMA_FREQUENCY)
	
	return text + result

# =============================================================================
# STORAGE HELPERS
# =============================================================================

## gets the current active storage bassed on where the player is
static func get_current_storage() -> Dictionary:
	if Global.at_ship:
		return Global.ship_storage
	return Global.sector_storage


## gets all items of a certain type with all their amounts
static func get_items_from_type(item_type) -> Dictionary:
	var current_storage = get_current_storage()
	var items: Dictionary = {}
	
	for tier in current_storage:
		items[tier] = {}
		for item_key in current_storage[tier]:
			if DataRegistry.items[item_key].type == item_type:
				items[tier][item_key] = current_storage[tier][item_key]

	return items


## checks if an item is in the current storage
static func check_for_item(item_resource: ItemData) -> bool:
	var current_storage = get_current_storage()
	var amount = current_storage[item_resource.tier].get(item_resource.key, 0)
	
	if amount <= 0:
		return false
	return true
	
	 
