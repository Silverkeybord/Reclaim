extends Node3D
## Controls the player's camera rotation and zoom distance.

const MIN_PITCH: float = -1.3 # Pitch is in rad so up and down are +- pi/2
const MAX_PITCH: float = 1.1

const ZOOM_SPEED := 0.5
const MAX_ZOOM := 15.0
const FIRST_PERSON_THRESHOLD := 1.25
const FIRST_PERSON_CAMERA_LENGTH := 0
const THIRD_PERSON_CAMERA_OFFSET := Vector3(0, 1.25, 0.8)
const FIRST_PERSON_CAMERA_OFFSET := Vector3(0, 0.4, 0)
const Z_AXIS_THIRD_PERSON_POSITION := Vector3(0, 1.25, 0)

const RAY_LENGTH := 50 # in meters

@export_group("settings")
@export var sensitivity: float = 0.003

@export_group("in scene")
@export var player: CharacterBody3D
@export var spring_arm: SpringArm3D
@export var gun_piviot : Node3D
@export var z_axis_spring_arm : SpringArm3D

var pitch := 0.0
var zoom_value := 3.0


func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


# Input function converting mouse movement into camera movement
func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		_pan_and_pitch(event)
	
	if event is InputEventMouseButton:
		_zoom_in_out(event)


# Controls camera movement
func _pan_and_pitch(event) -> void:
	# Horizontal mouse movement rotates the player body.
	player.rotation.y -= event.relative.x * sensitivity
	
	# Vertical mouse movement tilts the camera up and down.
	pitch -= event.relative.y * sensitivity
	pitch = clamp(pitch, MIN_PITCH, MAX_PITCH)
	rotation.x = pitch
	gun_piviot.rotation.x = pitch


# Controls zooming in and out
func _zoom_in_out(event: InputEventMouseButton) -> void:
	if event.button_index == MOUSE_BUTTON_WHEEL_UP:
		zoom_value -= ZOOM_SPEED
	elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
		zoom_value += ZOOM_SPEED
	
	zoom_value = clamp(zoom_value, FIRST_PERSON_THRESHOLD, MAX_ZOOM)
	spring_arm.spring_length = zoom_value
	
	# Zooming to a threshold snaps the camera to a first-person position.
	if zoom_value <= FIRST_PERSON_THRESHOLD:
		position = FIRST_PERSON_CAMERA_OFFSET
		spring_arm.spring_length = FIRST_PERSON_CAMERA_LENGTH
		z_axis_spring_arm.spring_length = FIRST_PERSON_CAMERA_LENGTH
		z_axis_spring_arm.position = FIRST_PERSON_CAMERA_OFFSET
	else:
		position = THIRD_PERSON_CAMERA_OFFSET
		z_axis_spring_arm.spring_length = THIRD_PERSON_CAMERA_OFFSET.z
		z_axis_spring_arm.position = Z_AXIS_THIRD_PERSON_POSITION
