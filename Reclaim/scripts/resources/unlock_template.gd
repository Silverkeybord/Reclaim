extends Resource
class_name UnlockTemplate

enum UnlockType {
	SECTOR,
	RECIPE,
	AUTHORISATION
}

const ENUM_STRING_LOOKUP := {
	UnlockType.SECTOR : "sector",
	UnlockType.RECIPE : "recipe",
	UnlockType.AUTHORISATION : "authorisation",
}

## The type of unlock from sectors, crafting recipe, ect
@export var unlock_type := UnlockType.RECIPE

## the resource of what is unlocked
@export var unlock_data : Resource

## the level of the authorisation needed
@export var authorisation_level : int
