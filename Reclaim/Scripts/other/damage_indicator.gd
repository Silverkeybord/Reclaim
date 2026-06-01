extends Label3D

const FADE_OUT_ANIMATION_TIME := 0.3
const FADE_OUT_ANIMAITON_NAME := "fade_out"

const MAX_RISE := 5.0
const MIN_RISE := 3.0
const HOZ_OFFSET := 3.0
const MAX_LIFE := 1.5
const MIN_LIFE := 1
const MIN_SCALE := 4
const MAX_SCALE := 5

@export var animation_player : AnimationPlayer

@onready var player = get_tree().get_first_node_in_group("player")


func init() -> void:
	var life = randf_range(MIN_LIFE, MAX_LIFE)
	
	var rise_tween = create_tween()
	var end_pos = Vector3(
		randf_range(-HOZ_OFFSET, HOZ_OFFSET), 
		randf_range(MIN_RISE, MAX_RISE), 
		randf_range(-HOZ_OFFSET, HOZ_OFFSET)
	)
	rise_tween.set_ease(Tween.EASE_OUT)
	rise_tween.tween_property(self, "global_position", global_position + end_pos, life)
	
	var scale_tween = create_tween()
	var end_scale = randf_range(MIN_SCALE, MAX_SCALE)
	scale_tween.set_ease(Tween.EASE_OUT)
	scale_tween.tween_property(self, "scale", scale * end_scale, life)
	
	await get_tree().create_timer(life - FADE_OUT_ANIMATION_TIME).timeout
	animation_player.play(FADE_OUT_ANIMAITON_NAME)
	
	await animation_player.animation_finished
	Global.damage_indications -= 1
	queue_free()
