extends Node3D

const empty_tres := "res://textures_and_materials/turrets/turret_position_slot.tres"
const base_tres := "res://textures_and_materials/turrets/normal_turret_base.tres"


@export var place_cooldown : Timer
@export var turrets_scenes := {
	"basic" : preload("res://scenes/turrets/t1/basic.tscn")
}

@export var turret_origin_point : Marker3D
@export var mesh : MeshInstance3D
@export var current_turret := ""
@export var unlocked := false

var turret : Node
var can_place := true


func place_selected_turret() -> void:
	if not can_place:
		return
	
	if not turrets_scenes.has(current_turret):
		return
	
	can_place = false
	place_cooldown.start()
	
	_remove_current_turret()
	
	var turret_resource = turrets_scenes[current_turret]
	turret = turret_resource.instantiate()
	get_tree().root.get_child(Global.CURRENT_SCENE_ROOT_INDEX).add_child(turret)
	turret.global_position = turret_origin_point.global_position


func build_base() -> void:
	pass


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
