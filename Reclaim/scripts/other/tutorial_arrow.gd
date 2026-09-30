extends Node3D

const MAX_VERTICLE_ANGLE := PI / 4
const MIN_DISTANCE := 10.0

@export var indicator: Node3D
@export var lerp_power: float = 5.0

@onready var player: Player = get_tree().get_first_node_in_group(Global.GROUP_PLAYER)


# Looks at the player easeing with lerping and if in a min distance will stay straight
func _process(delta: float) -> void:
	if indicator == null or not is_instance_valid(player):
		return
	
	var target_transform := indicator.global_transform.looking_at(
		player.global_position,
		Vector3.UP)
	var target_rotation := target_transform.basis.get_euler()
	
	var target_x := 0.0
	var target_z := 0.0
	
	if indicator.global_position.distance_to(player.global_position) > MIN_DISTANCE:
		target_x = clamp(target_rotation.x, -MAX_VERTICLE_ANGLE, MAX_VERTICLE_ANGLE)
		target_z = clamp(target_rotation.z, -MAX_VERTICLE_ANGLE, MAX_VERTICLE_ANGLE)
	
	var target_y := target_rotation.y
	
	var lerp_weight := clampf(lerp_power * delta, 0.0, 1.0)
	
	indicator.rotation.x = lerp_angle(indicator.rotation.x, target_x, lerp_weight)
	indicator.rotation.y = lerp_angle(indicator.rotation.y, target_y, lerp_weight)
	indicator.rotation.z = clamp(
		lerp_angle(indicator.rotation.z, target_z, lerp_weight),
		-MAX_VERTICLE_ANGLE,
		MAX_VERTICLE_ANGLE
		)
