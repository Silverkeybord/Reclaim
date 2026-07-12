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


func setup() -> void:
	update_amount()
	
	cell_texture.texture = BUILDING_CELLS[item_resource.tier]
	
	item_texture.texture = item_resource.get_item_texture()


func update_amount() -> void:
	var storage = Global.get_current_storage()
	amount = storage[item_resource.tier].get(item_resource.key, 0)
	amount_label.text = Global.return_amount_shorthand(amount)
	
	# you can get booleans from this
	visible = amount > 0


func move(direction : int, tween_time : float) -> void:
	if direction == 0:
		return
	
	if direction == 1:
		if cell_position < -3 or cell_position > 2:
			return
	else:
		if cell_position > 3 or cell_position < -2:
			return
	
	cell_position += direction
	
	var target_scale = cell_properties[cell_position]["scale"]
	var target_position = cell_properties[cell_position]["marker"].global_position
	var target_modulate = cell_properties[cell_position]["modulate"]
	
	var move_tween = create_tween().set_parallel(true)
	move_tween.tween_property(self, "scale", target_scale, tween_time)
	move_tween.tween_property(self, "position", target_position, tween_time)
	move_tween.tween_property(self, "modulate", target_modulate, tween_time)


func place() -> void:
	update_amount()
	
