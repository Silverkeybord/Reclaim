extends Node

const TURRET_PATH: String = "res://data/turrets/"
const MODULES_PATH: String = "res://data/modules/"
const WEAPONS_PATH: String = "res://data/weapon/"
const ENEMIES_PATH: String = "res://data/enemies/"
const WAVE_PATH: String = "res://data/wave/"
const AUTHORISATION_PATH: String = "res://data/authorisation/"
const CRAFTING_PATH: String = "res://data/crafting/"
const BULLET_TRAIL_PATH: String = "res://data/bullet_trails/"
const ITEMS_PATH: String = "res://data/items/"

const RESOURCE_FILE_EXTENSION: String = ".tres"
const REMAP_FILE_EXTENSION: String = ".remap"
const PATH_SEPARATOR: String = "/"

const PROP_KEY: StringName = &"key"

const COULD_NOT_OPEN_PATH_ERROR: String = "DataRegistry: could not open path: "
const INVALID_RESOURCE_ERROR: String = "DataRegistry: invalid resource at path: "

var turrets: Dictionary = {}
var modules: Dictionary = {}
var weapon: Dictionary = {}
var enemies: Dictionary = {}
var wave: Dictionary = {}
var research: Dictionary = {}
var crafting: Dictionary = {}
var bullet_trail: Dictionary = {}
var items: Dictionary = {}


func _ready() -> void:
	_load_folder(TURRET_PATH, turrets, true)
	_load_folder(MODULES_PATH, modules, true)
	_load_folder(WEAPONS_PATH, weapon)
	_load_folder(ENEMIES_PATH, enemies)
	_load_folder(WAVE_PATH, wave)
	_load_folder(AUTHORISATION_PATH, research)
	_load_folder(CRAFTING_PATH, crafting, true)
	_load_folder(BULLET_TRAIL_PATH, bullet_trail)
	_load_folder(ITEMS_PATH, items, true)


func _load_folder(path: String, dict: Dictionary, recursive: bool = false) -> void:
	if path.is_empty():
		return
	
	var directory := DirAccess.open(path)
	if directory == null:
		push_error(COULD_NOT_OPEN_PATH_ERROR + path)
		return
	
	directory.list_dir_begin()
	var file_name: String = directory.get_next()
	
	while not file_name.is_empty():
		
		if recursive and directory.current_is_dir() and not file_name.begins_with("."):
			_load_folder(path + file_name + PATH_SEPARATOR, dict, true)
		else:
			var clean_file_name: String = file_name
			if clean_file_name.ends_with(REMAP_FILE_EXTENSION):
				clean_file_name = clean_file_name.trim_suffix(REMAP_FILE_EXTENSION)
			
			if clean_file_name.ends_with(RESOURCE_FILE_EXTENSION):
				var full_file_path: String = path + clean_file_name
				var res: Resource = load(full_file_path)
				var key = res.get(PROP_KEY) if res != null else null
				
				if res == null or key == null or str(key).is_empty():
					push_error(INVALID_RESOURCE_ERROR + full_file_path)
				else:
					dict[key] = res
		
		file_name = directory.get_next()
	
	directory.list_dir_end()
