class_name CraftCell
extends ExpandButtons

const DOUBLE_CLICK_TIME : float = 0.3
const CAN_CRAFT_TEXTURES : Dictionary = {
	true : preload("res://2d_assets/crafting/can_craft_cell.png"),
	false : preload("res://2d_assets/crafting/cant_craft_cell.png")
}

const DOUBLE_CLICK_CRAFT_AMOUNT : int = 1

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
	if double_click_timer:
		double_click_timer.wait_time = DOUBLE_CLICK_TIME
	#Global.set_random_storage()
	set_up()


func set_up() -> void:
	if craft_data == null or craft_data.crafted_item == null:
		disabled = true
		can_craft = false
		cant_craft_overlay.visible = true
		return
	
	item_image.texture = craft_data.crafted_item.get_item_texture()
	
	check_requirements()


func check_requirements() -> void:
	can_craft = true
	if craft_data == null or craft_data.crafted_item == null:
		can_craft = false
		cant_craft_overlay.visible = true
		return
	
	for requirement : RequirementsTemplate in craft_data.requirements:
		if requirement == null or not HelperFunctions.is_valid_item(requirement.item):
			can_craft = false
			continue
		
		var have_enough := HelperFunctions.has_item_amount(requirement.item, requirement.amount)
		if not have_enough:
			can_craft = false
		
		craft_requirements[requirement.item] = have_enough
	
	cant_craft_overlay.visible = not can_craft


func _on_pressed() -> void:
	if not crafting_menu:
		return
	
	play_press_sound()
	check_requirements()
	
	if crafting_menu.current_displayed_requirments != craft_data:
		crafting_menu.display_requirements_for(craft_data, can_craft)
	
	if valid_last_click and can_craft:
		crafting_menu.craft(true)
		if double_click_timer:
			double_click_timer.stop()
			double_click_timer.start()


func _on_double_click_timer_timeout() -> void:
	valid_last_click = false


func _on_button_up() -> void:
	valid_last_click = true
	if double_click_timer:
		double_click_timer.start()
