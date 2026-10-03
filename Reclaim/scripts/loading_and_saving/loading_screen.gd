extends Control

const AUTHORISATION_STARTING_LEVEL := 0

var finished_loading: bool = false

@export var min_loading_time := 0.5

@export var min_loading_timer : Timer
@export var ship_scene : PackedScene


func _ready() -> void:
	# for broken save data in testing
	#await Global.reset_game()
	
	min_loading_timer.start(min_loading_time)
	
	# First loads the base council_authorisations to then loads the game data 
	# writing over if there is data
	DataRegistry.load_data_registry()
	_load_council_authoriseations()
	await Global.load_game()
	finished_loading = true
	
	if min_loading_timer.is_stopped():
		get_tree().change_scene_to_packed(ship_scene)


func _on_min_loading_timer_timeout() -> void:
	if finished_loading:
		get_tree().change_scene_to_packed(ship_scene)


# Creates the base values for 
func _load_council_authoriseations() -> void:
	for authority_key in DataRegistry.authorisation:
		Global.council_authorisations[authority_key] = AUTHORISATION_STARTING_LEVEL
