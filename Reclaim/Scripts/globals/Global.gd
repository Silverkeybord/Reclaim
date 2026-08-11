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

# SECTORS ----------------------------------------------------------------
const SECTORS := {
	"remote_island" : preload("res://scenes/maps/remote_island.tscn")
}

# PATHS & DEFAULTS --------------------------------------------------------
const SAVE_PATH: String = "user://reclaim.save"
const DEFAULT_SECTOR_PATH: PackedScene = SECTORS["remote_island"]

# SAVE KEYS ---------------------------------------------------------------
const SAVE_SHIP_STORAGE_KEY: String = "ship_storage"
const SAVE_CUBITS_KEY: String = "cubits"
const SAVE_COUNCIL_AUTHORIZATION_KEY: String = "council_authorization"
const SAVE_TURRET_SLOTS_KEY: String = "turret_slots"

# TIER CONFIG KEYS --------------------------------------------------------
const KEY_COLOR: String = "color"
const KEY_STYLE: String = "style"
const KEY_CELLS: String = "cells"
const KEY_RESOURCES: String = "resources"
const KEY_TURRETS: String = "turrets"
const KEY_MODULES: String = "modules"

# ERROR MESSAGES ----------------------------------------------------------
const ERR_SAVE_WRITE: String = "Could not open save file for writing: %s"
const ERR_SAVE_READ: String = "Could not open save file for reading: %s"
const ERR_SAVE_INVALID: String = "Save file did not contain valid save data."

# MISC --------------------------------------------------------------------
const TEST_STORAGE_MIN_AMOUNT: int = 100
const TEST_STORAGE_MAX_AMOUNT: int = 999
const TEST_STORAGE_EXPONENT: int = 0

const TIER_CONFIG: Dictionary = {
	1: {
		KEY_COLOR: Color(0.541, 0.561, 0.596),
		KEY_STYLE: preload("res://other_assets/styles/crafting_styles/t1_style.tres"),
		KEY_CELLS: {
			KEY_RESOURCES: preload("res://2d_assets/storage/resource_cells/rough_cell.png"),
			KEY_TURRETS: preload("res://2d_assets/storage/turret_cells/rough_cell.png"),
			KEY_MODULES: preload("res://2d_assets/storage/module_cells/rough_cell.png")
		}
	},
	2: {
		KEY_COLOR: Color(0.29, 0.871, 0.502),
		KEY_STYLE: preload("res://other_assets/styles/crafting_styles/t2_style.tres"),
		KEY_CELLS: {
			KEY_RESOURCES: preload("res://2d_assets/storage/resource_cells/plain_cell.png"),
			KEY_TURRETS: preload("res://2d_assets/storage/turret_cells/plain_cell.png"),
			KEY_MODULES: preload("res://2d_assets/storage/module_cells/plain_cell.png")
		}
	},
	3: {
		KEY_COLOR: Color(0.29, 0.557, 0.996),
		KEY_STYLE: preload("res://other_assets/styles/crafting_styles/t3_style.tres"),
		KEY_CELLS: {
			KEY_RESOURCES: preload("res://2d_assets/storage/resource_cells/usefull_cell.png"),
			KEY_TURRETS: preload("res://2d_assets/storage/turret_cells/useful_cell.png"),
			KEY_MODULES: preload("res://2d_assets/storage/module_cells/usefull_cell.png")
		}
	},
	4: {
		KEY_COLOR: Color(1.0, 0.847, 0.243),
		KEY_STYLE: preload("res://other_assets/styles/crafting_styles/t4_style.tres"),
		KEY_CELLS: {
			KEY_RESOURCES: preload("res://2d_assets/storage/resource_cells/valuable_cell.png"),
			KEY_TURRETS: preload("res://2d_assets/storage/turret_cells/valuable_cell.png"),
			KEY_MODULES: preload("res://2d_assets/storage/module_cells/valuable_cell.png")
		}
	},
	5: {
		KEY_COLOR: Color(0.937, 0.267, 0.267),
		KEY_STYLE: preload("res://other_assets/styles/crafting_styles/t5_style.tres"),
		KEY_CELLS: {
			KEY_RESOURCES: preload("res://2d_assets/storage/resource_cells/extraordinary_cell.png"),
			KEY_TURRETS: preload("res://2d_assets/storage/turret_cells/extraordinary_cell.png"),
			KEY_MODULES: preload("res://2d_assets/storage/module_cells/extraordinary_cell.png")
		}
	}
}

# CAPS --------------------------------------------------------------------
const MAX_DROPS: int = 250
const MAX_SPHERES: int = 300

# =============================================================================
# VARIABLES ===================================================================
# =============================================================================

# LOGIC --------------------------------------------------------------------
var player_mode := PLAYER_MODES.WEAPON
var current_build_mode := BUILD_MODES.TURRET
var at_ship := true
var mouse_captured := true
var major_animation_playing := false

# USER INTERFACE -----------------------------------------------------------
var paused := false
var ui_open := false
var market_open := false
var storage_open := false
var crafting_open := false
var extraction_open := false
var authorization_open := false

# SECTOR RELATED ------------------------------------------------------------
var selected_sector : String
var selected_sector_path : PackedScene = DEFAULT_SECTOR_PATH
var sector_run_time : float
var shield_overdrive : bool = false 
var just_extracted : bool = false

# ENEMIES
var enemies: int = 0

# META UPGRADES / COUNCIL AUTHORIZATION -------------------------------------
var ship_level: int = 8
var turret_slots: int = 1
var shield_strength: int = 1


# INVENTORY + CURRENCY -------------------------------------------------------
var cubits: int = 0
var sector_storage: Dictionary = {
	1: {},
	2: {},
	3: {},
	4: {},
	5: {}
}
var ship_storage: Dictionary = {
	1: {
		"dirt" : 5,
		"sand" : 5,
		"clay" : 3,
		"rock" : 3,
		"scrap" : 1,
	},
	2: {},
	3: {},
	4: {},
	5: {}
}
var extraction_storage: Dictionary = {
	1: {},
	2: {},
	3: {},
	4: {},
	5: {}
}


## Temp testing function to fill storage - THIS IS A TESTING SCRIPT IGNORE CONVENTIONS
func set_random_storage(set_sector_storage: bool = false) -> void:
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
				randi_range(TEST_STORAGE_MIN_AMOUNT, TEST_STORAGE_MAX_AMOUNT)
				* (10 ** TEST_STORAGE_EXPONENT)
				)


## Sets the mouse of the player to be unlocked or locked bassed on its last value
func set_mouse_captured(set_mode : bool = false, set_value : bool = false) -> void:
	if set_mode:
		mouse_captured = set_value
	else:
		mouse_captured = not mouse_captured
	
	if mouse_captured:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


# =============================================================================
# SAVING, LOADING, AND RESETING GAME DATA =====================================
# =============================================================================
## Saves the current game data to the path
func save_game() -> void:
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		push_error(ERR_SAVE_WRITE % SAVE_PATH)
		return
	
	var save_data := {
		# storage / storage
		SAVE_SHIP_STORAGE_KEY: ship_storage,
		SAVE_CUBITS_KEY: cubits,
		SAVE_COUNCIL_AUTHORIZATION_KEY: {
			SAVE_TURRET_SLOTS_KEY: turret_slots
		}
	}
	
	file.store_var(save_data)


## Loads the data from the saved folder if there is one
func load_game() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return
	
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		push_error(ERR_SAVE_READ % SAVE_PATH)
		return
	
	var data = file.get_var()
	if typeof(data) != TYPE_DICTIONARY:
		push_error(ERR_SAVE_INVALID)
		return
	
	if data.has(SAVE_SHIP_STORAGE_KEY):
		ship_storage = data[SAVE_SHIP_STORAGE_KEY]
	
	cubits = int(data.get(SAVE_CUBITS_KEY, cubits))
	
	var council_authorization = data.get(SAVE_COUNCIL_AUTHORIZATION_KEY, {})
	if typeof(council_authorization) == TYPE_DICTIONARY:
		turret_slots = int(council_authorization.get(SAVE_TURRET_SLOTS_KEY, turret_slots))


## Deletes the game data completely, removing the save file
func reset_game() -> void:
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE_PATH))
	get_tree().quit()
