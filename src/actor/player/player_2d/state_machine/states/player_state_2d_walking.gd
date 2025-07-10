extends PlayerState2D


# Public Method
 
func physics_update(delta: float) -> void:
	_update_state()
	var movement_direction_x: float = _get_input_movement_direction_x()
	_apply_x_movement(delta, movement_direction_x)
	_player.move_and_slide()
	
	

func enter(_data: Dictionary={}) -> void:
	_animate()

# Private Method

func _animate() -> void:
	_animation_state_machine.travel("walk")

func _update_state() -> void:
	var target_state_id: String = name
	if _get_input_movement_direction_x() == 0:
		target_state_id = "Idle"
	if Input.is_action_pressed("jump") && _player.is_on_floor():
		target_state_id = "Jumping"
	if target_state_id != name:
		emit_signal("change_state_request", target_state_id, {})
