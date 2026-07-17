class_name turret_slot

extends Node3D

const empty_tres := "res://textures_and_materials/turrets/turret_position_slot.tres"
const base_tres := "res://textures_and_materials/turrets/normal_turret_base.tres"

const turret_scenes := {
	"single" : preload("res://scenes/turrets/1/single.tscn"),
	"dual" : preload("res://scenes/turrets/1/dual.tscn")
}
const base_scenes := {
 	"plate" : preload("res://scenes/bases/plate.tscn")
}

@export var turret_place_cooldown : Timer
@export var base_place_cooldown : Timer

@export var turret_origin_point : Marker3D
@export var mesh : MeshInstance3D
@export var current_turret : String
@export var current_base : String
@export var unlocked := false

var base : Node
var turret : Node
var can_place_turret := true
var can_place_base := true


func place_selected_turret(turret_type : String) -> void:
	if not can_place_turret or not base:
		return
	
	can_place_turret = false
	
	current_turret = turret_type
	
	if not turret_scenes.has(current_turret):
		push_error("Turret not found in array when placed")
		return
	
	turret_place_cooldown.start()
	
	if turret: 
		turret.pick_up()
	
	var turret_scene = turret_scenes[current_turret]
	turret = turret_scene.instantiate()
	HelperFunctions.add_to_root_node(turret)
	turret.global_position = turret_origin_point.global_position
	turret.global_rotation = turret_origin_point.global_rotation


func build_base(base_type : String) -> void:
	if not can_place_base:
		return
	
	can_place_base = false
	
	current_base = base_type
	
	if base:
		base.pick_up()
	
	base = base_scenes[base_type].instantiate()
	base.slot = self
	HelperFunctions.add_to_root_node(base)
	base.global_position = global_position
	base.global_rotation = global_rotation
	
	mesh.visible = false
	
	base_place_cooldown.start()


func base_removed() -> void:
	mesh.visible = true


func _on_turret_place_cooldown_timeout() -> void:
	can_place_turret = true
	
	if turret:
		turret.place_cooldown_active = false


func _on_base_place_cooldown_timeout() -> void:
	can_place_base = true
