extends PlayerState3D
# Public Method
 
func physics_update(delta: float) -> void:
	var movement_direction_xz: Vector3 = _get_input_movement_direction_xz()
	_apply_xz_movement(delta, movement_direction_xz)
	if movement_direction_xz != Vector3.ZERO:
		_rotate_body(delta, movement_direction_xz)
	var space_state = _player.get_world_3d().direct_space_state
	var params = PhysicsRayQueryParameters3D.new()
	var raw_direction = movement_direction_xz.normalized()
	var facing_direction = Vector3(
		sign(raw_direction.x),
		0,
		sign(raw_direction.z)
	)
	print(facing_direction)
	params.from = _player.global_position
	params.to = _player.global_position + facing_direction
	params.collide_with_areas = true
	params.exclude = []
	var result = space_state.intersect_ray(params)
	if result != {}:
		if result.collider is Area3D:
			if result.collider.get_parent() is CharacterBody3D:
				var chair = result.collider.get_parent()
				chair.push_speed = move_speed_xz
				chair.push_direction = facing_direction
				chair.is_being_pushed = true
	_update_state()
	_player.move_and_slide()
	
	

func enter(_data: Dictionary={}) -> void:
	_animate()

# Private Method

func _animate() -> void:
	_animation_state_machine.travel("interact")

func _update_state() -> void:
	var target_state_id: String = name
	if _get_input_movement_direction_xz() == Vector3.ZERO:
		target_state_id = "Idle"

	if target_state_id != name:
		emit_signal("change_state_request", target_state_id, {})
