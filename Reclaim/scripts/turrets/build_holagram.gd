extends Node3D

const valid_color := Color(0.0, 0.431, 0.871, 0.506)
const invalid_color := Color(0.813, 0.0, 0.412, 0.506)

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
		active_holagram.get_surface_override_material(0).albedo_color = valid_color
	else:
		active_holagram.get_surface_override_material(0).albedo_color = invalid_color
