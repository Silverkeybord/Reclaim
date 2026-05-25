extends Node

# MISC --------------------------------------------------------------------
const GRAVITY : float = 40.0
const MAX_SPHERES : int = 100

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

# INVENORY
