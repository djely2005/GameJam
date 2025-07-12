extends Area3D

@export var bound_2d: MeshInstance2D;
@export var pillar_wall: MeshInstance3D;


func _on_area_entered(area):
	if area.name == "Detection":
		print("Player entered the area!")
		Global.bound_2d = bound_2d;
		Global.pillar_wall = pillar_wall
		# Add your custom logic here (e.g., spawn an enemy)
