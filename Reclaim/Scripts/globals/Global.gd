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
const GRAVITY : float = 40.0
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
# VARIBLES ===================================================================
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

# INVENORY + CURRENCY -------------------------------------------------------
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
		if set_sector_storage:
			sector_storage[resource.tier][key] = (
				randi_range(3, 3) * (10 ** (randi_range(0, 0)))
				)
		else:
			ship_storage[resource.tier][key] = (
				randi_range(1, 999) * (10 ** (randi_range(0, 0)))
				)


## Sets the moust of the player to be unlocked or locked bassed on its last value
func set_mouse_captured() -> void:
	mouse_captured = not mouse_captured
	
	if mouse_captured:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


# =============================================================================
# SAVEING, LODING, AND RESETING GAME DATA =====================================
# =============================================================================
## Saves the current game data to the path
func save_game():
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	
	var save_data = {
		# storage / storage
		"ship_storage" : ship_storage,
		"cubits" : cubits,
		"council_authorization" : {
			"turret_slots" : turret_slots
		}
		
	}
	
	file.store_var(save_data)


## Loads the data from the saved folder if there is one
func load_game():
	if !FileAccess.file_exists(SAVE_PATH):
		return
	
	
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	var data = file.get_var()
	
	ship_storage = data["ship_storage"]
	cubits = data["cubits"]
	turret_slots = data["council_authorization"]["turret_slots"]


## Deleats the game data completly removing the save file
func reset_game():
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE_PATH))
	get_tree().quit()
