extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if Global.just_extracted:
		Global.just_extracted = false
		_move_extract_storage_to_ship()


func _move_extract_storage_to_ship() -> void:
	for tier in Global.extraction_storage:
		for item in Global.extraction_storage[tier]:
			HelperFunctions.add_item_to_storage(
				DataRegistry.items[item],
				Global.extraction_storage[tier][item],
				Global.ship_storage
				)
	
	Global.extraction_storage = HelperFunctions.get_clean_storage()
