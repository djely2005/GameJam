class_name GenUtils
extends RefCounted
# A collection of static general utility functions which may be needed by many classes
# Last updated: 2022-08-26


static func connect_signal_assert_ok(origin: Object, sig: StringName, target: Object, method: StringName) -> void:
	var err: Error = origin.connect(sig, Callable(target, method))
	assert(err == OK, "Signal connection failed: %s.%s → %s.%s" % [origin, sig, target, method])


static func calc_parabollic_projectile_path(point_start: Vector3, point_end: Vector3, weight_step: float) -> PackedVector3Array:
	var result: PackedVector3Array = []
	var point_mid := (
		(((point_end - point_start) * 0.5) + point_start) +
		Vector3(0, 5, 0)
	)
	
	# Calc points along Bezier curve
	var weight := 0.0
	while weight <= 1.0:
		var q0 := point_start.lerp(point_mid, weight)
		var q1 := point_mid.lerp(point_end, weight)
		var point_at_time := q0.lerp(q1, weight)
		result.append(point_at_time)
		weight += weight_step
	
	return result


static func format_time_minutes_seconds(time_seconds: float) -> String:
	var whole_seconds := int(floor(time_seconds))
	#var partial_second := time_seconds - whole_seconds
	
	var remainder_seconds: int = whole_seconds % 60
	# warning-ignore:integer_division
	var minutes: int = (whole_seconds - remainder_seconds) / 60
	
	return "%02d:%02d" % [minutes, remainder_seconds]
