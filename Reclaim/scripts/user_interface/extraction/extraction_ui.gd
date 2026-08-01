class_name ExtractionUI
extends CanvasLayer

const ANIMATION_OPEN := "open_extraction"
const ANIMATION_CLOSE := "close_extraction"

const EXTRACTION_CELL_SCENE : PackedScene = preload(
	"res://scenes/user_interface/extraction_cell.tscn")

const FIRST_COLOR := Color("dbffffff")
const SECOND_COLOR := Color("c8ebffff")
const THIRD_COLOR := Color("B9FFAF")
const FOURTH_COLOR := Color("FFFF88")
const FITH_COLOR := Color("FFBA7E")
const MAX_COLOR := Color("FF7E7E")

const FITHS_RATIO_DIVISOR := 0.2

const MAX_MOVE_AMOUNT := 0

const CLOSE_UI_INPUT := "close_ui"

const WEIGHT_FORMAT := "--- Weight %s/%s kg ---"
const TOTAL_FORMAT := "Total : %s"

# each number is multiplyed by 0.2 for the ratio. using intergets for better precision
# so 1 means under 0.2
const EXTRACTION_BAR_COLOR_RATIOS := {
	1 : FIRST_COLOR,
	2 : SECOND_COLOR,
	3 : THIRD_COLOR,
	4 : FOURTH_COLOR,
	5 : FITH_COLOR
}

@export var extraction_pod : StaticBody3D
@export var extraction_animations : AnimationPlayer

@export_group("Extraction UI")
@export var item_tip : CanvasLayer
@export var extraction_bar : ProgressBar
@export var total_label : Label
@export var weight_label : Label
@export var help_display : PanelContainer
@export var sector_hflow : HFlowContainer
@export var extraction_hflow : HFlowContainer

var storage_cells := {}
var extraction_cells := {}

var total_stored_weight : int = 0


func _ready() -> void:
	set_process(false)
	storage_cells = Storage.load_all_cells(
		sector_hflow, EXTRACTION_CELL_SCENE, item_tip, self)
	extraction_cells = Storage.load_all_cells(
		extraction_hflow, EXTRACTION_CELL_SCENE, item_tip, self)
	
	for key : String in extraction_cells:
		var cell : ExtractionCell = extraction_cells[key]
		cell.in_storage = false


func _process(_delta: float) -> void:
	if extraction_bar.value > 0 and extraction_bar.value < extraction_bar.max_value:
		var extraction_weight_ratio = extraction_bar.value / extraction_bar.max_value
		var color_key = int(ceil(extraction_weight_ratio / FITHS_RATIO_DIVISOR))
		
		extraction_bar.modulate = EXTRACTION_BAR_COLOR_RATIOS[color_key]
		
	elif extraction_bar.value == extraction_bar.max_value:
		extraction_bar.modulate = MAX_COLOR
	
	if Input.is_action_just_pressed(CLOSE_UI_INPUT):
		close_ui()


func open_ui() -> void:
	if extraction_animations.is_playing():
		return
	
	extraction_bar.value = 0 # TEMP
	extraction_bar.max_value = 100 # TEMP
	
	_set_open_or_close(true)
	extraction_animations.play(ANIMATION_OPEN)
	load_extraction_cells()


# General loading and functoins -----------------------------------------------
func close_ui() -> void:
	if extraction_animations.is_playing():
		return
	
	_set_open_or_close(false)
	extraction_animations.play(ANIMATION_CLOSE)
	
	await extraction_animations.animation_finished
	
	Global.ui_open = false
	Global.extraction_open = false


func _set_open_or_close(toggle : bool) -> void:
	Global.ui_open = toggle
	Global.extraction_open = toggle
	set_process(toggle)
	Global.set_mouse_captured(true, not toggle)


func load_extraction_cells() -> void:
	for tier in Global.sector_storage:
		for item in Global.sector_storage[tier]:
			pass
	
	var sector_storage_items = HelperFunctions.get_item_from_storage(Global.sector_storage)
	for item in sector_storage_items:
		var item_data : ItemData = DataRegistry.items[item]
		storage_cells[item].update_amount()
		total_stored_weight += item_data.weight * sector_storage_items[item]
	
	total_label.text = TOTAL_FORMAT % HelperFunctions.return_amount_shorthand(total_stored_weight)
	weight_label.text = WEIGHT_FORMAT % [
		HelperFunctions.return_amount_shorthand(extraction_bar.value), 
		HelperFunctions.return_amount_shorthand(extraction_bar.max_value)
		]


# Help icon showing -----------------------------------------------------------
func _on_help_icon_mouse_entered() -> void:
	help_display.visible = true


func _on_help_icon_mouse_exited() -> void:
	help_display.visible = false


# Extract and Cancel Buttons --------------------------------------------------
func _on_extract_button_pressed() -> void:
	extraction_pod.extract()


func _on_cancel_button_pressed() -> void:
	close_ui()


# Moving items and checking ---------------------------------------------------
func move_item(in_storage : bool, move_amount : int, item : ItemData) -> void:
	if not item:
		return
	
	var item_amount : int
	
	if in_storage:
		item_amount = Global.sector_storage[item.tier].get(item.key)
	else:
		item_amount = Global.extraction_storage[item.tier].get(item.key)
	
	if move_amount > item_amount:
		move_amount = item_amount
	
	if move_amount == MAX_MOVE_AMOUNT:
		move_amount = item_amount
	
	var move_weight : int = move_amount * item.weight
	
	if in_storage:
		if move_weight > extraction_bar.max_value - extraction_bar.value:
			var remaining_weight = extraction_bar.max_value - extraction_bar.value
			move_amount = floori(remaining_weight / item.weight)
			move_weight = move_amount * item.weight
		
		if move_amount != 0:
			HelperFunctions.add_item_to_storage(item, move_amount, Global.extraction_storage)
			HelperFunctions.remove_item_from_storage(item, move_amount, Global.sector_storage)
			storage_cells[item.key].update_amount()
			extraction_cells[item.key].update_amount()
			extraction_bar.value += move_weight
		
	else:
		HelperFunctions.add_item_to_storage(item, move_amount, Global.sector_storage)
		HelperFunctions.remove_item_from_storage(item, move_amount, Global.extraction_storage)
		storage_cells[item.key].update_amount()
		extraction_cells[item.key].update_amount()
		extraction_bar.value -= move_weight
	
	weight_label.text = WEIGHT_FORMAT % [extraction_bar.value, extraction_bar.max_value]


# Presets --------------------------------------------------------------------
func _on_most_valuable_preset_pressed() -> void:
	
	pass # Replace with function body.


func _on_highest_tier_preset_pressed() -> void:
	
	pass # Replace with function body.


func _on_most_items_preset_pressed() -> void:
	pass # Replace with function body.


func _on_best_value_pressed() -> void:
	pass


# clears extraction storage
func _on_clear_selection_pressed() -> void:
	var items = HelperFunctions.get_item_from_storage(Global.extraction_storage)
	
	for item in items:
		move_item(false, 0, DataRegistry.items[item])
