class_name Player2D
extends CharacterBody2D

## Exported
@export var gravity: float = 10.0


### Public variables ###
var snap_vector: Vector3 = Vector3.ZERO
var input_movement_direction_xz: Vector3 = Vector3.ZERO
var floor_max_angle_deg: float = 45.0

var _animation_state_machine: AnimationNodeStateMachinePlayback :get = get_animation_state_machine


@onready var _state_machine: StateMachine = get_node("StateMachine")
@onready var _anim_tree: AnimationTree = get_node("AnimationTree")

# Godot Engine
func _ready() -> void:
	_anim_tree.active = true
	_animation_state_machine = _anim_tree["parameters/playback"]

# Public Method

func get_animation_state_machine() -> AnimationNodeStateMachinePlayback:
	return _animation_state_machine

# Engine Callback
func _physics_process(delta: float) -> void:
	velocity.y += gravity  # gravity
	move_and_slide() 
	_state_machine.physics_update(delta);
	
func _unhandled_input(event: InputEvent) -> void:
	_state_machine.handle_input(event)
