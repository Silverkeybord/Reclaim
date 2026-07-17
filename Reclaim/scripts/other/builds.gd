class_name Builds
extends Node

@export var build : String 
@export var build_type : Global.BUILD_TYPES


func pick_up() -> void:
	var item_resource : ItemData = DataRegistry.items[build]
	
	HelperFunctions.get_current_storage()[item_resource.tier][item_resource.key] += 1
	
	queue_free()
