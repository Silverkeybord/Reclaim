class_name CraftingSelection
extends PanelContainer

const TIER_TEXT := "Tier "
const DASH := "-"
const BORDER_THICKNESS := 4

@export_range(1, 5) var tier : int = 1

@export var tier_label : Label
@export var hflow : HFlowContainer
@export var tab : String


func set_up() -> void: 
	tier_label.text = "Tier - " + str(tier) + " -"
	var style : StyleBoxFlat = Global.TIER_CONFIG[tier]["style"].duplicate()
	style.border_width_bottom = BORDER_THICKNESS
	style.border_width_top = BORDER_THICKNESS
	style.border_width_left = BORDER_THICKNESS
	style.border_width_right = BORDER_THICKNESS
	add_theme_stylebox_override("panel", style)
