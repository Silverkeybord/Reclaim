class_name Storage
extends Node

const INVENTORY_CELLS_SCENE: PackedScene = preload("res://scenes/user_interface/storage_cell.tscn")
const OPEN_ANIMATION: StringName = &"open_storage"
const CLOSE_ANIMATION: StringName = &"close_storage"
const SCROLL_AMOUNT: int = 50
const MIN_SCROLL: int = 0

const INTERACT_INPUT: StringName = &"interact"
const CLOSE_UI_INPUT: StringName = &"close_ui"

const MISSING_CELL_PARENT_ERROR: String = "Storage UI item parent is missing."

@export var item_tip: CanvasLayer
@export var item_parent: Node
@export var crafting_inventory: bool = false
@export var storage_animations: AnimationPlayer
@export var scroll_container: ScrollContainer

var displayed_cells: Dictionary = {}


func _ready() -> void:
	set_process(false)
	displayed_cells = load_all_cells(item_parent, INVENTORY_CELLS_SCENE, item_tip)
	update_storage()


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed(CLOSE_UI_INPUT):
		close_ui()


static func load_all_cells(
	cell_parent: Node,
	cell_scene: PackedScene,
	scene_item_tip: CanvasLayer,
	extraction_ui: CanvasLayer = null
) -> Dictionary:
	
	if cell_parent == null:
		push_error(MISSING_CELL_PARENT_ERROR)
		return {}
	
	var loaded_cells: Dictionary = {}
	
	# Sort all items by tier
	var all_items: Array = DataRegistry.items.values()
	all_items.sort_custom(func(a: ItemData, b: ItemData) -> bool:
		return a.tier < b.tier
	)
	
	for item: ItemData in all_items:
		if not HelperFunctions.is_valid_item(item):
			continue
		
		var new_cell := cell_scene.instantiate() as BaseStorageCell
		if new_cell == null:
			continue
			
		cell_parent.add_child(new_cell)
		new_cell.item_resource = item
		new_cell.item_tip = scene_item_tip
		new_cell.setup()
		new_cell.visible = false
		loaded_cells[item.key] = new_cell
		
		if extraction_ui:
			new_cell.set(&"extraction_ui", extraction_ui)
	
	return loaded_cells


func update_storage() -> void:
	for item_key: String in displayed_cells:
		var cell: BaseStorageCell = displayed_cells[item_key]
		if cell and cell.has_method(&"update_amount"):
			cell.update_amount()


func _input(event: InputEvent) -> void:
	if not Global.storage_open:
		return
	
	var mouse_event := event as InputEventMouseButton
	if mouse_event and mouse_event.pressed and not crafting_inventory and scroll_container:
		match mouse_event.button_index:
			MOUSE_BUTTON_WHEEL_UP:
				scroll_container.scroll_vertical = maxi(
					scroll_container.scroll_vertical - SCROLL_AMOUNT,
					MIN_SCROLL
				)
			MOUSE_BUTTON_WHEEL_DOWN:
				scroll_container.scroll_vertical += SCROLL_AMOUNT


func open_ui() -> void:
	if storage_animations and storage_animations.is_playing():
		return
	
	_set_open_or_close(true)
	
	update_storage()
	if not crafting_inventory and storage_animations:
		storage_animations.play(OPEN_ANIMATION)


func close_ui() -> void:
	if storage_animations and storage_animations.is_playing():
		return
	
	_set_open_or_close(false)
	
	if not crafting_inventory and storage_animations:
		storage_animations.play(CLOSE_ANIMATION)


func _set_open_or_close(toggle: bool) -> void:
	Global.ui_open = toggle
	Global.storage_open = toggle
	set_process(toggle)
