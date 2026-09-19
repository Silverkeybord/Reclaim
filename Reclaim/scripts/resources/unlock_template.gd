extends Resource
class_name UnlockTemplate

## The type of unlock from sectors, crafting recipe, ect
@export_enum(
	"sector",
	"recipe",
	"authorisation"
) var unlock_type : String = "recipe"

## the resource of what is unlocked
@export var unlock_data : Resource

## the level of the authorisation needed
@export var authorisation_level : int
