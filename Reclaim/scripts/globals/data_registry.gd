extends Node

const TURRET_PATH : String = "res://data/turrets/"
const MODULES_PATH : String = "res://data/modules/"
const WEAPONS_PATH : String = "res://data/weapon/"
const AMMO_PATH : String = "res://data/ammo/"
const ENEMIES_PATH : String = "res://data/enemies/"
const WAVE_PATH : String = "res://data/wave/"
const RESEARCH_PATH : String = "res://data/research/"
const CRAFTING_PATH : String = "res://data/crafting/"
const BULLET_TRAIL_PATH : String = "res://data/bullet_trails/"
const DROPS_PATH : String = "res://data/drops/"

var turrets : Dictionary
var modules : Dictionary
var weapon : Dictionary
var ammo : Dictionary
var enemies : Dictionary
var wave : Dictionary
var research : Dictionary
var crafting : Dictionary
var bullet_trail : Dictionary
var drops : Dictionary


func _ready() -> void:
	_load_folder(TURRET_PATH, turrets)
	_load_folder(MODULES_PATH, modules)
	_load_folder(WEAPONS_PATH, weapon)
	_load_folder(AMMO_PATH, ammo)
	_load_folder(ENEMIES_PATH, enemies)
	_load_folder(WAVE_PATH, wave)
	_load_folder(RESEARCH_PATH, research)
	_load_folder(CRAFTING_PATH, crafting)
	_load_folder(BULLET_TRAIL_PATH, bullet_trail)
	_load_folder(DROPS_PATH, drops)
	
	print("fin loading files")


func _load_folder(path : String, dict : Dictionary) -> void:
	if not path:
		return
	
	var dir = DirAccess.open(path)
	dir.list_dir_begin()
	var file = dir.get_next()
	while file != "":
		if file.ends_with(".tres"):
			var res = load(path + file)
			dict[res.key] = res
		file = dir.get_next()
