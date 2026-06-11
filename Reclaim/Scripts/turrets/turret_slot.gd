extends Node3D

const empty_tres := "res://textures_and_materials/turrets/turret_position_slot.tres"
const base_tres := "res://textures_and_materials/turrets/normal_turret_base.tres"

const turret_scenes := {
	"basic" : preload("res://scenes/turrets/t1/basic.tscn")
}
const base_scenes := {
	"basic" : preload("res://scenes/turrets/turret_base.tscn")
}

@export var place_cooldown : Timer

@export var turret_origin_point : Marker3D
@export var mesh : MeshInstance3D
@export var current_turret : String
@export var current_base : String
@export var unlocked := false

var base
var turret : Node
var can_place := true


func place_selected_turret(turret_type : String) -> void:
	if not can_place:
		return
	
	current_turret = turret_type
	
	if not base_scenes.has(current_turret):
		print("missing turret value")
		return
	
	can_place = false
	place_cooldown.start()
	
	_remove_current_turret()
	
	var turret_resource = turret_scenes[current_turret]
	turret = turret_resource.instantiate()
	get_tree().root.get_child(Global.CURRENT_SCENE_ROOT_INDEX).add_child(turret)
	turret.global_position = turret_origin_point.global_position
	turret.global_rotation = turret_origin_point.global_rotation


func build_base(base_type : String) -> void:
	if not can_place:
		return
	
	current_base = base_type
	
	if base:
		base.queue_free()
	
	base = base_scenes[base_type].instantiate()
	get_tree().root.get_child(Global.CURRENT_SCENE_ROOT_INDEX).add_child(base)
	base.global_position = global_position
	base.global_rotation = global_rotation
	
	mesh.visible = false


func _on_place_cooldown_timeout() -> void:
	can_place = true
	
	if turret:
		turret.place_cooldown_active = false


func _remove_current_turret() -> void:
	if turret == null:
		return
	
	var range_area = turret.get("turret_range_area") as TurretRangeArea
	
	# Stop the range Area3D before freeing the turret to avoid stale Jolt events.
	if range_area:
		range_area.monitoring = false
		range_area.monitorable = false
		range_area.in_range_enemies.clear()
	
	turret.queue_free()
	turret = null
