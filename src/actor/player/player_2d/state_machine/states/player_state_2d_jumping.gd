extends PlayerState2D

var locked_direction: int = 0  # -1 = left, 1 = right
# Public Method
 
func physics_update(delta: float) -> void:
	var direction_x = _get_input_movement_direction_x()
	if locked_direction != 0 && direction_x != 0:
		if sign(direction_x) != sign(locked_direction):
			direction_x = 0
	_apply_x_movement(delta, direction_x)
	_update_state()
	_player.move_and_slide()

func enter(_data: Dictionary={}) -> void:
	_apply_y_movement()
	_animate()
	
	var input_dir = _get_input_movement_direction_x()
	locked_direction = sign(input_dir)

# Private Method

func _animate() -> void:
	_animation_state_machine.travel("jumping")

func _update_state() -> void:
	var target_state_id: String = name
	if _player.is_on_floor():
		if _get_input_movement_direction_x() == 0:
			target_state_id = "Idle"
		if _get_input_movement_direction_x() != 0:
			target_state_id = "Walking"
	if target_state_id != name:
		emit_signal("change_state_request", target_state_id, {})
