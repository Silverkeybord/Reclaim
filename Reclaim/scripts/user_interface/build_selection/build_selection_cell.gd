class_name BuildSelectionCell
extends Control

const MARKER_KEY := "marker"
const SCALE_KEY := "scale"
const MODULATE_KEY := "modulate"
const POSITION_KEY := "position"

const HIDE_POSITION := Vector2(0, 0)

const BUILDING_CELLS := {
	1: preload("res://2d_assets/building/building_rough_cell.png"),
	2: preload("res://2d_assets/building/building_plain_cell.png"),
	3: preload("res://2d_assets/building/building_useful_cell.png"),
	4: preload("res://2d_assets/building/building_valuable_cell.png"),
	5: preload("res://2d_assets/building/building_extraordinary_cell.png"),
}

const MIN_AMOUNT := 0
const MIN_VISIBLE_POS := -3
const MAX_VISIBLE_POS := 3

## Logical position in the carousel (-3 to +3 are visible)
@export var cell_position: int
## Order of the cell in the full list
@export var cell_number: int

@export var build_selection: CanvasLayer
@export var cell_properties: Dictionary

@export_group("values")
@export var item_resource: ItemData

@export_group("visuals")
@export var cell_texture: TextureRect
@export var item_texture: TextureRect
@export var amount_label: Label

var amount: int = 0


func setup() -> void:
	if not HelperFunctions.is_valid_item(item_resource):
		_hide_cell()
		return
	
	update_amount()
	
	if BUILDING_CELLS.has(item_resource.tier):
		cell_texture.texture = BUILDING_CELLS[item_resource.tier]
	
	item_texture.texture = item_resource.get_item_texture()


func update_amount() -> void:
	if not HelperFunctions.is_valid_item(item_resource):
		amount = MIN_AMOUNT
		_hide_cell()
		return
	
	amount = HelperFunctions.get_item_amount(item_resource)
	amount_label.text = HelperFunctions.return_amount_shorthand(amount)
	
	_update_visibility()


func move(direction: int, tween_time: float) -> void:
	if direction == 0:
		return
	
	cell_position += direction
	
	var visual_index := clampi(cell_position, -3, 3)
	
	if not cell_properties.has(visual_index):
		visible = false
		return
	
	var properties: Dictionary = cell_properties[visual_index]
	var target_scale: Vector2 = properties[SCALE_KEY]
	var target_position: Vector2 = properties[MARKER_KEY].position
	var target_modulate: Color = properties[MODULATE_KEY]
	
	var should_be_visible := cell_position >= -3 and cell_position <= 3
	visible = should_be_visible
	
	var move_tween := create_tween().set_parallel(true)
	move_tween.tween_property(self, SCALE_KEY, target_scale, tween_time)
	move_tween.tween_property(self, POSITION_KEY, target_position, tween_time)
	move_tween.tween_property(self, MODULATE_KEY, target_modulate, tween_time)


func item_placed() -> void:
	update_amount()
	if amount <= 0:
		build_selection.remove_cell_in_place()


# Helper functions ============================================================
func _update_visibility() -> void:
	if amount <= 0 or cell_position < MIN_VISIBLE_POS or cell_position > MAX_VISIBLE_POS:
		visible = false
	else:
		visible = true


func _hide_cell() -> void:
	visible = false


func _show_cell() -> void:
	if amount > 0:
		visible = true
	if amount <= 0:
		return
	visible = true
