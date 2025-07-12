class_name Player3D
extends CharacterBody3D

@export var gravity: float = -9.8

### Public variables ###
var snap_vector: Vector3 = Vector3.ZERO
var input_movement_direction_xz: Vector3 = Vector3.ZERO
var floor_max_angle_deg: float = 45.0
var interactable = null;

var _animation_state_machine: AnimationNodeStateMachinePlayback :get = get_animation_state_machine


@onready var _state_machine: StateMachine = get_node("StateMachine")
@onready var _anim_tree: AnimationTree = get_node("AnimationTree")

func _on_area_entered(area):
	if area.get_parent().has_method("open"):
		interactable = area.get_parent()

func _on_area_exited(area):
	if area.get_parent() == interactable:
		interactable = null

# Godot Engine
func _ready() -> void:
	_anim_tree.active = true
	_animation_state_machine = _anim_tree["parameters/playback"]

	

# Public Method

func get_animation_state_machine() -> AnimationNodeStateMachinePlayback:
	return _animation_state_machine

# Engine Callback
func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta 
	_state_machine.physics_update(delta);
	
func _unhandled_input(event: InputEvent) -> void:
	_state_machine.handle_input(event)
