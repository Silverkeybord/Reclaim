extends Node3D
# Controls the player's camera rotation and zoom distance.

# =============================================================================
# CONSTANTS
# =============================================================================

# Input Actions
const ACTION_TOGGLE_MOUSE_CAPTURE: StringName = &"toggle_mouse_capture"

# Camera Bounds & Offsets
const MIN_PITCH: float = -PI / 2.0 + 0.1
const MAX_PITCH: float = PI / 2.0 - 0.3

const ZOOM_SPEED: float = 0.5
const MAX_ZOOM: float = 15.0
const FIRST_PERSON_THRESHOLD: float = 1.25
const FIRST_PERSON_CAMERA_LENGTH: float = 0.0
const THIRD_PERSON_CAMERA_OFFSET: Vector3 = Vector3(0.0, 1.25, 0.8)
const FIRST_PERSON_CAMERA_OFFSET: Vector3 = Vector3(0.0, 0.4, 0.0)
const Z_AXIS_THIRD_PERSON_POSITION: Vector3 = Vector3(0.0, 1.25, 0.0)

# =============================================================================
# EXPORTS
# =============================================================================

@export_group("Settings")
@export var sensitivity: float = 0.003

@export_group("Scene References")
@export var player: CharacterBody3D
@export var spring_arm: SpringArm3D
@export var arm_pivot: Node3D
@export var z_axis_spring_arm: SpringArm3D

var pitch: float = 0.0
var zoom_value: float = 3.0


func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


# Input function converting mouse movement into camera movement
func _input(event: InputEvent) -> void:
	if Global.crafting_open or Global.extraction_open or Global.major_animation_playing:
		return
	
	if event is InputEventMouseMotion and Global.mouse_captured:
		_pan_and_pitch(event)
	
	if Global.storage_open:
		return
	
	if event is InputEventMouseButton:
		if Global.player_mode != Global.PLAYER_MODES.BUILDING:
			_zoom_in_out(event as InputEventMouseButton)
	
	if event.is_action_pressed(ACTION_TOGGLE_MOUSE_CAPTURE):
		HelperFunctions.set_mouse_captured()


# =============================================================================
# HELPER FUNCTIONS
# =============================================================================

# Controls camera movement
func _pan_and_pitch(event: InputEventMouseMotion) -> void:
	if player == null:
		return
		
	# Horizontal mouse movement rotates the player body.
	player.rotation.y -= event.relative.x * sensitivity
	
	# Vertical mouse movement tilts the camera up and down.
	pitch -= event.relative.y * sensitivity
	pitch = clampf(pitch, MIN_PITCH, MAX_PITCH)
	
	rotation.x = pitch
	if arm_pivot != null:
		arm_pivot.rotation.x = pitch


# Controls zooming in and out
func _zoom_in_out(event: InputEventMouseButton) -> void:
	if spring_arm == null or z_axis_spring_arm == null:
		return

	if event.button_index == MOUSE_BUTTON_WHEEL_UP:
		zoom_value -= ZOOM_SPEED
	elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
		zoom_value += ZOOM_SPEED
	
	zoom_value = clampf(zoom_value, FIRST_PERSON_THRESHOLD, MAX_ZOOM)
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
