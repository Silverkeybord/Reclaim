extends Control

# Wave State Enum
enum WaveState {
	SPAWNING,
	CLEARING,
	BREATHING,
	SECTOR_CLEARED
}

# Animation
const ANIM_OVERDRIVE: StringName = &"extraction_overdrive"

# Dictionary & Lookup Keys
const KEY_LEFT: StringName = &"left"
const KEY_RIGHT: StringName = &"right"

# UI Text Display
const DAMAGE_PREFIX: String = "-"
const HEAL_PREFIX: String = "+"
const ENEMIES_IN_FORMAT: String = "Enemies in : %d"
const WAVE_END_FORMAT: String = "Wave Ends in : %d"
const ENEMIES_LEFT_FORMAT: String = "Enemies left : %d"
const SECTOR_CLEARED_FORMAT: String = "Sector Cleared"
const EXTRACTING_FORMAT: String = "extracting in : %d"
const WAVE_FORMAT: String = "Wave : %d"
const SHIELD_HEALTH_FORMAT: String = "%d / %d hp"

# Methods
const METHOD_SETUP: StringName = &"setup"

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
@export var wave_label: Label
@export var shield_health_label: Label
@export var extraction_timer_label: Label
@export var wave_stage_label: Label

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

# Wave state variables set by EnemySpawner
var current_wave: int = 1
var current_state: WaveState = WaveState.BREATHING
var phase_time_left: float = 0.0
var enemies_left: int = 0


func _ready() -> void:
	if left_small == null or right_small == null:
		return
	var child_index: int = 0
	var left_small_segments: Array[Node] = left_small.get_children()
	var right_small_segments: Array[Node] = right_small.get_children()
	for decimal in texture_rect_percentage_lookup:
		if child_index >= left_small_segments.size():
			break
		if child_index >= right_small_segments.size():
			break
		texture_rect_percentage_lookup[decimal] = {
			KEY_LEFT: left_small_segments[child_index],
			KEY_RIGHT: right_small_segments[child_index]
		}
		child_index += 1


func _process(_delta: float) -> void:
	if shield == null:
		return
	if wave_label and current_state != WaveState.SECTOR_CLEARED:
		wave_label.text = WAVE_FORMAT % current_wave
	if shield_health_label:
		shield_health_label.text = SHIELD_HEALTH_FORMAT % [
			shield.shield_health,
			shield.max_shield_health
		]
	if shield.shield_overdrive and extraction_timer_label and shield.overdrive_timer:
		extraction_timer_label.text = EXTRACTING_FORMAT % shield.overdrive_timer.time_left
	if wave_stage_label == null:
		return
	match current_state:
		WaveState.BREATHING:
			wave_stage_label.text = ENEMIES_IN_FORMAT % int(phase_time_left)
		WaveState.SPAWNING:
			wave_stage_label.text = WAVE_END_FORMAT % int(phase_time_left)
		WaveState.CLEARING:
			wave_stage_label.text = ENEMIES_LEFT_FORMAT % enemies_left
		WaveState.SECTOR_CLEARED:
			wave_stage_label.text = ENEMIES_LEFT_FORMAT % enemies_left
			if wave_label:
				wave_label.text = SECTOR_CLEARED_FORMAT


# Visual Updates -------------------------------------------------------------
func update_visuals(change: float, is_damage: bool = true) -> void:
	if shield == null or shield.max_shield_health <= 0.0:
		return
	var ratio: float = clampf(shield.shield_health / shield.max_shield_health, 0.0, 1.0)
	if all_segment_control:
		all_segment_control.modulate = _get_health_color(ratio)
	_update_segment_textures(ratio)
	if is_damage:
		_hit_flash()
	else:
		_heal_flash()
	_make_health_indicator(change, is_damage)


func _get_health_color(ratio: float) -> Color:
	# marks must be sorted so the ratio lands in the right segment
	var sorted_marks: Array = HEALTH_BAR_COLOR_MARKS.keys()
	sorted_marks.sort()
	if sorted_marks.is_empty():
		return EXTRACTING_COLOR
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
	return from_color.lerp(to_color, inbetween_ratio)


func _update_segment_textures(ratio: float) -> void:
	for segment_decimal in texture_rect_percentage_lookup:
		var side_dict: Dictionary = texture_rect_percentage_lookup[segment_decimal]
		for side in side_dict:
			var segment_node := side_dict[side] as TextureRect
			if segment_node == null:
				continue
			segment_node.texture = (
				EMPTY_SMALL_SEGMENT if ratio < segment_decimal else SMALL_SEGMENT
			)


func _hit_flash() -> void:
	_flash_segments(HIT_FLASH_COLOR, HIT_LERP_WEIGHT)


func _heal_flash() -> void:
	_flash_segments(HEAL_FLASH_COLOR, HEAL_LERP_WEIGHT)


func _flash_segments(flash_color: Color, lerp_weight: float) -> void:
	if all_segment_control == null:
		return
	var flash_tween: Tween = create_tween()
	var original_color: Color = all_segment_control.modulate
	var target_color: Color = original_color.lerp(flash_color, lerp_weight)
	flash_tween.tween_property(all_segment_control, PROP_MODULATE, target_color, FLASH_TIME)
	flash_tween.tween_property(all_segment_control, PROP_MODULATE, original_color, FLASH_TIME)


func _make_health_indicator(change: float, is_damage: bool = true) -> void:
	if shield and shield.shield_overdrive:
		return
	if (health_change_indicator == null
			or min_indication_marker == null
			or max_indication_marker == null):
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
	if new_indicator.has_method(METHOD_SETUP):
		new_indicator.setup(text, is_damage)


func start_overdrive() -> void:
	if overdrive_animation_player:
		overdrive_animation_player.play(ANIM_OVERDRIVE)
	if extraction_timer_label:
		extraction_timer_label.visible = true
	if wave_label:
		wave_label.visible = false
	if shield_health_label:
		shield_health_label.visible = false
