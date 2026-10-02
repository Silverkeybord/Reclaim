class_name CraftQueueItem
extends Control

const INPUT_RIGHT_CLICK: StringName = &"m2"

@export var amount: int
@export var craft_data: CraftData
@export var crafting_ui: CraftingUI
@export var item_notif_controller: ItemNotifController

@export var name_label: Label
@export var craft_timer: Timer
@export var progress_bar: ProgressBar
@export var craft_amount_label: Label
@export var item_texture_rect: TextureRect
@export var progress_panel: PanelContainer

var mouse_in_zone: bool = false
var final_craft_time: float = 0.0


func _ready() -> void:
	if (
		craft_data == null
		or not HelperFunctions.is_valid_item(craft_data.crafted_item)
		or craft_timer == null
	):
		queue_free()
		return

	set_amount_label()
	if name_label:
		name_label.text = HelperFunctions.get_display_name(craft_data.crafted_item.key)
	if item_texture_rect:
		item_texture_rect.texture = craft_data.crafted_item.get_item_texture()
	final_craft_time = craft_data.craft_time # * auth for future progress
	craft_timer.wait_time = final_craft_time
	if progress_bar:
		progress_bar.max_value = final_craft_time


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed(INPUT_RIGHT_CLICK) and mouse_in_zone:
		_cancel_craft()
	
	if progress_bar and craft_timer:
		progress_bar.value = craft_timer.wait_time - craft_timer.time_left


func start_craft() -> void:
	if progress_panel:
		progress_panel.visible = true
	if craft_timer:
		craft_timer.start()


func _cancel_craft() -> void:
	for requirment : RequirementsTemplate in craft_data.requirements:
		if requirment == null or not HelperFunctions.is_valid_item(requirment.item):
			continue

		var refund_amount := requirment.amount * amount
		HelperFunctions.add_item_to_storage(requirment.item, refund_amount)
		if item_notif_controller:
			item_notif_controller.add_notif(requirment.item, refund_amount)
	
	if crafting_ui:
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
	if craft_data == null or not HelperFunctions.is_valid_item(craft_data.crafted_item):
		queue_free()
		return

	HelperFunctions.add_item_to_storage(
		craft_data.crafted_item,
		craft_data.craft_amount,
	)
	
	if item_notif_controller:
		item_notif_controller.add_notif(craft_data.crafted_item, craft_data.craft_amount)
	amount -= 1
	set_amount_label()
	
	if amount <= 0:
		if crafting_ui:
			remove_from_group(crafting_ui.GROUP_CRAFT_QUEUE)
			crafting_ui.queue_next()
		queue_free()


# Helpers
func set_amount_label() -> void:
	if craft_amount_label and craft_data:
		craft_amount_label.text = HelperFunctions.return_amount_shorthand(
			craft_data.craft_amount * amount
		)
