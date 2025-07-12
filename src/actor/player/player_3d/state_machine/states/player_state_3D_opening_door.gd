extends PlayerState3D
var door

# Public Method
 
func physics_update(delta: float) -> void:
	_update_state()
	_player.move_and_slide()
	
	

func enter(_data: Dictionary={}) -> void:
	door = _get_nearest_physics_object()
	_face_target_cardinal(door, PI)
	door.open()
	_animate()

func handle_input(event: InputEvent) -> void:
	pass
# Private Method

func _animate() -> void:
	_animation_state_machine.travel("opening_door")

func _update_state() -> void:
	var target_state_id: String = name
	if _get_input_movement_direction_xz() == Vector3.ZERO:
		target_state_id = "Idle"
	if _get_input_movement_direction_xz() != Vector3.ZERO:
		target_state_id = "Walking"
	if target_state_id != name:
		emit_signal("change_state_request", target_state_id, {})
