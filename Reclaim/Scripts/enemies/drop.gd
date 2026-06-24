extends RigidBody3D

const TEIR_DESPAWN_MULT := 20 # seconds before desawning multipyled by the interger value of the rarity

const DESPAWN_SCALE := Vector3(0.1, 0.1, 0.1)
const DESPAWN_TWEEN_TIME := 0.5

const AREA_COLLISION_SHAPE_MARGIN := Vector3(0.2, 0.2, 0.2)

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
const MAX_VERT_VELOCITY := 25.0
const MIN_VERT_VELOCITY := 5.0
const DIRECTION := [-1, 1]

@export var player : CharacterBody3D
@export var item_resource : ItemData

@export var mesh : MeshInstance3D

@export_group("Collision Shapes")
@export var rigid_collision_shape : CollisionShape3D

@export_group("Logic")
@export var valid : bool = true
@export var despawn_timer : Timer
@export var process_freeze_timer : Timer

@export_group("Sounds")
@export var pickup_sounds : Array[SoundInfo]

var last_process_pos : Vector3
var on_ground : bool = false
var being_picked_up : bool = false
var picked_up : bool = false

# starting speedgame
var speed = 3


func _ready() -> void:
	despawn_timer.wait_time = TEIR_DESPAWN_MULT * item_resource.teir
	despawn_timer.start()
	
	mesh.mesh = mesh.mesh.duplicate()
	rigid_collision_shape.shape = rigid_collision_shape.shape.duplicate()

	rigid_collision_shape.shape.size = item_resource.size
	mesh.mesh.size = item_resource.size
	
	var material_path = item_resource.get_material_path()
	mesh.set_surface_override_material(0, load(material_path))
	
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
	
	being_picked_up = true
	freeze = false
	set_process(true)


# gives the drop some random upwards movement w
func _give_random_movement() -> void:
	# throws the drop in a random direction upwards when it spawns
	var x_vel = randf_range(0, MAX_HOZ_VELOCITY) * DIRECTION.pick_random()
	var z_vel = randf_range(0, MAX_HOZ_VELOCITY) * DIRECTION.pick_random()
	var y_vel = randf_range(MIN_VERT_VELOCITY, MAX_VERT_VELOCITY) 
	linear_velocity = Vector3(x_vel, y_vel, z_vel)
	
	# gives the drop a random spin
	var x_ang = randf_range(MIN_ANGULAR_VELOCITY, MAX_ANGULAR_VELOCITY) * DIRECTION.pick_random()
	var z_ang = randf_range(MIN_ANGULAR_VELOCITY, MAX_ANGULAR_VELOCITY) * DIRECTION.pick_random()
	var y_ang = randf_range(MIN_ANGULAR_VELOCITY, MAX_ANGULAR_VELOCITY) * DIRECTION.pick_random()
	angular_velocity = Vector3(x_ang, y_ang, z_ang)


## add the drop into the inventory of the player
func _pick_up() -> void:
	Global.spawn_temp_sound(pickup_sounds.pick_random())
	
	if Global.sector_inventory[item_resource.teir].has(item_resource.key):
		Global.sector_inventory[item_resource.teir][item_resource.key] += 1
	else:
		Global.sector_inventory[item_resource.teir][item_resource.key] = 1
