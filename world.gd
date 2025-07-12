extends Node

@onready var world_2d: SubViewportContainer = $"2D"
@onready var world_3d: SubViewportContainer = $"3D"
@onready var player_3d: Player3D = $"3D/SubViewport/World3D/Player3D"
@onready var pillar_wall: MeshInstance3D = $"3D/SubViewport/PillarWall"
@onready var bound_2d: MeshInstance2D = $"2D/SubViewport/World2D/Bound2D"
@onready var fade_control: ColorRect = $FadeControl
@onready var player_camera: Camera3D = $"3D/SubViewport/World3D/Camera3D"
@onready var player_2d: Player2D = $"2D/SubViewport/World2D/Player2D"
@onready var camera_2d: Camera2D = player_2d.get_node('Camera2D')

signal switch(is_2d : bool)
signal check_if_switch_is_possible();

var transforming_elements;
var is_2d: bool = false
var map_camera;
var is_transitioning = false

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
	if event.is_action_pressed("switch") && !is_transitioning:
		if !is_2d:
			emit_signal("check_if_switch_is_possible")
		else:
			animate_to_3d_and_switch()


func _on_player_abort_transformation(boolean: bool) -> void:
	if !boolean:
		await animate_to_2d_and_switch()
	pass

func set_mode():
	is_2d = !is_2d
	world_2d.visible = is_2d
	world_3d.visible = !is_2d
	emit_signal("switch", is_2d)

func animate_to_2d_and_switch():
	var cam = player_camera
	var tween = get_tree().create_tween()

	# Step 2: Fade to white/black
	fade_control.visible = true
	fade_control.modulate.a = 0.0
	tween = get_tree().create_tween()
	tween.tween_property(fade_control, "modulate:a", 1.0, 0.3)
	await tween.finished
	# Step 3: Switch mode (turn on 2D, off 3D)
	set_mode()

	# Step 4: Reset FOV
	cam.fov = 70.0  # Reset to your default camera FOV

	# Step 5: Fade back in
	tween = get_tree().create_tween()
	tween.tween_property(fade_control, "modulate:a", 0.0, 0.3)
	await tween.finished
	fade_control.visible = false
	is_transitioning = false

func animate_to_3d_and_switch():
	var tween = get_tree().create_tween()

	# Step 2: Fade out
	fade_control.visible = true
	fade_control.modulate.a = 0.0
	tween = get_tree().create_tween()
	tween.tween_property(fade_control, "modulate:a", 1.0, 0.3)
	await tween.finished
	# Step 3: Switch to 3D
	set_mode()

	# Step 4: Reset zoom
	camera_2d.zoom = Vector2(1, 1)

	# Step 5: Fade back in
	tween = get_tree().create_tween()
	tween.tween_property(fade_control, "modulate:a", 0.0, 0.3)
	await tween.finished
	fade_control.visible = false
	is_transitioning = false
