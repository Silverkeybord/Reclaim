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


func open_ui() -> void:
	extraction_bar.value = 0 # TEMP
	extraction_bar.max_value = 100 # TEMP
	
	set_process(true)
	Global.ui_open = true
	Global.extraction_open = true
	Global.set_mouse_captured()
	extraction_animations.play(ANIMATION_OPEN)
	load_extraction_cells()


func close_ui() -> void:
	set_process(false)
	extraction_animations.play(ANIMATION_CLOSE)
	Global.set_mouse_captured()
	
	await extraction_animations.animation_finished
	
	Global.ui_open = false
	Global.extraction_open = false


func load_extraction_cells() -> void:
	for tier in Global.sector_storage:
		for item in Global.sector_storage[tier]:
			pass
	
	for tier in Global.sector_storage:
		for item in Global.sector_storage[tier]:
			storage_cells[item].update_amount()


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
