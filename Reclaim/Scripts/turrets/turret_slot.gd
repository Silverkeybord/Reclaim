extends Node3D

const empty_tres := "res://Textures and Materials/turrets/turret_position_slot.tres"
const base_tres := "res://Textures and Materials/turrets/normal_turret_base.tres"

@export var turrets_scenes := {
	"basic" : preload("res://Scenes/turrets/T1/basic.tscn")
}

@export var turret_origin_point : Marker3D
@export var mesh : MeshInstance3D
@export var current_turret := ""
@export var unlocked := false

var turret : Node


func place_selected_turret() -> void:
	if turret:
		turret.queue_free()
	
	var turret_resource = turrets_scenes[current_turret]
	turret = turret_resource.instantiate()
	turret_origin_point.add_child(turret)


func build_base() -> void:
	pass
