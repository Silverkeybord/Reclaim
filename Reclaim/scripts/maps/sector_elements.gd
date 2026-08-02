extends Node3D

const LANDING_ANIMATION : StringName = &"landing"

@export var sector_element_animation : AnimationPlayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Global.major_animation_playing = true
	sector_element_animation.play(LANDING_ANIMATION)



func _on_sector_elements_animations_animation_finished(anim_name: StringName) -> void:
	if anim_name == LANDING_ANIMATION:
		Global.major_animation_playing = false
