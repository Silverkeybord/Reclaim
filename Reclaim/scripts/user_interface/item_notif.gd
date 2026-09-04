extends PanelContainer
# life time is set in the timer

const ADD_LABEL_SETTINGS := preload(
	"res://other_assets/label_settings/notif_colors/add_notif.tres"
	)
const MINUS_LABEL_SETTINGS := preload(
	"res://other_assets/label_settings/notif_colors/minus_notif.tres"
	)

const FADE_TIME := 0.5
const MODULATE_A_PROPERTY := "modulate:a"

const ADD_FORMATTING := "+%dx"
const MINUS_FORMATTING := "%dx"

@export var notif_controller : Control

@export var item_data : ItemData
@export var amount_label : Label
@export var item_name_label : Label
@export var texture_rect : TextureRect
@export var life_timer : Timer
@export var item_amount : int = 1

var fade_tween : Tween


func _ready() -> void:
	texture_rect.texture = item_data.get_item_texture()
	_set_amount_label_text()
	item_name_label.text = HelperFunctions.get_display_name(item_data.key)
	item_name_label.label_settings = Global.TIER_CONFIG[item_data.tier][Global.KEY_FONT]
	life_timer.start()


func item_pick_up(amount : int) -> void:
	item_amount += amount
	
	if amount < 0 and item_amount > 0 or amount > 0 and item_amount < 0:
		item_amount = 0
		item_amount += amount
	elif item_amount == 0:
		_on_life_timer_timeout()
	
	_set_amount_label_text()
	life_timer.start()


func _set_amount_label_text() -> void:
	var final_formatting := ADD_FORMATTING
	var final_label_settings := ADD_LABEL_SETTINGS
	
	if item_amount < 0:
		final_formatting = MINUS_FORMATTING
		final_label_settings = MINUS_LABEL_SETTINGS
	
	amount_label.label_settings = final_label_settings
	amount_label.text = final_formatting % item_amount


func _on_life_timer_timeout() -> void:
	notif_controller.remove_notif(item_data)
	fade_tween = create_tween()
	fade_tween.set_ignore_time_scale(true)
	fade_tween.tween_property(self, MODULATE_A_PROPERTY, 0.0, FADE_TIME)
	await fade_tween.finished
	
	queue_free()
