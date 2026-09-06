class_name RecpiePinning
extends Control

const INPUT_SHOW := &"show_pinned_recipes"
const MAX_PINNED := 3
const craft_pin_recipe_scene := preload(
	"res://scenes/user_interface/recipe_pinning/craft_pin_recipe.tscn")

#Tween values
const TWEEN_TIME := 0.15
const TWEEN_HIDDEN_POS := Vector2(140, 0)
const TWEEN_SHOW_POS := Vector2(0, 0)
const PROP_POSITION := "position"

@export var pining_vbox : VBoxContainer
@export var margin_container : MarginContainer

var last_open_ui_state : bool = false


func _ready() -> void:
	for craft_data : CraftData in Global.pined_crafts:
		var new_craft_pin : CraftPinRecipe = craft_pin_recipe_scene.instantiate()
		var pinned_crafts := pining_vbox.get_children()
		var child_index := pinned_crafts.size()
		
		for existing_pin : CraftPinRecipe in pinned_crafts:
			if existing_pin.craft_data.requirements.size() < craft_data.requirements.size():
				child_index -= 1
		
		new_craft_pin.craft_data = craft_data
		pining_vbox.add_child(new_craft_pin)
		pining_vbox.move_child(new_craft_pin, child_index)
		Global.pined_crafts[craft_data] = new_craft_pin


func _process(_delta: float) -> void:
	var current_open_ui_state = true
	if Global.ui_open and not Global.storage_open or Global.major_animation_playing:
		current_open_ui_state = false
	
	if current_open_ui_state == false and current_open_ui_state != last_open_ui_state:
		show_or_hide_tween(false)
	
	if not current_open_ui_state:
		return
	
	if Input.is_action_just_pressed(INPUT_SHOW):
		show_or_hide_tween(not Global.crafting_pin_open)
	
	last_open_ui_state = current_open_ui_state


func show_or_hide_tween(is_show := true) -> void:
	if is_show == Global.crafting_pin_open:
		return
	
	Global.crafting_pin_open = is_show
	var show_tween = create_tween()
	show_tween.set_ease(Tween.EASE_IN)
	show_tween.tween_property(
		margin_container, 
		PROP_POSITION, 
		TWEEN_SHOW_POS if is_show else TWEEN_HIDDEN_POS, 
		TWEEN_TIME
	)
	
	for craft_data in Global.pined_crafts:
		Global.pined_crafts[craft_data].show_or_hide_tween(is_show)


func pin_recipe(craft_data : CraftData) -> bool:
	if (
		Global.pined_crafts.size() >= MAX_PINNED or 
		not craft_data or 
		not craft_data.crafted_item.key in DataRegistry.items
	):
		return false
	
	if craft_data in Global.pined_crafts.keys():
		Global.pined_crafts[craft_data].queue_free()
		Global.pined_crafts.erase(craft_data)
		
	else:
		var new_craft_pin : CraftPinRecipe = craft_pin_recipe_scene.instantiate()
		new_craft_pin.craft_data = craft_data
		
		var child_index = Global.pined_crafts.size()
		var required_items = craft_data.requirements.size()
		
		for requirment : CraftData in Global.pined_crafts:
			if requirment.requirements.size() < required_items:
				child_index -= 1
		
		pining_vbox.add_child(new_craft_pin)
		pining_vbox.move_child(new_craft_pin, child_index)
		Global.pined_crafts[craft_data] = new_craft_pin
	
	return true
