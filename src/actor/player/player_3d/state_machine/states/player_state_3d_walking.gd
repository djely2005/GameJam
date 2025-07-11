extends PlayerState3D


# Public Method
 
func physics_update(delta: float) -> void:
	var movement_direction_xz: Vector3 = _get_input_movement_direction_xz()
	_apply_xz_movement(delta, movement_direction_xz)
	_update_state()
	_player.move_and_slide()
	
	

func enter(_data: Dictionary={}) -> void:
	_animate()

func handle_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion && Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		var mouse_motion_event: InputEventMouseMotion = event as InputEventMouseMotion
		_player.rotation.y -= mouse_motion_event.relative.x * rotation_speed
	pass
# Private Method

func _animate() -> void:
	_animation_state_machine.travel("walk")

func _update_state() -> void:
	var target_state_id: String = name
	if _get_input_movement_direction_xz() == Vector3.ZERO:
		target_state_id = "Idle"
	if _get_nearest_physics_object() != null:
		if Input.is_action_just_pressed("interact") && _get_nearest_physics_object().has_method('open'):
			target_state_id= "OpeningDoor"
	if Input.is_action_just_pressed("interact") && !_get_nearest_physics_object().has_method('open'):
		target_state_id= "Pushing"
	if target_state_id != name:
		emit_signal("change_state_request", target_state_id, {})
