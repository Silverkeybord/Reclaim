extends Resource
class_name AuthorisationData

@export var key : String

## the type of upgrade
@export_enum(
	"stat_increase",
	"crafting_unlock",
	"ship_level"
) var upgrade_type : String = "stat_increase"

## the levels and requirements for 
@export var max_level : int = 1

## An array that holds all the 
@export var levels : Array[AuthorisationLevel]
