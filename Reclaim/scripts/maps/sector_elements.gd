class_name SectorElements
extends Node3D

const SHIP_SCENE := preload("res://scenes/ship.tscn")

const SECTOR_NAME_DELAY : float = 5.5
const SHOW_TWEEN_TIME : float = 0.5
const TIME_VISIBLE : float = 2.5
const NORMAL_MODULATE := Color(1, 1, 1, 1)
const HIDDEN_MODULATE := Color(1, 1, 1, 0)
const PROP_MODULATE := "modulate"

const RESET_ANIMATION : StringName = &"RESET"
const LANDING_ANIMATION : StringName = &"landing"
const EXTRACTING_ANIMATION : StringName = &"extracting"
const OVERDRIVE_ANIMATION : StringName = &"shield_overdrive"
const INTERACT_INPUT : StringName = &"interact"

@export var sector_name : String

@export var sector_element_animation : AnimationPlayer
@export var sector_name_label : Label
@export var animation_camera : Camera3D
@export var skip_label : Label

@export var shield_shader : Resource

@export_group("Elements")
@export var player : CharacterBody3D
@export var extraction_pod : StaticBody3D
@export var sector_shield : SectorShield


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	start_animation(RESET_ANIMATION)
	sector_name_label.text = sector_name
	sector_name_label.visible = true
	start_animation(LANDING_ANIMATION)
	
	await get_tree().create_timer(SECTOR_NAME_DELAY).timeout
	
	var show_tween = create_tween()
	show_tween.tween_property(sector_name_label, PROP_MODULATE, NORMAL_MODULATE, SHOW_TWEEN_TIME)
	
	await get_tree().create_timer(TIME_VISIBLE).timeout
	
	show_tween = create_tween()
	show_tween.tween_property(sector_name_label, PROP_MODULATE, HIDDEN_MODULATE, SHOW_TWEEN_TIME)
	
	await show_tween.finished
	
	sector_name_label.visible = false


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed(INTERACT_INPUT) and Global.major_animation_playing:
		Global.major_animation_playing = false
		
		if sector_element_animation.current_animation == LANDING_ANIMATION:
			sector_element_animation.play(RESET_ANIMATION)
			sector_element_animation.stop()
			
			animation_camera.current = false
			sector_shield.run_ui.visible = true
			sector_name_label.visible = false
			skip_label.visible = false
			
			set_process(false)
			
		elif sector_element_animation.current_animation == EXTRACTING_ANIMATION:
			sector_element_animation.play(RESET_ANIMATION)
			sector_element_animation.stop()
			
			skip_label.visible = false
			
			set_process(false)
			
			change_to_ship()


func _on_sector_elements_animations_animation_finished(anim_name: StringName) -> void:
	set_process(false)
	skip_label.visible = false
	
	if anim_name == LANDING_ANIMATION:
		Global.major_animation_playing = false
		sector_shield.run_ui.visible = true
	
	elif anim_name == EXTRACTING_ANIMATION:
		Global.major_animation_playing = false
		change_to_ship()


func extract_animation() -> void:
	start_animation(EXTRACTING_ANIMATION)


func start_animation(animation_name : StringName) -> void:
	if animation_name == RESET_ANIMATION:
		return
	
	Global.major_animation_playing = true
	skip_label.visible = true
	sector_shield.run_ui.visible = false
	set_process(true)
	sector_element_animation.play(animation_name)


func change_to_ship() -> void:
	Global.at_ship = true
	get_tree().change_scene_to_packed(SHIP_SCENE)


func start_overdrive() -> void:
	sector_element_animation.play(OVERDRIVE_ANIMATION)
