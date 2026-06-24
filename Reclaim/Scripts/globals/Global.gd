extends Node

# ENUMS ====================================================================
# TURRETS / WEAPONS --------------------------------------------------------
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
const ROOT_NODES_GROUP : String = "root_nodes"
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
const MAX_TEXT : String = "MAX"
const MAX_DROPS : int = 250
const MAX_SPHERES : int = 300
const MAX_SOUNDS : int = 50
const MAX_DAMAGE_INDICATIONS : int = 100
const ORDER_OF_MAGNITUDE : int = 10
const HUNDRED_THRESHOLD : int = 3
const SHORT_HAND_NUDGE : float = 1e-9
const MAX_SHORTHAND_MAGNITUDE : int = 12
const SHORTHAND_THRESHOLDS : Dictionary = {
	int(9) : "B",
	int(6) : "M",
	int(3) : "K",
}

# EFFECTS SCENES ----------------------------------------------------------
const TEMP_SOUND_SCENE : PackedScene = preload("res://scenes/misc/temp_sound_scene.tscn")
const TEMP_SOUND_SCENE_3D : PackedScene = preload("res://scenes/misc/temp_sound_scene_3D.tscn")
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
var sounds : int = 0
var enemies : int = 0
var damage_indications : int = 0

# META UPGRADES / COUNCIL AUTHORIZATION -------------------------------------
var turret_slots := 8

# INVENORY + CURRENCY -------------------------------------------------------
var cubits : int = 0
var sector_inventory : Dictionary = {
	1 : {},
	2 : {},
	3 : {},
	4 : {},
	5 : {}
}
var ship_inventory : Dictionary = {
	1 : {},
	2 : {},
	3 : {},
	4 : {},
	5 : {}
}


# FUNCTIONS ================================================================
## adds the node the the root node of the current scene bassed of the global group root_nodes
func add_to_root_node(node : Node) -> void:
	get_tree().get_first_node_in_group(ROOT_NODES_GROUP).add_child(node)


## Spawn Temp Sound. Spawns a tempory sound as a child of the root node
func spawn_temp_sound(sound : SoundInfo, pos : Vector3 = Vector3.ZERO) -> void:
	if sounds >= MAX_SOUNDS:
		return
	
	sounds += 1
	
	if pos != Vector3.ZERO:
		var new_sound : AudioStreamPlayer3D = TEMP_SOUND_SCENE_3D.instantiate()
		new_sound.stream = sound.stream
		add_to_root_node(new_sound)
		new_sound.global_position = pos
		new_sound.volume_db = sound.volume
		new_sound.max_db = sound.max_db
		new_sound.max_distance = sound.max_distance
		new_sound.play()
	else:
		var new_sound : AudioStreamPlayer = TEMP_SOUND_SCENE.instantiate()
		new_sound.stream = sound.stream
		add_to_root_node(new_sound)
		new_sound.volume_db = sound.volume
		new_sound.play()


## Creates a bullet trail between 2 point. as a child of the root node
func create_bullet_trail(
	from : Vector3, to : Vector3, 
	trail : Resource = DataRegistry.bullet_trail[DEFAULT_BULLET_TRAIL_KEY]
	) -> void:
	
	var new_bullet_trail = BULET_TRAIL_SCENE.instantiate()
	new_bullet_trail.trail = trail
	add_to_root_node(new_bullet_trail)
	new_bullet_trail.create_bullet_trail(from, to)


## Creates a damage indicator at the position of the caller child of the root node
func create_damage_indicator(pos : Vector3, damage : int) -> void:
	if damage_indications >= MAX_DAMAGE_INDICATIONS or at_ship:
		return
	
	damage_indications += 1
	var new_indication = DAMAGE_INDICATOR_SCENE.instantiate()
	new_indication.text = "-" + str(damage)
	add_to_root_node(new_indication)
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
	for key in DataRegistry.items:
		var resource = DataRegistry.items[key]
		ship_inventory[resource.teir][key] = randi_range(1, 999) ** (randi_range(1, 5))


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
		"ship_inventory" : ship_inventory,
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
	
	ship_inventory = data["ship_inventory"]
	cubits = data["cubits"]
	turret_slots = data["council_authorization"]["turret_slots"]


## Deleats the game data completly removing the save file
func reset_game():
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE_PATH))
	get_tree().quit()
