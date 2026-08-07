extends TextureRect

const TOTAL_FORMAT := "Total : %s"
const TIER_1 := 1
const TIER_2 := 2
const TIER_3 := 3
const TIER_4 := 4
const TIER_5 := 5

const FADE_TWEEN_TIME := 0.5
const PROP_MODULATE : String = "modulate"
const MODULATE_END := Color(1.0, 1.0, 1.0, 0.0)
const MODULATE_NORMAL := Color(1.0, 1.0, 1.0, 1)

@export var extraction_ui : CanvasLayer
@export var selection_menu : PanelContainer
@export var total_weight : Label

@export var hide_timer : Timer

@export_group("Button")
@export var resources_button : Button
@export var turrets_button : Button
@export var modules_button : Button
@export var t1 : Button
@export var t2 : Button
@export var t3 : Button
@export var t4 : Button
@export var t5 : Button

var weight : int

var resources_included := true
var turrets_included := false
var modules_included := false
var tiers_included := {
	TIER_1 : true,
	TIER_2 : true,
	TIER_3 : true,
	TIER_4 : true,
	TIER_5 : true,
}


func update_weight_label() -> void:
	weight = 0
	
	for tier in Global.sector_storage:
		if tiers_included[tier]:
			for item_name in Global.sector_storage[tier]:
				var item_data : ItemData = DataRegistry.items[item_name]
				var item_amount : int = 0
				var item_weight : int = 0
				
				match item_data.type:
					Global.ITEM_TYPES.RESOURCES:
						if not resources_included:
							continue
					Global.ITEM_TYPES.TURRET, Global.ITEM_TYPES.BASE:
						if not turrets_included:
							continue
					Global.ITEM_TYPES.MODULE:
						if not modules_included:
							continue
				
				item_amount = Global.sector_storage[tier][item_data.key]
				item_weight = DataRegistry.items[item_data.key].weight
				weight += item_amount * item_weight
	
	total_weight.text = TOTAL_FORMAT % HelperFunctions.return_amount_shorthand(weight)


# total displayed weight filtering --------------------------------------------
func _on_toggle_resources_pressed() -> void:
	resources_included = not resources_button.button_pressed
	update_weight_label()


func _on_toggle_turrets_pressed() -> void:
	turrets_included = not turrets_button.button_pressed
	update_weight_label()


func _on_toggle_modules_pressed() -> void:
	modules_included = not modules_button.button_pressed
	update_weight_label()


func _on_t_1_pressed() -> void:
	tiers_included[TIER_1] = not t1.button_pressed
	update_weight_label()


func _on_t_2_pressed() -> void:
	tiers_included[TIER_2] = not t2.button_pressed
	update_weight_label()


func _on_t_3_pressed() -> void:
	tiers_included[TIER_3] = not t3.button_pressed
	update_weight_label()


func _on_t_4_pressed() -> void:
	tiers_included[TIER_4] = not t4.button_pressed
	update_weight_label()


func _on_t_5_pressed() -> void:
	tiers_included[TIER_5] = not t5.button_pressed
	update_weight_label()


func _on_mouse_entered() -> void:
	selection_menu.visible = true
	selection_menu.modulate = MODULATE_NORMAL
	
	if not hide_timer.is_stopped():
		hide_timer.stop()


func _on_mouse_exited() -> void:
	hide_timer.start()


func _on_timer_timeout() -> void:
	var fade_tween = create_tween()
	fade_tween.tween_property(selection_menu, PROP_MODULATE, MODULATE_END, FADE_TWEEN_TIME)
	await fade_tween.finished
	
	selection_menu.visible = false


func _on_selction_menu_mouse_entered() -> void:
	if not hide_timer.is_stopped():
		hide_timer.stop()


func _on_selction_menu_mouse_exited() -> void:
	if hide_timer.is_stopped():
		hide_timer.start()
