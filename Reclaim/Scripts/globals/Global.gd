extends Node
# =============================================================================
# ENUMS
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
# CONSTANTS
# =============================================================================

# SECTORS ----------------------------------------------------------------
const SECTORS := {
	"remote_island" : preload("res://scenes/maps/remote_island.tscn")
}

# PATHS & DEFAULTS --------------------------------------------------------
const SAVE_PATH: String = "user://reclaim.save"
const DEFAULT_SECTOR_PATH: PackedScene = SECTORS["remote_island"]

# SAVE AND LOADING ---------------------------------------------------------
const SAVE_SHIP_STORAGE_KEY: String = "ship_storage"
const SAVE_CUBITS_KEY: String = "cubits"
const SAVE_COUNCIL_AUTHORIZATION_KEY: String = "council_authorization"
const SAVE_SETTINGS_KEY: String = "settings"

# UPGRADES
const SAVE_SHIP_KEY := "level_ship"
const SAVE_SHIP_CAPACITY_KEY := "level_ship_capacity"
const SAVE_EXTRACTION_CAPACITY_KEY := "level_extraction_capacity"
const SAVE_DEPLOYMENT_CAPACITY_KEY := "level_deployment_capacity"
const SAVE_SHIELD_STRENGTH_KEY := "level_shield_strength"
const SAVE_CRAFT_EFFICIENCY_KEY := "level_craft_efficiency"
const SAVE_WEAPON_AUTHORIZATION_KEY := "level_weapon_authorization"
const SAVE_TURRET_AUTHORIZATION_KEY := "level_turret_authorization"
const SAVE_MODULE_AUTHORIZATION_KEY := "level_module_authorization"
const SAVE_TURRET_SLOTS_KEY := "level_turret_slots"

const SAVE_SENSIVITY_KEY: String = "sensitivity"
const SAVE_SHOW_FPS_TOGGLE: String = "show_fps"
const SAVE_SHOW_INPUT_TIP_TOGGLE: String = "show_input_tip"

const SAVE_AND_LOAD_BUFFER: float = 0.5

# TIER CONFIG KEYS --------------------------------------------------------
const KEY_COLOR: String = "color"
const KEY_STYLE: String = "style"
const KEY_CELLS: String = "cells"
const KEY_FONT: String = "font"
const KEY_RESOURCES: String = "resources"
const KEY_TURRETS: String = "turrets"
const KEY_MODULES: String = "modules"

# ERROR MESSAGES ----------------------------------------------------------
const ERR_SAVE_WRITE: String = "Could not open save file for writing: %s"
const ERR_SAVE_READ: String = "Could not open save file for reading: %s"
const ERR_SAVE_INVALID: String = "Save file did not contain valid save data."
const ERR_OUT_OF_BOUNDS_TIMESCALE: String = "Out of Bounds Time Scale %s"

# MISC --------------------------------------------------------------------
const TEST_STORAGE_MIN_AMOUNT: int = 100
const TEST_STORAGE_MAX_AMOUNT: int = 999
const TEST_STORAGE_EXPONENT: int = 0

const UI_OPEN_TIME_SCALE := 0.5
const NORMAL_TIME_SCALE := 1.0

const TIER_CONFIG: Dictionary = {
	1: {
		KEY_COLOR: Color(0.541, 0.561, 0.596),
		KEY_STYLE: preload("res://other_assets/styles/crafting_styles/t1_style.tres"),
		KEY_FONT: preload("res://other_assets/label_settings/tier_fonts/t1_font.tres"),
		KEY_CELLS: {
			KEY_RESOURCES: preload("res://2d_assets/storage/resource_cells/rough_cell.png"),
			KEY_TURRETS: preload("res://2d_assets/storage/turret_cells/rough_cell.png"),
			KEY_MODULES: preload("res://2d_assets/storage/module_cells/rough_cell.png")
		}
	},
	2: {
		KEY_COLOR: Color(0.29, 0.871, 0.502),
		KEY_STYLE: preload("res://other_assets/styles/crafting_styles/t2_style.tres"),
		KEY_FONT: preload("res://other_assets/label_settings/tier_fonts/t2_font.tres"),
		KEY_CELLS: {
			KEY_RESOURCES: preload("res://2d_assets/storage/resource_cells/plain_cell.png"),
			KEY_TURRETS: preload("res://2d_assets/storage/turret_cells/plain_cell.png"),
			KEY_MODULES: preload("res://2d_assets/storage/module_cells/plain_cell.png")
		}
	},
	3: {
		KEY_COLOR: Color(0.29, 0.557, 0.996),
		KEY_STYLE: preload("res://other_assets/styles/crafting_styles/t3_style.tres"),
		KEY_FONT: preload("res://other_assets/label_settings/tier_fonts/t3_font.tres"),
		KEY_CELLS: {
			KEY_RESOURCES: preload("res://2d_assets/storage/resource_cells/usefull_cell.png"),
			KEY_TURRETS: preload("res://2d_assets/storage/turret_cells/useful_cell.png"),
			KEY_MODULES: preload("res://2d_assets/storage/module_cells/usefull_cell.png")
		}
	},
	4: {
		KEY_COLOR: Color(1.0, 0.847, 0.243),
		KEY_STYLE: preload("res://other_assets/styles/crafting_styles/t4_style.tres"),
		KEY_FONT: preload("res://other_assets/label_settings/tier_fonts/t4_font.tres"),
		KEY_CELLS: {
			KEY_RESOURCES: preload("res://2d_assets/storage/resource_cells/valuable_cell.png"),
			KEY_TURRETS: preload("res://2d_assets/storage/turret_cells/valuable_cell.png"),
			KEY_MODULES: preload("res://2d_assets/storage/module_cells/valuable_cell.png")
		}
	},
	5: {
		KEY_COLOR: Color(0.937, 0.267, 0.267),
		KEY_STYLE: preload("res://other_assets/styles/crafting_styles/t5_style.tres"),
		KEY_FONT: preload("res://other_assets/label_settings/tier_fonts/t5_font.tres"),
		KEY_CELLS: {
			KEY_RESOURCES: preload("res://2d_assets/storage/resource_cells/extraordinary_cell.png"),
			KEY_TURRETS: preload("res://2d_assets/storage/turret_cells/extraordinary_cell.png"),
			KEY_MODULES: preload("res://2d_assets/storage/module_cells/extraordinary_cell.png")
		}
	}
}

const STARTER_RESOURCES := {
	"dirt" : 8,
	"clay" : 10,
	"rock" : 15,
	"sand" : 12,
	"flint" : 2,
	"scrap" : 5,
}

# CAPS --------------------------------------------------------------------
const MAX_DROPS: int = 250
const MAX_SPHERES: int = 300

# =============================================================================
# VARIABLES
# =============================================================================

# LOGIC --------------------------------------------------------------------
var player_mode := PLAYER_MODES.WEAPON
var current_build_mode := BUILD_MODES.TURRET
var at_ship := true
var mouse_captured := true
var major_animation_playing := false

# TUTORIAL RELATED ---------------------------------------------------------
var turorial_stage := 1
var cleared_tutorial := false
var first_run := true

# USER INTERFACE -----------------------------------------------------------
var paused := false
var ui_open := false
var market_open := false
var storage_open := false
var crafting_open := false
var extraction_open := false
var crafting_pin_open := false
var authorization_open := false

var pined_crafts : Dictionary

# SECTOR RELATED ------------------------------------------------------------
var selected_sector : String
var selected_sector_path : PackedScene = DEFAULT_SECTOR_PATH
var sector_run_time : float
var shield_overdrive : bool = false 
var just_extracted : bool = false

# ENEMIES
var enemies: int = 0

# META UPGRADES / COUNCIL AUTHORIZATION -------------------------------------
var level_ship: int = 8
var level_ship_capacity: int = 1
var level_extraction_capacity: int = 1
var level_deployment_capacity: int = 1
var level_shield_strength: int = 1
var level_craft_efficiency: int = 1
var level_weapon_authorization: int = 1
var level_turret_authorization: int = 1
var level_module_authorization: int = 1
var level_turret_slots: int = 1

# INVENTORY + CURRENCY -------------------------------------------------------
var cubits: int = 0
var sector_storage: Dictionary = HelperFunctions.get_clean_storage()
var ship_storage: Dictionary = HelperFunctions.get_clean_storage()
var extraction_storage: Dictionary = HelperFunctions.get_clean_storage()
var deploy_storage: Dictionary = HelperFunctions.get_clean_storage()

# SETTINGS -------------------------------------------------------------------
## Goes from 0.05 to 2 as a multiplyer of the base sensitivity
var sensitivity: float = 1.0
var show_input_tip: bool = true
var show_fps: bool = false


## Temp testing function to fill storage - THIS IS A TESTING FUNCTION IGNORE CONVENTIONS
func set_random_storage(set_sector_storage: bool = false) -> void:
	print(ship_storage)
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


# =============================================================================
# PAUSING CONTROL AND GAME SPEED
# =============================================================================
## sets get_tree().paused to pause
func set_paused(pause := false) -> void:
	get_tree().paused = pause
	Global.paused = pause


## sets the time scale of the engine to the passed float should be between 0.0 - 1.0
func set_time_scale(time_scale := 1.0) -> void:
	if time_scale == 1.0:
		Engine.time_scale = time_scale
	
	if time_scale > 1.0 or time_scale < 0.0:
		push_error(ERR_OUT_OF_BOUNDS_TIMESCALE % str(time_scale))
	
	time_scale = clampf(time_scale, 0, 1)
	
	Engine.time_scale = time_scale


# =============================================================================
# SAVING, LOADING, AND RESETING GAME DATA
# =============================================================================
## Saves the current game data to the path
func save_game() -> void:
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		push_error(ERR_SAVE_WRITE % SAVE_PATH)
		return
	
	var save_data := {
		SAVE_SHIP_STORAGE_KEY: ship_storage,
		SAVE_CUBITS_KEY: cubits,
		SAVE_COUNCIL_AUTHORIZATION_KEY: {
			SAVE_SHIP_KEY: level_ship,
			SAVE_SHIP_CAPACITY_KEY: level_ship_capacity,
			SAVE_EXTRACTION_CAPACITY_KEY: level_extraction_capacity,
			SAVE_DEPLOYMENT_CAPACITY_KEY: level_deployment_capacity,
			SAVE_SHIELD_STRENGTH_KEY: level_shield_strength,
			SAVE_CRAFT_EFFICIENCY_KEY: level_craft_efficiency,
			SAVE_WEAPON_AUTHORIZATION_KEY: level_weapon_authorization,
			SAVE_TURRET_AUTHORIZATION_KEY: level_turret_authorization,
			SAVE_MODULE_AUTHORIZATION_KEY: level_module_authorization,
			SAVE_TURRET_SLOTS_KEY: level_turret_slots,
		},
		SAVE_SETTINGS_KEY: {
			SAVE_SENSIVITY_KEY: sensitivity,
			SAVE_SHOW_FPS_TOGGLE: show_fps,
			SAVE_SHOW_INPUT_TIP_TOGGLE: show_input_tip
		}
	}
	
	file.store_var(save_data)
	
	await get_tree().create_timer(SAVE_AND_LOAD_BUFFER).timeout
	return


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
	
	# Settings ---------------------------------------------------------------
	var settings = data.get(SAVE_SETTINGS_KEY, {})
	if typeof(settings) == TYPE_DICTIONARY:
		sensitivity = settings.get(SAVE_SENSIVITY_KEY, sensitivity)
		show_fps = settings.get(SAVE_SHOW_FPS_TOGGLE, show_fps)
		show_input_tip = settings.get(SAVE_SHOW_INPUT_TIP_TOGGLE, show_input_tip)
	
	# Ship storage -----------------------------------------------------------
	ship_storage = data.get(SAVE_SHIP_STORAGE_KEY, HelperFunctions.get_clean_storage())
	
	# Cubits -----------------------------------------------------------------
	cubits = int(data.get(SAVE_CUBITS_KEY, cubits))
	
# Council authorisation loading -------------------------------------------
	var council_authorization: Dictionary = data.get(SAVE_COUNCIL_AUTHORIZATION_KEY, {})
	if typeof(council_authorization) == TYPE_DICTIONARY:
		level_ship = council_authorization.get(SAVE_SHIP_KEY, level_ship)
		level_ship_capacity = council_authorization.get(SAVE_SHIP_CAPACITY_KEY, level_ship_capacity)
		level_extraction_capacity = council_authorization.get(
			SAVE_EXTRACTION_CAPACITY_KEY, level_extraction_capacity
		)
		level_deployment_capacity = council_authorization.get(
			SAVE_DEPLOYMENT_CAPACITY_KEY, level_deployment_capacity
		)
		level_shield_strength = council_authorization.get(
			SAVE_SHIELD_STRENGTH_KEY, level_shield_strength
		)
		level_craft_efficiency = council_authorization.get(
			SAVE_CRAFT_EFFICIENCY_KEY, level_craft_efficiency
		)
		level_weapon_authorization = council_authorization.get(
			SAVE_WEAPON_AUTHORIZATION_KEY, level_weapon_authorization
		)
		level_turret_authorization = council_authorization.get(
			SAVE_TURRET_AUTHORIZATION_KEY, level_turret_authorization
		)
		level_module_authorization = council_authorization.get(
			SAVE_MODULE_AUTHORIZATION_KEY, level_module_authorization
		)
		level_turret_slots = council_authorization.get(
			SAVE_TURRET_SLOTS_KEY, level_turret_slots
		)
	
	await get_tree().create_timer(SAVE_AND_LOAD_BUFFER).timeout
	return


## Deletes the game data completely, removing the save file
func reset_game() -> void:
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE_PATH))
	get_tree().quit()
