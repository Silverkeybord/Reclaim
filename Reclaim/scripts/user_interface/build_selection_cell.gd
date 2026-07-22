class_name BuildSelectionCell
extends Control

const CELLS_TEXTURE_KEY := "cells"
const RESOURCES_KEY := "resources"
const TURRETS_KEY := "turrets"
const MODULES_KEY := "modules"
const BUILDING_CELLS := {
	1 : preload("res://2d_assets/building/building_rough_cell.png"),
	2 : preload("res://2d_assets/building/building_plain_cell.png"),
	3 : preload("res://2d_assets/building/building_useful_cell.png"),
	4 : preload("res://2d_assets/building/building_valuable_cell.png"),
	5 : preload("res://2d_assets/building/building_extraordinary_cell.png"),
}
const POS_TWEEN_REQUIRMENTS = [-2, 3]
const NEG_TWEEN_REQUIRMENTS = [-3, 2]

const INSTANT_SCROLL_REQUIRMENT := 5
const MIN_AMOUNT := 0

## actual position of the cell
@export var cell_position : int
## the order of the cells
@export var cell_number : int
@export var build_selection : CanvasLayer
@export var cell_properties : Dictionary

@export_group("values")
@export var item_resource : ItemData

@export_group("visuals")
@export var cell_texture : TextureRect
@export var item_texture : TextureRect
@export var amount_label : Label

var amount : int 
var instant_scroll : bool = false


func setup() -> void:
	if not HelperFunctions.is_valid_item(item_resource):
		visible = false
		return
	
	update_amount()
	
	if BUILDING_CELLS.has(item_resource.tier):
		cell_texture.texture = BUILDING_CELLS[item_resource.tier]
	
	item_texture.texture = item_resource.get_item_texture()


func update_amount() -> void:
	if not HelperFunctions.is_valid_item(item_resource):
		amount = MIN_AMOUNT
		visible = false
		return
	
	amount = HelperFunctions.get_item_amount(item_resource)
	amount_label.text = HelperFunctions.return_amount_shorthand(amount)
	
	# you can get booleans from this
	visible = amount > 0


func move(direction : int, tween_time : float) -> void:
	if direction == 0 or not cell_properties.has(cell_position + direction):
		return
	
	cell_position += direction
	
	if direction == 1:
		if cell_position < POS_TWEEN_REQUIRMENTS[0] or cell_position > POS_TWEEN_REQUIRMENTS[1]:
			return
	else:
		if cell_position < NEG_TWEEN_REQUIRMENTS[0] or cell_position > NEG_TWEEN_REQUIRMENTS[1]:
			return
	
	var target_scale = cell_properties[cell_position]["scale"]
	var target_position = cell_properties[cell_position]["marker"].position
	var target_modulate = cell_properties[cell_position]["modulate"]
	
	var move_tween = create_tween().set_parallel(true)
	move_tween.tween_property(self, "scale", target_scale, tween_time)
	move_tween.tween_property(self, "position", target_position, tween_time)
	move_tween.tween_property(self, "modulate", target_modulate, tween_time)
	
	await get_tree().create_timer(tween_time).timeout


func item_placed() -> void:
	amount = HelperFunctions.get_item_amount(item_resource)
	
	update_amount()
	
	if amount <= 0:
		build_selection.remove_cell_in_place()
