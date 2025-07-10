class_name PlayerState2D
extends State
# Generic state for the player which should be extended to specific states

### Exported variables ###
@export var move_speed: float = 500.0
@export var acceleration: float = 35.0
@export var friction: float = 850.0
@export var acceleration_body_rotation: float = 1.0
@export var jump_force: float = 400
@export var gravity: float = 20

### Private variables ###
@onready var _player: Player2D
var _animation_state_machine: AnimationNodeStateMachinePlayback


############################
# Engine Callback Methods  #
############################
func _ready() -> void:
	await(owner.ready)
	_player = owner
	_animation_state_machine = _player.get_animation_state_machine()


############################
#      Public Methods      #
############################
# Corresponds to _unhandled_input() callback
# warning-ignore:unused_argument
func handle_input(event: InputEvent) -> void:
	pass


# Corresponds to the _process() callback
# warning-ignore:unused_argument
func update(delta: float) -> void:
	pass


# Corresponds to the _physics_process() callback
# warning-ignore:unused_argument
func physics_update(delta: float) -> void:
	_update_state()
	pass


func enter(_data: Dictionary={}) -> void:
	_animate()
	pass


func exit() -> void:
	pass


# Private Methods

func _get_input_movement_direction_x() -> float:
	var Input_arrow = Input.get_axis("left", "right")
	return Input_arrow


func _apply_x_movement(delta: float, direction_x: float) -> void:
	if direction_x != 0:
		var velocity_target_x: float = direction_x * move_speed
		#var velocity_target = Vector2.ZERO;
		#velocity_target.x = velocity_target_x
		_player.velocity.x = velocity_target_x * acceleration * delta
		#_player.velocity.move_toward(velocity_target, acceleration * delta).x
	else:
		var frictioned_velocity: Vector2 = _player.velocity.move_toward(
				Vector2.ZERO, friction * delta
		)
		_player.velocity.x = frictioned_velocity.x

func _apply_y_movement() -> void:
	_player.velocity.y = - jump_force

func _animate() -> void:
	pass


func _update_state() -> void:
	pass
