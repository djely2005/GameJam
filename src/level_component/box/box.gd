extends Sync

@onready var player3d = $"../3D/SubViewport/World3D/Box3d"
@onready var player2d = $"../2D/SubViewport/World2D/Box2d"

var is_2d_mode = false

func _ready():
	pass

func set_mode(to_2d: bool):
	is_2d_mode = to_2d
	player2d.visible = to_2d
	player3d.visible = not to_2d
	player2d.set_process(to_2d)
	player3d.set_process(!to_2d)
	# Position sync
	if to_2d:
		# Project 3D position into 2D
		transform_3d_to_2d(player2d, player3d)
	else:
		# Get correct 3D Z position (e.g., standing on the right box)
		# var top_box = get_topmost_box_at_2d(player2d.global_position)
		var new_pos = transform_2d_to_3d(player2d, player3d)
		player3d.global_position = new_pos


func _on_world_switch(is_2d: bool) -> void:
	set_mode(is_2d)
	pass # Replace with function body.
