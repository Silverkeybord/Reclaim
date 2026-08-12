extends PanelContainer
# life time is set in the timer

const FADE_TIME := 0.5
const MODULATE_A_PROPERTY := "modulate:a"

const TEXT_FORMATTING := "+%dx"

@export var notif_controller : Control

@export var item_data : ItemData
@export var amount_label : Label
@export var item_name_label : Label
@export var texture_rect : TextureRect
@export var life_timer : Timer

var item_amount : int = 1
var fade_tween : Tween


func _ready() -> void:
	texture_rect.texture = item_data.get_item_texture()
	amount_label.text = TEXT_FORMATTING % item_amount
	item_name_label.text = HelperFunctions.get_display_name(item_data.key)
	item_name_label.label_settings = Global.TIER_CONFIG[item_data.tier][Global.KEY_FONT]
	life_timer.start()


func item_pick_up() -> void:
	item_amount += 1
	amount_label.text = TEXT_FORMATTING % item_amount
	life_timer.start()


func _on_life_timer_timeout() -> void:
	notif_controller.remove_notif(item_data)
	fade_tween = create_tween()
	fade_tween.tween_property(self, MODULATE_A_PROPERTY, 0.0, FADE_TIME)
	await fade_tween.finished
	
	queue_free()
