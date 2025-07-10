extends CharacterBody3D

var push_direction: Vector3 = Vector3.ZERO
var push_speed: float = 8.0
var is_being_pushed: bool = false
@onready var pushing_area: Area3D = $PushingArea


func _physics_process(delta: float) -> void:
	
	if is_being_pushed:
		if abs(push_direction.x) > abs(push_direction.z): 
			global_position.x += sign(push_direction.x) * push_speed * delta
		elif abs(push_direction.z) > abs(push_direction.x):
			global_position.z += sign(push_direction.z) * push_speed * delta
		move_and_slide()
		is_being_pushed = false  # reset each frame
	


func _on_pushing_area_body_entered(body: Node3D) -> void:
	is_being_pushed = false
	pass # Replace with function body.
