class_name Builds
extends Node

@export var build : String 
@export var build_type : Global.BUILD_TYPES


func pick_up() -> void:
	var item_resource : ItemData = DataRegistry.items[build]
	
	HelperFunctions.get_current_storage()[item_resource.tier][item_resource.key] += 1
	
	if build_type == Global.BUILD_TYPES.BASE:
		check_for_turret()
	
	queue_free()


# defined here so it wont throw error but if a node that extends this script has
# check_for_turret() that function will run instead of this one. this is done with
# the shoot function for the turrets aswell
func check_for_turret() -> void:
	pass
