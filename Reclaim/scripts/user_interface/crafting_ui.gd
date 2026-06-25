extends CanvasLayer

enum TABS {
	TURRETS,
	MODULES,
	RESOURCES
}

const ACTIVE_TURRETS_TAB := preload("res://2d_assets/crafting/active_turret_tab.png")
const ACTIVE_MODULES_TAB := preload("res://2d_assets/crafting/active_modules_tab.png")
const ACTIVE_RESOURCE_TAB := preload("res://2d_assets/crafting/active_resources_tab.png")
const INACTIVE_TURRETS_TAB := preload("res://2d_assets/crafting/inactive_turret_tab.png")
const INACTIVE_MODULES_TAB := preload("res://2d_assets/crafting/inactive_modules_tab.png")
const INACTIVE_RESOURCE_TAB := preload("res://2d_assets/crafting/inactive_resources_tab.png")

@export_group("Requirments")
@export var current_displayed_requirments : CraftData
@export var recipe_requirments_scene : PackedScene
@export var craft_name : Label
@export var weight_stat : Label
@export var value_stat : Label
@export var teir_stat : Label
@export var craft_time_stat : Label
@export var description : Label
@export var requirments_hflow : HFlowContainer
@export var craft_button : Button
@export var craft_overlay : MarginContainer

@export_group("crafting tabs")
@export var turrets_tab : Button
@export var modules_tab : Button
@export var resources_tab : Button

var current_tab = TABS.TURRETS


# Loading and Crafting ======================================================
func craft(craft_data : CraftData) -> void:
	var current_inventory = Global.get_current_inventory()
	
	for requirment : RequirementsTemplate in craft_data.requirements:
		current_inventory[requirment.item.tier][requirment.item.key] -= requirment.amount
	
	current_inventory[craft_data.crafted_item.tier][craft_data.crafted_item.key] += (
		craft_data.craft_amount
		)


# Craft Selection and Requirments Controlling ===============================
func display_requirements_for(craft_data : CraftData, can_craft : bool) -> void:
	current_displayed_requirments = craft_data
	craft_name.text = Global.get_display_name(craft_data.crafted_item.key)
	weight_stat.text = "Weight: " + Global.comma_number(craft_data.crafted_item.weight)
	value_stat.text = "Value: " + str(craft_data.crafted_item.value)
	teir_stat.text = "Tier: " + str(craft_data.crafted_item.tier)
	craft_time_stat.text = "Craft Time: " + str(craft_data.craft_time)
	description.text = craft_data.description
	
	for requirment in craft_data.requirements:
		var new_requirment : RecipeRequirement = recipe_requirments_scene.instantiate()
		new_requirment.item_data = requirment.item
		new_requirment.amount_required = requirment.amount
		new_requirment.update_value()
		requirments_hflow.add_child(new_requirment)
		
	
	craft_overlay.visible = not can_craft
	craft_button.disabled = not can_craft


# Tab Controlling ============================================================
func _change_to_tab(tab : Button) -> void:
	turrets_tab.icon = INACTIVE_TURRETS_TAB
	modules_tab.icon = INACTIVE_MODULES_TAB
	resources_tab.icon = INACTIVE_RESOURCE_TAB
	
	if tab == turrets_tab:
		turrets_tab.icon = ACTIVE_TURRETS_TAB
		current_tab = TABS.TURRETS
	elif tab == modules_tab:
		modules_tab.icon = ACTIVE_MODULES_TAB
		current_tab = TABS.MODULES
	elif tab == resources_tab:
		resources_tab.icon = ACTIVE_RESOURCE_TAB
		current_tab = TABS.RESOURCES


func _on_turret_tab_button_pressed() -> void:
	_change_to_tab(turrets_tab)


func _on_modules_tab_button_pressed() -> void:
	_change_to_tab(modules_tab)


func _on_resources_tab_button_pressed() -> void:
	_change_to_tab(resources_tab)
