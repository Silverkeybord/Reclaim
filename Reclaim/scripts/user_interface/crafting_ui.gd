extends CanvasLayer

const ACTIVE_TURRETS_TAB_RESOURCE := preload("res://2d_assets/crafting/active_turret_tab.png")
const ACTIVE_MODULES_TAB_RESOURCE := preload("res://2d_assets/crafting/active_modules_tab.png")
const ACTIVE_RESOURCES_TAB_RESOURCE := preload("res://2d_assets/crafting/active_resources_tab.png")
const INACTIVE_TURRETS_TAB_RESOURCE := preload("res://2d_assets/crafting/inactive_turret_tab.png")
const INACTIVE_MODULES_TAB_RESOURCE := preload("res://2d_assets/crafting/inactive_modules_tab.png")
const INACTIVE_RESOURCES_TAB_RESOURCE := preload("res://2d_assets/crafting/inactive_resources_tab.png")

@export_group("crafting tabs")
@export var turrets_tab : Button
@export var modules_tab : Button
@export var resources_tab : Button


# Tab Controlling ============================================================
func _change_to_tab(tab : Button) -> void:
	turrets_tab.icon = INACTIVE_TURRETS_TAB_RESOURCE
	modules_tab.icon = INACTIVE_MODULES_TAB_RESOURCE
	resources_tab.icon = INACTIVE_RESOURCES_TAB_RESOURCE
	
	if tab == turrets_tab:
		turrets_tab.icon = ACTIVE_TURRETS_TAB_RESOURCE
	elif tab == modules_tab:
		modules_tab.icon = ACTIVE_MODULES_TAB_RESOURCE
	elif tab == resources_tab:
		resources_tab.icon = ACTIVE_RESOURCES_TAB_RESOURCE


func _on_turret_tab_button_pressed() -> void:
	_change_to_tab(turrets_tab)


func _on_modules_tab_button_pressed() -> void:
	_change_to_tab(modules_tab)


func _on_resources_tab_button_pressed() -> void:
	_change_to_tab(resources_tab)
