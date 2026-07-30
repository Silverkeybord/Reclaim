extends Control

const EXTRACTING_TEXT := "extracting in : "

const HIT_LERP_WEIGHT := 0.5
const HEAL_LERP_WEIGHT := 0.3
const HIT_FLASH_COLOR := Color("ffffffff")
const HEAL_FLAHS_COLOR := Color("00ff00ff")
const FLASH_TIME := 0.05
const MODULATE_PROPERTY := "modulate"

const BLUE_HEALTH_COLOR := Color("afffffff")
const GREEN_HEALTH_COLOR := Color("B9FFAF")
const YELLOW_HEALTH_COLOR := Color("FFFF88")
const ORANGE_HEALTH_COLOR := Color("FFBA7E")
const RED_HEALTH_COLOR := Color("FF7E7E")
const EXTRACTING_COLOR := Color("E33131")

const HEALTH_BAR_COLOR_MARKS := {
	0.0 : EXTRACTING_COLOR,
	0.1 : RED_HEALTH_COLOR,
	0.3 : ORANGE_HEALTH_COLOR,
	0.5 : YELLOW_HEALTH_COLOR,
	0.8 : GREEN_HEALTH_COLOR,
	1.0 : BLUE_HEALTH_COLOR,
}

const RUN_TIME_TEXT := "Run time :  "

const SMALL_SEGMENT := preload("res://2d_assets/shield/side_segment.png")
const TALL_SEGMENT := preload("res://2d_assets/shield/tall_segment.png")
const EMPTY_SMALL_SEGMENT := preload("res://2d_assets/shield/empty_side_segment.png")
const EMPTY_TALL_SEGMENT := preload("res://2d_assets/shield/empty_tall_segment.png")

@export var shield : SectorShield

@export var run_time_label : Label
@export var shield_health_label : Label
@export var extraction_timer_label : Label
@export var show_health_timer : Timer

@export var health_change_indicator : PackedScene
@export var max_indicatoin_marker : Marker2D
@export var min_indicatoin_marker : Marker2D

@export_group("Segment Controls")
@export var all_segment_control : Control
@export var left_small : Control
@export var right_small : Control
@export var left_tall : Control
@export var right_tall : Control

var texture_rect_percentage_lookup := {
	0.9 : {},
	0.8 : {},
	0.7 : {},
	0.6 : {},
	0.5 : {},
	0.4 : {},
	0.3 : {},
	0.2 : {},
	0.1 : {},
}


func _ready() -> void:
	var child_index := 0
	var left_small_segments = left_small.get_children()
	var right_small_segments = right_small.get_children()
	
	for decimal in texture_rect_percentage_lookup:
		texture_rect_percentage_lookup[decimal] = {
			"left" : left_small_segments[child_index],
			"right" : right_small_segments[child_index]
		}
		child_index += 1


func _process(_delta: float) -> void:
	run_time_label.text = RUN_TIME_TEXT + str(int(round(Global.sector_run_time)))
	
	var current_health := HelperFunctions.return_amount_shorthand(shield.shield_health) 
	var max_health = HelperFunctions.return_amount_shorthand(shield.max_shield_health) 
	
	shield_health_label.text = (current_health + " / " + max_health)
	
	if shield.shield_overdrive:
		extraction_timer_label.text = (
			EXTRACTING_TEXT + str(int(ceil(shield.overdrive_timer.time_left)))
			)


func update_visuals(change : float, is_damage := true) -> void:
	var ratio = clampf(shield.shield_health / shield.max_shield_health, 0.0, 1.0)
	
	var marks := HEALTH_BAR_COLOR_MARKS.keys()
	
	var from_ratio : float = marks[0]
	var to_ratio : float = marks[marks.size() - 1]
	var from_color : Color = HEALTH_BAR_COLOR_MARKS[from_ratio]
	var to_color : Color = HEALTH_BAR_COLOR_MARKS[to_ratio]

	for index in range(marks.size() - 1):
		var current: float = marks[index]
		var next: float = marks[index + 1]
		
		if ratio >= current and ratio <= next:
			from_ratio = current
			to_ratio = next
			from_color = HEALTH_BAR_COLOR_MARKS[current]
			to_color = HEALTH_BAR_COLOR_MARKS[next]
			break
	
	var inbetween_ratio := 0.0
	if to_ratio > from_ratio:
		inbetween_ratio = (ratio - from_ratio) / (to_ratio - from_ratio)
	
	all_segment_control.modulate = from_color.lerp(to_color, inbetween_ratio)
	
	for segment_decimal in texture_rect_percentage_lookup:
		for side in texture_rect_percentage_lookup[segment_decimal]:
			if ratio < segment_decimal:
				texture_rect_percentage_lookup[segment_decimal][side].texture = EMPTY_SMALL_SEGMENT
			else:
				texture_rect_percentage_lookup[segment_decimal][side].texture = SMALL_SEGMENT
	
	if is_damage:
		_hit_flash()
	else:
		_heal_flash()
	
	_make_health_indicator(change, is_damage)


func _hit_flash() -> void:
	var hit_tween = create_tween()
	var original_color = all_segment_control.modulate
	var target_color = lerp(original_color, HIT_FLASH_COLOR, HIT_LERP_WEIGHT)
	
	hit_tween.tween_property(all_segment_control, MODULATE_PROPERTY, target_color, FLASH_TIME)
	hit_tween.tween_property(all_segment_control, MODULATE_PROPERTY, original_color, FLASH_TIME)
	
	if not shield.shield_overdrive:
		run_time_label.visible = false
		shield_health_label.visible = true
	
	show_health_timer.start()


func _heal_flash() -> void:
	var hit_tween = create_tween()
	var original_color = all_segment_control.modulate
	var target_color = lerp(original_color, HEAL_FLAHS_COLOR, HEAL_LERP_WEIGHT)
	
	hit_tween.tween_property(all_segment_control, "modulate", target_color, FLASH_TIME)
	hit_tween.tween_property(all_segment_control, "modulate", original_color, FLASH_TIME)
	
	run_time_label.visible = false
	shield_health_label.visible = true
	
	show_health_timer.start()


func _on_show_health_timer_timeout() -> void:
	if not shield.shield_overdrive:
		run_time_label.visible = true
		shield_health_label.visible = false


func _make_health_indicator(change : float, is_damage := true) -> void:
	if shield.shield_overdrive:
		return
	
	var new_indicator = health_change_indicator.instantiate()
	add_child(new_indicator)
	
	new_indicator.position = Vector2(
		randf_range(min_indicatoin_marker.position.x, max_indicatoin_marker.position.x),
		randf_range(min_indicatoin_marker.position.y, max_indicatoin_marker.position.y)
		)
	
	var change_text = HelperFunctions.return_amount_shorthand(change)
	
	var text = str("-", change_text) if is_damage else str("+", change_text)
	new_indicator.setup(text, is_damage)


func start_overdrive() -> void:
	extraction_timer_label.visible = true
	run_time_label.visible = false
	shield_health_label.visible = false
