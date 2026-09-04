class_name CraftQueueItem
extends Control

const INPUT_RIGHT_CLICK := &"m2"
const MIN_CRAFT_TIME := 0.01

@export var amount : int
@export var craft_data : CraftData
@export var crafting_ui : CraftingUI
@export var item_notif_controller : ItemNotifController

@export var name_label : Label
@export var craft_timer : Timer
@export var progress_bar : ProgressBar
@export var craft_amount_label : Label
@export var item_texture_rect : TextureRect
@export var progress_panel : PanelContainer

var mouse_in_zone := false
var final_craft_time : float


func _ready() -> void:
	_set_amount_label()
	name_label.text = HelperFunctions.get_display_name(craft_data.crafted_item.key)
	item_texture_rect.texture = craft_data.crafted_item.get_item_texture()
	final_craft_time = craft_data.craft_time # * auth for future progress
	craft_timer.wait_time = final_craft_time
	progress_bar.max_value = final_craft_time


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed(INPUT_RIGHT_CLICK) and mouse_in_zone:
		_cancel_craft()
	
	progress_bar.value = craft_timer.wait_time - craft_timer.time_left


func start_craft() -> void:
	progress_panel.visible = true
	craft_timer.start()


func _cancel_craft() -> void:
	for requirment : RequirementsTemplate in craft_data.requirements:
		HelperFunctions.add_item_to_storage(
			requirment.item, 
			requirment.amount * amount * craft_data.craft_amount,
			HelperFunctions.get_current_storage()
			)
		
		item_notif_controller.add_notif(
			requirment.item, requirment.amount * amount
			)
	
	remove_from_group(crafting_ui.GROUP_CRAFT_QUEUE)
	crafting_ui.queue_next()
	queue_free()


# Toggle detection for removing craft =========================================
func _on_mouse_entered() -> void:
	mouse_in_zone = true


func _on_mouse_exited() -> void:
	mouse_in_zone = false


# When the timer finishes the crafted item will increase ======================
func _on_timer_timeout() -> void:
	HelperFunctions.add_item_to_storage(
		craft_data.crafted_item,
		craft_data.craft_amount,
	)
	
	item_notif_controller.add_notif(craft_data.crafted_item, craft_data.craft_amount)
	amount -= 1
	_set_amount_label()
	
	if amount == 0:
		remove_from_group(crafting_ui.GROUP_CRAFT_QUEUE)
		crafting_ui.queue_next()
		queue_free()


# Helpers
func _set_amount_label() -> void:
	craft_amount_label.text = HelperFunctions.return_amount_shorthand(
		craft_data.craft_amount * amount
	)
