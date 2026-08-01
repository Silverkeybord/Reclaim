extends Node

const TURRET_PATH : String = "res://data/turrets/"
const MODULES_PATH : String = "res://data/modules/"
const WEAPONS_PATH : String = "res://data/weapon/"
const ENEMIES_PATH : String = "res://data/enemies/"
const WAVE_PATH : String = "res://data/wave/"
const RESEARCH_PATH : String = "res://data/authorisation/"
const CRAFTING_PATH : String = "res://data/crafting/"
const BULLET_TRAIL_PATH : String = "res://data/bullet_trails/"
const ITEMS_PATH : String = "res://data/items/"
const RESOURCE_FILE_EXTENSION := ".tres"
const PATH_SEPARATOR := "/"
const KEY_PROPERTY := "key"
const FINISHED_LOADING_MESSAGE := " -- finished loading files -- "

var turrets : Dictionary
var modules : Dictionary
var weapon : Dictionary
var enemies : Dictionary
var wave : Dictionary
var research : Dictionary
var crafting : Dictionary
var bullet_trail : Dictionary
var items : Dictionary


func _ready() -> void:
	_load_folder(TURRET_PATH, turrets, true)
	_load_folder(MODULES_PATH, modules, true)
	_load_folder(WEAPONS_PATH, weapon)
	_load_folder(ENEMIES_PATH, enemies)
	_load_folder(WAVE_PATH, wave)
	_load_folder(RESEARCH_PATH, research)
	_load_folder(CRAFTING_PATH, crafting, true)
	_load_folder(BULLET_TRAIL_PATH, bullet_trail)
	_load_folder(ITEMS_PATH, items, true)
	
	print(FINISHED_LOADING_MESSAGE)


func _load_folder(path: String, dict: Dictionary, recursive: bool = false) -> void:
	if not path:
		return
	
	var directory = DirAccess.open(path)
	
	# Check for valid directory
	if not directory: 
		push_error("DataRegistry: could not open path: " + path)
		return
	
	# If recursive is true and file is a directory, recursively searches that directory,
	# placing resources into the same dictionary.
	directory.list_dir_begin()
	var file = directory.get_next() 
	
	while file != "":
		if file.ends_with(RESOURCE_FILE_EXTENSION):
			var res = load(path + file)
			var key = res.get(KEY_PROPERTY) if res != null else ""
			if key == null or str(key).is_empty():
				push_error("DataRegistry: invalid resource at path: " + path + file)
			else:
				dict[key] = res
		
		elif recursive and directory.current_is_dir() and not file.begins_with("."):
			_load_folder(path + file + PATH_SEPARATOR, dict, true)
		
		file = directory.get_next()
