extends CanvasLayer

const SELECTED_SCALE := Vector2(1.1, 1.1)
const FIRST_SCALE := Vector2(1, 1)
const SECOND_SCALE := Vector2(0.9, 0.9)

const SELECTED_MODULATE := Color(1.0, 1.0, 1.0, 1.0)
const FIRST_MODULATE := Color(1.0, 1.0, 1.0, 0.6)
const SECOND_MODULATE := Color(1.0, 1.0, 1.0, 0.3)
const THIRD_MODULATE := Color(1.0, 1.0, 1.0, 0.0)

const MARKER_KEY := "marker"
const SCALE_KEY := "scale"
const MODULATE_KEY := "modulate"

const MIN_CELL_POSITION := -3
const MAX_CELL_POSITION := 3

const TWEEN_TIME := 0.2

const MIN_SCROLL_POSITION := 0

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

var available_turrets := {}
var available_bases := {}
var active_turret_cell : Array[BuildSelectionCell]
var active_base_cell : Array[BuildSelectionCell]
var turret_cells : Dictionary
var base_cells : Dictionary

var moving_cells := false

@onready var cell_properties := {
	-3: {
		"marker": position_negative_3,
		"scale": SECOND_SCALE,
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
		"scale": SECOND_SCALE,
		"modulate": THIRD_MODULATE
	}
}


func _ready() -> void:
	var turret_cell_index : int = 0
	var base_cell_index : int = 0
	for item_key : String in DataRegistry.items:
		var item : ItemData = DataRegistry.items[item_key]
		
		if item.type == Global.ITEM_TYPES.TURRET or item.type == Global.ITEM_TYPES.BASE:
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
			new_build_cell.item_resource = DataRegistry.items[item_key]
			add_child(new_build_cell)
			new_build_cell.setup()
			new_build_cell.visible = false
			new_build_cell.scale = scale
	
	# minus one because on the last loop the index will still go up
	turret_max_scroll_position = turret_cell_index - 1
	base_max_scroll_position = base_cell_index - 1


func load_selection() -> void:
	available_turrets = Global._get_items_from_type(Global.ITEM_TYPES.TURRET)
	available_bases = Global._get_items_from_type(Global.ITEM_TYPES.BASE)
	
	_load_type(available_turrets, active_turret_cell, turret_cells, turret_scroll_position)
	_load_type(available_bases, active_base_cell, base_cells, base_scroll_position)
	
	change_build_mode()
	
	selected_cell = active_turret_cell[turret_scroll_position]
	selected_name.text = selected_cell.name


func _load_type(available : Dictionary, active : Array, cells : Dictionary, scroll_shift : int):
	var index_position := scroll_shift
	
	for tier in available:
		for build in available[tier]:
			var cell : BuildSelectionCell = cells[build]
			var marker : Marker2D
			if index_position < MIN_CELL_POSITION:
				marker = cell_properties[MIN_CELL_POSITION][MARKER_KEY]
				cell.scale = cell_properties[MIN_CELL_POSITION][SCALE_KEY]
				cell.modulate = cell_properties[MIN_CELL_POSITION][MODULATE_KEY]
			else:
				marker = cell_properties[index_position][MARKER_KEY]
				cell.scale = cell_properties[index_position][SCALE_KEY]
				cell.modulate = cell_properties[index_position][MODULATE_KEY]
			
			if not cell in active:
				active.append(cell)
			cell.cell_position = index_position
			cell.position = marker.position
			index_position -= 1


func _input(event: InputEvent) -> void:
	if Global.player_mode != Global.PLAYER_MODES.BUILDING:
		return
	
	if Input.is_action_just_released("change_selected_build"):
		visible = false
	
	if Input.is_action_just_pressed("change_selected_build"):
		visible = true
		load_selection()
	
	if (
		event is InputEventMouseButton and
		Input.is_action_pressed("change_selected_build") and 
		Global.player_mode == Global.PLAYER_MODES.BUILDING and
		not moving_cells
	):
		
		scroll(event)


func scroll(event : InputEventMouseButton) -> void:
	var scroll_direction : int
	
	if event.button_index == MOUSE_BUTTON_WHEEL_UP:
		match Global.current_build_mode:
			Global.BUILD_MODES.TURRET:
				if turret_scroll_position > MIN_SCROLL_POSITION:
					scroll_direction = -1
					turret_scroll_position += scroll_direction
					selected_cell = active_turret_cell[turret_scroll_position]
					player.selected_turret = selected_cell.name
				
			Global.BUILD_MODES.BASE:
				if base_scroll_position > MIN_SCROLL_POSITION:
					scroll_direction = -1
					base_scroll_position += scroll_direction
					selected_cell = active_turret_cell[base_max_scroll_position]
					player.selected_base = selected_cell.name
	
	elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
		match Global.current_build_mode:
			Global.BUILD_MODES.TURRET:
				if turret_scroll_position < turret_max_scroll_position:
					scroll_direction = 1
					turret_scroll_position += scroll_direction
					selected_cell = active_turret_cell[turret_scroll_position]
					player.selected_turret = selected_cell.name
				
			Global.BUILD_MODES.BASE:
				if base_scroll_position < base_max_scroll_position:
					scroll_direction = 1
					base_scroll_position += scroll_direction
					selected_cell = active_turret_cell[base_scroll_position]
					player.selected_base = selected_cell.name
	
	if scroll_direction == 0:
		return
	
	moving_cells = true
	
	selected_name.text = selected_cell.name
	
	
	var cells_to_move = (
		active_turret_cell 
		if Global.current_build_mode == Global.BUILD_MODES.TURRET else 
		active_base_cell
		)
	
	for cell : BuildSelectionCell in cells_to_move:
		cell.move(scroll_direction, TWEEN_TIME)
	
	await get_tree().create_timer(TWEEN_TIME).timeout
	moving_cells = false


func change_build_mode() -> void:
	match Global.current_build_mode:
		Global.BUILD_MODES.TURRET:
			for cell in active_base_cell:
				cell.visible = false
			
			for cell in active_turret_cell:
				cell.visible = true
			
			selected_cell = active_turret_cell[turret_scroll_position]
			player.selected_turret = selected_cell.name
		
		Global.BUILD_MODES.BASE:
			for cell in active_turret_cell:
				cell.visible = false
			
			for cell in active_base_cell:
				cell.visible = true
			
			selected_cell = active_base_cell[base_scroll_position]
			player.selected_base = selected_cell.name
	
	selected_name.text = selected_cell.name


func placed_build() -> void:
	var current_storage = Global.get_current_storage()
	var item = selected_cell.item_resource
	current_storage[item.tier][selected_cell.name] -= 1
	
	selected_cell.place()
