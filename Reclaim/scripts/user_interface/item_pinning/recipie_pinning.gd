class_name RecpiePinning
extends Control

const INPUT_SHOW := &"show_pinned_recipes"
const MAX_PINNED := 3
const craft_pin_recipe_scene := preload(
	"res://scenes/user_interface/recipe_pinning/craft_pin_recipe.tscn")

#Tween values
const TWEEN_TIME := 0.15
const TWEEN_HIDDEN_POS := Vector2(120, 0)
const TWEEN_SHOW_POS := Vector2(0, 0)
const PROP_POSITION := "position"

@export var pining_vbox : VBoxContainer

var last_open_ui_state : bool = false


func _ready() -> void:
	for craft_data in Global.pined_crafts:
		var new_craft_pin : CraftPinRecipe = craft_pin_recipe_scene.instantiate()
		new_craft_pin.craft_data = craft_data
		pining_vbox.add_child(new_craft_pin)
		Global.pined_crafts[craft_data] = new_craft_pin


func _process(_delta: float) -> void:
	var current_open_ui_state = true
	if Global.ui_open and not Global.storage_open or Global.major_animation_playing:
		current_open_ui_state = false
	
	if current_open_ui_state == false and current_open_ui_state != last_open_ui_state:
		show_or_hide_tween(false)
	
	if not current_open_ui_state:
		return
	
	if Input.is_action_just_pressed(INPUT_SHOW):
		show_or_hide_tween(not Global.crafting_pin_open)
	
	last_open_ui_state = current_open_ui_state


func show_or_hide_tween(is_show := true) -> void:
	if is_show == Global.crafting_pin_open:
		return
	
	Global.crafting_pin_open = is_show
	var show_tween = create_tween()
	show_tween.set_ease(Tween.EASE_IN)
	show_tween.tween_property(
		self, 
		PROP_POSITION, 
		TWEEN_SHOW_POS if is_show else TWEEN_HIDDEN_POS, 
		TWEEN_TIME
	)
	
	for craft_data in Global.pined_crafts:
		Global.pined_crafts[craft_data].show_or_hide_tween(is_show)


func pin_recipe(craft_data : CraftData) -> bool:
	if (Global.pined_crafts.size() >= MAX_PINNED and 
	craft_data not in Global.pined_crafts or 
	not craft_data or 
	not craft_data.crafted_item.key in DataRegistry.crafting
):
		return false
	
	if craft_data in Global.pined_crafts.keys():
		Global.pined_crafts[craft_data].queue_free()
		Global.pined_crafts.erase(craft_data)
		
	else:
		var new_craft_pin : CraftPinRecipe = craft_pin_recipe_scene.instantiate()
		new_craft_pin.craft_data = craft_data
		pining_vbox.add_child(new_craft_pin)
		Global.pined_crafts[craft_data] = new_craft_pin
	
	return true
