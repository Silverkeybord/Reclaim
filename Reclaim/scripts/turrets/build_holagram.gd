extends Node3D

const VALID_MAT := preload("res://textures_and_materials/building/valid_holagram_placement.tres")
const INVALID_MAT := preload("res://textures_and_materials/building/invalid_holagram_placement.tres")

@export var turret_holagram: MeshInstance3D
@export var base_holagram: MeshInstance3D

var valid_position := false
var current_item_type: int = -1


func _process(_delta: float) -> void:
	var active_holagram: MeshInstance3D = null
	
	match current_item_type:
		Global.ITEM_TYPES.TURRET:
			active_holagram = turret_holagram
			base_holagram.visible = false
			turret_holagram.visible = true
		
		Global.ITEM_TYPES.BASE:
			active_holagram = base_holagram
			base_holagram.visible = true
			turret_holagram.visible = false
		
		# this is a else for matching
		_:
			# Failsafe: hide both if the type is invalid or empty
			base_holagram.visible = false
			turret_holagram.visible = false
			return
	
	if active_holagram:
		if valid_position:
			active_holagram.set_surface_override_material(0, VALID_MAT)
		else:
			active_holagram.set_surface_override_material(0, INVALID_MAT)
