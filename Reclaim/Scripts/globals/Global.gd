extends Node

# eums
# TURRETS / WEAPONS ------------------------------------------------------- 
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

# CONSTANTS ===============================================================
# MISC --------------------------------------------------------------------
const SAVE_PATH : String = "user://reclaim.save"
const GRAVITY : float = 40.0
const DEFAULT_BULLET_TRAIL_KEY : String = "default"
const CURRENT_SCENE_ROOT_INDEX : int = 2
const RARITY_CONFIG : Dictionary = {
	1 : {
		"color" : Color(0.541, 0.561, 0.596),
		"cell" : preload("res://2d_assets/inventory/rough_cell.png")
	},
	2 : {
		"color" : Color(0.29, 0.871, 0.502),
		"cell" : preload("res://2d_assets/inventory/plain_cell.png")
	},
	3 : {
		"color" : Color(0.29, 0.557, 0.996),
		"cell" : preload("res://2d_assets/inventory/usefull_cell.png")
	},
	4 : {
		"color" : Color(1.0, 0.847, 0.243),
		"cell" : preload("res://2d_assets/inventory/valuable_cell.png")
	},
	5 : {
		"color" : Color(0.937, 0.267, 0.267),
		"cell" : preload("res://2d_assets/inventory/extraordinary_cell.png")
	}
}

# CAPS --------------------------------------------------------------------
const MAX_DROPS : int = 250
const MAX_SPHERES : int = 300
const MAX_DAMAGE_INDICATIONS : int = 100
const ORDER_OF_MAGNITUDE : int = 10
const HUNDRED_THRESHOLD : int = 3
const SHORT_HAND_NUDGE : float = 1e-9
const MAX_SHORTHAND_MAGNITUDE : int = 12
const MAX_TEXT : String = "MAX"
const SHORTHAND_THRESHOLDS : Dictionary = {
	int(9) : "B",
	int(6) : "M",
	int(3) : "K",
}

# EFFECTS SCENES ----------------------------------------------------------
const TEMP_SOUND_SCENE : PackedScene = preload("res://scenes/misc/temp_sound_scene.tscn")
const BULET_TRAIL_SCENE : PackedScene = preload("res://scenes/turrets/bullet_trail.tscn")
const DAMAGE_INDICATOR_SCENE : PackedScene = preload("res://scenes/misc/damage_indicator.tscn")

# VARIBLES =================================================================
# LOGIC --------------------------------------------------------------------
var build_mode := false
var current_build_mode := BUILD_MODES.TURRET
var picking_up_builds := false
var at_ship := true
var mouse_captured := true

# SECTOR RELATED ------------------------------------------------------------
var selected_sector : String
var selected_sector_path := "res://scenes/maps/remote_island.tscn"
var sector_run_time : float

# ENEMIES
var enemies := 0
var damage_indications := 0

# META UPGRADES / RESEARCH --------------------------------------------------
var turret_slots := 8

# INVENORY + CURRENCY -------------------------------------------------------
var cubits : int = 0
var item_inventory : Dictionary = {
	1 : {
		"clay" : 0,
		"dirt" : 0,
		"flint" : 0,
		"rock" : 0,
		"sand" : 0,
		"scrap" : 0,
		"basic_material" : 0
	},
	2 : {
		"brick" : 0,
		"coal" : 0,
		"copper" : 0,
		"elemental_essence" : 0,
		"glass" : 0,
		"gunpowder" : 0,
		"rubber" : 0,
		"construction_material" : 0
	},
	3 : {
		"circuit" : 0,
		"concrete" : 0,
		"gear" : 0,
		"ice" : 0,
		"iron" : 0,
		"steel" : 0,
		"advanced_material" : 0,
		"tungsten" : 0,
		"water" : 0,
		"wind" : 0
	},
	4 : {
		"acid" : 0,
		"chip" : 0,
		"earth" : 0,
		"fire" : 0,
		"gold" : 0,
		"silicon" : 0,
		"electronic_material" : 0,
		"uranium" : 0
	},
	5 : {
		"antimatter" : 0,
		"dark" : 0,
		"graphene" : 0,
		"light" : 0,
		"platinum" : 0,
		"exotic_material" : 0,
		"tesseract" : 0
	},
}
var turret_inventory : Dictionary = {
	1 : {
		"basic" : 0,
		"dual" : 0,
		"wind" : 0
	},
	2 : {
		"minigun" : 0,
		"mortar" : 0,
		"shotgun" : 0,
		"water" : 0
	},
	3 : {
		"cannon" : 0,
		"earth" : 0,
		"explosive" : 0
	},
	4 : {
		"fire" : 0,
		"missle" : 0,
		"sniper" : 0
	},
	5 : {
		"cube" : 0,
		"railgun" : 0,
	}
}
var ship_inventory : Dictionary = {
	
}
var base_inventory : Dictionary = {
	"plate" : 0,
	"single" : 0,
}


# FUNCTIONS ================================================================
## Spawn Temp Sound. Spawns a tempory sound as a child of the root node
func spawn_temp_sound() -> void:
	pass


## Creates a bullet trail between 2 point. as a child of the root node
func create_bullet_trail(
	from : Vector3, to : Vector3, 
	trail : Resource = DataRegistry.bullet_trail[DEFAULT_BULLET_TRAIL_KEY]
	) -> void:
	
	var new_bullet_trail = BULET_TRAIL_SCENE.instantiate()
	new_bullet_trail.trail = trail
	get_tree().root.get_child(CURRENT_SCENE_ROOT_INDEX).add_child(new_bullet_trail)
	new_bullet_trail.create_bullet_trail(from, to)


## Creates a damage indicator at the position of the caller
func create_damage_indicator(pos : Vector3, damage : int) -> void:
	if damage_indications >= MAX_DAMAGE_INDICATIONS or at_ship:
		return
	
	damage_indications += 1
	var new_indication = DAMAGE_INDICATOR_SCENE.instantiate()
	new_indication.text = "-" + str(damage)
	get_tree().root.get_child(CURRENT_SCENE_ROOT_INDEX).add_child(new_indication)
	new_indication.global_position = pos
	new_indication.init()


## Converts large integers into shorthand notation (e.g. 1_500 → "1.5K")
func return_amount_shorthand(value: float) -> String:
	# works out the order of magnitude value has
	var magnitude : int = floori(log(value) / log(ORDER_OF_MAGNITUDE) + SHORT_HAND_NUDGE)
	var magnitude_divisor : int
	var suffix : String
	var decimal_point_needed : bool = false
	
	# stops 0 and negitive numbers breaking the log
	if value <= 0:
		return str(int(value))
	
	# numbers under 1000 dont need shorthand
	if magnitude < HUNDRED_THRESHOLD:
		return str(int(value))
	
	# caps very large numbers so they dont go past the shown range
	if magnitude >= MAX_SHORTHAND_MAGNITUDE:
		return MAX_TEXT
	
	# finds what suffix should be used like K, M, or B
	for x in SHORTHAND_THRESHOLDS:
		if x <= magnitude:
			suffix = SHORTHAND_THRESHOLDS[x]
			magnitude_divisor = x
			
			# only adds a decimal when the number just reached that shorthand group
			if magnitude == x:
				decimal_point_needed = true
			
			break
	
	if decimal_point_needed:
		# gets the first decimal digit for stuff like 1.5K
		var tenth : int = roundi(value / (ORDER_OF_MAGNITUDE ** magnitude_divisor) * 10.0)
		var whole : int = roundi(float(tenth) / 10.0)
		var remainder : int = tenth % 10
		
		# skips the decimal if it would just be .0
		if remainder == 0:
			return str(whole) + suffix
		return "%d.%d" % [whole, remainder] + suffix
	
	# for bigger numbers it just shows the whole shorthand amount
	return str(floori(value / (ORDER_OF_MAGNITUDE ** magnitude_divisor))) + suffix


## Temp testing function to fill inventory
func set_random_inventory() -> void:
	for teir in item_inventory:
		for item in item_inventory[teir]:
			item_inventory[teir][item] = randi_range(1, 999) * (10 ** randi_range(1, 9))


## Sets the moust of the player to be unlocked or locked bassed on its last value
func set_mouse_captured() -> void:
	mouse_captured = not mouse_captured
	
	if mouse_captured:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


# SAVEING, LODING, AND RESETING GAME DATA =====================================
## Saves the current game data to the path
func save_game():
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	
	var save_data = {
		# inventory / storage
		"inventory" : item_inventory,
	}
	
	file.store_var(save_data)


## Loads the data from the saved folder if there is one
func load_game():
	if !FileAccess.file_exists(SAVE_PATH):
		return
	
	
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	var data = file.get_var()
	
	item_inventory = data["inventory"]


## Deleats the game data completly removing the save file
func reset_game():
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE_PATH))
	get_tree().quit()
