class_name ExtractionUI
extends CanvasLayer

const ANIMATION_OPEN := "open_extraction"
const ANIMATION_CLOSE := "close_extraction"

const EXTRACTION_CELL_SCENE : PackedScene = preload(
	"res://scenes/user_interface/move_cel.tscn")

const FIRST_COLOR := Color("dbffffff")
const SECOND_COLOR := Color("c8ebffff")
const THIRD_COLOR := Color("B9FFAF")
const FOURTH_COLOR := Color("FFFF88")
const FITH_COLOR := Color("FFBA7E")
const MAX_COLOR := Color("FF7E7E")

const FITHS_RATIO_DIVISOR := 0.2

const MAX_MOVE_AMOUNT_NUMBER := 0

const ITEM_KEY := "key"
const ITEM_TIER := "tier"
const ITEM_VALUE := "value"
const ITEM_WEIGHT := "weight"

const CLOSE_UI_INPUT := "close_ui"

const WEIGHT_FORMAT := "--- Weight %s/%s kg ---"

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
@export var deploy_pod : StaticBody3D

@export var extraction_animations : AnimationPlayer
@export var is_extraction_ui : bool = true

@export_group("Move UI")
@export var total_weight : TextureRect
@export var item_tip : CanvasLayer
@export var extraction_bar : ProgressBar
@export var weight_label : Label
@export var help_display : PanelContainer
@export var sector_hflow : HFlowContainer
@export var extraction_hflow : HFlowContainer

var storage_cells := {}
var extraction_cells := {}


func _ready() -> void:
	extraction_bar.value = 0 # TEMP
	extraction_bar.max_value = 100 # TEMP
	
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


# General loading and functoins -----------------------------------------------
func close_ui(forced = false) -> void:
	if extraction_animations.is_playing() and not forced:
		return
	
	_set_open_or_close(false)
	extraction_animations.play(ANIMATION_CLOSE)
	
	await extraction_animations.animation_finished
	
	Global.ui_open = false
	Global.extraction_open = false


func open_ui() -> void:
	if extraction_animations.is_playing():
		return
	
	_set_open_or_close(true)
	extraction_animations.play(ANIMATION_OPEN)
	load_extraction_cells()


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
		storage_cells[item].update_amount()
	
	total_weight.update_weight_label()
	
	weight_label.text = WEIGHT_FORMAT % [
		HelperFunctions.return_amount_shorthand(extraction_bar.value), 
		HelperFunctions.return_amount_shorthand(extraction_bar.max_value)
		]


# Extract and Cancel Buttons --------------------------------------------------
func _on_extract_button_pressed() -> void:
	close_ui(true)
	if is_extraction_ui:
		extraction_pod.extract()
	else:
		deploy_pod.deploy()


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
	
	if move_amount == MAX_MOVE_AMOUNT_NUMBER:
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
	
	weight_label.text = WEIGHT_FORMAT % [int(extraction_bar.value), int(extraction_bar.max_value)]


# Presets --------------------------------------------------------------------
func _on_most_valuable_preset_pressed() -> void:
	var remaining_storage = extraction_bar.max_value - extraction_bar.value
	if not remaining_storage:
		return
	var item_array = get_item_array()
	item_array.sort_custom(sort_value_then_tier)
	move_over_items(item_array)


func _on_highest_tier_preset_pressed() -> void:
	var remaining_storage = extraction_bar.max_value - extraction_bar.value
	if not remaining_storage:
		return
	var item_array = get_item_array()
	item_array.sort_custom(sort_tier_then_value)
	move_over_items(item_array)


func _on_most_items_preset_pressed() -> void:
	var remaining_storage = extraction_bar.max_value - extraction_bar.value
	if not remaining_storage:
		return
	var item_array = get_item_array()
	item_array.sort_custom(sort_least_weight_then_value)
	move_over_items(item_array)


func on_best_value_pressed() -> void:
	var remaining_storage = extraction_bar.max_value - extraction_bar.value
	if not remaining_storage:
		return
	var item_array = get_item_array()
	item_array.sort_custom(sort_ratio_then_tier)
	move_over_items(item_array)


func _on_clear_selection_pressed() -> void:
	var items = HelperFunctions.get_item_from_storage(Global.extraction_storage)
	for item in items:
		move_item(false, 0, DataRegistry.items[item])


func get_item_array() -> Array[Dictionary]:
	var sector_items = HelperFunctions.get_item_from_storage(Global.sector_storage)
	var item_list : Array[Dictionary]
	for item in sector_items:
		var item_data : ItemData = DataRegistry.items[item]
		item_list.append({
			ITEM_KEY : item,
			ITEM_TIER : item_data.tier,
			ITEM_VALUE : item_data.value,
			ITEM_WEIGHT : item_data.weight
		})
	return item_list


# Sorting functions ----------------------------------------------------------
func sort_value_then_tier(a, b) -> bool:
	# Highest value first, then highest tier
	if a[ITEM_VALUE] != b[ITEM_VALUE]:
		return a[ITEM_VALUE] > b[ITEM_VALUE]
	return a[ITEM_TIER] > b[ITEM_TIER]


func sort_tier_then_value(a, b) -> bool:
	# Highest tier first, then highest value
	if a[ITEM_TIER] != b[ITEM_TIER]:
		return a[ITEM_TIER] > b[ITEM_TIER]
	return a[ITEM_VALUE] > b[ITEM_VALUE]


func sort_least_weight_then_value(a, b) -> bool:
	# lightest items first then highest value
	if a[ITEM_WEIGHT] != b[ITEM_WEIGHT]:
		return a[ITEM_WEIGHT] < b[ITEM_WEIGHT]
	return a[ITEM_VALUE] > b[ITEM_VALUE]


func sort_ratio_then_tier(a, b) -> bool:
	# best value per weight first, then highest tier
	var ratio_a = a[ITEM_VALUE] / max(a[ITEM_WEIGHT], 0.001)  # prevent division by zero
	var ratio_b = b[ITEM_VALUE] / max(b[ITEM_WEIGHT], 0.001)
	
	if not is_equal_approx(ratio_a, ratio_b):
		return ratio_a > ratio_b
	return a[ITEM_TIER] > b[ITEM_TIER]


func move_over_items(item_array : Array[Dictionary]) -> void:
	var remaining_weight : int = int(extraction_bar.max_value - extraction_bar.value)
	for item_values in item_array:
		if remaining_weight == 0:
			break
		var item_data : ItemData = DataRegistry.items[item_values[ITEM_KEY]]
		var storage_items : int = HelperFunctions.get_item_amount(item_data)
		var fit_items : int = floori(float(remaining_weight) / float(item_data.weight))
		
		if fit_items <= storage_items:
			remaining_weight -= fit_items * item_data.weight
			extraction_bar.value += fit_items * item_data.weight
		else:
			remaining_weight -= storage_items * item_data.weight
			extraction_bar.value += storage_items * item_data.weight
			fit_items = storage_items
		
		HelperFunctions.remove_item_from_storage(item_data, fit_items)
		HelperFunctions.add_item_to_storage(item_data, fit_items, Global.extraction_storage)
		print("moved over item - ", item_data.key, " - of amount of - ", fit_items)
		storage_cells[item_data.key].update_amount()
		extraction_cells[item_data.key].update_amount()
	
	weight_label.text = WEIGHT_FORMAT % [int(extraction_bar.value), int(extraction_bar.max_value)]
