@tool
extends EditorPlugin

var script_editor: ScriptEditor
var file_system: EditorFileSystem
var tracked_files: Dictionary = {}
var processed_files: Dictionary = {}  # Track files we've already processed

func _enter_tree() -> void:
	print("[AutoClassName] Plugin entering tree")
	
	script_editor = get_editor_interface().get_script_editor()
	file_system = get_editor_interface().get_resource_filesystem()
	
	if not script_editor or not file_system:
		print("[AutoClassName] ERROR: Could not get editor references")
		return
	
	# Only track existing files, don't process them
	_initialize_file_tracking()
	
	# Connect to filesystem changes
	file_system.connect("filesystem_changed", _on_filesystem_changed)
	print("[AutoClassName] Plugin ready - monitoring for new scripts")

func _exit_tree() -> void:
	if file_system and file_system.is_connected("filesystem_changed", _on_filesystem_changed):
		file_system.disconnect("filesystem_changed", _on_filesystem_changed)

func _initialize_file_tracking() -> void:
	# Just build a list of existing files without processing them
	var existing_files = _get_all_gd_files("res://")
	for file_path in existing_files:
		if not file_path.begins_with("res://addons/"):
			tracked_files[file_path] = {
				"modified_time": FileAccess.get_modified_time(file_path),
				"size": _get_file_size(file_path)
			}
	print("[AutoClassName] Tracking ", tracked_files.size(), " existing files")

func _get_all_gd_files(path: String) -> Array:
	var files = []
	var dir = DirAccess.open(path)
	if not dir:
		return files
		
	dir.list_dir_begin()
	var file_name = dir.get_next()
	
	while file_name != "":
		if file_name != "." and file_name != "..":
			var full_path = path + file_name
			
			if dir.current_is_dir():
				files.append_array(_get_all_gd_files(full_path + "/"))
			elif file_name.ends_with(".gd"):
				files.append(full_path)
		
		file_name = dir.get_next()
	
	dir.list_dir_end()
	return files

func _get_file_size(file_path: String) -> int:
	var file = FileAccess.open(file_path, FileAccess.READ)
	if not file:
		return 0
	var size = file.get_length()
	file.close()
	return size

func _on_filesystem_changed() -> void:
	# Wait a moment for file system to settle
	await get_tree().process_frame
	await get_tree().create_timer(0.1).timeout
	
	# Only check for new .gd files, not all files
	var current_files = _get_all_gd_files("res://")
	
	for file_path in current_files:
		if file_path.begins_with("res://addons/"):
			continue
			
		_check_if_new_script(file_path)

func _check_if_new_script(file_path: String) -> void:
	var current_modified_time = FileAccess.get_modified_time(file_path)
	var current_size = _get_file_size(file_path)
	var current_time = Time.get_unix_time_from_system()
	var time_diff = current_time - current_modified_time
	
	var is_new_file = false
	
	if file_path in tracked_files:
		var tracked_info = tracked_files[file_path]
		# Check if file was modified recently and size changed
		if time_diff < 5.0 and current_size != tracked_info["size"]:
			# Only process if we haven't already processed this file
			if not (file_path in processed_files):
				is_new_file = _is_likely_new_script(file_path)
				if is_new_file:
					print("[AutoClassName] Detected modified script: ", file_path)
	else:
		# Completely new file
		if time_diff < 5.0:
			is_new_file = true
			print("[AutoClassName] Detected new script: ", file_path)
	
	# Update tracking regardless
	tracked_files[file_path] = {
		"modified_time": current_modified_time,
		"size": current_size
	}
	
	if is_new_file:
		_add_class_name_to_new_script(file_path)

func _is_likely_new_script(file_path: String) -> bool:
	var file = FileAccess.open(file_path, FileAccess.READ)
	if not file:
		return false
	
	var content = file.get_as_text()
	file.close()
	
	# Skip if already has class_name
	if "class_name " in content:
		return false
	
	# Count meaningful lines
	var lines = content.split("\n")
	var meaningful_lines = 0
	
	for line in lines:
		var trimmed = line.strip_edges()
		if trimmed.length() > 0 and not trimmed.begins_with("#"):
			meaningful_lines += 1
	
	# Consider it new if it has very few meaningful lines
	return meaningful_lines <= 5

func _add_class_name_to_new_script(file_path: String) -> void:
	print("[AutoClassName] Processing: ", file_path)
	
	var file = FileAccess.open(file_path, FileAccess.READ)
	if not file:
		print("[AutoClassName] ERROR: Could not read file")
		return
	
	var content = file.get_as_text()
	file.close()
	
	# Skip if already has class_name
	if "class_name " in content:
		print("[AutoClassName] File already has class_name")
		return
	
	# Generate class name from filename
	var file_name = file_path.get_file().get_basename()
	var class_name_str = _snake_case_to_pascal_case(file_name)
	
	print("[AutoClassName] Generated class name: ", class_name_str)
	
	# Add class_name at the top
	var new_content = "class_name " + class_name_str + "\n" + content
	
	var write_file = FileAccess.open(file_path, FileAccess.WRITE)
	if write_file:
		write_file.store_string(new_content)
		write_file.close()
		print("[AutoClassName] ✓ Added class_name to: ", file_path)
		
		# Mark this file as processed so we don't process it again
		processed_files[file_path] = true
		
		# Reload if currently open
		_reload_script_if_open(file_path)
	else:
		print("[AutoClassName] ERROR: Could not write to file")

func _snake_case_to_pascal_case(snake_str: String) -> String:
	var parts = snake_str.split("_")
	var pascal_str = ""
	
	for part in parts:
		if part.length() > 0:
			pascal_str += part[0].to_upper() + part.substr(1)
	
	return pascal_str

func _reload_script_if_open(file_path: String) -> void:
	# Force filesystem refresh
	file_system.scan()
	
	# In Godot 4, we can't directly reload scripts from the plugin
	# The editor will automatically refresh when the file changes
	print("[AutoClassName] File updated, editor should refresh automatically")

func get_plugin_name() -> String:
	return "Auto Class Name"
