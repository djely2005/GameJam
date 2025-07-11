extends Node

@onready var world_2d: SubViewportContainer = $"2D"
@onready var world_3d: SubViewportContainer = $"3D"
@onready var player_3d: Player3D = $"3D/SubViewport/World3D/Player3D"
@onready var pillar_wall: MeshInstance3D = $"3D/SubViewport/PillarWall"
@onready var bound_2d: MeshInstance2D = $"2D/SubViewport/World2D/Bound2D"


signal switch(is_2d : bool)
signal check_if_switch_is_possible();

var transforming_elements;
var is_2d: bool = false
var map_camera;
var player_camera;

func _ready():
	# Set initial visibility states
	for c in get_children():
		if c is Sync:
			c.connect("switch", c._on_world_switch)
			if [c.player2d, c.player3d] not in Global.transforming_items: 
				Global.transforming_items.append([c.player2d, c.player3d])
	world_2d.visible = is_2d
	world_3d.visible = !is_2d
	Global.pillar_wall = pillar_wall
	Global.bound_2d = bound_2d

func _input(event):
	if event.is_action_pressed("switch"):
		if !is_2d:
			emit_signal("check_if_switch_is_possible")
		else:
			set_mode()
		
		


func _on_player_abort_transformation(boolean: bool) -> void:
	if !boolean:
		set_mode()
	pass

func set_mode():
	is_2d = !is_2d
	world_2d.visible = is_2d
	world_3d.visible = !is_2d
	emit_signal("switch", is_2d)
