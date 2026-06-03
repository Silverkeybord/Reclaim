extends Node

# TURRETS / WEAPONS ------------------------------------------------------- 
enum SHOT_TYPE {
	HITSCAN,
	PROJECTILE
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
var at_ship := true

# SECTOR RELATED ------------------------------------------------------------
var selected_sector : String
var selected_sector_path := "res://scenes/maps/remote_island.tscn"
var sector_run_time : float

# ENEMIES
var enemies := 0
var damage_indications := 0

# META UPGRADES / RESEARCH --------------------------------------------------
var turret_slots := 8

# INVENORY -----------------------------------------------------------------
var cubits : int = 0
var inventory : Dictionary = {}


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
