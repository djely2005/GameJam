# Door.gd
extends Node3D

var is_open = false

@onready var anim = $AnimationPlayer

func open():
	if not is_open:
		is_open = true
		anim.play("door_opening") # Make sure you created an "open" animation

func close():
	if is_open:
		is_open = false
		anim.play_backwards("door_opening")
