class_name PlayerState3D
extends State
# Generic state for the player which should be extended to specific states

### Exported variables ###
@export var move_speed_xz: float = 8.0
@export var acceleration_xz: float = 20.0
@export var friction_xz: float = 20
@export var acceleration_body_rotation: float = 1.0
@export var jump_velocity: float = 5.0
@export var rotation_speed: float = 0.005

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
	var forward = -_player.global_transform.basis.z
	var right = _player.global_transform.basis.x
	if direction_xz != Vector3.ZERO:
		direction_xz = (abs(right) * direction_xz.x + forward * direction_xz.z).normalized()
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

func _get_nearest_physics_object() -> Node3D:
	var min_distance = INF
	var nearest: Node3D = null
	for body in _player.get_node("Detection").get_overlapping_bodies():
		
		if body is PhysicsBody3D:
			var distance = _player.global_position.distance_to(body.global_position)
			if distance < min_distance:
				min_distance = distance
				nearest = body
	return nearest

func _face_target_cardinal(target, offset = 0):
	if not target:
		return

	var direction = target.global_position - _player.global_position
	direction.y = 0

	if direction.length_squared() == 0:
		return
	
	var angle = atan2(direction.x, direction.z)
	var snapped_angle = round(angle / (PI / 2.0) + offset) * (PI / 2.0)  # Snap to 90-degree angles
	_player.rotation.y = snapped_angle

func _move_towards_target(delta, target):
	if not target:
		return

	var target_pos = target.global_position
	var direction = (target_pos - _player.global_position)
	direction.y = 0  # Stay in XZ plane
	var distance = direction.length()
	
	if distance > 0:
		direction = direction.normalized()
		_player.velocity = direction * move_speed_xz
		_player.move_and_slide()
	else:
		_player.velocity = Vector3.ZERO
		_player.global_position.x = target.global_position.x
		_player.global_position.z = target.global_position.z  # Snap to center
	return true
