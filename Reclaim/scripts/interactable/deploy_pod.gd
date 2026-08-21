class_name DeployPod
extends StaticBody3D

const FADE_TIME := 0.5
const NORMAL_MODULATE := Color(1, 1, 1, 1)
const HIDDEN_MODULATE := Color(1, 1, 1, 0)
const PROP_MODULATE : String = "modulate"

@export var color_rect : ColorRect
@export var deploy_ui : MoveUI


func interact() -> void:
	if Global.first_run:
		deploy()
	else:
		deploy_ui.open_ui()


func deploy() -> void:
	color_rect.visible = true
	var fade_in_tween = create_tween()
	fade_in_tween.tween_property(color_rect, PROP_MODULATE, NORMAL_MODULATE, FADE_TIME)
	Global.sector_storage = Global.deploy_storage
	
	await fade_in_tween.finished
	color_rect.visible = false
	color_rect.modulate = HIDDEN_MODULATE
	
	get_tree().change_scene_to_packed(Global.selected_sector_path)
	Global.at_ship = false
