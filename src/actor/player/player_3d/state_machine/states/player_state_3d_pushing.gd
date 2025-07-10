extends PlayerState3D

var result = {};
var target: Node3D = null;
var cardinal_facing = 0;
var facing_direction;
var is_attached := false
# Public Method
 
func physics_update(delta: float) -> void:
	if not is_attached:
		if target == null:
			target = _get_nearest_physics_object()
		elif target:
			_move_towards_target(delta)
			_face_target_cardinal()
	else:
		_move_player_and_push(delta)
	_update_state()
	
	

func enter(_data: Dictionary={}) -> void:
	_animate()

# Private Method

func _animate() -> void:
	_animation_state_machine.travel("interact")

func _update_state() -> void:
	var target_state_id: String = name
	if _get_input_movement_direction_xz() == Vector3.ZERO && (target == null || Input.is_action_just_pressed("interact")):
		target_state_id = "Idle"
		print('test')
	if _get_input_movement_direction_xz() != Vector3.ZERO && (target == null || Input.is_action_just_pressed("interact")):
		target_state_id = "Walking"
	if target_state_id != name:
		emit_signal("change_state_request", target_state_id, {})


func _get_nearest_physics_object() -> Node3D:
	var min_distance = INF
	var nearest: Node3D = null
	for body in _player.get_node("Detection").get_overlapping_bodies():
		
		if body is PhysicsBody3D:
			var distance = _player.global_position.distance_to(body.global_position)
			if distance < min_distance:
				min_distance = distance
				nearest = body
				
	print(nearest)
	return nearest

func _move_towards_target(delta):
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
	is_attached = true

func _face_target_cardinal():
	if not target:
		return

	var direction = target.global_position - _player.global_position
	direction.y = 0

	if direction.length_squared() == 0:
		return
	
	var angle = atan2(direction.x, direction.z)
	var snapped_angle = round(angle / (PI / 2.0)) * (PI / 2.0)  # Snap to 90-degree angles
	_player.rotation.y = snapped_angle

func _move_player_and_push(delta):
	var input_dir = Vector3.ZERO
	input_dir = _get_input_movement_direction_xz()

	if input_dir != Vector3.ZERO:
		print('check')
		input_dir = input_dir.normalized()

		# Rotate input based on player's facing direction
		var basis = Basis(Vector3.UP, _player.rotation.y)  # Y-axis rotation
		var move_dir = _player.basis * input_dir      # Convert local to global direction

		# Apply velocity
		_player.velocity = move_dir * move_speed_xz / PI
		_player.move_and_slide()

		# Move target object if attached
		if target:
			target.velocity = move_dir * move_speed_xz / PI
			target.move_and_slide()
	else:
		_player.velocity = Vector3.ZERO
		if target:
			target.velocity = Vector3.ZERO
