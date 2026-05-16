extends Node3D

const empty_tres := "res://Textures and Materials/turrets/turret_position_slot.tres"
const base_tres := "res://Textures and Materials/turrets/normal_turret_base.tres"

@export var turret_origin_point : Marker3D
@export var mesh : MeshInstance3D
@export var current_turret := ""
@export var unlocked := false


func place_selected_turret(turret_type: String) -> void:
	pass


func build_base() -> void:
	pass
