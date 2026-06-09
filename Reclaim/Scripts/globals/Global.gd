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

# CONSTANTS ===============================================================
# MISC --------------------------------------------------------------------
const GRAVITY : float = 40.0
const DEFAULT_BULLET_TRAIL_KEY : String = "default"
const PROBABLITY_DIVIDE_CONSTANT : float = 100.0
const CURRENT_SCENE_ROOT_INDEX : int = 2

# CAPS --------------------------------------------------------------------
const MAX_DROPS : int = 250
const MAX_SPHERES : int = 100
const MAX_DAMAGE_INDICATIONS : int = 100

# EFFECTS SCENES ----------------------------------------------------------
const TEMP_SOUND_SCENE : PackedScene = preload("res://scenes/misc/temp_sound_scene.tscn")
const BULET_TRAIL_SCENE : PackedScene = preload("res://scenes/turrets/bullet_trail.tscn")
const DAMAGE_INDICATOR_SCENE : PackedScene = preload("res://scenes/misc/damage_indicator.tscn")

# VARIBLES =================================================================
# LOGIC --------------------------------------------------------------------
var build_mode := false
var current_build_mode := BUILD_MODES.TURRET
var at_ship := true

# SECTOR RELATED ------------------------------------------------------------
var selected_sector : String
var selected_sector_path := "res://scenes/maps/remote_island.tscn"
var sector_run_time : float

# ENEMIES
var enemies := 0
var damage_indications := 0

# META UPGRADES / RESEARCH --------------------------------------------------
var turret_slots := 1

# INVENORY -----------------------------------------------------------------
var cubits : int = 0
var inventory : Dictionary = {
	"1" : {
		"dirt" : 0,
		"sand" : 0,
		"rock" : 0
	}
}
var turret_inventory : Dictionary = {
	"1" : { 
		"basic" : 0,
		"dual" : 0,
		"wind" : 0
 	},
	"2" : { 
		"shotgun" : 0,
		"water" : 0,
		"minigun" : 0,
		"mortar" : 0
 	},
	"3" : { 
		"explosive" : 0,
		"cannon" : 0,
		"earth" : 0
 	},
	"4" : { 
		"missle" : 0,
		"sniper" : 0,
		"fire" : 0
 	},
	"5" : { 
		"railgun" : 0,
		"cube" : 0,
		"wind" : 0
 	}
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
	trail : Resource = GameData.bullet_trail[DEFAULT_BULLET_TRAIL_KEY]
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


## Converts large integers into human-readable shorthand formatting. 
## --- Made With Gemini ---
func get_amount_shorthand(value: int) -> String:
	const THOUSAND_LIMIT : float = 1_000.0
	const MILLION_LIMIT  : float = 1_000_000.0
	const BILLION_LIMIT  : float = 1_000_000_000.0

	const SUFFIX_THOUSAND : String = "K"
	const SUFFIX_MILLION  : String = "M"
	const SUFFIX_BILLION  : String = "B"

	const STRING_FORMAT_ONE_DECIMAL : String = "%.1f"
	const FLOATING_POINT_ZERO_TRAIL : String = ".0"

	var absolute_value : int = abs(value)
	var suffix := ""
	var divided_value := float(value)

	# Direct evaluation blocks remove loop overhead entirely
	if absolute_value >= BILLION_LIMIT:
		divided_value = float(value) / BILLION_LIMIT
		suffix = SUFFIX_BILLION
	elif absolute_value >= MILLION_LIMIT:
		divided_value = float(value) / MILLION_LIMIT
		suffix = SUFFIX_MILLION
	elif absolute_value >= THOUSAND_LIMIT:
		divided_value = float(value) / THOUSAND_LIMIT
		suffix = SUFFIX_THOUSAND
	else:
		return str(value)

	# Apply truncation formatting rule
	var formatted_string := STRING_FORMAT_ONE_DECIMAL % divided_value
	
	# Strip trailing zeros dynamically based on target string length
	if formatted_string.ends_with(FLOATING_POINT_ZERO_TRAIL):
		formatted_string = formatted_string.left(-FLOATING_POINT_ZERO_TRAIL.length())
		
	return formatted_string + suffix
