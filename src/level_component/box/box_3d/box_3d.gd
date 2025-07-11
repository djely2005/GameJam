extends CharacterBody3D

var push_direction: Vector3 = Vector3.ZERO
var push_speed: float = 8.0
var is_being_pushed: bool = false
var gravity = 9.8;
@onready var pushing_area: Area3D = $PushingArea


func _physics_process(delta: float) -> void:
	velocity.y -= gravity
	move_and_slide()
	

	
func _on_pushing_area_body_entered(body: Node3D) -> void:
	is_being_pushed = false
	pass # Replace with function body.
