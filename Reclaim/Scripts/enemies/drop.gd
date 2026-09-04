extends RigidBody3D

# seconds before despawning multiplyed by the integer value of the rarity
const TIER_DESPAWN_MULT := 20

const DESPAWN_SCALE := Vector3(0.1, 0.1, 0.1)
const DESPAWN_TWEEN_TIME := 0.5

const AREA_COLLISION_SHAPE_MARGIN := Vector3(0.2, 0.2, 0.2)

const GROUND_GROUP_NAME := "ground"
const PLAYER_GROUP_NAME := "player"
const GROUND_COLLISION_LAYER := 1
const DROP_COLLISION_LAYER := 8

const MAX_SPEED := 100.0
const ACCELERATION_MULT := 1.08 # each frame it gets X times faster
const PICK_UP_BUFFER := 0.2

const MAX_ANGULAR_VELOCITY := 10.0
const MIN_ANGULAR_VELOCITY := 5.0
const MAX_HOZ_VELOCITY := 10.0
const MAX_VERT_VELOCITY := 25.0
const MIN_VERT_VELOCITY := 5.0
const DIRECTION := [-1, 1]
const DROP_SIZE_SPEED_FACTOR := 0.1

const DEFAULT_ADD_AMOUNT := 1

@export var player : Player
@export var item_data : ItemData

@export var mesh : MeshInstance3D

@export_group("Collision Shapes")
@export var rigid_collision_shape : CollisionShape3D

@export_group("Logic")
@export var valid : bool = true
@export var despawn_timer : Timer
@export var process_freeze_timer : Timer

@export_group("Sounds")
@export var pickup_sounds : Array[SoundInfo]

var on_ground : bool = false
var being_picked_up : bool = false
var picked_up : bool = false

# starting pick up speed
var speed : float = 3.0


func _ready() -> void:
	despawn_timer.wait_time = TIER_DESPAWN_MULT * item_data.tier
	despawn_timer.start()
	
	mesh.mesh = mesh.mesh.duplicate()
	rigid_collision_shape.shape = rigid_collision_shape.shape.duplicate()

	rigid_collision_shape.shape.size = item_data.size
	mesh.mesh.size = item_data.size
	
	mesh.set_surface_override_material(0, item_data.get_material())
	
	_give_random_movement()
	
	# stops the player instantly picking it up while it is still flying out
	await get_tree().create_timer(PICK_UP_BUFFER).timeout
	set_collision_layer_value(DROP_COLLISION_LAYER, true)


func _process(delta: float) -> void:
	if being_picked_up:
		# validity testing
		if not player:
			return
		
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
			_pick_up()
			set_process(false)
			queue_free()


func _on_despawn_timer_timeout() -> void:
	# deletes old drops that the player didnt pick up
	if being_picked_up:
		return
	
	valid = false
	
	var despawn_tween = create_tween()
	
	despawn_tween.tween_property(self, "scale", DESPAWN_SCALE, DESPAWN_TWEEN_TIME)
	
	await despawn_tween.finished
	
	queue_free()


# primes the drop to be picked up when the drop enters the pick up area
func prime_pick_up() -> void: 
	linear_velocity = Vector3.ZERO
	# turns off ground collision so the drop can fly into the player
	set_collision_mask_value(GROUND_COLLISION_LAYER, false)
	set_collision_mask_value(DROP_COLLISION_LAYER, false)
	
	being_picked_up = true
	freeze = false
	set_process(true)


# gives the drop some random upwards movement w
func _give_random_movement() -> void:
	var item_size_speed_scale =  max(1, item_data.size.x * DROP_SIZE_SPEED_FACTOR)
	
	# throws the drop in a random direction upwards when it spawns
	var x_vel = randf_range(0, MAX_HOZ_VELOCITY) * DIRECTION.pick_random()
	var z_vel = randf_range(0, MAX_HOZ_VELOCITY) * DIRECTION.pick_random()
	var y_vel = randf_range(MIN_VERT_VELOCITY, MAX_VERT_VELOCITY) 
	linear_velocity = Vector3(x_vel, y_vel, z_vel) * item_size_speed_scale
	
	# gives the drop a random spin
	var x_ang = randf_range(MIN_ANGULAR_VELOCITY, MAX_ANGULAR_VELOCITY) * DIRECTION.pick_random()
	var z_ang = randf_range(MIN_ANGULAR_VELOCITY, MAX_ANGULAR_VELOCITY) * DIRECTION.pick_random()
	var y_ang = randf_range(MIN_ANGULAR_VELOCITY, MAX_ANGULAR_VELOCITY) * DIRECTION.pick_random()
	angular_velocity = Vector3(x_ang, y_ang, z_ang) * item_size_speed_scale


# add the drop into the storage of the player
func _pick_up() -> void:
	HelperFunctions.spawn_temp_sound(pickup_sounds.pick_random())
	HelperFunctions.add_item_to_storage(item_data, DEFAULT_ADD_AMOUNT, Global.sector_storage)
	player.item_notif_controller.add_notif(item_data)
