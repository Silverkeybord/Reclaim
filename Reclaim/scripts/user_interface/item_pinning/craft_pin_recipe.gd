class_name CraftPinRecipe
extends PanelContainer

# Duplicate Style Values
const PANEL_NAME := &"panel"
const STYLE_CONTENT_MARGINS := -1
const STYLE_BG_COLOR_A := 0.4
const STYLE_BORDER_WIDTH := 4
const STYLE_CORNER_RADIUS := 16

const CANT_CRAFT_COLOR := Color(0.659, 0.659, 0.659, 0.4)
const CAN_CRAFT_COLOR := Color(0.58, 1.0, 0.5, 0.4)

const CRAFT_TIMES_FORMATING := "%dx"

# Tween values
const TWEEN_TIME := 0.15
const TWEEN_HIDDEN_SEPARATION := -44
const TWEEN_SHOW_SEPARATION := 4
const PROP_SEPARATION := "theme_override_constants/separation"

@export var craft_pin_amount_scene : PackedScene
@export var craft_data : CraftData

@export var item_panel_container : PanelContainer
@export var item_amounts_hbox : HBoxContainer
@export var item_craft_texture : TextureRect
@export var craft_times_label : Label

var craft_pin_amounts : Array[CraftPinAmount]


func _ready() -> void:
	if not craft_data:
		return
	
	for recipe_requirement: RequirementsTemplate in craft_data.requirements:
		var new_amount := craft_pin_amount_scene.instantiate()
		new_amount.item_data = recipe_requirement.item
		new_amount.required_amount = recipe_requirement.amount
		
		craft_pin_amounts.append(new_amount)
		item_amounts_hbox.add_child(new_amount)
	
	item_craft_texture.texture = craft_data.crafted_item.get_item_texture()
	
	var tier_style : StyleBoxFlat = (
		Global.TIER_CONFIG[craft_data.crafted_item.tier][Global.KEY_STYLE].duplicate()
		)
	
	tier_style.bg_color.a = STYLE_BG_COLOR_A
	tier_style.set_border_width_all(STYLE_BORDER_WIDTH)
	tier_style.set_corner_radius_all(STYLE_CORNER_RADIUS)
	tier_style.set_content_margin_all(STYLE_CONTENT_MARGINS)
	
	item_panel_container.add_theme_stylebox_override(PANEL_NAME, tier_style)


func _process(_delta: float) -> void:
	if Global.crafting_pin_open:
		update_values()


func update_values() -> void:
	var craft_times : Array[int]
	for craft_pin_amount : CraftPinAmount in craft_pin_amounts:
		craft_times.append(craft_pin_amount.get_craft_times())
	
	craft_times.sort()
	
	var style : StyleBoxFlat = item_panel_container.get_theme_stylebox(PANEL_NAME)
	if craft_times[0] == 0:
		craft_times_label.visible = false
		style.border_color = CANT_CRAFT_COLOR
	else:
		craft_times_label.text = CRAFT_TIMES_FORMATING % craft_times[0]
		craft_times_label.visible = true
		style.border_color = CAN_CRAFT_COLOR
	
	item_panel_container.add_theme_stylebox_override(PANEL_NAME, style)
	
	for craft_pin_amount : CraftPinAmount in craft_pin_amounts:
		craft_pin_amount.update_item_amount()


func show_or_hide_tween(is_show : bool) -> void:
	var show_tween = create_tween()
	show_tween.set_ease(Tween.EASE_IN)
	show_tween.tween_property(
		item_amounts_hbox, 
		PROP_SEPARATION, 
		TWEEN_SHOW_SEPARATION if is_show else TWEEN_HIDDEN_SEPARATION, 
		TWEEN_TIME
	)
