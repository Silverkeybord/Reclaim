class_name turret_slot

extends Node3D

const empty_tres: String = "res://textures_and_materials/turrets/turret_position_slot.tres"
const base_tres: String = "res://textures_and_materials/turrets/normal_turret_base.tres"

const turret_scenes := {
	"single": preload("res://scenes/turrets/1/single.tscn"),
	"dual": preload("res://scenes/turrets/1/dual.tscn")
}
const base_scenes := {
	"plate": preload("res://scenes/bases/plate.tscn")
}

@export var turret_place_cooldown: Timer
@export var base_place_cooldown: Timer

@export var turret_origin_point: Marker3D
@export var mesh: MeshInstance3D
@export var current_turret: String
@export var current_base: String
@export var unlocked := false

var base: Node
var turret: Node
var can_place_turret := true
var can_place_base := true


func place_selected_turret(turret_type: String) -> bool:
	if (
		not can_place_turret
		or not unlocked
		or not is_instance_valid(base)
		or turret_place_cooldown == null
		or turret_origin_point == null
	):
		return false
	
	if not turret_scenes.has(turret_type):
		push_error("Turret not found in array when placed: %s" % turret_type)
		return false
	
	can_place_turret = false
	
	current_turret = turret_type
	
	turret_place_cooldown.start()
	
	if is_instance_valid(turret) and turret.has_method(&"pick_up"):
		turret.call(&"pick_up")
	
	var turret_scene: PackedScene = turret_scenes[current_turret]
	var new_turret := turret_scene.instantiate() as Node3D
	if new_turret == null or not HelperFunctions.add_to_root_node(new_turret):
		if new_turret:
			new_turret.queue_free()
		turret = null
		can_place_turret = true
		return false

	turret = new_turret
	new_turret.global_position = turret_origin_point.global_position
	new_turret.global_rotation = turret_origin_point.global_rotation
	return true


func build_base(base_type: String) -> bool:
	if not can_place_base or not unlocked or base_place_cooldown == null or mesh == null:
		return false
	
	if not base_scenes.has(base_type):
		push_error("Base not found in array when placed: %s" % base_type)
		return false
	
	can_place_base = false
	
	current_base = base_type
	
	if is_instance_valid(base) and base.has_method(&"pick_up"):
		base.call(&"pick_up")
	
	var base_scene: PackedScene = base_scenes[base_type]
	var new_base := base_scene.instantiate() as Node3D
	if new_base == null:
		can_place_base = true
		return false

	new_base.set(&"slot", self)
	if not HelperFunctions.add_to_root_node(new_base):
		new_base.queue_free()
		base = null
		can_place_base = true
		return false

	base = new_base
	new_base.global_position = global_position
	new_base.global_rotation = global_rotation
	
	mesh.visible = false
	
	base_place_cooldown.start()
	return true


func base_removed() -> void:
	if mesh:
		mesh.visible = true


func _on_turret_place_cooldown_timeout() -> void:
	can_place_turret = true
	
	if is_instance_valid(turret):
		turret.set(&"place_cooldown_active", false)


func _on_base_place_cooldown_timeout() -> void:
	can_place_base = true
