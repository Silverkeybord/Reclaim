extends Node

# MISC --------------------------------------------------------------------
const GRAVITY := 40.0

# LOGIC --------------------------------------------------------------------
var build_mode := false
var at_ship := true

# SECTOR RELATED ------------------------------------------------------------
var selected_sector : String
var selected_sector_path := "res://Scenes/maps/remote_island.tscn"

# META UPGRADES / RESEARCH --------------------------------------------------
var turret_slots = 8
