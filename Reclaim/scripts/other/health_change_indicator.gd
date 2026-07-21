extends Label

const DAMAGE_COLOR := Color("ffac9fff")
const HEAL_COLOR := Color("68ff49ff")
const TRANSPARENT_COLOR := Color(1.0, 1.0, 1.0, 0.0)

const MAX_TRAVEL_DISTANCE := 60
const MIN_TRAVEL_DISTANCE := 20
const MAX_LIFE := 2.5
const MIN_LIFE := 1.5
const FADE_TIME := 0.5


func setup(label_text : String, is_damage : bool) -> void:
	HelperFunctions.damage_indications += 1
	
	text = label_text
	
	visible = true
	var new_label_settings = label_settings.duplicate()
	new_label_settings.font_color = DAMAGE_COLOR if is_damage else HEAL_COLOR
	
	label_settings = new_label_settings
	
	var movement_tween = create_tween()
	movement_tween.set_ease(Tween.EASE_OUT)
	var random_offset = randi_range(MIN_TRAVEL_DISTANCE, MAX_TRAVEL_DISTANCE)
	var target_y = position.y + random_offset
	var tween_time = randf_range(MIN_LIFE, MAX_LIFE)
	
	if is_damage:
		movement_tween.tween_property(self, "position", Vector2(position.x, target_y), tween_time)
	else:
		var original_pos = position
		position = Vector2(position.x, target_y)
		
		movement_tween.tween_property(self, "position", original_pos, tween_time)
	
	await get_tree().create_timer(tween_time - FADE_TIME).timeout
	
	var fade_tween = create_tween()
	fade_tween.tween_property(self, "modulate", TRANSPARENT_COLOR, FADE_TIME)
	
	await get_tree().create_timer(FADE_TIME).timeout
	
	HelperFunctions.damage_indications -= 1
	queue_free()
