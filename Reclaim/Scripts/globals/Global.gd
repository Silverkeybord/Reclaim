extends Node
# =============================================================================
# ENUMS =======================================================================
# =============================================================================

enum SHOT_TYPE {
	HITSCAN,
	PROJECTILE
}
enum BUILD_MODES {
	TURRET,
	BASE
}
enum BUILD_TYPES {
	TURRET,
	BASE
}
enum ITEM_TYPES {
	MODULE,
	TURRET,
	BASE,
	RESOURCES
}
enum PLAYER_MODES {
	WEAPON,
	BUILDING,
	INSTALLING
}


# =============================================================================
# CONSTANTS ===================================================================
# =============================================================================

# MISC --------------------------------------------------------------------
const SAVE_PATH : String = "user://reclaim.save"
const SAVE_SHIP_STORAGE_KEY := "ship_storage"
const SAVE_CUBITS_KEY := "cubits"
const SAVE_COUNCIL_AUTHORIZATION_KEY := "council_authorization"
const SAVE_TURRET_SLOTS_KEY := "turret_slots"
const TEST_STORAGE_MIN_AMOUNT := 3
const TEST_STORAGE_MAX_AMOUNT := 3
const TEST_SHIP_STORAGE_MIN_AMOUNT := 1
const TEST_SHIP_STORAGE_MAX_AMOUNT := 999
const TEST_STORAGE_EXPONENT := 0
const TIER_CONFIG : Dictionary = {
	1 : {
		"color" : Color(0.541, 0.561, 0.596),
		"style" : preload("res://other_assets/crafting_styles/t1_style.tres"),
		"cells" : {
			"resources" : preload("res://2d_assets/storage/resource_cells/rough_cell.png"),
			"turrets" : preload("res://2d_assets/storage/turret_cells/rough_cell.png"),
			"modules" : preload("res://2d_assets/storage/module_cells/rough_cell.png")
		}
	},
	2 : {
		"color" : Color(0.29, 0.871, 0.502),
		"style" : preload("res://other_assets/crafting_styles/t2_style.tres"),
		"cells" : {
			"resources" : preload("res://2d_assets/storage/resource_cells/plain_cell.png"),
			"turrets" : preload("res://2d_assets/storage/turret_cells/plain_cell.png"),
			"modules" : preload("res://2d_assets/storage/module_cells/plain_cell.png")
		}
	},
	3 : {
		"color" : Color(0.29, 0.557, 0.996),
		"style" : preload("res://other_assets/crafting_styles/t3_style.tres"),
		"cells" : {
			"resources" : preload("res://2d_assets/storage/resource_cells/usefull_cell.png"),
			"turrets" : preload("res://2d_assets/storage/turret_cells/useful_cell.png"),
			"modules" : preload("res://2d_assets/storage/module_cells/usefull_cell.png")
		}
	},
	4 : {
		"color" : Color(1.0, 0.847, 0.243),
		"style" : preload("res://other_assets/crafting_styles/t4_style.tres"),
		"cells" : {
			"resources" : preload("res://2d_assets/storage/resource_cells/valuable_cell.png"),
			"turrets" : preload("res://2d_assets/storage/turret_cells/valuable_cell.png"),
			"modules" : preload("res://2d_assets/storage/module_cells/valuable_cell.png")
		}
	},
	5 : {
		"color" : Color(0.937, 0.267, 0.267),
		"style" : preload("res://other_assets/crafting_styles/t5_style.tres"),
		"cells" : {
			"resources" : preload("res://2d_assets/storage/resource_cells/extraordinary_cell.png"),
			"turrets" : preload("res://2d_assets/storage/turret_cells/extraordinary_cell.png"),
			"modules" : preload("res://2d_assets/storage/module_cells/extraordinary_cell.png")
		}
	}
}

# CAPS --------------------------------------------------------------------
const MAX_DROPS : int = 250
const MAX_SPHERES : int = 300

# =============================================================================
# VARIABLES ===================================================================
# =============================================================================

# LOGIC --------------------------------------------------------------------
var player_mode := PLAYER_MODES.WEAPON
var current_build_mode := BUILD_MODES.TURRET
var at_ship := true
var mouse_captured := true

# USER INTERFACE
var paused := false
var ui_open := false
var storage_open := false
var crafting_open := false
var research_open := false
var market_open := false

# var hidden_item_tip := false Testing 

# SECTOR RELATED ------------------------------------------------------------
var selected_sector : String
var selected_sector_path := "res://scenes/maps/remote_island.tscn"
var sector_run_time : float

# ENEMIES
var enemies : int = 0

# META UPGRADES / COUNCIL AUTHORIZATION -------------------------------------
var ship_level := 8
var turret_slots := 1
var shield_strength := 1


# INVENTORY + CURRENCY -------------------------------------------------------
var cubits : int = 0
var sector_storage : Dictionary = {
	1 : {},
	2 : {},
	3 : {},
	4 : {},
	5 : {}
}
var ship_storage : Dictionary = {
	1 : {},
	2 : {},
	3 : {},
	4 : {},
	5 : {}
}
var extraction_storage : Dictionary = {
	1 : {},
	2 : {},
	3 : {},
	4 : {},
	5 : {}
}


## Temp testing function to fill storage
func set_random_storage(set_sector_storage = false) -> void:
	for key in DataRegistry.items:
		var resource = DataRegistry.items[key]
		if not HelperFunctions.is_valid_item(resource):
			continue
		
		if set_sector_storage:
			sector_storage[resource.tier][key] = (
				randi_range(TEST_STORAGE_MIN_AMOUNT, TEST_STORAGE_MAX_AMOUNT)
				* (10 ** TEST_STORAGE_EXPONENT)
				)
		else:
			ship_storage[resource.tier][key] = (
				randi_range(TEST_SHIP_STORAGE_MIN_AMOUNT, TEST_SHIP_STORAGE_MAX_AMOUNT)
				* (10 ** TEST_STORAGE_EXPONENT)
				)


## Sets the mouse of the player to be unlocked or locked bassed on its last value
func set_mouse_captured() -> void:
	mouse_captured = not mouse_captured
	
	if mouse_captured:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


# =============================================================================
# SAVING, LOADING, AND RESETING GAME DATA =====================================
# =============================================================================
## Saves the current game data to the path
func save_game():
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		push_error("Could not open save file for writing: %s" % SAVE_PATH)
		return
	
	var save_data = {
		# storage / storage
		SAVE_SHIP_STORAGE_KEY : ship_storage,
		SAVE_CUBITS_KEY : cubits,
		SAVE_COUNCIL_AUTHORIZATION_KEY : {
			SAVE_TURRET_SLOTS_KEY : turret_slots
		}
		
	}
	
	file.store_var(save_data)


## Loads the data from the saved folder if there is one
func load_game():
	if not FileAccess.file_exists(SAVE_PATH):
		return
	
	
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		push_error("Could not open save file for reading: %s" % SAVE_PATH)
		return
	
	var data = file.get_var()
	if typeof(data) != TYPE_DICTIONARY:
		push_error("Save file did not contain valid save data.")
		return
	
	if data.has(SAVE_SHIP_STORAGE_KEY):
		ship_storage = data[SAVE_SHIP_STORAGE_KEY]
	
	cubits = int(data.get(SAVE_CUBITS_KEY, cubits))
	
	var council_authorization = data.get(SAVE_COUNCIL_AUTHORIZATION_KEY, {})
	if typeof(council_authorization) == TYPE_DICTIONARY:
		turret_slots = int(council_authorization.get(SAVE_TURRET_SLOTS_KEY, turret_slots))


## Deletes the game data completely, removing the save file
func reset_game():
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE_PATH))
	get_tree().quit()
