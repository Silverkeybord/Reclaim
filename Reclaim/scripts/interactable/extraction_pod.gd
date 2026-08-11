class_name ExtractionPod
extends StaticBody3D

@export var extraction_ui : ExtractionUI
@export var sector_elements : Node3D
@export var crafting_table : StaticBody3D
@export var storage_container : StaticBody3D


func interact() -> void:
	extraction_ui.open_ui()


func extract() -> void:
	Global.set_mouse_captured(true, true)
	Global.just_extracted = true
	Global.major_animation_playing = true
	Global.sector_storage = HelperFunctions.get_clean_storage()
	
	if Global.ui_open:
		if Global.storage_open:
			storage_container.storage_ui.close_ui()
		if Global.crafting_open:
			crafting_table.crafting_ui.close_ui()
		if Global.extraction_open:
			extraction_ui.close_ui()
	
	sector_elements.extract_animation()
