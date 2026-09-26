class_name BuildSelection
extends CanvasLayer

# Constants --------------------------------------------------------------------
const SELECTED_SCALE := Vector2(1.1, 1.1)
const FIRST_SCALE := Vector2(1.0, 1.0)
const SECOND_SCALE := Vector2(0.9, 0.9)
const THIRD_SCALE := Vector2(0.2, 0.2)
const SELECTED_MODULATE := Color(1.0, 1.0, 1.0, 1.0)
const FIRST_MODULATE := Color(1.0, 1.0, 1.0, 0.6)
const SECOND_MODULATE := Color(1.0, 1.0, 1.0, 0.3)
const THIRD_MODULATE := Color(1.0, 1.0, 1.0, 0.0)

const MARKER_KEY := "marker"
const SCALE_KEY := "scale"
const MODULATE_KEY := "modulate"
const GOT_NOTHING := "NOTHING..."
const EMPTY_SELECTION := ""

const TURRET_BUILD_TEXT := "turret"
const BASE_BUILD_TEXT := "base"
const TRAP_BUILD_TEXT := "trap"

const MIN_CELL_POSITION := -3
const MAX_CELL_POSITION := 3
const MAX_TWEEN_SPEED := 0.15
const MIN_TWEEN_SPEED := 0.05
const SCROLL_SPEED_FACTOR := 0.015
const SCROLL_SPEED_DETECTION_TIME := 0.05

const MIN_SCROLL_POSITION := 0
const EMPTY_SCROLL_POSITION := -1
const SCROLL_UP_DIRECTION := -1
const SCROLL_DOWN_DIRECTION := 1

# Exports ----------------------------------------------------------------------
@export var build_cell_scene: PackedScene
@export var selected_name: Label
@export var player: Player
@export var selected_cell: BuildSelectionCell
@export var build_type_label: Label

@export_group("Markers", "position_")
@export var position_negative_3: Marker2D
@export var position_negative_2: Marker2D
@export var position_negative_1: Marker2D
@export var position_selected_0: Marker2D
@export var position_positive_1: Marker2D
@export var position_positive_2: Marker2D
@export var position_positive_3: Marker2D

# Variables --------------------------------------------------------------------
var scroll_position := MIN_SCROLL_POSITION
var max_scroll_position: int = EMPTY_SCROLL_POSITION

var active_cells: Array[BuildSelectionCell] = []
var build_cells: Dictionary = {}

var moving_cells := false
var scroll_detections := 0
var scroll_speed_deduction := 0.0
var scroll_speed_buffer_active := false

@onready var cell_properties := {
	-3: {
		MARKER_KEY: position_negative_3,
		SCALE_KEY: THIRD_SCALE,
		MODULATE_KEY: THIRD_MODULATE
	},
	-2: {
		MARKER_KEY: position_negative_2,
		SCALE_KEY: SECOND_SCALE,
		MODULATE_KEY: SECOND_MODULATE
	},
	-1: {
		MARKER_KEY: position_negative_1,
		SCALE_KEY: FIRST_SCALE,
		MODULATE_KEY: FIRST_MODULATE
	},
	0: {
		MARKER_KEY: position_selected_0,
		SCALE_KEY: SELECTED_SCALE,
		MODULATE_KEY: SELECTED_MODULATE
	},
	1: {
		MARKER_KEY: position_positive_1,
		SCALE_KEY: FIRST_SCALE,
		MODULATE_KEY: FIRST_MODULATE
	},
	2: {
		MARKER_KEY: position_positive_2,
		SCALE_KEY: SECOND_SCALE,
		MODULATE_KEY: SECOND_MODULATE
	},
	3: {
		MARKER_KEY: position_positive_3,
		SCALE_KEY: THIRD_SCALE,
		MODULATE_KEY: THIRD_MODULATE
	}
}


# Builtin/lifecycle ------------------------------------------------------------
func _ready() -> void:
	if build_cell_scene == null:
		return
	
	var cell_index: int = 0
	
	for item_key: String in DataRegistry.items:
		var item: ItemData = DataRegistry.items[item_key]
		if HelperFunctions.is_valid_item(item) and (
			item.type == Global.ITEM_TYPES.TURRET or item.type == Global.ITEM_TYPES.BASE
		):
			var new_cell: BuildSelectionCell = (
				build_cell_scene.instantiate() as BuildSelectionCell
			)
			if not new_cell:
				continue
				
			new_cell.name = item_key
			build_cells[item_key] = new_cell
			new_cell.cell_number = cell_index
			cell_index += 1
			
			new_cell.cell_properties = cell_properties
			new_cell.build_selection = self
			new_cell.item_resource = item
			add_child(new_cell)
			new_cell.setup()
			new_cell.visible = false
			new_cell.scale = scale


func _process(_delta: float) -> void:
	if selected_cell and HelperFunctions.is_valid_item(selected_cell.item_resource):
		if selected_name:
			selected_name.text = selected_cell.item_resource.key
		
		match selected_cell.item_resource.type:
			Global.ITEM_TYPES.BASE:
				build_type_label.text = BASE_BUILD_TEXT
			Global.ITEM_TYPES.TURRET:
				build_type_label.text = TURRET_BUILD_TEXT
			Global.ITEM_TYPES.TRAP:
				build_type_label.text = TRAP_BUILD_TEXT
	else:
		if selected_name:
			selected_name.text = GOT_NOTHING
		if player:
			player.selected_build = EMPTY_SELECTION


func _input(event: InputEvent) -> void:
	if Global.player_mode != Global.PLAYER_MODES.BUILDING:
		visible = false
		return
	
	if (
		event is InputEventMouseButton and
		Global.player_mode == Global.PLAYER_MODES.BUILDING and
		not moving_cells
	):
		scroll(event)


# Setup & Processes ------------------------------------------------------------
func load_selection() -> void:
	var available_turrets: Dictionary = HelperFunctions.get_items_from_type(
		Global.ITEM_TYPES.TURRET
		)
	var available_bases: Dictionary = HelperFunctions.get_items_from_type(Global.ITEM_TYPES.BASE)
	var pref_build: String = player.selected_build if player else EMPTY_SELECTION
	
	active_cells.clear()
	for cell: BuildSelectionCell in build_cells.values():
		cell.visible = false
		
	var loops := 0
	loops = _append_available_to_active(available_turrets, loops)
	loops = _append_available_to_active(available_bases, loops)
	
	max_scroll_position = maxi(loops - 1, EMPTY_SCROLL_POSITION)
	scroll_position = _get_preferred_scroll_position(pref_build)
	scroll_position = clampi(
		scroll_position, MIN_SCROLL_POSITION, maxi(max_scroll_position, MIN_SCROLL_POSITION)
	)
	
	_layout_all_active_cells()
	_apply_selection()


func _append_available_to_active(available: Dictionary, current_loops: int) -> int:
	var loops := current_loops
	for tier in available:
		for build in available[tier]:
			if available[tier][build] <= 0:
				continue
			if not build_cells.has(build):
				continue
			
			var cell: BuildSelectionCell = build_cells[build]
			active_cells.append(cell)
			cell.update_amount()
			loops += 1
			
	return loops


func _get_preferred_scroll_position(preferred_key: String) -> int:
	if preferred_key == EMPTY_SELECTION:
		return scroll_position
		
	for i in range(active_cells.size()):
		if active_cells[i].item_resource.key == preferred_key:
			return i
			
	return scroll_position


func _layout_all_active_cells() -> void:
	var index_position := scroll_position
	for cell: BuildSelectionCell in active_cells:
		_set_cell_position(cell, index_position)
		index_position -= 1


func _set_cell_position(cell: BuildSelectionCell, position_index: int) -> void:
	if cell == null:
		return
	
	cell.cell_position = position_index
	var visual_index := clampi(position_index, MIN_CELL_POSITION, MAX_CELL_POSITION)
	
	if not cell_properties.has(visual_index):
		cell.visible = false
		return
	
	var properties: Dictionary = cell_properties[visual_index]
	var marker: Marker2D = properties[MARKER_KEY] as Marker2D
	
	if marker:
		cell.position = marker.position
		
	cell.scale = properties[SCALE_KEY]
	cell.modulate = properties[MODULATE_KEY]
	cell.visible = position_index >= MIN_CELL_POSITION and position_index <= MAX_CELL_POSITION


func _apply_selection() -> void:
	if active_cells and scroll_position >= 0 and scroll_position < active_cells.size():
		selected_cell = active_cells[scroll_position]
		if player:
			player.selected_build = selected_cell.item_resource.key
	else:
		selected_cell = null
		if player:
			player.selected_build = EMPTY_SELECTION


# Interactions -----------------------------------------------------------------
func scroll(event: InputEventMouseButton) -> void:
	if active_cells.is_empty():
		return
	
	var scroll_direction := 0
	
	if event.button_index == MOUSE_BUTTON_WHEEL_UP:
		if scroll_position > MIN_SCROLL_POSITION:
			scroll_direction = SCROLL_UP_DIRECTION
	elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
		if scroll_position < max_scroll_position:
			scroll_direction = SCROLL_DOWN_DIRECTION
	
	if scroll_direction == 0:
		return
	
	scroll_speed_deduction += SCROLL_SPEED_FACTOR
	if scroll_speed_buffer_active:
		return
	
	var new_pos := clampi(
		scroll_position + scroll_direction, 
		MIN_SCROLL_POSITION, 
		max_scroll_position
		)
	if new_pos < 0 or new_pos >= active_cells.size():
		return
	
	scroll_position = new_pos
	_apply_selection()
	
	scroll_speed_buffer_active = true
	var tree := get_tree()
	if tree:
		await tree.create_timer(SCROLL_SPEED_DETECTION_TIME).timeout
	scroll_speed_buffer_active = false
	
	moving_cells = true
	var tween_time: float = clampf(
		MAX_TWEEN_SPEED - scroll_speed_deduction, MIN_TWEEN_SPEED, MAX_TWEEN_SPEED
	)
	scroll_speed_deduction = 0.0
	
	for cell: BuildSelectionCell in active_cells:
		cell.move(scroll_direction, tween_time)
	
	if tree:
		await tree.create_timer(tween_time).timeout
	moving_cells = false


func placed_build() -> void:
	if not selected_cell or not HelperFunctions.is_valid_item(selected_cell.item_resource):
		return
	
	var item: ItemData = selected_cell.item_resource as ItemData
	if not HelperFunctions.remove_item_from_storage(item):
		return
	
	selected_cell.item_placed()


func remove_cell_in_place() -> void:
	var remove_index: int = active_cells.find(selected_cell)
	if remove_index < 0:
		return
	
	active_cells.pop_at(remove_index)
	
	if active_cells.is_empty():
		selected_cell = null
		scroll_position = MIN_SCROLL_POSITION
		max_scroll_position = EMPTY_SCROLL_POSITION
		if player:
			player.selected_build = EMPTY_SELECTION
		return
	
	var next_index: int = mini(remove_index, active_cells.size() - 1)
	scroll_position = next_index
	max_scroll_position = active_cells.size() - 1
	
	_layout_all_active_cells()
	_apply_selection()
