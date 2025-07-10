class_name PlayerState3D
extends State
# Generic state for the player which should be extended to specific states

### Exported variables ###
@export var move_speed_xz: float = 8.0
@export var acceleration_xz: float = 20.0
@export var friction_xz: float = 20
@export var acceleration_body_rotation: float = 1.0
@export var jump_velocity: float = 5.0

### Private variables ###
@onready var _player: Player3D
var _animation_state_machine: AnimationNodeStateMachinePlayback


############################
# Engine Callback Methods  #
############################
func _ready() -> void:
	await(owner.ready)
	_player = owner
	_animation_state_machine = _player.get_animation_state_machine()


############################
#      Public Methods      #
############################
# Corresponds to _unhandled_input() callback
# warning-ignore:unused_argument
func handle_input(event: InputEvent) -> void:
	pass


# Corresponds to the _process() callback
# warning-ignore:unused_argument
func update(delta: float) -> void:
	pass


# Corresponds to the _physics_process() callback
# warning-ignore:unused_argument
func physics_update(delta: float) -> void:
	_update_state()
	pass


func enter(_data: Dictionary={}) -> void:
	_animate()
	pass


func exit() -> void:
	pass


# Private Methods

func _get_input_movement_direction_xz() -> Vector3:
	var input_vector: Vector3 = Vector3.ZERO
	var Input_arrow = Input.get_vector("left", "right", "up", "down")
	input_vector.x = Input_arrow.x
	input_vector.z = Input_arrow.y
	var direction: Vector3 = input_vector.normalized()
	return direction

func _apply_xz_movement(delta: float, direction_xz: Vector3) -> void:
	if direction_xz != Vector3.ZERO:
		var velocity_target_xz: Vector3 = direction_xz * move_speed_xz
		_player.velocity.x = _player.velocity.move_toward(velocity_target_xz, acceleration_xz * delta).x
		_player.velocity.z = _player.velocity.move_toward(velocity_target_xz, acceleration_xz * delta).z
	else:
		var frictioned_velocity_xz: Vector3 = _player.velocity.move_toward(
				Vector3.ZERO, friction_xz * delta
		)
		_player.velocity.x = frictioned_velocity_xz.x
		_player.velocity.z = frictioned_velocity_xz.z


func _rotate_body(delta: float, direction: Vector3) -> void:
	_player.rotation.y = lerp_angle(
			_player.rotation.y, atan2(direction.x, direction.z), 
			acceleration_body_rotation * delta
	)
func _animate() -> void:
	pass


func _update_state() -> void:
	pass
