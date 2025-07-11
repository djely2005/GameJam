class_name Sync
extends Node


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func sort_element_overlapping(overlapping):
	var n = overlapping.size()
	for i in range(n):
		for j in range(0, n - i - 1):
			if overlapping[j].collider.global_position.z > overlapping[j + 1].collider.global_position.z:
				var temp = overlapping[j]
				overlapping[j] = overlapping[j + 1]
				overlapping[j + 1] = temp
	return overlapping
	var teleport_destination = overlapping[0].collider
	for element in overlapping:
		if teleport_destination.global_position.z > element.collider.global_position.z:
			teleport_destination = overlapping

func get_2d_and_3d_element(element):
	var body = null
	for item in Global.transforming_items:
		if element in item:
			body = item
	return body
func transform_3d_to_2d(element2D, element3D):
	var overlapping = get_element_overlaping_in_3D(element3D)
	overlapping.append({"collider": element3D})
	overlapping = sort_element_overlapping(overlapping)
	for i in overlapping.size():
		var equivalent = get_2d_and_3d_element(overlapping[i].collider)
		if equivalent != null:
			if equivalent[0].get_node("Sprite2D").z_index <= i:
				equivalent[0].get_node("Sprite2D").z_index = i
	var hidden: MeshInstance3D = element3D.get_node('Hidden');
	var object_size = hidden.mesh.get_aabb().size
	var wall_dim = Global.pillar_wall.mesh.get_aabb().size
	var wall_pos = Global.pillar_wall.global_position
	var pos3D = element3D.global_position

	# Convert global 3D to local wall space
	var local_x = pos3D.x - (wall_pos.x - wall_dim.x / 2) - object_size.x / 2
	var local_y = pos3D.y - (wall_pos.y - wall_dim.y / 2) - object_size.y / 2

	# Normalize to [0, 1]
	var normalized = Vector2(
		clampf(local_x / wall_dim.x, 0, 1),
		clampf(1.0 - (local_y / wall_dim.y), 0, 1)
	)
	var screen_size = get_visible_world_bounds_of_2d(element2D)
	var result: Vector2 = Vector2.ZERO;
	var rect = element2D.get_node("Hidden").mesh.get_aabb().size;
	result.x = normalized.x * (screen_size.x - rect.x / 2);
	result.y = normalized.y * (screen_size.y - rect.y / 2)
	
	element2D.global_position = result
	return result


func transform_2d_to_3d(element2D, element3D) -> Vector3:
	var hidden: MeshInstance3D = element3D.get_node('Hidden');
	var object_size = hidden.mesh.get_aabb().size
	var wall_dim = Global.pillar_wall.mesh.get_aabb().size
	var wall_pos = Global.pillar_wall.global_position
	var pos2D = element2D.global_position
	var screen_size = get_visible_world_bounds_of_2d(element2D)

	var normalized = Vector2(
		clampf(pos2D.x / screen_size.x, 0, 1),
		clampf(1.0 - (pos2D.y / screen_size.y), 0, 1)
	)
	# Scale to wall space
	var world_x = normalized.x * wall_dim.x + (wall_pos.x - wall_dim.x / 2) + object_size.x / 2
	var world_y = normalized.y * wall_dim.y + (wall_pos.y - wall_dim.y / 2) + object_size.y / 2
	var world_z = element3D.global_position.z

	return Vector3(world_x, world_y, world_z)
	 
	
func get_visible_world_bounds_of_2d(node: Node2D) -> Vector2:
	var viewport := node.get_viewport()
	var canvas_transform := viewport.get_canvas_transform()
	return viewport.get_visible_rect().size / canvas_transform.get_scale()

func get_unique_array(input_array: Array) -> Array:
	var unique_elements := {} # Use a dictionary to store unique elements as keys
	for item in input_array:
		unique_elements[item] = true # The value doesn't matter, only the unique key
	return unique_elements.keys() # Return an array of the dictionary's keys

func get_element_overlaping_in_3D(element3D, result = [], second = {}):
	if !second.is_empty():
		var branch = get_element_overlaping_in_3D(second)
		result.append_array(branch)
	var space_state = element3D.get_world_3d().direct_space_state
	var params = PhysicsRayQueryParameters3D.new()
	var hidden = element3D.get_node("Hidden");
	var size = hidden.mesh.get_aabb().size
	var from = element3D.global_position + Vector3(size.x/2, 0, 0);
	var to = from + Vector3(0, 0, 10) + Vector3(size.x/2, 0, 0)
	params.from = from
	params.to = to
	params.exclude = []
	var intersection1 = space_state.intersect_ray(params)
	params.from.x -= size.x
	params.to.x -= size.x
	var intersection2 = space_state.intersect_ray(params)
	if intersection1.is_empty() && intersection2.is_empty():
		return result
	else:
		if !intersection1.is_empty():
			result.append(intersection1)
			get_element_overlaping_in_3D(intersection1.collider, result)
		elif !intersection2.is_empty():
			result.append(intersection2)
			get_element_overlaping_in_3D(intersection2.collider, result)
		else: 
			result.append(intersection2)
			result.append(intersection2)
			get_element_overlaping_in_3D(intersection2.collider, result, intersection1.collider)
	return get_unique_array(result);


func get_element_in_the_same_2D_position(element2D, element3D) -> Array:
	var array = [element2D, element3D]
	var over_position = get_all_element_in_same_2D_x_position_in_3D();
	for el in over_position:
		if array in el:
			el.erase(array)
			return el
	return []
func get_all_element_in_same_2D_x_position_in_3D():
	var dic = []
	var skip = []
	if Global.transforming_items == []:
		return dic
	var i = 0
	var list = Global.transforming_items
	for el in list:
		if el in skip:
			continue
		dic.append([el])
		skip.append(el)
		for other in list:
			if el[0].global_position.x == other[0].global_position.x && el not in skip:
					dic[i].append(other)
					skip.append(other)
		i += 1
	i = 0
	var final = []
	for el in dic:
		if el.size() != 2:
			final.append(el)
		i += 1
	return final

func _on_world_switch(is_2d: bool) -> void:
	set_mode(is_2d)
	pass # Replace with function body.

func set_mode(is_2d):
	pass
