extends Control

# Tween Properties & Animations
const ANIM_OVERDRIVE: StringName = &"extraction_overdrive"

# Dictionary & Lookup Keys
const KEY_LEFT: StringName = &"left"
const KEY_RIGHT: StringName = &"right"

# UI Text Display
const DAMAGE_PREFIX: String = "-"
const HEAL_PREFIX: String = "+"
const ENEMIES_IN_FORMAT: String = "Enemies in : %d"
const WAVE_END_FORMAT: String = "Wave End in : %d"
const EXTRACTING_FORMAT: String = "extracting in : %d"
const RUN_TIME_FORMAT: String = "Run time : %d"
const SHIELD_HEALTH_FORMAT: String = "%d / %d hp"

# Visual Tweens & Flash Timing
const PROP_MODULATE: String = "modulate"
const HIT_LERP_WEIGHT: float = 0.5
const HEAL_LERP_WEIGHT: float = 0.3
const FLASH_TIME: float = 0.05

const HIT_FLASH_COLOR: Color = Color(1.0, 1.0, 1.0, 1.0)
const HEAL_FLASH_COLOR: Color = Color(0.0, 1.0, 0.0, 1.0)

const BLUE_HEALTH_COLOR: Color = Color("afffffff")
const GREEN_HEALTH_COLOR: Color = Color("B9FFAF")
const YELLOW_HEALTH_COLOR: Color = Color("FFFF88")
const ORANGE_HEALTH_COLOR: Color = Color("FFBA7E")
const RED_HEALTH_COLOR: Color = Color("FF7E7E")
const EXTRACTING_COLOR: Color = Color("E33131")

const HEALTH_BAR_COLOR_MARKS: Dictionary = {
	0.0: EXTRACTING_COLOR,
	0.1: RED_HEALTH_COLOR,
	0.3: ORANGE_HEALTH_COLOR,
	0.5: YELLOW_HEALTH_COLOR,
	0.8: GREEN_HEALTH_COLOR,
	1.0: BLUE_HEALTH_COLOR,
}

# Assets
const SMALL_SEGMENT: CompressedTexture2D = preload("res://2d_assets/shield/side_segment.png")
const TALL_SEGMENT: CompressedTexture2D = preload("res://2d_assets/shield/tall_segment.png")
const EMPTY_SMALL_SEGMENT: CompressedTexture2D = preload(
	"res://2d_assets/shield/empty_side_segment.png"
	)
const EMPTY_TALL_SEGMENT: CompressedTexture2D = preload(
	"res://2d_assets/shield/empty_tall_segment.png"
	)


# Exports ---------------------------------------------------------------------
@export var shield: SectorShield

@export_group("Labels & Timers")
@export var run_time_label: Label
@export var shield_health_label: Label
@export var extraction_timer_label: Label
@export var wave_stage_label: Label
@export var wave_stage_timer: Timer

@export_group("Indicators")
@export var health_change_indicator: PackedScene
@export var max_indication_marker: Marker2D
@export var min_indication_marker: Marker2D

@export_group("Animations")
@export var overdrive_animation_player: AnimationPlayer

@export_group("Segment Controls")
@export var all_segment_control: Control
@export var left_small: Control
@export var right_small: Control
@export var left_tall: Control
@export var right_tall: Control

var texture_rect_percentage_lookup: Dictionary = {
	0.9: {},
	0.8: {},
	0.7: {},
	0.6: {},
	0.5: {},
	0.4: {},
	0.3: {},
	0.2: {},
	0.1: {},
}
# This value is set by enemy_spawner trough sector elements as that is where
# the sectors wave data is set
var wave_stages : Array[Array]
var stage_index := 0
var wave_stage_format : String = ENEMIES_IN_FORMAT


func _ready() -> void:
	if left_small == null or right_small == null:
		return
	
	var child_index: int = 0
	var left_small_segments: Array[Node] = left_small.get_children()
	var right_small_segments: Array[Node] = right_small.get_children()
	
	for decimal in texture_rect_percentage_lookup:
		if child_index < left_small_segments.size() and child_index < right_small_segments.size():
			texture_rect_percentage_lookup[decimal] = {
				KEY_LEFT: left_small_segments[child_index],
				KEY_RIGHT: right_small_segments[child_index]
			}
			child_index += 1
	
	print(wave_stages)


func _process(_delta: float) -> void:
	if shield == null:
		return
	
	if run_time_label:
		run_time_label.text = RUN_TIME_FORMAT % Global.sector_run_time
	
	if shield_health_label:
		shield_health_label.text = SHIELD_HEALTH_FORMAT % [
			shield.shield_health, shield.max_shield_health
			]
	
	if shield.shield_overdrive and extraction_timer_label and shield.overdrive_timer:
		extraction_timer_label.text = EXTRACTING_FORMAT % shield.overdrive_timer.time_left
	
	if (
		wave_stages[stage_index][WaveData.INDEX_TIME] < Global.sector_run_time and 
		stage_index < wave_stages.size() - 1
	):
		var last_stage = wave_stages[stage_index]
		stage_index += 1
		var stage = wave_stages[stage_index]
		
		var wait_time = stage[WaveData.INDEX_TIME] - last_stage[WaveData.INDEX_TIME]
		
		if wave_stage_timer:
			wave_stage_timer.start(wait_time)
		
		wave_stage_format = WAVE_END_FORMAT
		if wave_stages[stage_index][WaveData.INDEX_IS_BREATHING]:
			wave_stage_format = ENEMIES_IN_FORMAT
	
	wave_stage_label.text = wave_stage_format % wave_stage_timer.time_left


# Visual Updates -------------------------------------------------------------
func update_visuals(change: float, is_damage: bool = true) -> void:
	if shield == null or shield.max_shield_health <= 0.0:
		return
	
	var ratio: float = clampf(shield.shield_health / shield.max_shield_health, 0.0, 1.0)
	
	# sorts the cells by interger name values
	var sorted_marks: Array = HEALTH_BAR_COLOR_MARKS.keys()
	sorted_marks.sort()
	
	var from_ratio: float = sorted_marks[0]
	var to_ratio: float = sorted_marks[sorted_marks.size() - 1]
	var from_color: Color = HEALTH_BAR_COLOR_MARKS[from_ratio]
	var to_color: Color = HEALTH_BAR_COLOR_MARKS[to_ratio]
	
	for index in range(sorted_marks.size() - 1):
		var current: float = sorted_marks[index]
		var next: float = sorted_marks[index + 1]
		
		if ratio >= current and ratio <= next:
			from_ratio = current
			to_ratio = next
			from_color = HEALTH_BAR_COLOR_MARKS[current]
			to_color = HEALTH_BAR_COLOR_MARKS[next]
			break
	
	var inbetween_ratio: float = 0.0
	if to_ratio > from_ratio:
		inbetween_ratio = (ratio - from_ratio) / (to_ratio - from_ratio)
	
	if all_segment_control:
		all_segment_control.modulate = from_color.lerp(to_color, inbetween_ratio)
	
	for segment_decimal in texture_rect_percentage_lookup:
		var side_dict: Dictionary = texture_rect_percentage_lookup[segment_decimal]
		for side in side_dict:
			var segment_node:= side_dict[side] as TextureRect
			if segment_node:
				segment_node.texture = EMPTY_SMALL_SEGMENT if ratio < segment_decimal else SMALL_SEGMENT
	
	if is_damage:
		_hit_flash()
	else:
		_heal_flash()
	
	_make_health_indicator(change, is_damage)


func _hit_flash() -> void:
	if all_segment_control == null:
		return
	
	var hit_tween: Tween = create_tween()
	var original_color: Color = all_segment_control.modulate
	var target_color: Color = original_color.lerp(HIT_FLASH_COLOR, HIT_LERP_WEIGHT)
	
	hit_tween.tween_property(all_segment_control, PROP_MODULATE, target_color, FLASH_TIME)
	hit_tween.tween_property(all_segment_control, PROP_MODULATE, original_color, FLASH_TIME)


func _heal_flash() -> void:
	if all_segment_control == null:
		return
	
	var heal_tween: Tween = create_tween()
	var original_color: Color = all_segment_control.modulate
	var target_color: Color = original_color.lerp(HEAL_FLASH_COLOR, HEAL_LERP_WEIGHT)
	
	heal_tween.tween_property(all_segment_control, PROP_MODULATE, target_color, FLASH_TIME)
	heal_tween.tween_property(all_segment_control, PROP_MODULATE, original_color, FLASH_TIME)


func _make_health_indicator(change: float, is_damage: bool = true) -> void:
	if shield and shield.shield_overdrive:
		return
	
	if health_change_indicator == null or min_indication_marker == null or max_indication_marker == null:
		return
	
	var new_indicator: Node = health_change_indicator.instantiate()
	add_child(new_indicator)
	
	if new_indicator is Control or new_indicator is Node2D:
		new_indicator.position = Vector2(
			randf_range(min_indication_marker.position.x, max_indication_marker.position.x),
			randf_range(min_indication_marker.position.y, max_indication_marker.position.y)
		)
	
	var change_text: String = HelperFunctions.return_amount_shorthand(change)
	var text: String = (DAMAGE_PREFIX if is_damage else HEAL_PREFIX) + change_text
	
	if new_indicator.has_method(&"setup"):
		new_indicator.setup(text, is_damage)


func start_overdrive() -> void:
	if overdrive_animation_player:
		overdrive_animation_player.play(ANIM_OVERDRIVE)
	
	if extraction_timer_label:
		extraction_timer_label.visible = true
	if run_time_label:
		run_time_label.visible = false
	if shield_health_label:
		shield_health_label.visible = false
