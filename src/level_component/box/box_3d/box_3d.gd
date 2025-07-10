extends CharacterBody3D

var push_direction: Vector3 = Vector3.ZERO
var push_speed: float = 8.0
var is_being_pushed: bool = false


func _physics_process(delta: float) -> void:
	if is_being_pushed:
		global_position.x += push_direction.x * push_speed * delta
		global_position.z += push_direction.z * push_speed * delta
		is_being_pushed = false  # reset each frame
