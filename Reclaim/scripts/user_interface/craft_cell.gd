class_name CraftCell
extends Button

const DOUBLE_CLICK_TIME : float = 0.2
const CAN_CRAFT_TEXTURES : Dictionary = {
	true : preload("res://2d_assets/crafting/can_craft_cell.png"),
	false : preload("res://2d_assets/crafting/cant_craft_cell.png")
}

@export var craft_data : CraftData

@export_group("In Scene")
@export var item_image : TextureRect
@export var double_click_timer : Timer
@export var cant_craft_overlay : PanelContainer

@export_group("Out Of Scene")
@export var crafting_menu : CanvasLayer

var craft_requirements : Dictionary
var can_craft : bool = true
var valid_last_click : bool = false


func _ready() -> void:
	double_click_timer.wait_time = DOUBLE_CLICK_TIME
	#Global.set_random_inventory()
	set_up()


func set_up() -> void:
	item_image.texture = craft_data.texture
	check_requirements()


func check_requirements() -> void:
	for requirement : RequirementsTemplate in craft_data.requirements:
		var have_enough = true
		var current_inventory : Dictionary = Global.get_current_inventory()
		
		if current_inventory[requirement.item.tier].has(requirement.item.key):
			if current_inventory[requirement.item.tier][requirement.item.key] < requirement.amount:
				have_enough = false
				can_craft = false
		else:
			can_craft = false
		
		craft_requirements[requirement.item] = [have_enough]
	
	cant_craft_overlay.visible = not can_craft
	disabled = not can_craft


func _on_pressed() -> void:
	if not crafting_menu:
		return
	
	if crafting_menu.current_displayed_requirments != craft_data:
		crafting_menu.display_requirements_for(craft_data, can_craft)
	
	if valid_last_click:
		crafting_menu.craft(craft_data)


func _on_double_click_timer_timeout() -> void:
	valid_last_click = false


func _on_button_up() -> void:
	valid_last_click = true
	double_click_timer.start()
