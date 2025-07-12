extends PlayerState3D

var target: Node3D = null;
var is_attached := false
# Public Method
 
func physics_update(delta: float) -> void:
	if not is_attached:
		target = _get_nearest_physics_object()
		is_attached = _move_towards_target(delta, target)
		_face_target_cardinal(target)
	else:
		_move_player_and_push(delta)
	_update_state()
	
	

func enter(_data: Dictionary={}) -> void:
	_animate()

func exit() -> void:
	if target != null:
		target.set_physics_process(true)
# Private Method
func handle_input(event: InputEvent) -> void:
	pass

func _animate() -> void:
	_animation_state_machine.travel("interact")

func _update_state() -> void:
	var target_state_id: String = name
	if _get_input_movement_direction_xz() == Vector3.ZERO && (target == null || Input.is_action_just_pressed("interact")):
		target_state_id = "Idle"
	if _get_input_movement_direction_xz() != Vector3.ZERO && (target == null || Input.is_action_just_pressed("interact")):
		target_state_id = "Walking"
	if target_state_id != name:
		is_attached = false
		
		emit_signal("change_state_request", target_state_id, {})


func _move_player_and_push(delta):
	var input_dir = Vector3.ZERO
	input_dir = _get_input_movement_direction_xz()
	if input_dir != Vector3.ZERO:
		input_dir = input_dir.normalized()

		# Rotate input based on player's facing direction
		var basis = Basis(Vector3.UP, _player.rotation.y)  # Y-axis rotation
		var move_dir = input_dir      # Convert local to global direction
		
		# Apply velocity
		_player.velocity = move_dir * move_speed_xz / PI
		_player.move_and_slide()

		# Move target object if attached
		if target:
			target.set_physics_process(false)
			target.velocity = move_dir * move_speed_xz / PI
			target.move_and_slide()
	else:
		_player.velocity = Vector3.ZERO
		if target:
			target.velocity = Vector3.ZERO
