extends Node3D

const VALID_MAT := preload("res://textures_and_materials/building/valid_holagram_placement.tres")
const INVALID_MAT := preload("res://textures_and_materials/building/invalid_holagram_placement.tres")

@export var turret_holagram : MeshInstance3D
@export var base_holagram : MeshInstance3D
@export var valid_position := false


func _process(_delta: float) -> void:
	var active_holagram : MeshInstance3D
	
	match Global.current_build_mode:
		Global.BUILD_MODES.TURRET:
			active_holagram = turret_holagram
			base_holagram.visible = false
			turret_holagram.visible = true
		
		Global.BUILD_MODES.BASE:
			active_holagram = base_holagram
			base_holagram.visible = true
			turret_holagram.visible = false
	
	if valid_position:
		active_holagram.set_surface_override_material(0, VALID_MAT)
	else:
		active_holagram.set_surface_override_material(0, INVALID_MAT)
