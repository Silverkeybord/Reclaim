class_name TurretData
extends Resource

enum RANGE_SHAPES {
	CYLNIDER,
	SPHERE
}


@export var id: int
@export var key: String
@export var display_name: String
@export var tier: int
@export var damage: float
@export var cooldown: float
@export var turret_range: float
@export var range_shape : RANGE_SHAPES
@export var ammo_types: Array[String]
@export var recipe: Dictionary
@export var synergy_tags: Array[String]
@export var targetable_enemies : Dictionary = {
	"ground" : true,
	"air" : false,
	"hidden" : false,
}
@export var allowed_modules : Dictionary = {
	"damage" : true,
	"overclock" : true,
	"range" : true,
	"modular_modules" : true,
	"turbo_charge" : true,
	"frost" : true,
	"ammo_efficiency" : true,
	"explosive_bullets" : false
}
