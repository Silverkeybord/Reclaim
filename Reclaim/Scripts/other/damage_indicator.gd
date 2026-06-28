extends Label3D

const NORMAL_COLOR := Color(1.0, 0.514, 0.447)
const CRITICAL_COLOR := Color(1.0, 0.26, 0.199, 1.0)

const FADE_OUT_ANIMATION_TIME := 0.3
const FADE_OUT_ANIMAITON_NAME := "fade_out"

const MAGNITUDE_SCALE_MULT := 0.2
const MAGNITUDE_POS_MULT := 0.5

const MAX_TOTAL_SCALE := 10
const MAX_TOTAL_POS := 10

const MAX_RISE := 3.5
const MIN_RISE := 2.0
const HOZ_OFFSET := 3.0
const MAX_LIFE := 1.5
const MIN_LIFE := 1
const MIN_SCALE := 3
const MAX_SCALE := 4

@export var animation_player : AnimationPlayer
@export var crit : bool
@export var color : Color
@export var damage : float

@onready var player = get_tree().get_first_node_in_group("player")


func init() -> void:
	text = "-" + Global.comma_number(round(damage))
	
	var magnitude : int = (
		floori(log(damage) / log(Global.ORDER_OF_MAGNITUDE) 
		+ Global.SHORT_HAND_NUDGE)
		)
	var life = randf_range(MIN_LIFE, MAX_LIFE)
	
	var rise_tween = create_tween()
	var end_pos = Vector3(
		randf_range(-HOZ_OFFSET, HOZ_OFFSET), 
		randf_range(MIN_RISE, MAX_RISE) + (magnitude * MAGNITUDE_POS_MULT), 
		randf_range(-HOZ_OFFSET, HOZ_OFFSET)
	)
	rise_tween.set_ease(Tween.EASE_OUT)
	rise_tween.tween_property(self, "global_position", global_position + end_pos, life)
	
	if color:
		modulate = color
	else:
		if crit:
			modulate = CRITICAL_COLOR
		else:
			modulate = NORMAL_COLOR
	
	# scale tweening =========================================================
	var scale_tween = create_tween()
	var end_scale = randf_range(MIN_SCALE, MAX_SCALE) + (magnitude * MAGNITUDE_SCALE_MULT)
	scale_tween.set_ease(Tween.EASE_OUT)
	scale_tween.tween_property(self, "scale", scale * end_scale, life)
	
	await get_tree().create_timer(life - FADE_OUT_ANIMATION_TIME).timeout
	animation_player.play(FADE_OUT_ANIMAITON_NAME)
	
	await animation_player.animation_finished
	Global.damage_indications -= 1
	queue_free()
