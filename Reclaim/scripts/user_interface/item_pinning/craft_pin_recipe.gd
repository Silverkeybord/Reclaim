class_name CraftPinRecipe
extends PanelContainer

const CRAFT_TIMES_FORMATING := "%dx"

#Tween values
const TWEEN_TIME := 0.15
const TWEEN_HIDDEN_SEPARATION := -44
const TWEEN_SHOW_SEPARATION := 4
const PROP_SEPARATION := "theme_override_constants/separation"

@export var craft_pin_amount_scene : PackedScene
@export var craft_data : CraftData

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


func _process(_delta: float) -> void:
	if Global.crafting_pin_open:
		update_values()


func update_values() -> void:
	var craft_times : Array[int]
	for craft_pin_amount : CraftPinAmount in craft_pin_amounts:
		craft_times.append(craft_pin_amount.get_craft_times())
	
	craft_times.sort()
	
	if craft_times[0] == 0:
		craft_times_label.visible = false
	else:
		craft_times_label.text = CRAFT_TIMES_FORMATING % craft_times[0]
		craft_times_label.visible = true
	
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
