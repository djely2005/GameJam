extends Sync

@onready var player3d = $"../3D/SubViewport/World3D/Player3D"
@onready var player2d = $"../2D/SubViewport/World2D/Player2D" 
@onready var camera_3d: Camera3D = $"../3D/SubViewport/World3D/Camera3D"

signal abort_transformation(boolean: bool)

var is_2d_mode = false

func _ready():
	pass

func set_mode(to_2d: bool):
	var attached_camera = player3d.get_viewport().get_camera_3d()
	if to_2d:
		disable_input(player3d)
		transform_3d_to_2d(player2d, player3d)
	else:
		var floor_collider = player2d.get_node("FloorCollider");
		var top_box = null
		var body = null;
		if floor_collider.is_colliding():
			var collider = floor_collider.get_collider()
			for item in Global.transforming_items:
				if collider in item:
					body = item
		var overlapping;
		if body:
			overlapping = get_element_overlaping_in_3D(body[1])
			if !overlapping:
				overlapping.append({"collider": body[1]})
		var teleport_destination;
		if overlapping:
			teleport_destination = overlapping[0].collider
			for element in overlapping:
				if teleport_destination.global_position.z > element.collider.global_position.z:
					teleport_destination = overlapping
		var new_pos = transform_2d_to_3d(player2d, player3d)
		var depth = player3d.global_position.z
		if (overlapping):
			new_pos.z = teleport_destination.global_position.z
		else:
			new_pos.z = depth
		player3d.global_position = new_pos
		disable_input(player2d)


func disable_input(player):
	player.set_process_input(false)
	player.set_process_unhandled_input(false)


func _on_world_switch(is_2d: bool) -> void:
	set_mode(is_2d)
	pass # Replace with function body.


func _on_world_check_if_switch_is_possible() -> void:
	var overlaping = get_element_overlaping_in_3D(player3d)
	var is_overlaping = overlaping.size() > 0
	emit_signal("abort_transformation", is_overlaping)
	pass # Replace with function body.
