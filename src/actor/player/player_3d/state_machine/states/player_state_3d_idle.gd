extends PlayerState3D
# State controlling the player while idle


############################
#      Public Methods      #
############################


func physics_update(delta: float) -> void:
	_apply_xz_movement(delta, Vector3.ZERO)
	_update_state()
	_player.move_and_slide()


func enter(_data: Dictionary={}) -> void:
	_animate()


############################
#      Private Methods     #
############################
func _animate() -> void:
	_animation_state_machine.travel("idle")


func _update_state() -> void:
	var target_state_id: String = name
	if _get_input_movement_direction_xz() != Vector3.ZERO:
		target_state_id = "Walking"
	
	if target_state_id != name:
		emit_signal("change_state_request", target_state_id, {})
