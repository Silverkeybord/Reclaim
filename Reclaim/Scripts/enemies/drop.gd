extends RigidBody3D

const RARITY_RESPAWN_MULT := 20 # seconds before desawning multipyled by the interger value of the rarity

const DESPAWN_SCALE := Vector3(0.1, 0.1, 0.1)
const DESPAWN_TWEEN_TIME := 0.5

const GROUND_GROUP_NAME := "ground"
const PLAYER_GROUP_NAME := "player"
const GROUND_COLLISION_LAYER := 1
const DROP_COLLISION_LAYER := 8

const MAX_SPEED := 100.0
const ACCELERATION_MULT := 1.1 # each frame it gets 1.1 times faster
const PICK_UP_BUFFER := 0.2

const MAX_ANGULAR_VELOCITY := 10.0
const MIN_ANGULAR_VELOCITY := 5.0
const MAX_HOZ_VELOCITY := 10.0
const MIN_HOZ_VELOCITY := 1.0
const MAX_VERT_VELOCITY := 25.0
const MIN_VERT_VELOCITY := 20.0
const DIRECTION := [-1, 1]

@export var player : CharacterBody3D
@export var valid : bool = true

@export var despawn_timer : Timer
@export var process_freeze_timer : Timer
@export var area3D : Area3D

var last_process_pos : Vector3
var on_ground : bool = false
var being_picked_up : bool = false
var picked_up : bool = false

# starting speed
var speed = 3


func _ready() -> void:
	despawn_timer.wait_time = RARITY_RESPAWN_MULT
	despawn_timer.start()
	
	# throws the drop in a random direction upwards when it spawns
	var x_vel = randf_range(MIN_HOZ_VELOCITY, MAX_HOZ_VELOCITY) * DIRECTION.pick_random()
	var z_vel = randf_range(MIN_HOZ_VELOCITY, MAX_HOZ_VELOCITY) * DIRECTION.pick_random()
	var y_vel = randf_range(MIN_VERT_VELOCITY, MAX_VERT_VELOCITY) 
	linear_velocity = Vector3(x_vel, y_vel, z_vel)
	
	# gives the drop a random spin
	var x_ang = randf_range(MIN_ANGULAR_VELOCITY, MAX_ANGULAR_VELOCITY) * DIRECTION.pick_random()
	var z_ang = randf_range(MIN_ANGULAR_VELOCITY, MAX_ANGULAR_VELOCITY) * DIRECTION.pick_random()
	var y_ang = randf_range(MIN_ANGULAR_VELOCITY, MAX_ANGULAR_VELOCITY) * DIRECTION.pick_random()
	angular_velocity = Vector3(x_ang, y_ang, z_ang)
	
	# stops the player instantly picking it up while it is still flying out
	await get_tree().create_timer(PICK_UP_BUFFER).timeout
	set_collision_layer_value(DROP_COLLISION_LAYER, true)


func _process(delta: float) -> void:
	if being_picked_up:
		# accelerates towards the player until it reaches its cap
		var dir = (player.global_position - global_position).normalized()
		linear_velocity = dir * speed
		
		if (speed * ACCELERATION_MULT) <= MAX_SPEED:
			speed *= ACCELERATION_MULT
		else:
			speed = MAX_SPEED
		
		if global_position.distance_to(player.global_position) <= speed * delta:
			# snaps to the player and deletes once its basically collected
			global_position = player.global_position
			linear_velocity = Vector3.ZERO
			picked_up = true
			set_process(false)
			queue_free()
	else:
		# gravity when the drops spawn
		if linear_velocity.y > -Global.GRAVITY:
			linear_velocity.y -= Global.GRAVITY * delta


func _on_area_3d_body_entered(body: Node3D) -> void:
	# starts checking if the drop has stopped moving on the ground
	if body in get_tree().get_nodes_in_group(GROUND_GROUP_NAME):
		on_ground = true
		if process_freeze_timer.is_stopped():
			process_freeze_timer.start()


func _on_area_3d_body_exited(body: Node3D) -> void:
	# stops the freeze timer if the drop bounces off the ground again
	if body in get_tree().get_nodes_in_group(GROUND_GROUP_NAME):
		on_ground = false
		if not process_freeze_timer.is_stopped():
			process_freeze_timer.stop()


func _on_process_freeze_timer_timeout() -> void:
	# freezes the drop when it has been sitting on the ground for a bit
	if on_ground:
		freeze = true
		set_process(false)
		linear_velocity.y = 0
		area3D.monitoring = false


func _on_despawn_timer_timeout() -> void:
	# deletes old drops that the player didnt pick up
	valid = false
	
	var despawn_tween = create_tween()
	
	despawn_tween.tween_property(self, "scale", DESPAWN_SCALE, DESPAWN_TWEEN_TIME)
	
	await despawn_tween.finished
	
	queue_free()


# primes the drop to be picked up
func pick_up() -> void: 
	# turns off ground collision so the drop can fly into the player
	set_collision_mask_value(GROUND_COLLISION_LAYER, false)
	
	being_picked_up = true
	freeze = false
	set_process(true)
