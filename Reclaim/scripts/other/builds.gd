class_name Builds
extends Node

@export var build : String 
@export var build_type : Global.BUILD_TYPES


func pick_up() -> void:
	if build.is_empty() or not DataRegistry.items.has(build):
		push_error("Build item not found when picking up: %s" % build)
		return
	
	var item_resource : ItemData = DataRegistry.items[build]
	if not HelperFunctions.add_item_to_storage(item_resource):
		return
	
	if build_type == Global.BUILD_TYPES.BASE:
		check_for_turret()
	
	queue_free()


# defined here so it wont throw error but if a node that extends this script has
# check_for_turret() that function will run instead of this one. this is done with
# the shoot function for the turrets aswell
func check_for_turret() -> void:
	pass
