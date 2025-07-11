extends Sync

@export var element_3d_path: NodePath;
@export var element_2d_path: NodePath;

var player2d;
var player3d;

var is_2d_mode = false

func _ready():
	player2d = get_node(element_2d_path)
	player3d = get_node(element_3d_path)
	get_parent().switch.connect(_on_world_switch)
	pass

func set_mode(to_2d: bool):
	player2d.visible = to_2d
	player3d.visible = not to_2d
	player2d.set_process(to_2d)
	player3d.set_process(!to_2d)
	# Position sync
	if to_2d:
		# Project 3D position into 2D
		var overlapping = get_element_overlaping_in_3D(player3d)
		transform_3d_to_2d(player2d, player3d)
	else:
		# Get correct 3D Z position (e.g., standing on the right box)
		# var top_box = get_topmost_box_at_2d(player2d.global_position)
		var new_pos = transform_2d_to_3d(player2d, player3d)
		player3d.global_position = new_pos


func _on_world_switch(is_2d: bool) -> void:
	set_mode(is_2d)
	pass # Replace with function body.
