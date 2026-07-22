extends CanvasLayer

const SELECTED_SCALE := Vector2(1.1, 1.1)
const FIRST_SCALE := Vector2(1, 1)
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

@export var build_cell_scene : PackedScene
@export var selected_name : Label
@export var player : Player
@export var selected_cell : BuildSelectionCell

@export_group("Markers", "position_")
@export var position_negative_3 : Marker2D
@export var position_negative_2 : Marker2D
@export var position_negative_1 : Marker2D
@export var position_selected_0 : Marker2D
@export var position_positive_1 : Marker2D
@export var position_positive_2 : Marker2D
@export var position_positive_3 : Marker2D

var turret_scroll_position := MIN_SCROLL_POSITION
var base_scroll_position := MIN_SCROLL_POSITION
var turret_max_scroll_position : int
var base_max_scroll_position : int

var active_turret_cells : Array[BuildSelectionCell]
var active_base_cells : Array[BuildSelectionCell]
var turret_cells : Dictionary
var base_cells : Dictionary

var moving_cells := false

var scroll_detections := 0
var scroll_speed_deduction := 0.0
var scroll_speed_buffer_active := false

@onready var cell_properties := {
	-3: {
		"marker": position_negative_3,
		"scale": THIRD_SCALE,
		"modulate": THIRD_MODULATE
	},
	-2: {
		"marker": position_negative_2,
		"scale": SECOND_SCALE,
		"modulate": SECOND_MODULATE
	},
	-1: {
		"marker": position_negative_1,
		"scale": FIRST_SCALE,
		"modulate": FIRST_MODULATE
	},
	0: {
		"marker": position_selected_0,
		"scale": SELECTED_SCALE,
		"modulate": SELECTED_MODULATE
	},
	1: {
		"marker": position_positive_1,
		"scale": FIRST_SCALE,
		"modulate": FIRST_MODULATE
	},
	2: {
		"marker": position_positive_2,
		"scale": SECOND_SCALE,
		"modulate": SECOND_MODULATE
	},
	3: {
		"marker": position_positive_3,
		"scale": THIRD_SCALE,
		"modulate": THIRD_MODULATE
	}
}


func _ready() -> void:
	if build_cell_scene == null:
		push_error("Build selection cell scene is missing.")
		return
	
	var turret_cell_index : int = 0
	var base_cell_index : int = 0
	for item_key : String in DataRegistry.items:
		var item : ItemData = DataRegistry.items[item_key]
		
		if HelperFunctions.is_valid_item(item) and (
			item.type == Global.ITEM_TYPES.TURRET or item.type == Global.ITEM_TYPES.BASE
		):
			var new_build_cell : BuildSelectionCell = build_cell_scene.instantiate()
			new_build_cell.name = item_key
			
			match item.type:
				Global.ITEM_TYPES.TURRET:
					turret_cells[item_key] = new_build_cell
					new_build_cell.cell_number = turret_cell_index
					turret_cell_index += 1
					
				Global.ITEM_TYPES.BASE:
					base_cells[item_key] = new_build_cell
					new_build_cell.cell_number = base_cell_index
					base_cell_index += 1 
			
			new_build_cell.cell_properties = cell_properties
			new_build_cell.build_selection = self
			new_build_cell.item_resource = item
			add_child(new_build_cell)
			new_build_cell.setup()
			new_build_cell.visible = false
			new_build_cell.scale = scale


func _process(_delta: float) -> void:
	if selected_cell and HelperFunctions.is_valid_item(selected_cell.item_resource):
		selected_name.text = selected_cell.item_resource.key
	else:
		selected_name.text = GOT_NOTHING
		match Global.current_build_mode: 
			Global.BUILD_MODES.TURRET:
				player.selected_turret = ""
			Global.BUILD_MODES.BASE:
				player.selected_base = ""


func load_selection() -> void:
	var available_turrets = HelperFunctions.get_items_from_type(Global.ITEM_TYPES.TURRET)
	var available_bases = HelperFunctions.get_items_from_type(Global.ITEM_TYPES.BASE)
	
	# Keep the currently selected build centred when inventory changes, such as
	# after picking up a placed build.
	turret_scroll_position = _get_scroll_position(
		available_turrets, player.selected_turret, turret_scroll_position
	)
	base_scroll_position = _get_scroll_position(
		available_bases, player.selected_base, base_scroll_position
	)
	
	for cell in turret_cells.values():
		cell.visible = false
	for cell in base_cells.values():
		cell.visible = false
	
	turret_max_scroll_position = _load_type(
		available_turrets, turret_cells, turret_scroll_position, Global.BUILD_MODES.TURRET
		)
	turret_scroll_position = clampi(
		turret_scroll_position, MIN_SCROLL_POSITION, max(
			turret_max_scroll_position, MIN_SCROLL_POSITION)
	)
	
	base_max_scroll_position = _load_type(
		available_bases, base_cells, base_scroll_position, Global.BUILD_MODES.BASE
		)
	base_scroll_position = clampi(
		base_scroll_position, MIN_SCROLL_POSITION, max(
			base_max_scroll_position, MIN_SCROLL_POSITION)
	)
	
	change_build_mode()


func _get_scroll_position(
	available: Dictionary, preferred_key: String, current_position: int
	) -> int:
	var item_count := 0
	var preferred_position := -1
	
	for tier in available:
		for build in available[tier]:
			if available[tier][build] <= 0:
				continue
			if build == preferred_key:
				preferred_position = item_count
			item_count += 1
	
	if preferred_position >= 0:
		return preferred_position
	
	return clampi(current_position, MIN_SCROLL_POSITION, max(item_count - 1, MIN_SCROLL_POSITION))


func _load_type(
	available : Dictionary, 
	cells : Dictionary, 
	scroll_shift : int,
	build_type : int
	) -> int:
	
	var loops := 0
	var index_position := scroll_shift
	var active : Array[BuildSelectionCell]
	
	for tier in available:
		for build in available[tier]:
			if available[tier][build] <= 0:
				continue
			if not cells.has(build):
				continue
			
			var cell : BuildSelectionCell = cells[build]
			
			active.append(cell)
			
			cell.update_amount()
			_set_cell_position(cell, index_position)
			index_position -= 1
			loops += 1
	
	match build_type:
		Global.BUILD_MODES.TURRET:
			active_turret_cells = active
		
		Global.BUILD_MODES.BASE:
			active_base_cells = active
	
	return max(loops - 1, EMPTY_SCROLL_POSITION)


func _set_cell_position(cell: BuildSelectionCell, position_index: int) -> void:
	if cell == null:
		return
	
	var marker_index := clampi(position_index, MIN_CELL_POSITION, MAX_CELL_POSITION)
	if not cell_properties.has(marker_index):
		return
	
	var marker: Marker2D = cell_properties[marker_index][MARKER_KEY]
	
	cell.cell_position = position_index
	cell.position = marker.position
	cell.scale = cell_properties[marker_index][SCALE_KEY]
	cell.modulate = cell_properties[marker_index][MODULATE_KEY]


func _layout_cells(cells: Array[BuildSelectionCell], selected_index: int) -> void:
	var position_index := selected_index
	for cell in cells:
		_set_cell_position(cell, position_index)
		position_index -= 1


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


func scroll(event : InputEventMouseButton) -> void:
	var scroll_direction : int
	
	match Global.current_build_mode:
		Global.BUILD_MODES.TURRET:
			if not active_turret_cells:
				return
		Global.BUILD_MODES.BASE:
			if not active_base_cells:
				return
	
	if event.button_index == MOUSE_BUTTON_WHEEL_UP:
		match Global.current_build_mode:
			Global.BUILD_MODES.TURRET:
				if turret_scroll_position > MIN_SCROLL_POSITION:
					scroll_direction = SCROLL_UP_DIRECTION
					if not scroll_speed_buffer_active:
						turret_scroll_position += scroll_direction
						selected_cell = active_turret_cells[turret_scroll_position]
						player.selected_turret = selected_cell.item_resource.key
				
			Global.BUILD_MODES.BASE:
				if base_scroll_position > MIN_SCROLL_POSITION:
					scroll_direction = SCROLL_UP_DIRECTION
					if not scroll_speed_buffer_active:
						base_scroll_position += scroll_direction
						selected_cell = active_base_cells[base_scroll_position]
						player.selected_base = selected_cell.item_resource.key
	
	elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
		match Global.current_build_mode:
			Global.BUILD_MODES.TURRET:
				if turret_scroll_position < turret_max_scroll_position:
					scroll_direction = SCROLL_DOWN_DIRECTION
					if not scroll_speed_buffer_active:
						turret_scroll_position += scroll_direction
						selected_cell = active_turret_cells[turret_scroll_position]
						player.selected_turret = selected_cell.item_resource.key
				
			Global.BUILD_MODES.BASE:
				if base_scroll_position < base_max_scroll_position:
					scroll_direction = SCROLL_DOWN_DIRECTION
					if not scroll_speed_buffer_active:
						base_scroll_position += scroll_direction
						selected_cell = active_base_cells[base_scroll_position]
						player.selected_base = selected_cell.item_resource.key
	
	if scroll_direction == 0:
		return
	
	var cells_to_move = (
		active_turret_cells 
		if Global.current_build_mode == Global.BUILD_MODES.TURRET else 
		active_base_cells
		)
	
	scroll_speed_deduction += SCROLL_SPEED_FACTOR
	
	if scroll_speed_buffer_active:
		return
	
	scroll_speed_buffer_active = true
	
	await get_tree().create_timer(SCROLL_SPEED_DETECTION_TIME).timeout
	
	scroll_speed_buffer_active = false
	moving_cells = true
	
	var tween_time : float = clamp(
		MAX_TWEEN_SPEED - scroll_speed_deduction, 
		MIN_TWEEN_SPEED, MAX_TWEEN_SPEED
		)
	
	scroll_speed_deduction = 0.0
	
	for cell : BuildSelectionCell in cells_to_move:
		cell.move(scroll_direction, tween_time)
	
	await get_tree().create_timer(tween_time).timeout
	moving_cells = false


func change_build_mode() -> void:
	match Global.current_build_mode:
		Global.BUILD_MODES.TURRET:
			for cell in active_base_cells:
				cell.visible = false
			
			for cell in active_turret_cells:
				cell.visible = true
			
			if active_turret_cells:
				selected_cell = active_turret_cells[turret_scroll_position]
				player.selected_turret = selected_cell.item_resource.key
			else:
				selected_cell = null
				player.selected_turret = ""
		
		Global.BUILD_MODES.BASE:
			for cell in active_turret_cells:
				cell.visible = false
			
			for cell in active_base_cells:
				cell.visible = true
			
			if active_base_cells:
				selected_cell = active_base_cells[base_scroll_position]
				player.selected_base = selected_cell.item_resource.key
			else:
				selected_cell = null
				player.selected_base = ""


func placed_build() -> void:
	if not selected_cell or not HelperFunctions.is_valid_item(selected_cell.item_resource):
		return
	
	var item = selected_cell.item_resource
	if not HelperFunctions.remove_item_from_storage(item):
		return
	
	selected_cell.item_placed()


func remove_cell_in_place() -> void:
	var cells_array: Array[BuildSelectionCell]
	match Global.current_build_mode:
		Global.BUILD_MODES.TURRET: 
			cells_array = active_turret_cells
		Global.BUILD_MODES.BASE:   
			cells_array = active_base_cells
	
	var remove_cell_index: int = cells_array.find(selected_cell)
	if remove_cell_index < 0:
		return
	
	cells_array.pop_at(remove_cell_index)
	
	if cells_array.is_empty():
		selected_cell = null
		match Global.current_build_mode:
			Global.BUILD_MODES.TURRET:
				turret_scroll_position = MIN_SCROLL_POSITION
				turret_max_scroll_position = EMPTY_SCROLL_POSITION
				player.selected_turret = ""
			Global.BUILD_MODES.BASE:
				base_scroll_position = MIN_SCROLL_POSITION
				base_max_scroll_position = EMPTY_SCROLL_POSITION
				player.selected_base = ""
		return
	
	var next_selected_index: int = min(remove_cell_index, cells_array.size() - 1)
	selected_cell = cells_array[next_selected_index]
	_layout_cells(cells_array, next_selected_index)
	
	match Global.current_build_mode:
		Global.BUILD_MODES.TURRET:
			turret_scroll_position = next_selected_index
			turret_max_scroll_position = cells_array.size() - 1
			player.selected_turret = selected_cell.item_resource.key
		Global.BUILD_MODES.BASE:
			base_scroll_position = next_selected_index
			base_max_scroll_position = cells_array.size() - 1
			player.selected_base = selected_cell.item_resource.key
