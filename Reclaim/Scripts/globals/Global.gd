extends Node

# TURRETS / WEPONS ------------------------------------------------------- 
enum SHOT_TYPE {
	HITSCAN,
	PROJECTILE
}

# MISC --------------------------------------------------------------------
const GRAVITY : float = 40.0
const MAX_SPHERES : int = 100
const DEFAULT_BULLET_TRAIL_KEY : String = "default"

# EFFECTS SCENES ----------------------------------------------------------
const TEMP_SOUND_SCENE : PackedScene = preload("res://Scenes/misc/temp_sound_scene.tscn")
const BULET_TRAIL_SCENE : PackedScene = preload("res://Scenes/turrets/bullet_trail.tscn")

# LOGIC --------------------------------------------------------------------
var build_mode := false
var at_ship := true

# SECTOR RELATED ------------------------------------------------------------
var selected_sector : String
var selected_sector_path := "res://Scenes/maps/remote_island.tscn"

# ENEMIES
var enemies := 0

# META UPGRADES / RESEARCH --------------------------------------------------
var turret_slots := 8

# INVENORY -----------------------------------------------------------------
var inventory : Dictionary = {}


# FUNCTIONS ================================================================
## Spawn Temp Sound. Spawns a tempory sound as a child of the root node
func spawn_temp_sound() -> void:
	pass


## Creates a bullet trail between 2 point
func create_bullet_trail(from : Vector3, to : Vector3, trail : Resource = GameData.bullet_trail["default"]) -> void:
	var new_bullet_trail = BULET_TRAIL_SCENE.instantiate()
	new_bullet_trail.trail = trail
	get_tree().root.add_child(new_bullet_trail)
	new_bullet_trail.create_bullet_trail(from, to)
